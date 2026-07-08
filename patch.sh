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

    # Extract subject to check if already applied (handling unfolded multi-line headers, CRLF, and stripping [PATCH] prefixes)
    local subject
    subject=$(awk '/^Subject: / { sub(/\r$/, ""); sub(/^Subject: /, ""); subj = $0; while (getline > 0) { sub(/\r$/, ""); if (/^[ \t]/) { sub(/^[ \t]+/, ""); subj = subj " " $0 } else { break } }; sub(/^\[[^]]*\] /, "", subj); print subj; exit }' "$temp_patch")

    if [ -n "$subject" ] && [ -n "$(git -C "$repo_dir" log -F --grep="$subject" -n 1 --oneline)" ]; then
        echo "      ✔ Already applied: $subject"
        separator
        rm -f "$temp_patch"
        return 0
    fi

    if ! git -C "$repo_dir" am -s < "$temp_patch"; then
        echo "❌ Failed to patch $repo_dir ($desc)! Aborting..."
        rm -f "$temp_patch"
        exit 1
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
PATCHES_FILE_ARG=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        -v|--version)
            VERSION="$2"
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
            echo "Usage: patch.sh <version> [options]"
            echo "   or: patch.sh [options]"
            echo ""
            echo "Options:"
            echo "  -v, --version <version>  LineageOS version (e.g., 17.1)"
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
                echo "❌ Error: Multiple versions specified ($VERSION and $1)"
                separator
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$VERSION" ]; then
    separator
    echo "❌ Error: LineageOS version not specified."
    echo "Usage: patch.sh <version> (e.g., 17.1) or patch.sh -v <version> -p <file>"
    list_versions
    exit 1
fi

if test -f "build/envsetup.sh"; then
    REPO_URL="https://raw.githubusercontent.com/samsungexynos3475/android_patches/refs/heads/lineage-$VERSION"

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
else
    separator
    echo "❌ LineageOS build system not found. Make sure you're in the build folder! Aborting..."
    separator
fi
