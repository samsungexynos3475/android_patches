#!/usr/bin/env bash

apply_msg "🎵 Audio blast fix"
apply "hardware/samsung" "samsung-audio-Implement-auto-fade-in-to-suppress-AudioFlinger-volume-delay-blast.patch"

apply_msg "🔵 Bluetooth SCO I2S routing"
apply "system/bt" "btm-fix-SCO-I2S-routing.patch"

apply_msg "🔵 Bluetooth revert WBS by default"
apply "system/bt" "Revert-Bluetooth-HFP-Use-WBS-by-default-1-5.patch"

apply_msg "⚙️ BPF support for legacy devices"
apply "system/bpf" \
    "bpf-bring-back-isBpfSupported-method-but-using-ro.kernel.ebpf.supported.patch" \
    "bpfloader-support-legacy-kernel-using-ro.kernel.ebpf.supported-false.patch"

apply_msg "📲 Bring back legacy FunctionFS support"
apply "packages/modules/adb" "adb-Bring-back-support-for-legacy-FunctionFS.patch"

apply_msg "📷 Camera feature extensions"
apply "system/core" "Camera-Add-feature-extensions.patch"

apply_msg "⚙️ Frameworks patch for legacy devices"
apply "frameworks/base" \
    "Camera-Restore-camera-HALv1-support-2-2.patch" \
    "Camera-Add-feature-extensions.patch" \
    "SystemUI-unregisters-fragment-from-TunerService-when-destroyed-to-prevent-NullPointerException.patch" \
    "JNI-reduce-eBPF-log-spam-on-legacy-kernels.patch" \
    "core-some-services-should-just-stfu.patch" \
    "hwui-stop-davey-messages-when-using-latch_unsignaled.patch" \
    "CameraServiceProxy-Loosen-UID-check-conditionally.patch" \
    "Hack-Ignore-SensorPrivacyService-Security-Exception.patch" \
    "SettingsLib-fix-brightness-slider-curve-for-some-devices.patch" \
    "javac-bump-shard_size-to-100000.patch"

apply_msg "🔐 Keystore patch"
apply "hardware/libhardware" "hardware_libhardware/include-keystore-hackup.patch"
apply "system/security" "system_security/keystore2-keystore-hackup.patch"

apply_msg "🌐 NETD support for legacy devices"
apply "system/netd" \
    "Revert-eliminate-TrafficController-s-mBpfEnabled-friends.patch" \
    "Revert-bpf-is-always-supported.patch" \
    "Revert-BandwidthController.cpp-fix-a-clang-warning-abseil-string-find-startswith.patch" \
    "Revert-Remove-unused-IptJumpOp-value.patch" \
    "Revert-Use-UidOwnerMatchType-rather-than-IptJumpOp-in-TrafficController.patch" \
    "Revert-Refactoring-string-uid-vectors.patch" \
    "Revert-Remove-unused-code-from-BandwidthController.patch" \
    "Revert-Remove-non-bpf-support-from-BandwidthController.patch" \
    "netd-Allow-devices-to-force-add-directly-connected-routes.patch"

apply_msg "🌐 Opt-out for TCP info parsing on legacy kernels"
apply "packages/modules/NetworkStack" "TcpSocketTracker-Opt-out-for-TCP-info-parsing-on-legacy-kernels.patch"

apply_msg "📶 Reset global pointer and skip vendor group"
apply "hardware/broadcom/wlan" "WifiHAl-reset-global-pointer-to-NULL-to-fix-memory-leak.patch"

apply_msg "🎥 Restore camera HAL v1 support"
apply "frameworks/av" \
    "Camera-Restore-camera-HALv1-support-1-2.patch" \
    "nuplayer-Avoid-crash-when-codec-fails-to-load.patch" \
    "camera-Don-t-segfault-if-we-get-a-NULL-parameter.patch" \
    "libstagefright-Support-YVU420SemiPlanar-camera-format.patch" \
    "stagefright-omx-Don-t-signal-dataspace-change-on-legacy-QCOM.patch" \
    "stagefright-ACodec-Resolve-empty-vendor-parameters-usage.patch" \
    "libstagefright-Free-buffers-on-observer-died.patch" \
    "libstagefright-use-64-bit-usage-for-native_window_set_usage.patch" \
    "camera-include-Don-t-override-possible-overlayed-header.patch" \
    "camera-media-Support-legacy-HALv1-camera-in-mediaserver.patch" \
    "Camera-check-metadata-type-before-releasing-frame.patch" \
    "libstagefright-Fix-memory-leak-due-to-lock-timeout.patch" \
    "camera-Allow-devices-to-load-custom-CameraParameter-code.patch" \
    "Camera-Add-support-for-preview-frame-fd.patch" \
    "stagefright-add-changes-related-to-high-framerates-in-CameraSource.patch" \
    "libcameraservice-Don-t-pass-NULL-args-on-setCallbacks-call.patch" \
    "Camera-Add-extensions-to-CameraClient.patch"

apply_msg "📱 SurfaceFlinger patch for legacy devices"
apply "frameworks/native" \
    "SurfaceFlinger-Don-t-cleanup-resources-from-previous-frame.patch" \
    "SurfaceFlinger-Don-t-cleanup-resources-from-previous-frame-on-virtual-display.patch" \
    "SurfaceFlinger-avoiding-unnecessary-frame-skip-to-reduce-janks.patch" \
    "SurfaceFlinger-Bring-back-support-for-disabling-backpressure-propagation.patch"

apply_msg "📞 Telephony support for old RIL features"
apply "frameworks/opt/telephony" \
    "telephony-avoid-SubscriptionManager-getUriForSubscriptionId-calls-with-invalid-subIds.patch" \
    "telephony-2G-wants-proper-signal-strength-too.patch" \
    "telephony-squashed-support-for-simactivation-feature.patch" \
    "telephony-add-option-for-using-regular-poll-state-for-airplane-mode.patch" \
    "telephony-fix-NPE-in-updateServiceStateArfcnRsrpBoost.patch"

apply_msg "📷 Undeclared F_DUPFD_CLOEXEC after restored camera HALv1"
apply "hardware/lineage/interfaces" "interfaces-camera-fix-undeclared-F_DUPFD_CLOEXEC-identifier.patch"
