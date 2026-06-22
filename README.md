# Exynos 3475 Android patches

A collection of patches for Exynos 3475 devices running LineageOS.

## Usage

You don't need to clone this repository to apply the patches. Simply navigate to the root of your LineageOS build directory and execute the command below.

### 1. Apply Patches
To apply patches for a specific LineageOS version (e.g., `17.1`), run:

```bash
bash <(curl -sf https://raw.githubusercontent.com/samsungexynos3475/android_patches/main/patch.sh) 17.1
```

Or using the version option flag:

```bash
bash <(curl -sf https://raw.githubusercontent.com/samsungexynos3475/android_patches/main/patch.sh) -v 17.1
```

### 2. Custom Patch List
To run patches using a custom patch list file (e.g. `custom.txt`), run:

```bash
bash <(curl -sf https://raw.githubusercontent.com/samsungexynos3475/android_patches/main/patch.sh) -v 17.1 -p custom.txt
```

### 3. List Available Versions
To retrieve and display the list of supported LineageOS versions directly from the repository, run:

```bash
bash <(curl -sf https://raw.githubusercontent.com/samsungexynos3475/android_patches/main/patch.sh) -l
```

### 4. Local Execution (Alternative)
If you have cloned the repository locally, copy `patch.sh` to the root of your LineageOS build directory and run:

```bash
./patch.sh <version>
# Or with a custom patch list:
./patch.sh -v 17.1 -p custom.txt
```
