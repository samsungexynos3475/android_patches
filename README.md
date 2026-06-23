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
