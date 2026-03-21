#!/usr/bin/env bash

apply_msg "🎵 Audio blast fix"
apply "hardware/samsung" "hardware_samsung/samsung-audio-Implement-auto-fade-in-to-suppress-AudioFlinger-volume-delay-blast.patch"

apply_msg "🔋 Battery Extender"
apply "device/lineage/sepolicy" "batteryextender/device_lineage_sepolicy/sepolicy-add-hal_lineage_batterylifeextender.patch"
apply "hardware/lineage/interfaces" "batteryextender/hardware_lineage_interfaces/lineage-interfaces-add-batterylifeextender-HAL.patch"
apply "hardware/samsung" "batteryextender/hardware_samsung/hidl-add-batterylifeextender-implementation.patch"
apply "packages/apps/Settings" "batteryextender/packages_apps_Settings/Settings-add-Protect-battery-toggle.patch"

apply_msg "🔵 Bluetooth SCO I2S routing"
apply "system/bt" "system_bt/btm-fix-SCO-I2S-routing.patch"

apply_msg "✉️ Email crash fix"
apply "packages/apps/UnifiedEmail" "packages_apps_UnifiedEmail/UnifiedEmail-Replace-incompatible-bitmap-drawables.patch"

apply_msg "🔑 Keystore backports"
apply "frameworks/base" "keystore/frameworks_base/keystore-backport-KeyStoreException.patch"
apply "system/security" "keystore/system_security/keystore-silently-upgrade-key-blobs-during-attestation-to-bypass-KEY_REQUIRES_UPGRADE-errors.patch"
