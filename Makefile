include $(THEOS_MAKE_PATH)/common.mk

FindFiles = $(foreach ext, c cpp m mm x xm xi xmi, $(wildcard $(1)/*.$(ext)))

TWEAK_NAME = SearchDelete
SearchDelete_FILES = $(call FindFiles, Source/Hooks)
SearchDelete_FRAMEWORKS = UIKit CoreGraphics
SearchDelete_PRIVATE_FRAMEWORKS = FrontBoardServices SpringBoardServices
SearchDelete_CFLAGS = -std=c++14 -Wno-deprecated-declarations
SearchDelete_LDFLAGS = -stdlib=libc++

SUBPROJECTS += Source/PreferenceBundle

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
