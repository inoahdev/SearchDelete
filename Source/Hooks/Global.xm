//
//  Source/Hooks/Global.xm
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 inoahdev. All rights reserved.
//

#include "../Headers/Theos/Version-Extensions.h"
#include "Global.h"

static void LoadPreferences(CFNotificationCenterRef center, void *observer, CFStringRef notificationName, const void *object, CFDictionaryRef userInfo) {
    SearchDeleteTweak *searchDelete = (SearchDeleteTweak *)object;

    if (!searchDelete.applicationID) {
        searchDelete.applicationID = @"com.inoahdev.searchdelete";
    }

    CFStringRef applicationID = (__bridge CFStringRef)searchDelete.applicationID;
    if (CFPreferencesAppSynchronize(applicationID)) {
        if (access("/private/var/mobile/Library/Preferences/com.inoahdev.searchdelete.plist", F_OK) != -1) {
            CFArrayRef keyList = CFPreferencesCopyKeyList(applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
            if (keyList) {
                searchDelete.preferences = (NSDictionary *)CFPreferencesCopyMultiple(keyList, applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
                if (searchDelete.preferences) {
                    [searchDelete.preferences retain];
                }

                CFRelease(keyList);
            }
        }
    }

    if (!searchDelete.preferences) {
        searchDelete.preferences = @{@"kEnabledLongPress" : @YES,
                                     @"kJitter"           : @YES};
    }
}

@implementation SearchDeleteTweak
+ (instancetype)sharedInstance {
    static SearchDeleteTweak *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[SearchDeleteTweak alloc] init];

        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        LoadPreferences,
                                        CFStringCreateWithCString(kCFAllocatorDefault, "iNoahDevSearchDeletePreferencesChangedNotification", kCFStringEncodingUTF8),
                                        (const void *)sharedInstance,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
        LoadPreferences(NULL, NULL, NULL, sharedInstance, NULL);
    });

    return sharedInstance;
}

- (void)setCurrentJitteringCell:(SearchUISingleResultTableViewCell *)cell {
    self->_currentJitteringCell = [cell retain];
}
@end

%ctor {
    [SearchDeleteTweak sharedInstance];
}
