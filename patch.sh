#!/usr/bin/env bash

# ANSI Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global state
declare -A ORIGINAL_HEADS
declare -A WIPED_REPOS
PATCH_BASE=""
REVERT_MODE=0
DRY_RUN=0
INTERACTIVE=0
AUTO_SKIP=0

# Tracking
declare -a SUCCESS_PATCHES
declare -a FAIL_PATCHES
declare -a SKIPPED_PATCHES

separator() {
    echo -e "---------------------------------------------------------"
}

# Ensure we are in a build environment before executing anything
check_env() {
    if [ ! -f "build/envsetup.sh" ]; then
        echo -e "${RED}❌ Error: Please execute this script from the root of your LineageOS build directory.${NC}"
        exit 1
    fi
}

# The new `apply_msg` function
apply_msg() {
    echo -e "\n   ${BLUE}$1${NC}"
}

# Abort and undo all function
abort_and_undo() {
    echo -e "${RED}🛑 Aborting process and undoing all patches applied during this session...${NC}"
    for repo in "${!ORIGINAL_HEADS[@]}"; do
        echo -e "${YELLOW}🔄 Restoring $repo to original state (${ORIGINAL_HEADS[$repo]:0:7})...${NC}"
        git -C "$repo" reset --hard "${ORIGINAL_HEADS[$repo]}" >/dev/null 2>&1
        git -C "$repo" clean -fdx >/dev/null 2>&1
    done
    echo -e "${GREEN}✅ Workspace safely restored. Exiting.${NC}"
    exit 1
}

