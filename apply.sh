#!/usr/bin/env bash

# apply_msg "🎵 Audio blast fix"
# apply "hardware/samsung" "samsung-audio-Implement-auto-fade-in-to-suppress-AudioFlinger-volume-delay-blast.patch"

apply_msg "🎵 Audio fixed for legacy devices"
apply "hardware/interfaces" "Revert-audio-use-binder-threadpool.patch"
apply "hardware/interfaces" "Revert-Audio-Load-Bluetooth-AIDL-HAL.patch"

# apply_msg "🔵 Bluetooth SCO I2S routing"
# apply "system/bt" "btm-fix-SCO-I2S-routing.patch"

# apply_msg "🔵 Bluetooth revert WBS by default"
# apply "system/bt" "Revert-Bluetooth-HFP-Use-WBS-by-default-1-5.patch"

apply_msg "📲 Bring back legacy FunctionFS support"
apply "packages/modules/adb" "adb-Bring-back-support-for-legacy-FunctionFS.patch"

apply_msg "📶 Bypass unsupported Wi-Fi diagnostic commands"
apply "hardware/broadcom/wlan" "WifiHAl-bypass-unsupported-diagnostic-commands.patch"

apply_msg "📷 Camera feature extensions"
apply "system/core" "camera-add-feature-extensions.patch"

apply_msg "⚙️ Cgroups v2 revert for legacy devices"
apply "system_core" "Revert-init-Treat-failure-to-create-a-process-group-as fatal.patch"
apply "system_core" "Revert-libprocessgroup-switch-freezer-to-cgroup-v2.patch"

apply_msg "📷 Fix build after restored camera HAL v1"
apply "hardware/lineage/interfaces" "camera-fix-build-after-restore-camera-HAL-v1"

apply_msg "⚙️ Frameworks patch for legacy devices"
apply "frameworks/base" \
    "Revert-CameraManager-Swap-propertyName-packageName-i.patch" \
    "Revert-DO-NOT-MERGE-Force-slowJpegMode-on-certain-ca.patch" \
    "Revert-Per-app-compat-treatment-for-overrideToPortra.patch" \
    "Revert-DO-NOT-MERGE-CameraManager-Enable-override-to.patch" \
    "Revert-DO-NOT-MERGE-CameraManager-Provide-flag-for-o.patch" \
    "Revert-camera-Skip-HFR-checks-for-privileged-apps.patch" \
    "Revert-Camera-Skip-stream-size-check-for-whitelisted.patch" \
    "CameraServiceProxy-Loosen-UID-check-conditionally.patch" \
    "camera-revert-Camera-Injection.patch" \
    "Camera-Restore-camera-HALv1-support-2-2.patch" \
    "Camera-Add-feature-extensions.patch" \
    "Revert-Camera-Add-support-for-readout-timestamp.patch" \
    "BiometricScheduler-Cancel-operation-if-not-idle.patch" \
    "HACK-sensorprivacy-ignore-SensorPrivacyService-Secur.patch" \
    "wm-disable-vendor-mismatch-warning.patch" \
    "core-Remove-old-app-target-SDK-dialog.patch" \
    "Fix-brightness-slider-curve-for-some-devices.patch" \
    "sensors-Create-bool-to-select-what-timestamp-to-use.patch" \
    "hwui-reset-to-android-13.0.0_r13.patch" \
    "Revert-Enable-multiprocess-WebView-for-all-devices.patch" \
    "am-allow-to-tune-killing-cached-processes-until-post.patch" \
    "fixup-am-allow-to-tune-killing-cached-processes-unti.patch" \
    "Revert-CachedAppOptimizer-use-new-cgroup-api-for-fre.patch" \
    "Revert-CachedAppOptimizer-remove-native-freezer-enab.patch" \
    "Revert-CachedAppOptimizer-don-t-hardcode-freezer-pat.patch" \
    "CachedAppOptimizer-revert-freezer-to-cgroups-v1.patch" \
    "batterysaver-add-property-to-disable-night-mode-on-b.patch"

apply_msg "🔐 Keystore patch"
apply "hardware/libhardware" "hardware_libhardware/include-keystore-hackup.patch"
apply "system/security" "system_security/keystore2-keystore-hackup.patch"

apply_msg "⚙️ Low RAM mode hack"
apply "frameworks/base" "lowram/frameworks_base/HACK-core-services-allow-features-on-low-ram-mode.patch"
apply "frameworks/native" "lowram/frameworks_native/handheld-allow-PiP-and-work-profile-on-low-ram-mode.patch"
apply "packages/apps/Settings" "lowram/packages_apps_Settings/HACK-Settings-allow-features-settings-page-on-low-ram-mode.patch"

