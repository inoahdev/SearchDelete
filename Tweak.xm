#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <substrate.h>

#import "Interfaces.h"

#define kiOS7 (kCFCoreFoundationVersionNumber >= 847.20 && kCFCoreFoundationVersionNumber <= 847.27)
#define kiOS8 (kCFCoreFoundationVersionNumber >= 1140.10 && kCFCoreFoundationVersionNumber >= 1145.15)
#define kiOS9 (kCFCoreFoundationVersionNumber == 1240.10)

#define SBLocalizedString(key) [[NSBundle mainBundle] localizedStringForKey:key value:@"None" table:@"SpringBoard"]
#define SDDebugLog(FORMAT, ...) NSLog(@"[SearchDelete: %s - %i] %@", __FILE__, __LINE__, [NSString stringWithFormat:FORMAT, ##__VA_ARGS__])

static NSString *const kSearchDeleteJitterTransformAnimationKey = @"kSearchDeleteJitterTransformAnimationKey";
static NSString *const kSearchDeleteJitterPositionAnimationKey = @"kSearchDeleteJitterPositionAnimationKey";
static SearchUISingleResultTableViewCell *currentJitteringCell = nil;

static const char *kSearchDeleteAssossciatedObjectSingleResultTableViewCellIsJitteringKey;

static NSDictionary *prefs = nil;
static CFStringRef applicationID = CFSTR("com.noahdev.searchdelete");

static void LoadPreferences() {
    if (CFPreferencesAppSynchronize(applicationID)) { //sharedRoutine - MSGAutoSave8
        CFArrayRef keyList = CFPreferencesCopyKeyList(applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) ?: CFArrayCreate(NULL, NULL, 0, NULL);
        if (access("/var/mobile/Library/Preferences/com.noahdev.searchdelete", F_OK) != -1) {
            prefs = (__bridge NSDictionary *)CFPreferencesCopyMultiple(keyList, applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        } else { //register defaults for first launch
            prefs = @{@"kEnabledLongPress" : @YES,
                      @"kJitter" : @YES};
        }

        CFRelease(keyList);
    }
}

%group iOS9
%hook SBDeleteIconAlertItem
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    %orig();

    if (!currentJitteringCell) {
        return;
    }

    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];

    if ([buttonTitle isEqualToString:SBLocalizedString(@"DELETE_ICON_CONFIRM")]) {
        if ([currentJitteringCell.result isSystemApplication]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Respring"
                                                            message:@"A respring is required to fully delete System Applications. Until you respring, a non-functioning icon will exist on SpringBoard and Spotlight will still show results for the Application. Do you want to respring now?"
                                                           delegate:[%c(SPUISearchViewController) sharedInstance]
                                                  cancelButtonTitle:@"Later"
                                                  otherButtonTitles:@"Respring", nil];
            [alert show];
        } else {
            [[%c(SPUISearchViewController) sharedInstance] searchdelete_reload];
        }
    }

    [currentJitteringCell searchdelete_stopJittering];
}
%end
%hook SearchUISingleResultTableViewCell
- (void)layoutSubviews {
    %orig();

    if (![prefs[@"kEnabledLongPress"] boolValue] || ![self.result isKindOfClass:%c(SPSearchResult)]) {
        return;
    }

    if (![self.result searchdelete_allowsUninstall]) {
        return;
    }

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(searchdelete_longPressGestureRecognizer:)];
    longPress.minimumPressDuration = 0.5; //TODO: find system default
    longPress.cancelsTouchesInView = YES;

    if (![self.gestureRecognizers containsObject:longPress]) {
        [self addGestureRecognizer:longPress];
    }
}

%new
- (void)searchdelete_longPressGestureRecognizer:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state != UIGestureRecognizerStateBegan || ![prefs[@"kEnabledLongPress"] boolValue]) {
        return;
    }

    if (![self.result searchdelete_allowsUninstall]) {
        return;
    }

    SBIconModel *model = (SBIconModel *)[[%c(SBIconController) sharedInstance] model];
    SBIcon *icon = [model expectedIconForDisplayIdentifier:self.result.bundleID];

    SBIconView *iconView = [[%c(SBIconViewMap) homescreenMap] iconViewForIcon:icon];
    [[%c(SBIconController) sharedInstance] iconCloseBoxTapped:iconView]; //Have CyDelete record identifier

    //add animations
    if ([prefs[@"kJitter"] boolValue]) {
        [self searchdelete_startJittering];
    }
}

