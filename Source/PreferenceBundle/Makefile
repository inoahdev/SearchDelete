include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SearchDelete
SearchDelete_FILES = SearchDeleteRootListController.m
SearchDelete_INSTALL_PATH = /Library/PreferenceBundles
SearchDelete_FRAMEWORKS = UIKit
SearchDelete_PRIVATE_FRAMEWORKS = Preferences
SearchDelete_LDFLAGS = -stdlib=libc++

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SearchDelete.plist$(ECHO_END)
