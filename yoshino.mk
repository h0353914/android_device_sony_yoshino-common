#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Add common definitions for Qualcomm
$(call inherit-product, hardware/qcom-caf/common/common.mk)

# Lights
PRODUCT_PACKAGES += \
    android.hardware.light-service.lineage

# Partitions
PRODUCT_PACKAGES += \
    vendor_bt_firmware_mountpoint \
    vendor_dsp_mountpoint \
    vendor_firmware_mnt_mountpoint

# Soong
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH) \
    bootable/deprecated-ota

# Update
AB_OTA_UPDATER := false

# Inherit proprietary blobs
$(call inherit-product, vendor/sony/yoshino-common/yoshino-common-vendor.mk)
