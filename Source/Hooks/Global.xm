//
//  Source/Hooks/Global.xm
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#import "../Headers/Theos/Version-Extensions.h"
#import "Global.h"

static NSMutableDictionary *preferences = nil;
static CFStringRef applicationID = (__bridge CFStringRef)@"com.inoahdev.searchdelete";

static void LoadPreferences() {
    if (CFPreferencesAppSynchronize(applicationID)) {
        CFArrayRef keyList = CFPreferencesCopyKeyList(applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        if (keyList) {
            preferences = [(NSDictionary *)CFPreferencesCopyMultiple(keyList, applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) mutableCopy];
            CFRelease(keyList);
        }
    }

    if (!preferences) {
        SDDebugLog(@"Unable to find Preferences!");
        preferences = [@{@"kEnabledLongPress" : @YES,
                         @"kJitter"           : @YES} mutableCopy];
    }

    SDDebugLog(@"Preferences: %@", preferences);
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

- (BOOL)shouldJitter {
    return [preferences[@"kJitter"] boolValue];
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
