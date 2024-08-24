#!/usr/bin/env bash

apply_msg "🎵 Audio blast fix"
apply "hardware/samsung" "https://raw.githubusercontent.com/samsungexynos3475/android_patches/refs/heads/lineage-17.1/hardware_samsung/samsung-audio-Implement-auto-fade-in-to-suppress-AudioFlinger-volume-delay-blast.patch"

apply_msg "🔵 Bluetooth SCO I2S routing"
apply "system/bt" "system_bt/btm-fix-SCO-I2S-routing.patch"

apply_msg "🔵 Bluetooth revert WBS by default"
apply "system/bt" "system_bt/Revert-Bluetooth-HFP-Use-WBS-by-default-1-5.patch"

apply_msg "⚙️ BPF support for legacy devices"
apply "system/bpf" "https://github.com/LineageOS/android_system_bpf/compare/lineage-23.2...samsungexynos3475:android_system_bpf:lineage-19.1.patch"

apply_msg "📲 Bring back legacy FunctionFS support"
apply "packages/modules/adb" "https://github.com/LineageOS-UL/android_packages_modules_adb/commit/614f92cfc4355173ddc9d401a3d7722bc405a113.patch"

apply_msg "📷 Camera feature extensions"
apply "system/core" "system_core/Camera-Add-feature-extensions.patch"

apply_msg "⚙️ Frameworks patch for legacy devices"
apply "frameworks/base" "https://github.com/samsungexynos3475/android_frameworks_base/compare/LineageOS:lineage-19.1...lineage-19.1.patch"

apply_msg "🔐 Keystore patch"
apply "hardware/libhardware" "hardware_libhardware/include-keystore-hackup.patch"
apply "system/security" "system_security/keystore2-keystore-hackup.patch"

apply_msg "🌐 NETD support for legacy devices"
apply "system/netd" "https://github.com/samsungexynos3475/android_system_netd/compare/LineageOS:lineage-19.1...lineage-19.1.patch"

apply_msg "🌐 Opt-out for TCP info parsing on legacy kernels"
apply "packages/modules/NetworkStack" "https://github.com/DerpFest-AOSP/packages_modules_NetworkStack/commit/22fd53a977eeaf4e36be7bf6358ecf2c2737fa5e.patch"

apply_msg "🎨 Remove EGL requirement for legacy GPUs"
apply "frameworks/native" "frameworks_native/renderengine-implement-ultimate-EGLConfig-fallback-for-legacy-Mali-GPUs.patch"

apply_msg "📶 Reset global pointer and skip vendor group"
apply "hardware/broadcom/wlan" "hardware_broadcom_wlan/WifiHAl-reset-global-pointer-to-NULL-to-fix-memory-leak.patch"

apply_msg "🎥 Restore camera HALv1 support"
apply "frameworks/av" "https://github.com/samsungexynos3475/android_frameworks_av/compare/LineageOS:lineage-19.1...lineage-19.1.patch"

apply_msg "📱 SurfaceFlinger patch for legacy devices"
apply "frameworks/native" "https://github.com/LineageOS/android_frameworks_native/commit/83ce920d7edac575d60bd7e4d7a8b8be7dbe9b55.patch"

apply_msg "📞 Telephony support for old RIL features"
apply "frameworks/opt/telephony" "https://github.com/samsungexynos3475/android_frameworks_opt_telephony/compare/LineageOS:lineage-19.1...lineage-19.1.patch"

apply_msg "📷 Undeclared F_DUPFD_CLOEXEC after restored camera HALv1"
apply "hardware/lineage/interfaces" "hardware_lineage_interfaces/interfaces-camera-fix-undeclared-F_DUPFD_CLOEXEC-identifier.patch"
