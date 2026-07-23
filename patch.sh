#!/usr/bin/env bash

separator() {
    echo "---------------------------------------------------------"
}

apply_patch() {
    local repo_dir="$1"
    local emoji="$2"
    local desc="$3"
    local patch_url="$4"

    echo "   📂 $repo_dir"
    echo "      $emoji Patching $desc"
    separator

    local temp_patch
    temp_patch=$(mktemp)

    if ! curl -sf "$patch_url" > "$temp_patch"; then
        echo "❌ Failed to download patch: $patch_url"
        rm -f "$temp_patch"
        exit 1
    fi

    # Use git mailinfo to robustly parse the patch subject exactly as git am sees it
    local temp_msg temp_diff subject
    temp_msg=$(mktemp)
    temp_diff=$(mktemp)
    subject=$(git mailinfo "$temp_msg" "$temp_diff" < "$temp_patch" | grep "^Subject: " | sed 's/^Subject: //')
    rm -f "$temp_msg" "$temp_diff"

    if [ -n "$subject" ] && git -C "$repo_dir" log --format="%s" | grep -F -x -q "$subject"; then
        echo "      ✔ Already applied: $subject"
        separator
        rm -f "$temp_patch"
        return 0
    fi

    if ! git -C "$repo_dir" am -s < "$temp_patch"; then
        echo "❌ Failed to patch $repo_dir ($desc)!"
        echo "⚠️ Conflict detected. Please resolve the conflicts in $repo_dir."
        echo "   After resolving, run 'git add <files>' and 'git am --continue' in that directory."
        
        while true; do
            read -p "Type 'c' to continue after resolving, 's' to skip this patch, or 'a' to abort: " choice < /dev/tty
            case "$choice" in
                c|C )
                    if [ -d "$repo_dir/.git/rebase-apply" ]; then
                        echo "⚠️ git am is still in progress in $repo_dir."
                        echo "   Did you forget to run 'git am --continue'?"
                    else
                        echo "✅ Patch successfully resolved and applied."
                        break
                    fi
                    ;;
                s|S )
                    echo "⏭️ Skipping patch..."
                    git -C "$repo_dir" am --abort
                    break
                    ;;
                a|A )
                    echo "🛑 Aborting script..."
                    git -C "$repo_dir" am --abort
                    rm -f "$temp_patch"
                    exit 1
                    ;;
                * )
                    echo "Invalid choice. Please type 'c', 's', or 'a'."
                    ;;
            esac
        done
    fi

    rm -f "$temp_patch"
}

list_versions() {
    separator
    echo "🔍 Retrieving available LineageOS versions from remote..."
    separator

    local repo_dir
    local remote_url="https://github.com/samsungexynos3475/android_patches"
    repo_dir=$(dirname "$0")

    if [ -d "$repo_dir/.git" ]; then
        local local_remote
        local_remote=$(git -C "$repo_dir" remote get-url origin 2>/dev/null)
        if [ -n "$local_remote" ]; then
            remote_url="$local_remote"
        fi
    fi

    local versions
    versions=$(git ls-remote --heads "$remote_url" 2>/dev/null | grep 'refs/heads/lineage-' | sed 's|.*/lineage-||')

    if [ -z "$versions" ]; then
        echo "   No versions found (or unable to connect to the remote repository)."
    else
        echo "   Available versions:"
        echo "$versions" | sed 's/^/    - /'
    fi

    separator
}

VERSION=""
BRANCH=""
REPO_NAME="android_patches"
PATCHES_FILE_ARG=""
KEYS_ARG=""
GITHUB_TOKEN=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -b|--branch)
            BRANCH="$2"
            shift 2
            ;;
        --repo)
            REPO_NAME="$2"
            shift 2
            ;;
        --keys)
            KEYS_ARG="$2"
            shift 2
            ;;
        --token)
            GITHUB_TOKEN="$2"
            shift 2
            ;;
        -p|--patches)
            PATCHES_FILE_ARG="$2"
            shift 2
            ;;
        -l|--list|list)
            list_versions
            exit 0
            ;;
        -h|--help)
            echo "Usage: patch.sh [options]"
            echo ""
            echo "Options:"
            echo "  -v, --version <version>  LineageOS version (e.g., 17.1)"
            echo "  -b, --branch <branch>    Override branch name directly (e.g., patch-17.1)"
            echo "  --repo <name>            Target repository (default: android_patches)"
            echo "  --keys <dir_or_url>      Private repository URL or local dir for release keys"
            echo "  --token <token>          GitHub PAT token for private keys repo (HTTPS only)"
            echo "  -p, --patches <file>     Custom patch list filename (default: patch.txt)"
            echo "  -l, --list               List available versions"
            echo "  -h, --help               Show this help message"
            exit 0
            ;;
        -*)
            separator
            echo "❌ Error: Unknown option $1"
            echo "Run patch.sh --help for usage details."
            separator
            exit 1
            ;;
        *)
            if [ -z "$VERSION" ]; then
                VERSION="$1"
            else
                separator
                echo "❌ Error: Unexpected argument $1"
                separator
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$BRANCH" ]; then
    if [ -n "$VERSION" ]; then
        BRANCH="lineage-$VERSION"
    else
        separator
        echo "❌ Error: Branch or LineageOS version not specified."
        echo "Usage: patch.sh -v <version> OR patch.sh -b <branch>"
        list_versions
        exit 1
    fi
