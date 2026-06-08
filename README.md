# Exynos 3475 Android patches

A collection of patches for Exynos 3475 devices running LineageOS.

## Usage

The unified `patch.sh` script applies patches, resolves conflicts safely, and can securely fetch private release keys.

### Remote Execution

You can download and execute the script directly from the remote repository without cloning anything locally. 

**Basic Usage (Applying LineageOS patches):**
```bash
bash <(curl -sf https://raw.githubusercontent.com/samsungexynos3475/android_patches/refs/heads/main/patch.sh) -v 19.1
```

**Advanced Usage (Applying releases and fetching private keys):**
```bash
# Example: Apply releases patches securely via SSH
bash <(curl -sf https://raw.githubusercontent.com/samsungexynos3475/android_patches/refs/heads/main/patch.sh) --repo releases -b patch-19.1 --keys git@github.com:your-user/your-private-keys.git
```

### Local Execution

If you have cloned the `android_patches` repository locally, you can execute it from the root of your LineageOS build directory:

```bash
# Example: Apply patches for LineageOS 19.1
/path/to/android_patches/patch.sh -v 19.1

# Example: Run a dry run to check for conflicts before patching
/path/to/android_patches/patch.sh -v 19.1 --dry-run
```

When you provide the `--keys` argument, the script will securely clone your private keys repository using your local Git authentication (or the provided token) and copy the release keys into `vendor/lineage-priv/keys/` in your build environment. It will also auto-generate the `keys.mk` configuration file.

### Advanced Options

The unified script supports additional options:
- `-v, --version <version>`: Specify the LineageOS version (e.g. `19.1`).
- `-b, --branch <branch>`: Directly specify a remote branch to download the patch payload from (e.g. `lineage-19.1`).
- `-p, --patches <file>`: Specify a custom payload script to use instead of the default `apply.sh`.
- `--repo <repo_name>`: Specify a custom remote repository to fetch the patches from (e.g. `releases`).
- `--keys <dir_or_url>`: Securely fetch private release keys from a local directory or a private Git repository (SSH or HTTPS).
- `--token <token>`: Provide a GitHub Personal Access Token to seamlessly authenticate when cloning a private keys repository over HTTPS.
- `--revert`: Wipe all applied patches for the specified branch from your working tree.
- `--dry-run`: Simulate patching using `git apply --check` and explicitly log any conflicts.
- `-i, --interactive`: Prompt for approval `[y/n/q/a]` before applying every single patch.
- `--skip-conflicts`: Automatically skip failed patches and abort conflicts during an automated run, printing a final summary of skipped patches.
- `--log [file]`: Save all terminal output to a log file (auto-generated if no filename is provided).
- `--update`: Auto-update the local `patch.sh` script from git origin and seamlessly restart execution.
- `-l, --list`: Retrieve and display all available supported LineageOS versions directly from the remote repository.
- `-h, --help`: Show the help message.
