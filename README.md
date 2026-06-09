# Exynos 3475 Android patches (LineageOS 17.1)

This branch contains the patch files for LineageOS 17.1 on Exynos 3475 devices. These patches address key hardware integration issues.

## Included Patches

### 1. Stagefright Video Recording Fix
* **Target Path**: `frameworks/av`
* **Filename**: `frameworks_av/0001-Camera-stagefright-Resolve-video-recording-freezes-and-color.patch`
* **Details**: Resolves freezes and color format issues during video recording under Stagefright.

### 2. Camera Metadata Buffer Size Relaxation
* **Target Path**: `hardware/interfaces`
* **Filename**: `hardware_interfaces/0001-camera-Relax-metadata-buffer-size-check-in-sDataCbTimestamp.patch`
* **Details**: Relaxes the buffer size safety checks in `sDataCbTimestamp` to allow legacy camera HALs to function correctly.

### 3. Bluetooth Service Fix (Watchdog Timeout Extension)
* **Target Path**: `packages/apps/Bluetooth`
* **Filename**: `packages_apps_Bluetooth/0001-AdapterState-Increase-BLE-and-BREDR-start-watchdog-timeouts.patch`
* **Details**: Extends Java-side startup watchdog timeouts to 150s (coordinating with a 1000ms UART firmware delay and 150s native stack timeout) to prevent transitional-state hangs and crash loops under high CPU load.

### 4. UnifiedEmail Setup Inflation Crash Fix
* **Target Path**: `packages/apps/UnifiedEmail`
* **Filename**: `packages_apps_UnifiedEmail/0001-UnifiedEmail-Replace-incompatible-bitmap-drawables.patch`
* **Details**: Replaces incompatible `<bitmap>` wrapping of vector drawables with `<layer-list>` to resolve runtime `InflateException` crashes during account setup.
