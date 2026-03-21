#!/usr/bin/env bash

apply_msg "🎵 Audio blast fix"
apply "hardware/samsung" "https://raw.githubusercontent.com/samsungexynos3475/android_patches/refs/heads/lineage-17.1/hardware_samsung/samsung-audio-Implement-auto-fade-in-to-suppress-AudioFlinger-volume-delay-blast.patch"

apply_msg "🔋 Battery Extender"
apply "device/lineage/sepolicy" "batteryextender/device_lineage_sepolicy/sepolicy-add-hal_lineage_batterylifeextender.patch"
apply "hardware/lineage/interfaces" "batteryextender/hardware_lineage_interfaces/lineage-interfaces-add-batterylifeextender-HAL.patch"
apply "hardware/samsung" "batteryextender/hardware_samsung/hidl-add-batterylifeextender-implementation.patch"
apply "packages/apps/Settings" "batteryextender/packages_apps_Settings/Settings-add-Protect-battery-toggle.patch"

apply_msg "🔵 Bluetooth SCO I2S routing"
apply "system/bt" "https://raw.githubusercontent.com/samsungexynos3475/android_patches/refs/heads/lineage-17.1/system_bt/btm-fix-SCO-I2S-routing.patch"

apply_msg "⚙️ Brightness float sync"
apply "frameworks/base" "frameworks_base/core-Sync-float-brightness-from-int-setting-on-first-boot.patch"

apply_msg "🔑 Keystore backport"
apply "frameworks/base" "keystore/frameworks_base/core-Add-DEVICE_INITIAL_SDK_INT-to-Build.VERSION.patch"

apply_msg "📶 Wifi HAL"
apply "hardware/broadcom/wlan" "hardware_broadcom_wlan/WifiHAl-Fix-fatal-use-after-free-causing-infinite-POLLNVAL-loop.patch"