fi

if test -f "build/envsetup.sh"; then
    REPO_URL="https://raw.githubusercontent.com/samsungexynos3475/$REPO_NAME/refs/heads/$BRANCH"

    separator
    echo "✅ LineageOS build system found. Starting to patch now!"
    separator

    patches_file=$(mktemp)

    patches_name="patch.txt"
    if [ -n "$PATCHES_FILE_ARG" ]; then
        patches_name="$PATCHES_FILE_ARG"
    fi

    # Use specified patches file from current directory or script directory if it exists locally,
    # otherwise download it from the target lineage branch
    if [ -f "$patches_name" ]; then
        cp "$patches_name" "$patches_file"
    elif [ -f "$(dirname "$0")/$patches_name" ]; then
        cp "$(dirname "$0")/$patches_name" "$patches_file"
    else
        if ! curl -sf "$REPO_URL/$patches_name" > "$patches_file"; then
            echo "❌ Failed to download patches file: $REPO_URL/$patches_name"
            rm -f "$patches_file"
            exit 1
        fi
    fi

    # Read the patches_file line by line, parsing the grouped array elements
    while read -r line || [ -n "$line" ]; do
        # Handle backslash line continuations
        while [[ "$line" =~ \\$ ]]; do
            line="${line%\\}"
            read -r next_line || break
            line="$line$next_line"
        done

        # Ignore empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # Parse the line as a bash array to respect quoted strings with spaces
        eval "local_array=( $line )"
        repo_dir="${local_array[0]}"

        # Iterate over triplets of (emoji, desc, filename)
        for ((i=1; i<${#local_array[@]}; i+=3)); do
            emoji="${local_array[i]}"
            desc="${local_array[i+1]}"
            filename="${local_array[i+2]}"

            # Construct project folder name (replacing / with _) and patch URL
            if [[ "$filename" =~ ^https?:// ]]; then
                patch_url="$filename"
            else
                folder_name=$(echo "$repo_dir" | tr '/' '_')
                patch_url="$REPO_URL/$folder_name/$filename"
            fi

            apply_patch "$repo_dir" "$emoji" "$desc" "$patch_url"
        done
    done < "$patches_file"

    rm -f "$patches_file"

    if [ -n "$KEYS_ARG" ]; then
        separator
        echo "   📂 vendor/lineage-priv"
        echo "      🔑 Processing release signing keys..."

        mkdir -p vendor/lineage-priv/keys
        echo "PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/lineage-priv/keys/releasekey" > vendor/lineage-priv/keys/keys.mk

        if [[ "$KEYS_ARG" =~ ^https?:// ]] || [[ "$KEYS_ARG" =~ ^git@ ]]; then
            echo "      🌐 Cloning keys from private repository..."
            
            local_keys_url="$KEYS_ARG"
            if [ -n "$GITHUB_TOKEN" ] && [[ "$local_keys_url" =~ ^https:// ]]; then
                # Inject token into the HTTPS URL
                local_keys_url=$(echo "$local_keys_url" | sed -E "s|^(https://)(.*)|\1$GITHUB_TOKEN@\2|")
            fi

            temp_keys=$(mktemp -d)
            if git clone --depth 1 "$local_keys_url" "$temp_keys"; then
                cp -v "$temp_keys/"*.pk8 "$temp_keys/"*.x509.pem vendor/lineage-priv/keys/
            else
                echo "❌ Failed to clone keys repository!"
                rm -rf "$temp_keys"
                exit 1
            fi
            rm -rf "$temp_keys"
        elif [ -d "$KEYS_ARG" ]; then
            echo "      📂 Copying local keys from $KEYS_ARG..."
            cp -v "$KEYS_ARG/"*.pk8 "$KEYS_ARG/"*.x509.pem vendor/lineage-priv/keys/
        else
            echo "❌ Keys argument provided ($KEYS_ARG) is not a valid directory or Git URL!"
            exit 1
        fi
    fi

else
    separator
    echo "❌ LineageOS build system not found. Make sure you're in the build folder! Aborting..."
    separator
fi
