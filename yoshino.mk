#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Soong
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH) \
    bootable/deprecated-ota

# Update
AB_OTA_UPDATER := false

# Inherit proprietary blobs
$(call inherit-product, vendor/sony/yoshino-common/yoshino-common-vendor.mk)
