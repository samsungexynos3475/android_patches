# Exynos 3475 Android patches (LineageOS 18.1)

This branch contains custom hardware patches for LineageOS 18.1 on Exynos 3475 devices.

## Included Patches

### 1. Cameraserver Video Native Handle Metadata Size Check
* **Target Path**: `frameworks/av`
* **Filename**: `frameworks_av/0001-cameraserver-relax-VideoNativeHandleMetadata-size-va.patch`
* **Details**: Relaxes cameraserver size validation checks for `VideoNativeHandleMetadata` from strict equality to relational (`>=`) checks to allow custom 20-byte metadata buffers from legacy camera HALs to pass through.

### 2. Wifi HAL Use-After-Free & Loop Fix
* **Target Path**: `hardware/broadcom/wlan`
* **Filename**: `hardware_broadcom_wlan/0001-WifiHAl-Fix-fatal-use-after-free-causing-infinite-POLLNVAL-loop.patch`
* **Details**: Moves the `vendor` multicast group registration outside the fatal error block to make it optional, and sets `halInfo = NULL;` on error paths to eliminate a dangling pointer use-after-free causing infinite `POLLNVAL` loops on Exynos3475.

### 3. Camera Metadata Buffer Size Relaxation
* **Target Path**: `hardware/interfaces`
* **Filename**: `hardware_interfaces/0001-camera-relax-metadata-buffer-size-check-in-sDataCbTi.patch`
* **Details**: Relaxes the buffer size safety checks in `sDataCbTimestamp` from strict equality to `>=` to allow custom 20-byte metadata buffers from legacy camera HALs to pass through the HIDL layer.

### 4. LineageOS Camera Interfaces Metadata Buffer Size Check
* **Target Path**: `hardware/lineage/interfaces`
* **Filename**: `hardware_lineage_interfaces/0001-interfaces-camera-relax-metadata-buffer-size-check-i.patch`
* **Details**: Relaxes metadata buffer size verification checks in `sDataCbTimestamp` inside the 1.0-legacy camera device implementation to support custom 20-byte buffers on legacy camera HALs.

### 5. Display Light max_brightness caching
* **Target Path**: `hardware/samsung`
* **Filename**: `hardware_samsung/0001-hidl-light-cache-max_brightness-during-initialization.patch`
* **Details**: Caches the max_brightness value in the Display Light HAL constructor, eliminating a 1.2 second screen-off animation delay caused by repeatedly reading sysfs nodes on every setLight call.

### 6. Broadcom Bluetooth HAL I2S/PCM Initialization
* **Target Path**: `hardware/broadcom/libbt`
* **Filename**: `hardware_broadcom_libbt/0001-libbt-Ensure-complete-I2S-PCM-initialization-sequence.patch`
* **Details**: Extends the vendor specific command callbacks to ensure that PCM parameter (0xFC1C) and PCM format (0xFC1E) initialization sequences are fully executed even when the Bluetooth chip is configured in SCO I2S interface mode.

### 7. Samsung Audio BT SCO VoIP and Cellular Routing Fix
* **Target Path**: `hardware/samsung`
* **Filename**: `hardware_samsung/0002-samsung-audio-Restore-BT-SCO-VoIP-and-Cellular-routing.patch`
* **Details**: Opens ALSA PCM Node 3 (AIF3 interface) independently for Bluetooth SCO calls and VoIP without starting cellular voice sessions or waking the baseband modem, which previously hijacked audio paths during non-cellular VoIP calls.

### 8. System Bluetooth SCO I2S Routing Setup
* **Target Path**: `system/bt`
* **Filename**: `system_bt/0001-btm-fix-SCO-I2S-routing-for-Android-10.patch`
* **Details**: Manually injects Broadcom vendor-specific commands for configuring the SCO I2S interface (Master role, 256KHz clock, short sync) during connection request initialization, replacing the `BT_VND_OP_SET_AUDIO_STATE` operation removed in Android 10.

### 9. Battery Extender SELinux Policy (Sepolicy)
* **Target Path**: `device/lineage/sepolicy`
* **Filename**: `batteryextender-eleven/device_lineage_sepolicy/0001-sepolicy-add-hal_lineage_batterylifeextender.patch`
* **Details**: Adds necessary SELinux policy rules (`hal_lineage_batterylifeextender` client/server attributes, permissions for system apps and settings to call the service) to authorize Binder IPC for the Battery Life Extender HAL.

### 10. Battery Extender HIDL Interface Definition
* **Target Path**: `hardware/lineage/interfaces`
* **Filename**: `batteryextender-eleven/hardware_lineage_interfaces/0001-lineage-interfaces-add-batterylifeextender-HAL.patch`
* **Details**: Defines the `vendor.lineage.batterylifeextender@1.0` HIDL interface (`IBatteryLifeExtender.hal` with `isEnabled` and `setEnabled` methods) in LineageOS interfaces.

### 11. Battery Extender Samsung HAL Implementation
* **Target Path**: `hardware/samsung`
* **Filename**: `batteryextender-eleven/hardware_samsung/0001-hidl-add-batterylifeextender-implementation.patch`
* **Details**: Implements the `IBatteryLifeExtender` service for Samsung devices, reading/writing values to the `/sys/class/power_supply/battery/store_mode` sysfs node and managing permissions and vendor properties accordingly.

### 12. Battery Extender Settings Toggle UI
* **Target Path**: `packages/apps/Settings`
* **Filename**: `batteryextender-eleven/packages_apps_Settings/0001-Settings-add-Protect-battery-toggle.patch`
* **Details**: Adds a "Protect battery" toggle switch to the Settings application under the Battery usage summary page, linked to the `BatteryLifeExtenderPreferenceController` which interfaces with the `IBatteryLifeExtender` HIDL service.

### 13. LineageOS Updater Custom Server URL and Changelog
* **Target Path**: `packages/apps/Updater`
* **Filename**: `packages_apps_Updater/0001-Updater-change-update-url.patch`
* **Details**: Redirects the updater's server URL to download update definitions directly from the GitHub releases page for `samsungexynos3475/releases` on branch `lineage-18.1`, and updates the changelog and issue links to point to the corresponding GitHub repositories.



