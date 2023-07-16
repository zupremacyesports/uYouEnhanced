ifeq ($(ROOTLESS),1)
THEOS_PACKAGE_SCHEME=rootless
endif

DEBUG=0
FINALPACKAGE=1
TARGET := iphone:clang:latest:11.0
ARCHS = arm64
PACKAGE_VERSION = 3.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = uYouLocalization
$(TWEAK_NAME)_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk
