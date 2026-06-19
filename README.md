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

### 5. LineageOS Touch HAL Interface Declaration Fix
* **Target Path**: `hardware/samsung`
* **Filename**: `hardware_samsung/0001-samsung-hidl-Add-missing-touch-interface-declaration-to-init-script.patch`
* **Details**: Adds missing HIDL interface declaration to Touch HAL init script to resolve `system_server` watchdog bootloops in Enforcing mode.

### 6. libv4l2 cameraserver Freeze Fix
* **Target Path**: `hardware/samsung_slsi/exynos`
* **Filename**: `hardware_samsung_slsi_exynos/0001-libv4l2-Prevent-infinite-loop-when-fopen-fails-due-to-SELinux-denial.patch`
* **Details**: Increments the node index during sysfs video node queries when `fopen` fails, preventing cameraserver infinite loops/freezes due to SELinux denials.

### 7. gralloc CMA Heap uncached Allocation Workaround
* **Target Path**: `hardware/samsung_slsi/exynos`
* **Filename**: `hardware_samsung_slsi_exynos/0002-gralloc-Strip-ION_FLAG_CACHED-for-CMA-carveout-alloc.patch`
* **Details**: Strips `ION_FLAG_CACHED` flags when allocating from the CMA carveout heap (`ION_HEAP_EXYNOS_CONTIG_MASK`) to prevent `-EINVAL` allocation failures and fix black screens in the camera preview.

### 8. Samsung Audio Auto-Fade-In Workaround
* **Target Path**: `hardware/samsung`
* **Filename**: `hardware_samsung/0002-samsung-audio-Implement-auto-fade-in-to-suppress-AudioFlinger-volume-delay-blast.patch`
* **Details**: Monitors the PCM buffer for silence (>100ms) and applies a smooth 400ms software fade-in when audio resumes, suppressing initial loud blasts/pops caused by AudioFlinger volume setup delays.

### 9. Broadcom libbt I2S/PCM Initialization Sequence configuration
* **Target Path**: `hardware/broadcom/libbt`
* **Filename**: `hardware_broadcom_libbt/0001-libbt-Ensure-complete-I2S-PCM-initialization-sequence.patch`
* **Details**: Ensures complete I2S/PCM initialization sequence by sending both PCM parameter and format commands in I2S mode.

### 10. btm SCO I2S routing configuration for Android 10
* **Target Path**: `system/bt`
* **Filename**: `system_bt/0001-btm-fix-SCO-I2S-routing-for-Android-10.patch`
* **Details**: Injects Broadcom VSC initialization commands into `btm_send_connect_request` to configure the PCM/I2S interface for the s2803x codec.

### 11. Samsung Audio BT SCO VoIP and Cellular routing restoration
* **Target Path**: `hardware/samsung`
* **Filename**: `hardware_samsung/0003-samsung-audio-Restore-BT-SCO-VoIP-and-Cellular-routing.patch`
* **Details**: Restores BT SCO VoIP and cellular routing by opening card 0 device 3 (Bluetooth AIF3 interface) independently.