print_summary() {
    separator
    echo -e "${BLUE}📊 Patch Summary:${NC}"
    if [ "$DRY_RUN" -eq 1 ]; then
        echo -e "${GREEN}✅ ${#SUCCESS_PATCHES[@]} patches apply cleanly.${NC}"
        if [ ${#FAIL_PATCHES[@]} -gt 0 ]; then
            echo -e "${RED}❌ ${#FAIL_PATCHES[@]} patches will conflict:${NC}"
            for p in "${FAIL_PATCHES[@]}"; do
                echo -e "   - $p"
            done
        fi
    else
        echo -e "${GREEN}✅ Successfully applied ${#SUCCESS_PATCHES[@]} patches.${NC}"
        if [ ${#SKIPPED_PATCHES[@]} -gt 0 ]; then
            echo -e "${YELLOW}⏭️ Skipped ${#SKIPPED_PATCHES[@]} patches:${NC}"
            for p in "${SKIPPED_PATCHES[@]}"; do
                echo -e "   - $p"
            done
        fi
        if [ ${#FAIL_PATCHES[@]} -gt 0 ]; then
            echo -e "${RED}❌ Failed (skipped due to conflict) ${#FAIL_PATCHES[@]} patches:${NC}"
            for p in "${FAIL_PATCHES[@]}"; do
                echo -e "   - $p"
            done
        fi
    fi
    separator
}

# The new `apply` function
apply() {
    local repo_dir="$1"
    shift

    # If this is the first time we touch this repo in this session, save its original HEAD
    if [ -z "${ORIGINAL_HEADS[$repo_dir]}" ]; then
        if [ -d "$repo_dir/.git" ]; then
            ORIGINAL_HEADS[$repo_dir]=$(git -C "$repo_dir" rev-parse HEAD 2>/dev/null)
        else
            echo -e "${RED}❌ Error: $repo_dir is not a valid git repository!${NC}"
            exit 1
        fi
    fi

    # If --revert flag is passed, redefine behavior to just wipe the repo
    if [ "$REVERT_MODE" -eq 1 ]; then
        if [ -z "${WIPED_REPOS[$repo_dir]}" ]; then
            echo -e "${YELLOW}🧹 Wiping patches in $repo_dir...${NC}"
            local tracking_branch=$(git -C "$repo_dir" rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
            if [ -n "$tracking_branch" ]; then
                git -C "$repo_dir" reset --hard "$tracking_branch" >/dev/null 2>&1
            elif git -C "$repo_dir" rev-parse "m/$BRANCH" >/dev/null 2>&1; then
                git -C "$repo_dir" reset --hard "m/$BRANCH" >/dev/null 2>&1
            fi
            git -C "$repo_dir" clean -fdx >/dev/null 2>&1
            WIPED_REPOS[$repo_dir]=1
            echo -e "${GREEN}✅ Cleaned $repo_dir${NC}"
        fi
        return 0
    fi

    echo -e "      ${BLUE}📂 $repo_dir${NC}"

    for patch in "$@"; do
        local temp_patch
        temp_patch=$(mktemp)

        # Download or copy the patch
        if [[ "$patch" == http* ]]; then
            # Absolute URL passed directly to apply()
            if ! curl -sf "$patch" > "$temp_patch"; then
                echo -e "${RED}❌ Failed to download absolute patch: $patch${NC}"
                rm -f "$temp_patch"
                abort_and_undo
            fi
        elif [[ "$PATCH_BASE" == http* ]]; then
            # Remote payload (append to PATCH_BASE)
            local patch_url="$PATCH_BASE/$patch"
            if ! curl -sf "$patch_url" > "$temp_patch"; then
                echo -e "${RED}❌ Failed to download patch: $patch_url${NC}"
                rm -f "$temp_patch"
                abort_and_undo
            fi
        else
            # Local payload (append to PATCH_BASE)
            local local_patch="$PATCH_BASE/$patch"
            if [ ! -f "$local_patch" ]; then
                echo -e "${RED}❌ Local patch not found: $local_patch${NC}"
                rm -f "$temp_patch"
                abort_and_undo
            fi
            cp "$local_patch" "$temp_patch"
        fi

        # Parse subject and author
        local temp_msg temp_diff subject author
        temp_msg=$(mktemp)
        temp_diff=$(mktemp)
        subject=$(git mailinfo "$temp_msg" "$temp_diff" < "$temp_patch" | grep "^Subject: " | sed 's/^Subject: //')
        author=$(git mailinfo "$temp_msg" "$temp_diff" < "$temp_patch" | grep "^Author: " | sed 's/^Author: //')
        rm -f "$temp_msg" "$temp_diff"

        local patch_display="$subject"
        if [ -n "$author" ]; then
            patch_display="$subject (by $author)"
        fi

        # Check if already applied
        if [ -n "$subject" ] && git -C "$repo_dir" log --format="%s" | grep -F -x -q "$subject"; then
            echo -e "      ${YELLOW}✔ Already applied: $patch_display${NC}"
            
            if [ "$DRY_RUN" -eq 1 ]; then
                rm -f "$temp_patch"
                continue
            fi
            
            while true; do
                read -p "$(echo -e "${YELLOW}Type 's' to skip, 'f' to force apply, 'r' to revert this patch, 'q' to quit, or 'a' to abort (undo all): ${NC}")" choice </dev/tty
                case "$choice" in
                    s|S )
                        echo -e "${YELLOW}⏭️ Skipping patch...${NC}"
                        rm -f "$temp_patch"
                        continue 2 # continue outer loop (next patch)
                        ;;
                    f|F )
                        echo -e "${YELLOW}⚠️ Forcing patch application...${NC}"
                        break
                        ;;
                    r|R )
                        local commit_hash
                        commit_hash=$(git -C "$repo_dir" log --format="%h %s" | grep -F " $subject" | head -n 1 | awk '{print $1}')
                        if [ -n "$commit_hash" ]; then
                            echo -e "${YELLOW}🔍 Found commit hash for patch: $commit_hash${NC}"
                            echo -e "${YELLOW}🔄 Reverting commit $commit_hash...${NC}"
                            if git -C "$repo_dir" revert --no-edit "$commit_hash" >/dev/null 2>&1; then
                                echo -e "${GREEN}✅ Patch successfully reverted.${NC}"
                            else
                                echo -e "${RED}❌ Failed to cleanly revert commit. You may need to manually resolve it.${NC}"
                            fi
                        else
                            echo -e "${RED}❌ Could not find commit hash to revert.${NC}"
                        fi
                        rm -f "$temp_patch"
                        continue 2
                        ;;
                    q|Q )
                        echo -e "${YELLOW}👋 Quitting script. Previous patches are preserved.${NC}"
                        rm -f "$temp_patch"
                        print_summary
                        exit 0
                        ;;
                    a|A )
                        rm -f "$temp_patch"
                        abort_and_undo
                        ;;
                    * )
                        echo -e "Invalid choice."
                        ;;
                esac
            done
        fi

        # Interactive Cherry-Pick Mode
        if [ "$INTERACTIVE" -eq 1 ] && [ "$DRY_RUN" -eq 0 ]; then
            while true; do
                read -p "$(echo -e "${YELLOW}❓ Apply: $patch_display? [y]es/[n]o/[q]uit/[a]bort: ${NC}")" choice </dev/tty
                case "$choice" in
                    y|Y ) break ;;
                    n|N ) 
                        echo -e "${YELLOW}⏭️ Skipping patch...${NC}"
                        SKIPPED_PATCHES+=("$repo_dir: $subject")
                        rm -f "$temp_patch"
                        continue 2 
                        ;;
                    q|Q ) 
                        echo -e "${YELLOW}👋 Quitting script.${NC}"
                        rm -f "$temp_patch"
                        print_summary
                        exit 0 
                        ;;
                    a|A )
                        rm -f "$temp_patch"
                        abort_and_undo
                        ;;
                    * ) echo -e "Invalid choice." ;;
                esac
            done
        fi

        # Dry Run Mode
        if [ "$DRY_RUN" -eq 1 ]; then
            if git -C "$repo_dir" apply --check < "$temp_patch" >/dev/null 2>&1; then
                echo -e "      ${GREEN}✔ Can apply cleanly: $patch_display${NC}"
                SUCCESS_PATCHES+=("$repo_dir: $subject")
            else
                echo -e "      ${RED}❌ Will conflict: $patch_display${NC}"
                FAIL_PATCHES+=("$repo_dir: $subject")
            fi
            rm -f "$temp_patch"
            continue
        fi

        # Apply Patch
        if ! git -C "$repo_dir" am -3 -s < "$temp_patch" >/dev/null 2>&1; then
            echo -e "${RED}❌ Failed to patch $repo_dir ($subject)!${NC}"
            
            if [ "$AUTO_SKIP" -eq 1 ]; then
                echo -e "${YELLOW}⏭️ Auto-skipping conflict...${NC}"
                git -C "$repo_dir" am --abort >/dev/null 2>&1 || true
                git -C "$repo_dir" reset --hard HEAD >/dev/null 2>&1
                FAIL_PATCHES+=("$repo_dir: $subject")
                rm -f "$temp_patch"
                continue
            fi
            
            if ! git -C "$repo_dir" status -s | grep -q "^UU "; then
                git -C "$repo_dir" apply --reject < "$temp_patch" >/dev/null 2>&1 || true
            fi
            
            echo -e "${YELLOW}⚠️ Conflict detected. Conflicting files / Rejects:${NC}"
            git -C "$repo_dir" status -s
            echo ""
            echo -e "${YELLOW}👉 Please resolve the conflicts by running:${NC}"
            echo -e "${BLUE}     cd $repo_dir${NC}"
            echo -e "${YELLOW}   Look for <<<<<<< markers or .rej files. After resolving, run 'git add <files>' and 'git am --continue'.${NC}"
            echo ""
            
            while true; do
                read -p "$(echo -e "${YELLOW}Type 'c' to continue, 's' to skip, 'q' to quit, or 'a' to abort (undo all): ${NC}")" choice </dev/tty
                case "$choice" in
                    c|C )
                        if [ -d "$repo_dir/.git/rebase-apply" ]; then
                            echo -e "${YELLOW}🔄 Attempting to run 'git am --continue' for you...${NC}"
                            
                            # Prevent accidental commits of .rej or .orig files if user ran `git add .`
                            if git -C "$repo_dir" diff --cached --name-only | grep -qE '\.(rej|orig)$'; then
                                echo -e "${YELLOW}🧹 Removing accidentally staged .rej/.orig files from commit...${NC}"
                                git -C "$repo_dir" diff --cached --name-only | grep -E '\.(rej|orig)$' | while read -r file; do
                                    git -C "$repo_dir" reset HEAD "$file" >/dev/null 2>&1
                                    rm -f "$repo_dir/$file"
                                done
                            fi

                            if git -C "$repo_dir" am --continue >/dev/null 2>&1; then
                                echo -e "${GREEN}✅ Patch successfully resolved and applied.${NC}"
                                SUCCESS_PATCHES+=("$repo_dir: $subject")
                                if git -C "$repo_dir" status --porcelain | grep '??' | grep -qE '\.(rej|orig)$'; then
                                    echo -e "${GREEN}🧹 Cleaning up leftover .rej and .orig files...${NC}"
                                    git -C "$repo_dir" status --porcelain | awk '/^\?\? .*\.(rej|orig)$/ {print $2}' | while read -r file; do
                                        rm -f "$repo_dir/$file"
                                    done
                                fi
                                break
                            else
                                echo -e "${RED}⚠️ git am --continue failed in $repo_dir.${NC}"
                                if git -C "$repo_dir" diff --quiet && git -C "$repo_dir" diff --cached --quiet; then
                                    echo -e "${YELLOW}   It looks like this patch introduces no new changes (already applied?).${NC}"
                                    echo -e "${YELLOW}   👉 Please type 's' to skip this empty patch.${NC}"
                                else
                                    echo -e "${YELLOW}   Did you forget to 'git add' your resolved files?${NC}"
                                fi
                            fi
                        else
                            echo -e "${GREEN}✅ Patch successfully resolved and applied.${NC}"
                            SUCCESS_PATCHES+=("$repo_dir: $subject")
                            break
                        fi
                        ;;
                    s|S )
                        echo -e "${YELLOW}⏭️ Skipping patch...${NC}"
                        git -C "$repo_dir" am --abort >/dev/null 2>&1 || true
                        git -C "$repo_dir" reset --hard HEAD >/dev/null 2>&1
                        FAIL_PATCHES+=("$repo_dir: $subject")
                        if git -C "$repo_dir" status --porcelain | grep '??' | grep -qE '\.(rej|orig)$'; then
                            git -C "$repo_dir" status --porcelain | awk '/^\?\? .*\.(rej|orig)$/ {print $2}' | while read -r file; do
                                rm -f "$repo_dir/$file"
                            done
                        fi
                        break
                        ;;
                    q|Q )
                        echo -e "${YELLOW}👋 Quitting script. Previous patches are preserved.${NC}"
                        git -C "$repo_dir" am --abort >/dev/null 2>&1 || true
                        git -C "$repo_dir" reset --hard HEAD >/dev/null 2>&1
                        rm -f "$temp_patch"
                        print_summary
                        exit 0
                        ;;
                    a|A )
                        git -C "$repo_dir" am --abort >/dev/null 2>&1 || true
                        git -C "$repo_dir" reset --hard HEAD >/dev/null 2>&1
                        rm -f "$temp_patch"
                        abort_and_undo
                        ;;
                    * )
                        echo -e "Invalid choice."
                        ;;
                esac
            done
        else
            echo -e "      ${GREEN}✔ Applied: $patch_display${NC}"
            SUCCESS_PATCHES+=("$repo_dir: $subject")
        fi

        rm -f "$temp_patch"
    done
}