%new
- (void)searchdelete_startJittering {
    currentJitteringCell = self;

    if (![self.thumbnailContainer.layer animationForKey:kSearchDeleteJitterTransformAnimationKey]) {
        [self.thumbnailContainer.layer addAnimation:[%c(SBIconView) _jitterTransformAnimation] forKey:kSearchDeleteJitterTransformAnimationKey];
    }

    if (![self.thumbnailContainer.layer animationForKey:kSearchDeleteJitterPositionAnimationKey]) {
        [self.thumbnailContainer.layer addAnimation:[%c(SBIconView) _jitterPositionAnimation] forKey:kSearchDeleteJitterPositionAnimationKey];
    }

    objc_setAssociatedObject(self, &kSearchDeleteAssossciatedObjectSingleResultTableViewCellIsJitteringKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (BOOL)searchdelete_isJittering {
    return ([objc_getAssociatedObject(self, &kSearchDeleteAssossciatedObjectSingleResultTableViewCellIsJitteringKey) boolValue]);
}

%new
- (void)searchdelete_stopJittering {
    if ([self.thumbnailContainer.layer animationForKey:kSearchDeleteJitterTransformAnimationKey]) {
        [self.thumbnailContainer.layer removeAnimationForKey:kSearchDeleteJitterTransformAnimationKey];
    }

    if ([self.thumbnailContainer.layer animationForKey:kSearchDeleteJitterPositionAnimationKey]) {
        [self.thumbnailContainer.layer removeAnimationForKey:kSearchDeleteJitterPositionAnimationKey];
    }

    objc_setAssociatedObject(self, &kSearchDeleteAssossciatedObjectSingleResultTableViewCellIsJitteringKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
%end

%hook SPSearchResult
%new
- (BOOL)isApplication {
    if (!self.bundleID || self.section_header) {
        return NO;
    }

    return ([[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleID] != nil);
}

%new
- (BOOL)isUserApplication {
    if (![self isApplication]) {
        return NO;
    }

    return [[[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleID] iconClass] == %c(SBUserInstalledApplicationIcon);
}

%new
- (BOOL)isSystemApplication {
    if (![self isApplication]) {
        return NO;
    }

    return ([[[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleID] isSystemApplication]);
}

%new
- (BOOL)searchdelete_allowsUninstall {
    if (![self isApplication]) {
        return NO;
    }

    SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleID];
    SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:application];

    if (![icon allowsUninstall]) { //support the Apple Store app with a 'com.apple.' bundleID which is broken by CyDelete
        return [application iconAllowsUninstall:icon];
    }

    return [icon allowsUninstall];
}
%end

%hook SPUISearchViewController
%new
- (BOOL)isActivated {
    if (NSNumber *activated = [self valueForKeyPath:@"_activated"]) {
        return [activated boolValue];
    }

    return NO;
}

%new
- (void)searchdelete_reload {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self _searchFieldEditingChanged];
    });
}

%new
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:index];

    if ([buttonTitle isEqualToString:@"Respring"]) {
        [(SpringBoard *)[UIApplication sharedApplication] _relaunchSpringBoardNow];
    } else if ([buttonTitle isEqualToString:@"Later"]) {
        [self searchdelete_reload];
    }
}
%end
%end

%group iOS8 //TODO:
%end

%group iOS7 //TODO:
%end

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    (CFNotificationCallback)LoadPreferences,
                                    CFSTR("NoahDevSearchDeletePreferencesChangedNotification"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    LoadPreferences();

    if (kiOS9)
        %init(iOS9);
    if (kiOS8)
        %init(iOS8);
    if (kiOS7)
        %init(iOS7)
}
