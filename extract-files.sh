#!/bin/bash
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2025 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

set -e

export DEVICE_COMMON=yoshino-common
export VENDOR=sony
export VENDOR_COMMON=${VENDOR}

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

# If XML files don't have comments before the XML header, use this flag
# Can still be used with broken XML files by using blob_fixup
export TARGET_DISABLE_XML_FIXING=true

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

ONLY_COMMON=
ONLY_FIRMWARE=
ONLY_TARGET=
KANG=
SECTION=
CARRIER_SKIP_FILES=()

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-common)
            ONLY_COMMON=true
            ;;
        --only-firmware)
            ONLY_FIRMWARE=true
            ;;
        --only-target)
            ONLY_TARGET=true
            ;;
        -n | --no-cleanup)
            CLEAN_VENDOR=false
            ;;
        -k | --kang)
            KANG="--kang"
            ;;
        -s | --section)
            SECTION="${2}"
            shift
            CLEAN_VENDOR=false
            ;;
        *)
            SRC="${1}"
            ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        vendor/bin/ffu)
            [ "$2" = "" ] && return 0
            sed -i 's|/lib/firmware/ufs|/etc/firmware/ufs|g' "$2"
            ;;
        product/etc/permissions/vendor.qti.hardware.data.connection-V1.0-java.xml | \
            product/etc/permissions/vendor.qti.hardware.data.connection-V1.1-java.xml)
            [ "$2" = "" ] && return 0
            sed -i 's/version\="2\.0"/version\="1\.0"/g' "$2"
            ;;
        vendor/etc/init/taimport_vendor.rc)
            [ "$2" = "" ] && return 0
            if ! grep -q "restorecon /persist/wlan" "$2"; then
                sed -i '4 a\    restorecon /persist/wlan' "$2"
            fi
            ;;
        system_ext/lib64/lib-imsvideocodec.so)
            [ "$2" = "" ] && return 0
            if ! "${PATCHELF}" --print-needed "$2" | grep -q "libgui_shim.so"; then
                "${PATCHELF}" --add-needed "libgui_shim.so" "$2"
            fi
            ;;
        system/lib/libjni_imageutil.so | \
            system/lib/libjni_snapcammosaic.so | \
            system/lib/libjni_snapcamtinyplanet.so | \
            system/lib64/libseemore.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libstdc++.so" "libstdc++_vendor.so" "$2"
            ;;
        system/lib/libseemore.so | \
            vendor/lib/libsomc_alfortlp.so | \
            vendor/lib/libsomc_alfortlpserv.so | \
            vendor/lib/libsomc_alfortrsc.so | \
            vendor/lib/libsomc_bordeauxrsc.so | \
            vendor/lib/libsomc_buttercakersc.so | \
            vendor/lib/libsomc_canelersc.so | \
            vendor/lib/libsomc_cheesesconersc.so | \
            vendor/lib/libsomc_dars.so | \
            vendor/lib/libsomc_darsrsc.so | \
            vendor/lib/libsomc_marblersc.so | \
            vendor/lib/libsomc_melonpanrsc.so | \
            vendor/lib/libsomc_mugichocorsc.so | \
            vendor/lib/libsomc_pretzchocorsc.so | \
            vendor/lib/libsomc_raisinrsc.so | \
            vendor/lib/libsomc_shortcakersc.so | \
            vendor/lib/libsomc_spicarsc.so | \
            vendor/lib/libsomc_sumomolpserv.so | \
            vendor/lib/libsomc_sumomorsc.so | \
            vendor/lib/libsomc_topporsc.so | \
            vendor/lib/libsomc_yummyrsc.so | \
            vendor/lib/libsony_fooddetect.so | \
            vendor/lib/libsony_naruto.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF_0_17_2}" --replace-needed "libstdc++.so" "libstdc++_vendor.so" "$2"
            ;;
        system/bin/sony-modem-switcher)
            [ "$2" = "" ] && return 0
            "${PATCHELF_0_17_2}" --replace-needed "libhidlbase.so" "libhidlbase-v32.so" "$2"
            ;;
        system/lib/com.qualcomm.qti.ant@1.0.so | \
            system/lib/com.qualcomm.qti.bluetooth_audio@1.0.so | \
            system/lib/libMiscTaWrapper.so | \
            system/lib/vendor.qti.hardware.qteeconnector@1.0.so | \
            system/lib/vendor.qti.hardware.tui_comm@1.0.so | \
            system/lib/vendor.qti.hardware.vpp@1.1.so | \
            system/lib/vendor.semc.hardware.light@1.0.so | \
            system/lib/vendor.semc.system.idd@1.0.so | \
            system/lib/vendor.somc.hardware.camera.cacao@1.0.so | \
            system/lib/vendor.somc.hardware.camera.cacao@2.0.so | \
            system/lib/vendor.somc.hardware.camera.cacao@3.0.so | \
            system/lib/vendor.somc.hardware.camera.cacao@3.1.so | \
            system/lib/vendor.somc.hardware.camera.device@1.0.so | \
            system/lib/vendor.somc.hardware.camera.provider@1.0.so | \
            system/lib64/com.qualcomm.qti.ant@1.0.so | \
            system/lib64/com.qualcomm.qti.bluetooth_audio@1.0.so | \
            system/lib64/libMiscTaWrapper.so | \
            system/lib64/vendor.display.color@1.0.so | \
            system/lib64/vendor.display.color@1.1.so | \
            system/lib64/vendor.display.color@1.2.so | \
            system/lib64/vendor.display.postproc@1.0.so | \
            system/lib64/vendor.qti.esepowermanager@1.0.so | \
            system/lib64/vendor.qti.hardware.qdutils_disp@1.0.so | \
            system/lib64/vendor.qti.hardware.qteeconnector@1.0.so | \
            system/lib64/vendor.qti.hardware.tui_comm@1.0.so | \
            system/lib64/vendor.qti.hardware.vpp@1.1.so | \
            system/lib64/vendor.semc.hardware.light@1.0.so | \
            system/lib64/vendor.semc.system.idd@1.0.so | \
            system/lib64/vendor.somc.hardware.security.secd@1.0.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libhidlbase.so" "libhidlbase-v32.so" "$2"
            ;;
        vendor/etc/init/android.hardware.drm@1.1-service.widevine.rc)
            [ "$2" = "" ] && return 0
            sed -i 's|writepid /dev/cpuset/foreground/tasks|task_profiles ProcessCapacityHigh|g' "$2"
            ;;
        vendor/etc/init/init.illumination_service.rc | \
            vendor/etc/init/init.touchbacklightd.rc)
            [ "$2" = "" ] && return 0
            sed -i 's|writepid /dev/cpuset/system-background/tasks|task_profiles ServiceCapacityLow|g' "$2"
            ;;
        vendor/etc/init/vendor.somc.hardware.camera.provider@1.0-service.rc)
            [ "$2" = "" ] && return 0
            sed -i 's|writepid /dev/cpuset/camera-daemon/tasks /dev/stune/top-app/tasks|task_profiles CameraServiceCapacity MaxPerformance|g' "$2"
            ;;
        *)
            return 1
            ;;
    esac

    return 0
}

