# Exynos 3475 Android patches (LineageOS 19.1)

This branch contains custom hardware patches for LineageOS 19.1 on Exynos 3475 devices.

## Included Patches

### 1. Camera HALv1 Support Restoration
* **Target Path**: `frameworks/av`
* **Filename**: `https://github.com/samsungexynos3475/android_frameworks_av/compare/LineageOS:lineage-19.1...lineage-19.1.patch`
* **Details**: Restores support for legacy camera HALv1 and old recording paths in frameworks/av, adapting to changes in camera2 API to prevent boot loops and camera app crashes.

### 2. Camera legacy HALv1 Helper Classes
* **Target Path**: `frameworks/base`
* **Filename**: `https://github.com/samsungexynos3475/android_frameworks_base/compare/LineageOS:lineage-19.1...lineage-19.1.patch`
* **Details**: Restores Camera HALv1 compatibility helper methods and legacy camera object constructors in frameworks/base to support older camera HAL interfaces on Android 12.

### 3. RenderEngine EGLConfig Fallback for Legacy Mali GPUs
* **Target Path**: `frameworks/native`
* **Filename**: `frameworks_native/0001-renderengine-implement-ultimate-EGLConfig-fallback-for-legacy-Mali-GPUs.patch`
* **Details**: Removes the `EGL_RECORDABLE_ANDROID` attribute requirement from EGL configuration queries in `GLESRenderEngine` and `SkiaGLRenderEngine`. This allows legacy Mali-T720 GPU drivers to initialize SurfaceFlinger fallback configs properly, resolving bootloops on the LineageOS logo.

### 4. Telephony support for old RIL features
* **Target Path**: `frameworks/opt/telephony`
* **Filename**: `https://github.com/samsungexynos3475/android_frameworks_opt_telephony/compare/LineageOS:lineage-19.1...lineage-19.1.patch`
* **Details**: Squashes support for the legacy `simactivation` feature, implements `needsOldRilFeature`, adds 2G signal strength compatibility, avoids phone process crashes with invalid subIds during early init, and uses regular pollState for airplane mode.

### 5. WifiHAL Global Pointer Reset & Legacy Kernel Support
* **Target Path**: `hardware/broadcom/wlan`
* **Filename**: `hardware_broadcom_wlan/0001-WifiHAl-reset-global-pointer-to-NULL-to-fix-memory-leak.patch`
* **Details**: Resets the global `halInfo` pointer to `NULL` on initialization and cleanup failures to resolve memory leaks. Also skips the "vendor" membership registration check to prevent WiFi HAL load failures on legacy kernels.

### 6. Camera Legacy HIDL Compilation Fix
* **Target Path**: `hardware/lineage/interfaces`
* **Filename**: `hardware_lineage_interfaces/0001-interfaces-camera-fix-undeclared-F_DUPFD_CLOEXEC-identifier.patch`
* **Details**: Explicitly includes `<fcntl.h>` in `CameraDevice.cpp` for the 1.0-legacy camera HIDL service, resolving compilation failures on Android 12 due to cleanup of implicit header imports.

### 7. TcpSocketTracker Opt-out on Legacy Kernels
* **Target Path**: `packages/modules/NetworkStack`
* **Filename**: `https://github.com/DerpFest-AOSP/packages_modules_NetworkStack/commit/22fd53a977eeaf4e36be7bf6358ecf2c2737fa5e.patch`
* **Details**: Opt-out for TCP info parsing on legacy kernels (< 4.4) that lack the required netlink features, avoiding constant crashes in `TcpSocketTracker`.

### 8. ADB Legacy FunctionFS Support Backport
* **Target Path**: `packages/modules/adb`
* **Filename**: `https://github.com/LineageOS-UL/android_packages_modules_adb/commit/614f92cfc4355173ddc9d401a3d7722bc405a113.patch`
* **Details**: Restores support for legacy (non-blocking, synchronous) FunctionFS calls as a fallback in `adbd` when AIO on FFS is not supported (common on kernels < 3.18).

### 9. BPF Loader Fatal Initialization Bypass
* **Target Path**: `system/bpf`
* **Filename**: `system_bpf/0001-bpfloader-bypass-fatal-reboot-on-legacy-kernels-with.patch`
* **Details**: Bypasses the critical failure check in `bpfloader` for loading ELF BPF objects. This prevents fatal aborts and system_server bootloops on legacy kernels that lack BPF support.

### 10. Legacy Camera HAL System Core Extensions
* **Target Path**: `system/core`
* **Filename**: `system_core/0001-Camera-Add-feature-extensions.patch`
* **Details**: Restores vendor-specific camera messages (`CAMERA_MSG_STATS_DATA`, `CAMERA_MSG_META_DATA`), commands (`CAMERA_CMD_HISTOGRAM_ON/OFF`), and extra legacy fields in `camera_face_t` to resolve compilation and linkage issues with older HALs.

### 11. Netd eBPF bypass and iptables quota2 fix
* **Target Path**: `system/netd`
* **Filename**: `https://github.com/samsungexynos3475/android_system_netd/compare/LineageOS:lineage-19.1...lineage-19.1.patch`
* **Details**: Bypasses eBPF startup requirements and inserts a legacy UID 0 routing fallback rule for kernels without eBPF. Also patches netd to bypass `quota2` iptables module errors, preventing system_server crashes and bootloops when connecting to mobile data.

### 12. Generated Kernel Headers Output Directory Auto-Creation
* **Target Path**: `vendor/lineage`
* **Filename**: `vendor_lineage/generated_kernel_includes-auto-create-output-directory.patch`
* **Details**: Adds a `mkdir -p` command to `generated_kernel_includes` in the Soong build configuration (`Android.bp`) to create the build folder before running `headers_install`, resolving build failures when building with legacy 3.10 kernels.
