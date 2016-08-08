include $(THEOS)/makefiles/common.mk
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 9.0

TWEAK_NAME = SearchDelete
SearchDelete_FILES = Tweak.xm
SearchDelete_FRAMEWORKS = UIKit CoreGraphics
SearchDelete_LDFLAGS = -stdlib=libc++

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

SUBPROJECTS += searchdelete

after-install::
	install.exec "killall -9 SpringBoard"