apply_msg "🌐 NETD support for legacy devices"
apply "system/netd" \
    "Revert-eliminate-TrafficController-s-mBpfEnabled-friends.patch" \
    "Revert-bpf-is-always-supported.patch" \
    "Revert-BandwidthController.cpp-fix-a-clang-warning.patch" \
    "Revert-Remove-unused-IptJumpOp-value.patch" \
    "Revert-Remove-non-bpf-support-from-BandwidthControll.patch" \
    "netd-more-reverts-to-LOS-19-state.patch" \
    "Revert-netd-make-BandwidthController-startup-failure.patch" \
    "netd-allow-devices-to-force-add-directly-connected-routes.patch" \
    "netd-don-t-abort-in-case-of-cgroup-bpf-setup-fail.patch"

apply_msg "⚙️ Non-eBPF support for legacy devices"

apply "frameworks/libs/net" "BpfMap-restore-back-the-behavior-of-isValid.patch"

apply "packages/modules/Connectivity" \
    "BpfHandler-allow-failing-to-load-bpf-programs-for-BPF-less-devices.patch" \
    "libnetworkstats-BpfMap-implemented-new-checks-for-kernel-4.14.patch" \
    "NetworkStatsService-don-t-delete-UID-from-BpfMap-on-BPF-less-kernel.patch" \
    "jni-bring-back-traffic-indicators-for-legacy-devices.patch" \
    "Connectivity-restore-legacy-xt_qtaguid-fallback-for-non-eBPF-devices.patch"

apply "packages/modules/NetworkStack" "Revert-Enable-parsing-netlink-events-from-kernel-since-T.patch"

apply "system/bpf" \
    "bpfloader-support-legacy-kernel-using-isBpfSupported-method.patch" \
    "Revert-detect-inability-to-write-to-index-0-of-bpf-map-array.patch"

# apply_msg "🌐 Opt-out for TCP info parsing on legacy kernels"
# apply "packages/modules/NetworkStack" "TcpSocketTracker-Opt-out-for-TCP-info-parsing-on-legacy-kernels.patch"

apply_msg "💾 Remove memfd_create() version check"
apply "art" "art-Conditionally-remove-version-check-for-memfd_create.patch"
apply "external/perfetto" "perfetto-Conditionally-remove-version-check-for-memfd_create.patch"

apply_msg "📶 Reset global pointer and skip vendor group"
apply "hardware/broadcom/wlan" "WifiHAl-reset-global-pointer-to-NULL-to-fix-memory-leak.patch"

# apply_msg "📶 Restore mWifiLinkLayerStatsSupported check"
# apply "packages/modules/Wifi" "wifi-resurrect-mWifiLinkLayerStatsSupported-counter"

apply_msg "🎥 Restore camera HAL v1 support"
apply "frameworks/av" \
    "Revert-Camera-memcpy-Blob-header-rather-than-directl.patch" \
    "Revert-Camera-Fix-missing-physical-camera-availabili.patch" \
    "Revert-Camera-Avoid-roundBufferDimensionsNearest-als.patch" \
    "Revert-Camera-Skip-stream-size-check-for-whitelisted.patch" \
    "Revert-Camera-Avoid-over-delaying-frames-in-PreviewF.patch" \
    "Revert-Camera-Reduce-latency-for-dejittering.patch" \
    "Revert-Camera-Avoid-dequeue-too-many-buffers-from-bu.patch" \
    "Revert-Camera-Fix-parameter-misalignment-in-getDevic.patch" \
    "Revert-DO-NOT-MERGE-Force-slowJpegMode-on-certain-ca.patch" \
    "Revert-CameraService-Disable-overrideToPortrait-for-.patch" \
    "Revert-Turn-off-overrideToPortrait-where-not-needed.patch" \
    "Revert-Camera-Override-transform-of-all-inflight-req.patch" \
    "Revert-DO-NOT-MERGE-Camera-Enable-session-parameter-.patch" \
    "Revert-CameraService-Update-rotate-and-crop-dynamica.patch" \
    "Revert-Camera-NDK-Do-not-enable-overrideToPortrait-i.patch" \
    "Revert-DO-NOT-MERGE-libcameraservice-Provide-flag-fo.patch" \
    "Revert-Fix-an-issue-that-the-syncTimestampToDisplayL.patch" \
    "Revert-Camera-Add-adb-shell-cmd-to-override-stream-u.patch" \
    "Revert-Camera-Avoid-latency-accumulation-when-syncin.patch" \
    "Revert-Add-disable-enable-camera-service-watchdog-fe.patch" \
    "libcameraservice-reset-to-a0a10c95a363a0df93da678b1e.patch" \
    "libcameraservice-massive-revert-to-Android-12-state.patch" \
    "camera-Allow-to-use-boottime-as-timestamp-reference.patch" \
    "camera-allow-devices-to-load-custom-CameraParameter-.patch" \
    "Revert-Camera-Remove-old-recording-path-support.patch" \
    "camera-restore-camera-HALv1-support-1-2.patch" \
    "camera-add-extensions-to-CameraClient.patch" \
    "nuplayer-avoid-crash-when-codec-fails-to-load.patch" \
    "camera-don-t-segfault-if-we-get-a-NULL-parameter.patch" \
    "libstagefright-support-YVU420SemiPlanar-camera-forma.patch" \
    "stagefright-ACodec-resolve-empty-vendor-parameters-u.patch" \
    "libstagefright-free-buffers-on-observer-died.patch" \
    "libstagefright-use-64-bit-usage-for-native_window_se.patch" \
    "camera-include-don-t-override-possible-overlayed-hea.patch" \
    "camera-check-metadata-type-before-releasing-frame.patch" \
    "stagefright-add-changes-related-to-high-framerates-i.patch" \
    "camera-add-support-for-preview-frame-fd.patch" \
    "libstagefright-support-PIXEL_FORMAT_YUV420SP_NV21.patch" \
    "libstagefright-fix-memory-leak-due-to-lock-timeout.patch" \
    "camera-media-support-legacy-HALv1-camera-in-mediaser.patch" \
    "audiopolicy-there-are-three-SCO-devices-fallback-fro.patch"