fetch_keys() {
    local keys_url="$1"
    echo -e "\n   ${BLUE}🔑 Processing release signing keys...${NC}"
    echo -e "      ${BLUE}📂 vendor/lineage-priv${NC}"

    mkdir -p vendor/lineage-priv/keys
    echo "PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/lineage-priv/keys/releasekey" > vendor/lineage-priv/keys/keys.mk

    if [[ "$keys_url" =~ ^https?:// ]] || [[ "$keys_url" =~ ^git@ ]]; then
        echo -e "      🌐 Cloning keys from private repository..."
        
        local local_keys_url="$keys_url"
        if [ -n "$GITHUB_TOKEN" ] && [[ "$local_keys_url" =~ ^https:// ]]; then
            local_keys_url=$(echo "$local_keys_url" | sed -E "s|^(https://)(.*)|\1$GITHUB_TOKEN@\2|")
        fi

        local temp_keys=$(mktemp -d)
        if git clone --depth 1 "$local_keys_url" "$temp_keys" >/dev/null 2>&1; then
            cp -v "$temp_keys/"*.pk8 "$temp_keys/"*.x509.pem vendor/lineage-priv/keys/ >/dev/null
        else
            echo -e "${RED}❌ Failed to clone keys repository!${NC}"
            rm -rf "$temp_keys"
            exit 1
        fi
        rm -rf "$temp_keys"
    elif [ -d "$keys_url" ]; then
        echo -e "      📂 Copying local keys from $keys_url..."
        cp -v "$keys_url/"*.pk8 "$keys_url/"*.x509.pem vendor/lineage-priv/keys/ >/dev/null
    else
        echo -e "${RED}❌ Keys argument provided ($keys_url) is not a valid directory or Git URL!${NC}"
        exit 1
    fi
}

list_versions() {
    separator
    echo -e "${BLUE}🔍 Retrieving available LineageOS versions from remote...${NC}"
    separator

    local repo_dir
    local remote_url="https://github.com/samsungexynos3475/android_patches"
    if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
        repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    else
        repo_dir="$(pwd)"
    fi

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
        echo -e "   ${YELLOW}No versions found (or unable to connect to the remote repository).${NC}"
    else
        echo -e "   ${GREEN}Available versions:${NC}"
        echo "$versions" | sed 's/^/    - /'
    fi

    separator
}

print_usage() {
    echo -e "${GREEN}Android ROM Patching Script${NC}"
    echo -e "Usage: patch.sh [OPTIONS]"
    echo -e ""
    echo -e "Options:"
    echo -e "  -v, --version <version>  Specify LineageOS version (e.g., 17.1)"
    echo -e "  -b, --branch <branch>    Specify full branch name (e.g., lineage-17.1)"
    echo -e "  -p, --patches <file>     Specify custom payload script (default: apply.sh)"
    echo -e "  --repo <name>            Specify custom GitHub repository name"
    echo -e "  --keys <url_or_dir>      Clone or copy private signing keys"
    echo -e "  --token <token>          GitHub token for private repos"
    echo -e "  --revert                 Undo all patches for the specified branch"
    echo -e "  --dry-run                Simulate patches and explicitly log conflicts"
    echo -e "  -i, --interactive        Prompt [y/n/q/a] before applying each patch"
    echo -e "  --skip-conflicts         Automatically skip failed patches without prompting"
    echo -e "  --log [file]             Save output to a log file"
    echo -e "  --update                 Auto-update this script from git origin"
    echo -e "  -l, --list               List available versions on remote"
    echo -e "  -h, --help               Show this help message"
    echo -e ""
}

# --- Main Script Execution ---

# If sourced, return immediately
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    return 0
fi

# Save original arguments for auto-update restart
ORIGINAL_ARGS=("$@")

# We are executing as the main script!
VERSION=""
BRANCH=""
REPO_NAME="android_patches"
PAYLOAD_SCRIPT="apply.sh"
GITHUB_TOKEN=""
KEYS_ARG=""
UPDATE_MODE=0
LOG_FILE_SET=""
LOG_FILE=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help)
            print_usage
            exit 0
            ;;
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
            PAYLOAD_SCRIPT="$2"
            shift 2
            ;;
        --revert)
            REVERT_MODE=1
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        -i|--interactive)
            INTERACTIVE=1
            shift
            ;;
        --skip-conflicts)
            AUTO_SKIP=1
            shift
            ;;
        --update)
            UPDATE_MODE=1
            shift
            ;;
        --log)
            LOG_FILE_SET=1
            # Check if next argument exists and doesn't start with -
            if [ -n "$2" ] && [[ "$2" != -* ]]; then
                LOG_FILE="$2"
                shift 2
            else
                shift 1
            fi
            ;;
        -l|--list|list)
            list_versions
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

