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
