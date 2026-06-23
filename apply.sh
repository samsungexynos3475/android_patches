#!/usr/bin/env bash

apply_msg "⚙️ Brightness float sync"
apply "frameworks/base" "frameworks_base/core-Sync-float-brightness-from-int-setting-on-first-boot.patch"

apply_msg "🔑 Keystore backport"
apply "frameworks/base" "keystore/frameworks_base/core-Add-DEVICE_INITIAL_SDK_INT-to-Build.VERSION.patch"

apply_msg "📶 Wifi HAL"
apply "hardware/broadcom/wlan" "hardware_broadcom_wlan/WifiHAl-Fix-fatal-use-after-free-causing-infinite-POLLNVAL-loop.patch"
