#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

COMMON_PATH := device/sony/yoshino-common

# Kernel
TARGET_KERNEL_CONFIG := vendor/sony/yoshino.config

# Inherit from the proprietary version
include vendor/sony/yoshino-common/BoardConfigVendor.mk
