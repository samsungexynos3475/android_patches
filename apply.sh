#!/usr/bin/env bash

apply_msg "🎵 Audio blast fix"
apply "hardware/samsung" "hardware_samsung/samsung-audio-Implement-auto-fade-in-to-suppress-AudioFlinger-volume-delay-blast.patch"

apply_msg "🔵 Bluetooth SCO I2S routing"
apply "system/bt" "system_bt/btm-fix-SCO-I2S-routing.patch"

apply_msg "✉️ Email crash fix"
apply "packages/apps/UnifiedEmail" "packages_apps_UnifiedEmail/UnifiedEmail-Replace-incompatible-bitmap-drawables.patch"
