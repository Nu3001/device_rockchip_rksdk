# Get the long list of APNs
PRODUCT_COPY_FILES += device/rockchip/common/phone/etc/apns-full-conf.xml:system/etc/apns-conf.xml
PRODUCT_COPY_FILES += device/rockchip/common/phone/etc/spn-conf.xml:system/etc/spn-conf.xml
# The rksdk board
include device/rockchip/rksdk/BoardConfig.mk
$(call inherit-product, device/rockchip/rksdk/device.mk)

PRODUCT_BRAND := rockchip
PRODUCT_DEVICE := rksdk
PRODUCT_NAME := rksdk
PRODUCT_MODEL := rksdk
PRODUCT_MANUFACTURER := rockchip


PRODUCT_PROPERTY_OVERRIDES += \
			ro.product.version = 1.0.0 \
			ro.product.ota.host = www.rockchip.com:2300