function blob_fixup_dry() {
    blob_fixup "$1" ""
}

function prepare_firmware() {
    if [ "${SRC}" != "adb" ]; then
        local STAR="${ANDROID_ROOT}"/lineage/scripts/motorola/star.sh
        for IMAGE in bootloader radio; do
            if [ -f "${SRC}/${IMAGE}.img" ]; then
                echo "Extracting Motorola star image ${SRC}/${IMAGE}.img"
                sh "${STAR}" "${SRC}/${IMAGE}.img" "${SRC}"
            fi
        done
    fi
}

if [ -z "${ONLY_FIRMWARE}" ] && [ -z "${ONLY_TARGET}" ]; then
    # Initialize the helper for common device
    setup_vendor "${DEVICE_COMMON}" "${VENDOR_COMMON:-$VENDOR}" "${ANDROID_ROOT}" true "${CLEAN_VENDOR}"
    extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

if [ -z "${ONLY_COMMON}" ] && [ -s "${MY_DIR}/../../${VENDOR}/${DEVICE}/proprietary-files.txt" ]; then
    # Reinitialize the helper for device
    source "${MY_DIR}/../../${VENDOR}/${DEVICE}/extract-files.sh"
    setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

    if [ -z "${ONLY_FIRMWARE}" ]; then
        extract "${MY_DIR}/../../${VENDOR}/${DEVICE}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

        if [ -f "${MY_DIR}/../../${VENDOR}/${DEVICE}/proprietary-files-carriersettings.txt" ]; then
            generate_prop_list_from_image "product.img" "${MY_DIR}/../../${VENDOR}/${DEVICE}/proprietary-files-carriersettings.txt" CARRIER_SKIP_FILES carriersettings
            extract "${MY_DIR}/../../${VENDOR}/${DEVICE}/proprietary-files-carriersettings.txt" "${SRC}" "${KANG}" --section "${SECTION}"
            extract_carriersettings
        fi
    fi

    if [ -z "${SECTION}" ] && [ -f "${MY_DIR}/../../${VENDOR}/${DEVICE}/proprietary-firmware.txt" ]; then
        extract_firmware "${MY_DIR}/../../${VENDOR}/${DEVICE}/proprietary-firmware.txt" "${SRC}"
    fi
fi

"${MY_DIR}/setup-makefiles.sh"
