# Exynos 3475 Android patches (LineageOS 17.1)

This branch contains the patch files for LineageOS 17.1 on Exynos 3475 devices. These patches address key hardware integration issues.

## Included Patches

### 1. Stagefright Video Recording Fix
* **Target Path**: `frameworks/av`
* **Filename**: `frameworks_av/0001-Camera-stagefright-Resolve-video-recording-freezes-and-color.patch`
* **Details**: Resolves freezes and color format issues during video recording under Stagefright.

### 2. Bluetooth Service Fix (Watchdog Timeout Extension)
* **Target Path**: `packages/apps/Bluetooth`
* **Filename**: `packages_apps_Bluetooth/0001-AdapterState-Increase-BLE-and-BREDR-start-watchdog-timeouts.patch`
* **Details**: Extends Java-side startup watchdog timeouts to 150s (coordinating with a 1000ms UART firmware delay and 150s native stack timeout) to prevent transitional-state hangs and crash loops under high CPU load.

### 3. UnifiedEmail Setup Inflation Crash Fix
* **Target Path**: `packages/apps/UnifiedEmail`
* **Filename**: `packages_apps_UnifiedEmail/0001-UnifiedEmail-Replace-incompatible-bitmap-drawables.patch`
* **Details**: Replaces incompatible `<bitmap>` wrapping of vector drawables with `<layer-list>` to resolve runtime `InflateException` crashes during account setup.

### 4. Samsung Audio Auto-Fade-In Workaround
* **Target Path**: `hardware/samsung`
* **Filename**: `hardware_samsung/0001-samsung-audio-Implement-auto-fade-in-to-suppress-AudioFlinger-volume-delay-blast.patch`
* **Details**: Monitors the PCM buffer for silence (>100ms) and applies a smooth 400ms software fade-in when audio resumes, suppressing initial loud blasts/pops caused by AudioFlinger volume setup delays.

### 5. btm SCO I2S routing configuration for Android 10
* **Target Path**: `system/bt`
* **Filename**: `system_bt/0001-btm-fix-SCO-I2S-routing-for-Android-10.patch`
* **Details**: Injects Broadcom VSC initialization commands into `btm_send_connect_request` to configure the PCM/I2S interface for the s2803x codec.

### 6. Watchdog Timeout Extension
* **Target Path**: `frameworks/base`
* **Filename**: `frameworks_base/0001-services-Increase-watchdog-timeout-to-180s-to-prevent-.patch`
* **Details**: Increases Watchdog timeout to 180s to prevent false-positive system_server watchdog panics on low RAM devices under memory pressure.

### 7. Keystore KeyStoreException backport for Android 12 compatibility
* **Target Path**: `frameworks/base`
* **Filename**: `frameworks_base/0002-keystore-backport-KeyStoreException-for-Android-12-compatibility.patch`
* **Details**: Backports the Android 12 KeyStoreException class and Build.VERSION_CODES.DEVICE_INITIAL_SDK_INT field to allow modern keystore daemons (like TEESimulator) to initialize without throwing ClassNotFoundException on legacy Android 10.

### 8. Keystore Silent KeyBlob Upgrade during Attestation
* **Target Path**: `system/security`
* **Filename**: `system_security/0001-keystore-silently-upgrade-key-blobs-during-attestation-to-bypass-KEY_REQUIRES_UPGRADE-errors.patch`
* **Details**: Intercepts KEY_REQUIRES_UPGRADE errors during attestKey and silently upgrades the keyblobs, bypassing attestation failures on legacy devices where TrustZone patch level differs from OS properties.

### 9. SettingsProvider Pure Black Dark Theme by Default
* **Target Path**: `lineage-sdk`
* **Filename**: `lineage-sdk/0001-SettingsProvider-Enable-pure-black-dark-theme-by-default.patch`
* **Details**: Enables pure black theme for dark mode by default (instead of dark grey) on first boot/factory reset by initializing the secure database setting `berry_black_theme` to true.
