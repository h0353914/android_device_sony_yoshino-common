# OrangeFox build variables shared by the Yoshino devices (lilac, maple, poplar)
# Must be exported: the OrangeFox vendor script reads them from fox_env.sh
# The per-device ones (FOX_VARIANT, FOX_TARGET_DEVICES) are in each device tree

export OF_MAINTAINER="h0353914"

# Sony has no "recovery" partition: recovery lives in FOTAKernel
export FOX_RECOVERY_INSTALL_PARTITION="/dev/block/bootdevice/by-name/FOTAKernel"

# Keymaster 3.0 fallback for vendors without a manifest Fox can read (Oreo)
export OF_DEFAULT_KEYMASTER_VERSION="3.0"

# Not a Xiaomi device
export OF_DISABLE_MIUI_SPECIFIC_FEATURES=1
export OF_NO_MIUI_PATCH_WARNING=1

# Keep the "USB storage" button on the Mount menu like TWRP (mass_storage LUN is configured)
export OF_ENABLE_USB_STORAGE=1

# Quick backup list: boot + data
export OF_QUICK_BACKUP_LIST="/boot;/data;"

# OrangeFox extras
export FOX_USE_BASH_SHELL=1
export FOX_ASH_IS_BASH=1
export FOX_USE_NANO_EDITOR=1
export FOX_USE_TAR_BINARY=1
export FOX_USE_SED_BINARY=1
export FOX_USE_GREP_BINARY=1
export FOX_USE_XZ_UTILS=1
export FOX_ENABLE_APP_MANAGER=1