if [ -n "$LOG_FILE_SET" ]; then
    if [ -z "$LOG_FILE" ]; then
        LOG_FILE="patch_$(date +%s).log"
    fi
    echo -e "${BLUE}📝 Logging output to $LOG_FILE...${NC}"
    exec > >(tee -i "$LOG_FILE") 2>&1
fi

if [ "$UPDATE_MODE" -eq 1 ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -d "$SCRIPT_DIR/.git" ]; then
        echo -e "${BLUE}🔄 Updating patch.sh from remote...${NC}"
        if git -C "$SCRIPT_DIR" pull origin main; then
            echo -e "${GREEN}✅ Update complete. Restarting script...${NC}"
            # Reconstruct args without --update
            new_args=()
            for arg in "${ORIGINAL_ARGS[@]}"; do
                if [[ "$arg" != "--update" ]]; then
                    new_args+=("$arg")
                fi
            done
            exec "$0" "${new_args[@]}"
        else
            echo -e "${RED}❌ Failed to update. Continuing...${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ Cannot update: not running from a git clone.${NC}"
    fi
fi

if [ -z "$BRANCH" ] && [ -n "$VERSION" ]; then
    BRANCH="lineage-$VERSION"
fi

if [ -z "$BRANCH" ]; then
    echo -e "${RED}❌ Please specify a version with -v or branch with -b.${NC}"
    exit 1
