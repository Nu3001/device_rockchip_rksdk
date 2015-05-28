# config.mk
# 
# Product-specific compile-time definitions.
#

TARGET_PREBUILT_KERNEL ?= kernel/arch/arm/boot/Image
TARGET_BOARD_PLATFORM ?= rk30xx
TARGET_BOARD_PLATFORM_GPU ?= mali400
TARGET_BOARD_HARDWARE ?= rk30board
BOARD_USE_LCDC_COMPOSER ?= false
BOARD_USE_LOW_MEM ?= false
TARGET_NO_BOOTLOADER ?= true
TARGET_CPU_VARIANT := cortex-a9
TARGET_RELEASETOOLS_EXTENSIONS := device/rockchip/rksdk

DEVICE_PACKAGE_OVERLAYS += device/rockchip/rksdk/overlay

ifeq ($(strip $(TARGET_BOARD_PLATFORM_GPU)), mali400)
ifeq ($(TARGET_BOARD_PLATFORM),rk2928)
BOARD_EGL_CFG := device/rockchip/common/gpu/libmali/egl.cfg
else
BOARD_EGL_CFG := device/rockchip/common/gpu/libmali_smp/egl.cfg
endif
else
BOARD_EGL_CFG := device/rockchip/common/gpu/libpvr/egl.cfg
endif

TARGET_PROVIDES_INIT_RC ?= true

TARGET_NO_KERNEL ?= false
TARGET_NO_RECOVERY ?= false
TARGET_ROCHCHIP_RECOVERY ?= true
#for widevine drm
BOARD_WIDEVINE_OEMCRYPTO_LEVEL := 3

# to flip screen in recovery 
BOARD_HAS_FLIPPED_SCREEN := false

# To use bmp as kernel logo, uncomment the line below to use bgra 8888 in recovery
#TARGET_RECOVERY_PIXEL_FORMAT := "BGRA_8888"
TARGET_ROCKCHIP_PCBATEST ?= false
TARGET_RECOVERY_UI_LIB ?= librecovery_ui_$(TARGET_PRODUCT)
TARGET_USERIMAGES_USE_EXT4 ?= true
RECOVERY_UPDATEIMG_RSA_CHECK ?= false
RECOVERY_BOARD_ID ?= false
TARGET_CPU_SMP ?= true
BOARD_USES_GENERIC_AUDIO ?= true

//MAX-SIZE=512M, for generate out/.../system.img
BOARD_SYSTEMIMAGE_PARTITION_SIZE ?= 1073741824
BOARD_FLASH_BLOCK_SIZE ?= 131072

include device/rockchip/$(TARGET_PRODUCT)/wifi_bt.mk
include device/rockchip/rksdk/wifi_bt_common.mk

TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi

# Enable NEON feature
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
ARCH_ARM_HAVE_TLS_REGISTER := true

#BOARD_LIB_DUMPSTATE := libdumpstate.$(TARGET_BOARD_PLATFORM)

# google apps
BUILD_WITH_GOOGLE_MARKET ?= true

# face lock
BUILD_WITH_FACELOCK ?= false

# ebook
BUILD_WITH_RK_EBOOK ?= false

# rksu
BUILD_WITH_RKSU ?= false

USE_OPENGL_RENDERER ?= true

# rk30sdk uses Cortex A9
TARGET_EXTRA_CFLAGS += $(call cc-option,-mtune=cortex-a9,$(call cc-option,-mtune=cortex-a8)) $(call cc-option,-mcpu=cortex-a9,$(call cc-option,-mcpu=cortex-a8))

# sensors
BOARD_SENSOR_ST := true
#BOARD_SENSOR_COMPASS_AK8963 := true    #if use akm8963
#BOARD_SENSOR_ANGLE := true		#if need calculation angle between two gsensors
#BOARD_SENSOR_CALIBRATION := true	#if need calibration

TARGET_BOOTLOADER_BOARD_NAME ?= rk30sdk

# readahead files to improve boot time
# BOARD_BOOT_READAHEAD ?= true

BOARD_BP_AUTO := true

#phone pad codec list
BOARD_CODEC_WM8994 := false
BOARD_CODEC_RT5625_SPK_FROM_SPKOUT := false
BOARD_CODEC_RT5625_SPK_FROM_HPOUT := false
BOARD_CODEC_RT3261 := false
BOARD_CODEC_RT3224 := true
BOARD_CODEC_RT5631 := false
BOARD_CODEC_RK616 := false

#if set to true m-user would be disabled and UMS enabled, if set to disable UMS would be disabled and m-user enabled
BUILD_WITH_UMS := true

#if set to true BUILD_WITH_UMS must be false.
BUILD_WITH_CDROM := false
BUILD_WITH_CDROM_PATH ?= /system/etc/cd.iso

# for drmservice
BUILD_WITH_DRMSERVICE :=true

# for tablet encryption
BUILD_WITH_CRYPTO := false

# for update nand 2.1
NAND_UPDATE :=true

# define tablet support NTFS 
BOARD_IS_SUPPORT_NTFS := true

# product has GPS or not
BOARD_HAS_GPS := true

# ethernet
BOARD_HS_ETHERNET := true

# manifest
SYSTEM_WITH_MANIFEST := true

# multi usb partitions
BUILD_WITH_MULTI_USB_PARTITIONS := false

# no battery
BUILD_WITHOUT_BATTERY := true

#TWRP
DEVICE_RESOLUTION := 1024x600
HAVE_SELINUX := true
TW_INCLUDE_JB_CRYPTO := true
TW_NO_SCREEN_BLANK := true
TW_NO_SCREEN_TIMEOUT := true
TW_CUSTOM_POWER_BUTTON := 116
TARGET_USE_CUSTOM_LUN_FILE_PATH := /sys/devices/platform/usb20_otg/gadget/lun%d/file
TW_NO_BATT_PERCENT := true
TW_DISABLE_DOUBLE_BUFFERING := true
BOARD_RECOVERY_BLDRMSG_OFFSET := 16384

