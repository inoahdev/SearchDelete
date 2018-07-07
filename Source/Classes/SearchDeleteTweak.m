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

#ifdef DEBUG
static FILE *logFile = NULL;
#endif

static CFStringRef applicationID =
    (__bridge CFStringRef)@"com.inoahdev.searchdelete";

static void InitializePreferences(NSDictionary **preferences) {
    if (CFPreferencesAppSynchronize(applicationID)) {
        CFArrayRef keyList =
            CFPreferencesCopyKeyList(applicationID,
                                     kCFPreferencesCurrentUser,
                                     kCFPreferencesAnyHost);

        if (keyList) {
            *preferences =
                (NSDictionary *)CFPreferencesCopyMultiple(
                    keyList,
                    applicationID,
                    kCFPreferencesCurrentUser,
                    kCFPreferencesAnyHost);

            CFRelease(keyList);
        }
    }

    if (!*preferences) {
        NSNumber *yesNumber = [[NSNumber alloc] initWithBool:YES];
        *preferences =
            [[NSDictionary alloc] initWithObjectsAndKeys:yesNumber,
                                                         @"kEnabledLongPress",
                                                         yesNumber,
                                                         @"kJitter",
                                                         nil];

        [yesNumber release];
    }
}

static void LoadPreferences() {
    NSDictionary *preferences = nil;
    InitializePreferences(&preferences);

    SearchDeleteTweak *tweak = [SearchDeleteTweak sharedInstance];
    SearchDeleteLogFormat(@"Loaded preferences: %@, old: %@",
                            preferences,
                            [tweak preferences]);
                              
    [tweak setPreferences:preferences];
}

static CFStringRef preferencesChangedNotificationString =
    (__bridge CFStringRef)@"iNoahDevSearchDeletePreferencesChangedNotification";

@implementation SearchDeleteTweak
+ (instancetype)sharedInstance {
    static SearchDeleteTweak *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[SearchDeleteTweak alloc] init];

        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            NULL,
            (CFNotificationCallback)LoadPreferences,
            preferencesChangedNotificationString,
            NULL,
            CFNotificationSuspensionBehaviorDeliverImmediately);
    });

    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _currentJitteringCell = nil;
    
#ifdef DEBUG
        logFile = fopen("/User/SearchDelete_Logs.txt", "w");
#endif

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

#ifdef DEBUG
- (void)logString:(NSString *)string {
    if (logFile) {
        fprintf(logFile, "%s\n", [string UTF8String]);
        fflush(logFile);
    }
}
#endif

- (void)dealloc {
    [_preferences release];
    [super dealloc];
}
@end
