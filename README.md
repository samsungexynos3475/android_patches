# Exynos 3475 Android patches (LineageOS 19.1)

This branch contains custom hardware patches for LineageOS 19.1 on Exynos 3475 devices.

## Included Patches

### 1. RenderEngine EGLConfig Fallback for Legacy Mali GPUs
* **Target Path**: `frameworks/native`
* **Filename**: `frameworks_native/0001-renderengine-implement-ultimate-EGLConfig-fallback-for-legacy-Mali-GPUs.patch`
* **Details**: Removes the `EGL_RECORDABLE_ANDROID` attribute requirement from EGL configuration queries in `GLESRenderEngine` and `SkiaGLRenderEngine`. This allows legacy Mali-T720 GPU drivers to initialize SurfaceFlinger fallback configs properly, resolving bootloops on the LineageOS logo.

### 2. WifiHAL Global Pointer Reset & Legacy Kernel Support
* **Target Path**: `hardware/broadcom/wlan`
* **Filename**: `hardware_broadcom_wlan/0001-WifiHAl-reset-global-pointer-to-NULL-to-fix-memory-leak.patch`
* **Details**: Resets the global `halInfo` pointer to `NULL` on initialization and cleanup failures to resolve memory leaks. Also skips the "vendor" membership registration check to prevent WiFi HAL load failures on legacy kernels.

### 3. Camera Legacy HIDL Compilation Fix
* **Target Path**: `hardware/lineage/interfaces`
* **Filename**: `hardware_lineage_interfaces/0001-interfaces-camera-fix-undeclared-F_DUPFD_CLOEXEC-identifier.patch`
* **Details**: Explicitly includes `<fcntl.h>` in `CameraDevice.cpp` for the 1.0-legacy camera HIDL service, resolving compilation failures on Android 12 due to cleanup of implicit header imports.

### 4. ADB Legacy FunctionFS Support Backport
* **Target Path**: `packages/modules/adb`
* **Filename**: `packages_modules_adb/0001-adb-Bring-back-support-for-legacy-FunctionFS.patch`
* **Details**: Restores support for legacy (non-blocking, synchronous) FunctionFS calls as a fallback in `adbd` when AIO on FFS is not supported (common on kernels < 3.18).

### 5. BPF Loader Fatal Initialization Bypass
* **Target Path**: `system/bpf`
* **Filename**: `system_bpf/0001-bpfloader-bypass-fatal-reboot-on-legacy-kernels-with.patch`
* **Details**: Bypasses the critical failure check in `bpfloader` for loading ELF BPF objects. This prevents fatal aborts and system_server bootloops on legacy kernels that lack BPF support.

### 6. Legacy Camera HAL System Core Extensions
* **Target Path**: `system/core`
* **Filename**: `system_core/0001-Camera-Add-feature-extensions.patch`
* **Details**: Restores vendor-specific camera messages (`CAMERA_MSG_STATS_DATA`, `CAMERA_MSG_META_DATA`), commands (`CAMERA_CMD_HISTOGRAM_ON/OFF`), and extra legacy fields in `camera_face_t` to resolve compilation and linkage issues with older HALs.

### 7. Generated Kernel Headers Output Directory Auto-Creation
* **Target Path**: `vendor/lineage`
* **Filename**: `vendor_lineage/generated_kernel_includes-auto-create-output-directory.patch`
* **Details**: Adds a `mkdir -p` command to `generated_kernel_includes` in the Soong build configuration (`Android.bp`) to create the build folder before running `headers_install`, resolving build failures when building with legacy 3.10 kernels.
