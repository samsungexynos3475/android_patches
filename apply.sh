#!/usr/bin/env bash

apply_msg "🎵 Audio blast fix"
apply "hardware/samsung" "samsung-audio-Implement-auto-fade-in-to-suppress-AudioFlinger-volume-delay-blast.patch"

apply_msg "🔵 Bluetooth SCO I2S routing"
apply "system/bt" "btm-fix-SCO-I2S-routing.patch"

apply_msg "⚙️ Brightness float sync"
apply "frameworks/base" "core-Sync-float-brightness-from-int-setting-on-first-boot.patch"

apply_msg "🔑 Keystore backport"
apply "frameworks/base" "keystore/frameworks_base/core-Add-DEVICE_INITIAL_SDK_INT-to-Build.VERSION.patch"

apply_msg "📶 Wifi HAL"
apply "hardware/broadcom/wlan" "WifiHAl-Fix-fatal-use-after-free-causing-infinite-POLLNVAL-loop.patch"