fi

check_env

separator
echo -e "${GREEN}✅ LineageOS build system found. Starting to patch now!${NC}"
separator

# Determine if we are running from a local clone of android_patches or from curl
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -d "$SCRIPT_DIR/.git" ] && [ -f "$SCRIPT_DIR/$PAYLOAD_SCRIPT" ]; then
    # Local execution
    local_branch=$(git -C "$SCRIPT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ "$local_branch" == "$BRANCH" ]; then
        echo -e "   ${BLUE}🌐 Sourcing local $PAYLOAD_SCRIPT for $BRANCH...${NC}"
        PATCH_BASE="$SCRIPT_DIR"
        source "$SCRIPT_DIR/$PAYLOAD_SCRIPT"
    else
        echo -e "   ${YELLOW}⚠️ Local branch ($local_branch) does not match requested branch ($BRANCH). Fetching remote payload...${NC}"
        PATCH_BASE="https://raw.githubusercontent.com/samsungexynos3475/$REPO_NAME/refs/heads/$BRANCH"
        source <(curl -sf "$PATCH_BASE/$PAYLOAD_SCRIPT?t=$(date +%s)")
    fi
else
    # Remote execution
    echo -e "   ${BLUE}🌐 Fetching $PAYLOAD_SCRIPT payload for $BRANCH...${NC}"
    PATCH_BASE="https://raw.githubusercontent.com/samsungexynos3475/$REPO_NAME/refs/heads/$BRANCH"
    if ! curl -sf "$PATCH_BASE/$PAYLOAD_SCRIPT?t=$(date +%s)" > /tmp/"$PAYLOAD_SCRIPT"; then
        echo -e "${RED}❌ Failed to fetch $PAYLOAD_SCRIPT from $BRANCH!${NC}"
        exit 1
    fi
    source /tmp/"$PAYLOAD_SCRIPT"
    rm -f /tmp/"$PAYLOAD_SCRIPT"
fi

# Fetch keys if requested
if [ -n "$KEYS_ARG" ]; then
    fetch_keys "$KEYS_ARG"
fi

print_summary
