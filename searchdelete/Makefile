include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SearchDelete
SearchDelete_FILES = SearchDeletePrefsRootListController.m
SearchDelete_INSTALL_PATH = /Library/PreferenceBundles
SearchDelete_FRAMEWORKS = UIKit Social
SearchDelete_PRIVATE_FRAMEWORKS = Preferences
SearchDelete_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SearchDelete.plist$(ECHO_END)
