# Exynos 3475 Android patches (LineageOS 18.1)

This branch contains custom hardware patches for LineageOS 18.1 on Exynos 3475 devices.

## Included Patches

### 1. Wifi HAL Use-After-Free & Loop Fix
* **Target Path**: `hardware/broadcom/wlan`
* **Filename**: `hardware_broadcom_wlan/0001-WifiHAl-Fix-fatal-use-after-free-causing-infinite-POLLNVAL-loop.patch`
* **Details**: Moves the `vendor` multicast group registration outside the fatal error block to make it optional, and sets `halInfo = NULL;` on error paths to eliminate a dangling pointer use-after-free causing infinite `POLLNVAL` loops on Exynos3475.

### 2. Display Light max_brightness caching
* **Target Path**: `hardware/samsung`
* **Filename**: `hardware_samsung/0001-hidl-light-cache-max_brightness-during-initialization.patch`
* **Details**: Caches the max_brightness value in the Display Light HAL constructor, eliminating a 1.2 second screen-off animation delay caused by repeatedly reading sysfs nodes on every setLight call.

### 3. Broadcom Bluetooth HAL I2S/PCM Initialization
* **Target Path**: `hardware/broadcom/libbt`
* **Filename**: `hardware_broadcom_libbt/0001-libbt-Ensure-complete-I2S-PCM-initialization-sequence.patch`
* **Details**: Extends the vendor specific command callbacks to ensure that PCM parameter (0xFC1C) and PCM format (0xFC1E) initialization sequences are fully executed even when the Bluetooth chip is configured in SCO I2S interface mode.

### 4. System Bluetooth SCO I2S Routing Setup
* **Target Path**: `system/bt`
* **Filename**: `system_bt/0001-btm-fix-SCO-I2S-routing-for-Android-10.patch`
* **Details**: Manually injects Broadcom vendor-specific commands for configuring the SCO I2S interface (Master role, 256KHz clock, short sync) during connection request initialization, replacing the `BT_VND_OP_SET_AUDIO_STATE` operation removed in Android 10.

### 5. Battery Extender SELinux Policy (Sepolicy)
* **Target Path**: `device/lineage/sepolicy`
* **Filename**: `batteryextender-eleven/device_lineage_sepolicy/0001-sepolicy-add-hal_lineage_batterylifeextender.patch`
* **Details**: Adds necessary SELinux policy rules (`hal_lineage_batterylifeextender` client/server attributes, permissions for system apps and settings to call the service) to authorize Binder IPC for the Battery Life Extender HAL.

### 6. Battery Extender HIDL Interface Definition
* **Target Path**: `hardware/lineage/interfaces`
* **Filename**: `batteryextender-eleven/hardware_lineage_interfaces/0001-lineage-interfaces-add-batterylifeextender-HAL.patch`
* **Details**: Defines the `vendor.lineage.batterylifeextender@1.0` HIDL interface (`IBatteryLifeExtender.hal` with `isEnabled` and `setEnabled` methods) in LineageOS interfaces.

### 7. Battery Extender Samsung HAL Implementation
* **Target Path**: `hardware/samsung`
* **Filename**: `batteryextender-eleven/hardware_samsung/0001-hidl-add-batterylifeextender-implementation.patch`
* **Details**: Implements the `IBatteryLifeExtender` service for Samsung devices, reading/writing values to the `/sys/class/power_supply/battery/store_mode` sysfs node and managing permissions and vendor properties accordingly.

### 8. Battery Extender Settings Toggle UI
* **Target Path**: `packages/apps/Settings`
* **Filename**: `batteryextender-eleven/packages_apps_Settings/0001-Settings-add-Protect-battery-toggle.patch`
* **Details**: Adds a "Protect battery" toggle switch to the Settings application under the Battery usage summary page, linked to the `BatteryLifeExtenderPreferenceController` which interfaces with the `IBatteryLifeExtender` HIDL service.

### 9. Samsung Audio Auto-Fade-In Workaround
* **Target Path**: `hardware/samsung`
* **Filename**: `hardware_samsung/0002-samsung-audio-Implement-auto-fade-in-to-suppress-AudioFlinger-volume-delay-blast.patch`
* **Details**: Monitors the PCM buffer for silence (>100ms) and applies a smooth 280ms software fade-in when audio resumes, suppressing initial loud blasts/pops caused by AudioFlinger volume setup delays on headsets and other outputs (excluding the built-in speaker).

### 10. Brightness Float Setting Synchronization on First Boot
* **Target Path**: `frameworks/base`
* **Filename**: `frameworks_base/0001-core-Sync-float-brightness-from-int-setting-on-first-boot.patch`
* **Details**: Synchronizes the new `SCREEN_BRIGHTNESS_FLOAT` setting from the legacy integer `SCREEN_BRIGHTNESS` setting if the float setting is uninitialized (`Float.NaN`) on first boot or factory reset. This prevents physical screen brightness from defaulting to 50% while the Settings App UI slider incorrectly displays 0%.

### 11. SettingsProvider Pure Black Dark Theme by Default
* **Target Path**: `lineage-sdk`
* **Filename**: `lineage-sdk/0001-SettingsProvider-Enable-pure-black-dark-theme-by-default.patch`
* **Details**: Enables pure black theme for dark mode by default (instead of dark grey) on first boot/factory reset by initializing the secure database setting `berry_black_theme` to true.

### 12. Build.VERSION DEVICE_INITIAL_SDK_INT Field Backport
* **Target Path**: `frameworks/base`
* **Filename**: `frameworks_base/0002-core-Add-DEVICE_INITIAL_SDK_INT-to-Build.VERSION.patch`
* **Details**: Backports the `Build.VERSION.DEVICE_INITIAL_SDK_INT` field introduced in Android 12 to Android 11. This prevents Zygisk/root hiding modules (e.g. PlayIntegrityFix and Tricky Store) from throwing `NoSuchFieldError` and crashing system apps like the Google Play Store.