apply_msg "📱 SurfaceFlinger patch for legacy devices"
apply "frameworks/native" \
    "SurfaceFlinger-Don-t-cleanup-resources-from-previous-frame.patch" \
    "SurfaceFlinger-Don-t-cleanup-resources-from-previous-frame-on-display.patch" \
    "SurfaceFlinger-Don-t-cleanup-resources-from-previous-frame-on-virtual-display.patch" \
    "SurfaceFlinger-avoiding-unnecessary-frame-skip-to-re.patch" \
    "gpuservice-disable-gpu-service.patch" \
    "libbinder-Suppress-log-spam-when-unlinking-death-rec.patch" \
    "libbinder-O_CLOFORK.patch" \
    "surfaceflinger-fix-the-shadow-problem-caused-by-laye.patch" \
    "surfaceflinger-Scheduler-add-more-window-types-to-co.patch" \
    "surfaceflinger-Scheduler-vote-max-for-NOTIFICATION_S.patch" \
    "SurfaceFlinger-set-debug.sf.frame_rate_multiple_thre.patch" \
    "surfaceflinger-avoid-present-hidl-call-when-DP-is-di.patch" \
    "SurfaceFlinger-bring-back-support-for-disabling-back.patch" \
    "inputflinger-matching-an-input-with-a-display-uses-u.patch" \
    "installd-unshared_oob-didn-t-exist-in-O-P-so-detect-.patch" \
    "DO-NOT-MERGE-surfaceflinger-fix-a-race-between-layer.patch" \
    "nativedisplay-fix-the-flicker-issue-in-streaming-vid.patch" \
    "gui-fix-libgui-cts-crash-bug.patch" \
    "ui-fix-validateBufferDescriptorInfo-error-when-usage.patch" \
    "Revert-REThreaded-convert-gen-and-delete-Textures-to.patch"

apply_msg "📞 Telephony support for old RIL features"
apply "frameworks/opt/telephony" \
    "telephony-squashed-support-for-simactivation-feature.patch" \
    "telephony-avoid-SubscriptionManager-getUriForSubscri.patch" \
    "telephony-2G-wants-proper-signal-strength-too.patch" \
    "telephony-add-option-for-using-regular-poll-state-fo.patch" \
    "telephony-fix-data-detach-isn-t-informed.patch" \
    "telephony-ignore-PLMN-bit-when-SPN-is-required.patch" \
    "Revert-Remove-compat-version-of-ImsService-binding.patch" \
    "Revert-Telephony-Remove-IOem-in-Telephony.patch"

apply_msg "📦 Vendor Lineage config patches"
apply "vendor/lineage" \
    "Revert-config-Remove-TARGET_CAMERA_BOOTTIME_TIMESTAMP.patch" \
    "Revert-config-Remove-TARGET_NEEDS_NETD_DIRECT_CONNECT.patch" \
    "Revert-config-Remove-TARGET_HAS_MEMFD_BACKPORT.patch" \
    "Revert-config-Remove-TARGET_SPECIFIC_CAMERA_PARAMETER.patch" \
    "Revert-config-Remove-TARGET_HAS_LEGACY_CAMERA_HAL1.patch" \
    "kernel-bring-back-fuse-ld-lld-from-CFLAGS.patch"

apply_msg "📶 WiFI HIDL patches for legacy devices"
apply "hardware/lineage/interfaces" \
    "wifi-1.0-legacy-Add-provision-to-create-remove-dynamic-interfaces.patch" \
    "wifi-fix-legacy-HIDL-for-T.patch" \
    "wifi-hidl_struct_util.cpp-convertLegacyWifiChannelWidthToHidl.patch" \
    "wifi-wifi.h-fix-build-undef-NAN.patch"
