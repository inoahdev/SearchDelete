//
//  Source/Hooks/Global.xm
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 inoahdev. All rights reserved.
//

#include "../Headers/Theos/Version-Extensions.h"
#include "Global.h"

static NSMutableDictionary *preferences = nil;

@interface SearchDeleteTweak ()
@end

static void LoadPreferences() {
    CFStringRef applicationID = (__bridge CFStringRef)@"com.inoahdev.searchdelete";
    if (CFPreferencesAppSynchronize(applicationID)) {
        CFArrayRef keyList = CFPreferencesCopyKeyList(applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        if (keyList) {
            preferences = [(NSDictionary *)CFPreferencesCopyMultiple(keyList, applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) mutableCopy];
            CFRelease(keyList);
        }
    }

    if (!preferences) {
        preferences = [@{@"kEnabledLongPress" : @YES,
                       @"kJitter"             : @YES} mutableCopy];
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
                                        (CFNotificationCallback)LoadPreferences,
                                        (__bridge CFStringRef)@"iNoahDevSearchDeletePreferencesChangedNotification",
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
        LoadPreferences();
    });

    return sharedInstance;
}

- (BOOL)isEnabled {
    return [preferences[@"kEnabledLongPress"] boolValue];
}

- (void)setIsEnabled:(BOOL)isEnabled {
    preferences[@"kEnabledLongPress"] = @(isEnabled);
    CFPreferencesSetAppValue((__bridge CFStringRef)@"kEnabledLongPress", (CFPropertyListRef)@(isEnabled), (__bridge CFStringRef)self.applicationID);
}

- (BOOL)shouldJitter {
    return [preferences[@"kJitter"] boolValue];
}

- (void)setShouldJitter:(BOOL)jitter {
    preferences[@"kJitter"] = @(jitter);
    CFPreferencesSetAppValue((__bridge CFStringRef)@"kJitter", (CFPropertyListRef)@(jitter), (__bridge CFStringRef)self.applicationID);
}
@end

%ctor {
    [SearchDeleteTweak sharedInstance];
}

%dtor {
    if (preferences) {
        [preferences release];
        preferences = nil;
    }
}
