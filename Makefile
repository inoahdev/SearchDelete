include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SearchDelete
SearchDelete_FILES = Tweak.xm
SearchDelete_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += searchdelete
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
