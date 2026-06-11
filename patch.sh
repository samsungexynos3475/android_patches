#!/usr/bin/env bash

separator() {
    echo "---------------------------------------------------------"
}

list_versions() {
    separator
    echo "🔍 Retrieving available LineageOS versions from remote..."
    separator

    local repo_dir
    local remote_url="https://github.com/samsungexynos3475/android_patches"
    repo_dir=$(dirname "$0")

    if [ -d "$repo_dir/.git" ]; then
        local local_remote
        local_remote=$(git -C "$repo_dir" remote get-url origin 2>/dev/null)
        if [ -n "$local_remote" ]; then
            remote_url="$local_remote"
        fi
    fi

    local versions
    versions=$(git ls-remote --heads "$remote_url" 2>/dev/null | grep 'refs/heads/lineage-' | sed 's|.*/lineage-||')

    if [ -z "$versions" ]; then
        echo "   No versions found (or unable to connect to the remote repository)."
    else
        echo "   Available versions:"
        echo "$versions" | sed 's/^/    - /'
    fi

    separator
}

if [ "$1" = "list" ] || [ "$1" = "--list" ] || [ "$1" = "-l" ]; then
    list_versions
    exit 0
fi

if [ -z "$1" ]; then
    separator
    echo "❌ Error: LineageOS version not specified."
    echo "Usage: patch.sh <version> (e.g., 17.1) or patch.sh -l | --list"
    list_versions
    exit 1
fi

if test -f "build/envsetup.sh"; then
    REPO_URL="https://raw.githubusercontent.com/samsungexynos3475/android_patches/refs/heads/lineage-$1"

    separator
    echo "✅ LineageOS build system found. Starting to patch now!"
    separator

    # --- LineageOS/android_frameworks_av ---
    echo "   📂 frameworks/av"
    echo "      🎥 Patching Video Recording"
    separator

    (
        cd frameworks/av && \
        git am -s < <(curl -sf "$REPO_URL/frameworks_av/0001-Camera-stagefright-Resolve-video-recording-freezes-and-color.patch")
    ) || { echo "❌ Failed to patch frameworks/av! Aborting..."; exit 1; }

    # --- LineageOS/android_hardware_interfaces ---
    echo "   📂 hardware/interfaces"
    echo "      📷 Patching Camera"
    separator

    (
        cd hardware/interfaces && \
        git am -s < <(curl -sf "$REPO_URL/hardware_interfaces/0001-camera-Relax-metadata-buffer-size-check-in-sDataCbTimestamp.patch")
    ) || { echo "❌ Failed to patch hardware/interfaces! Aborting..."; exit 1; }

    # --- LineageOS/android_hardware_samsung ---
    echo "   📂 hardware/samsung"
    echo "      👆 Patching Touch HAL"
    separator

    (
        cd hardware/samsung && \
        git am -s < <(curl -sf "$REPO_URL/hardware_samsung/0001-samsung-hidl-Add-missing-touch-interface-declaration-to-init-script.patch")
    ) || { echo "❌ Failed to patch hardware/samsung! Aborting..."; exit 1; }

    # --- LineageOS/packages_apps_Bluetooth ---
    echo "   📂 packages/apps/Bluetooth"
    echo "      🔵 Patching Bluetooth"
    separator

    (
        cd packages/apps/Bluetooth && \
        git am -s < <(curl -sf "$REPO_URL/packages_apps_Bluetooth/0001-AdapterState-Increase-BLE-and-BREDR-start-watchdog-timeouts.patch")
    ) || { echo "❌ Failed to patch packages/apps/Bluetooth! Aborting..."; exit 1; }

    # --- LineageOS/packages_apps_UnifiedEmail ---
    echo "   📂 packages/apps/UnifiedEmail"
    echo "      ✉️ Patching UnifiedEmail"
    separator

    (
        cd packages/apps/UnifiedEmail && \
        git am -s < <(curl -sf "$REPO_URL/packages_apps_UnifiedEmail/0001-UnifiedEmail-Replace-incompatible-bitmap-drawables.patch")
    ) || { echo "❌ Failed to patch packages/apps/UnifiedEmail! Aborting..."; exit 1; }
else
    separator
    echo "❌ LineageOS build system not found. Make sure you're in the build folder! Aborting..."
    separator
fi
