# Boot animation
TARGET_BOOTANIMATION_HALF_RES := true
TARGET_SCREEN_WIDTH := 1280
TARGET_SCREEN_HEIGHT := 720

# Inherit some common LineageOS stuff.
$(call inherit-product, vendor/lineage/config/common_full_tablet_wifionly.mk)

# Inherit device configuration
$(call inherit-product, device/brcm/rpi4/rpi4.mk)
$(call inherit-product-if-exists, vendor/brcm/rpi4/rpi4-vendor.mk)

# Su
WITH_SU := true

# Vendor security patch level
PRODUCT_PROPERTY_OVERRIDES += \
    ro.lineage.build.vendor_security_patch=2018-07-05

# Device identifier. This must come after all inclusions
PRODUCT_DEVICE := rpi4
PRODUCT_NAME := lineage_rpi4
PRODUCT_BRAND := Richash
PRODUCT_MODEL := Richash RPi4
PRODUCT_MANUFACTURER := Richash
PRODUCT_RELEASE_NAME := Richash RPi4

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.lineage.releasetype=Richash