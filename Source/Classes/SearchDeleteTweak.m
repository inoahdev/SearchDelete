//
//  Source/Classes/SearchDeleteTweak.xm
//  SearchDelete
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#import "SearchDeleteTweak.h"

@interface SearchDeleteTweak ()
@property (nonatomic, strong) NSDictionary *preferences;
@end

static CFStringRef applicationID = (__bridge CFStringRef)@"com.inoahdev.searchdelete";

static void InitializePreferences(NSDictionary **preferences) {
    if (CFPreferencesAppSynchronize(applicationID)) {
        CFArrayRef keyList = CFPreferencesCopyKeyList(applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        if (keyList) {
            *preferences = (NSDictionary *)CFPreferencesCopyMultiple(keyList, applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
            CFRelease(keyList);
        }
    }

    if (!*preferences) {
        NSNumber *enabledNumber = [[NSNumber alloc] initWithBool:YES];
        *preferences = [[NSDictionary alloc] initWithObjectsAndKeys:enabledNumber, @"kEnabled", nil];

        [enabledNumber release];
    }
}

static void LoadPreferences() {
    NSDictionary *preferences = nil;
    InitializePreferences(&preferences);

    SearchDeleteTweak *searchDeleteTweak = [SearchDeleteTweak sharedInstance];
    [searchDeleteTweak setPreferences:preferences];
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
                                        (__bridge CFStringRef)@"iNoahDevLaunchInSafeModePreferencesChangedNotification",
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
    });

    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        InitializePreferences(&_preferences);
    }

    return self;
}

- (BOOL)isEnabled {
    return [_preferences[@"kEnabledLongPress"] boolValue];
}

- (BOOL)shouldJitter {
    return [_preferences[@"kJitter"] boolValue];
}

- (void)dealloc {
    [_preferences release];
    [super dealloc];
}
@end
