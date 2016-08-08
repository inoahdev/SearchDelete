#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>
#import <version.h>

#import "Interfaces.h"

#define SBLocalizedString(key) [[NSBundle mainBundle] localizedStringForKey:key value:@"None" table:@"SpringBoard"]
#define SDDebugLog(FORMAT, ...) NSLog(@"[SearchDelete: %s - %i] %@", __FILE__, __LINE__, [NSString stringWithFormat:@(FORMAT), ##__VA_ARGS__])

static NSString *const kSearchDeleteJitterTransformAnimationKey = @"kSearchDeleteJitterTransformAnimationKey";
static NSString *const kSearchDeleteJitterPositionAnimationKey = @"kSearchDeleteJitterPositionAnimationKey";

static SearchUISingleResultTableViewCell *currentJitteringCell = nil;
static const char *kSearchDeleteAssossciatedObjectSingleResultTableViewCellIsJitteringKey;

static NSDictionary *prefs = nil;

static void LoadPreferences() {
    CFStringRef applicationID = CFStringCreateWithCString(CFAllocatorGetDefault(), "com.inoahdev.searchdelete", kCFStringEncodingUTF8);

    if (CFPreferencesAppSynchronize(applicationID)) { //sharedRoutine - MSGAutoSave8
        if (access("/var/mobile/Library/Preferences/com.inoahdev.searchdelete", F_OK) != -1) {
            CFArrayRef keyList = CFPreferencesCopyKeyList(applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) ?: CFArrayCreate(NULL, NULL, 0, NULL);
            prefs = (__bridge NSDictionary *)CFPreferencesCopyMultiple(keyList, applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

            CFRelease(keyList);
        } else { //register defaults for first launch
            prefs = @{@"kEnabledLongPress" : @YES,
                      @"kJitter" : @YES};
        }
    }
}

%group iOS9
%hook SBDeleteIconAlertItem
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    %orig();

    if (!currentJitteringCell) {
        return;
    }

    if (![currentJitteringCell searchdelete_isJittering]) {
        return;
    }

    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];

    if ([buttonTitle isEqualToString:SBLocalizedString(@"DELETE_ICON_CONFIRM")]) {
        if ([currentJitteringCell.result searchdelete_isSystemApplication]) {
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

    SBIconController *iconController = [%c(SBIconController) sharedInstance];

    SBIconModel *model = (SBIconModel *)[iconController model];
    SBIcon *icon = [model expectedIconForDisplayIdentifier:self.result.bundleID];

    SBIconViewMap *homescreenMap = NULL;

    if ([iconController respondsToSelector:@selector(homescreenMap)]) {
        homescreenMap = [iconController homescreenMap];
    } else if ([%c(SBIconViewMap) respondsToSelector:@selector(homescreenMap)]) {
        homescreenMap = [%c(SBIconViewMap) homescreenMap];
    } else {
        //safety
        return;
    }

    SBIconView *iconView = [homescreenMap mappedIconViewForIcon:icon];
    if (!iconView) {
        iconView = [homescreenMap iconViewForIcon:icon]; //create SBIconView, but only when one is not readily available
        if (!iconView) {
            return;
        }
    }

    [[%c(SBIconController) sharedInstance] iconCloseBoxTapped:iconView];

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
- (BOOL)searchdelete_isApplication {
    if (!self.bundleID || self.section_header) {
        return NO;
    }

    return ([[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleID] != nil);
}

%new
- (BOOL)searchdelete_isSystemApplication {
    if (![self searchdelete_isApplication]) {
        return NO;
    }

    SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleID];
    return [application isSystemApplication];
}

%new
- (BOOL)searchdelete_allowsUninstall {
    if (![self searchdelete_isApplication]) {
        return NO;
    }

    SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleID];
    SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:application];

    if ([icon respondsToSelector:@selector(allowsUninstall)]) {
        BOOL allowsUninstall = [icon allowsUninstall]; //support the Apple Store app with a 'com.apple.' bundleID which is broken by CyDelete
        if (!allowsUninstall && [application respondsToSelector:@selector(iconAllowsUninstall:)]) {
            return [application iconAllowsUninstall:icon];
        }

        return allowsUninstall;
    } else if ([application respondsToSelector:@selector(isUninstallAllowed)]) {
        return [application isUninstallAllowed];
    }

    return false;
}
%end

%hook SPUISearchViewController
%new
- (BOOL)isActivated {
    if (NSNumber *activated = MSHookIvar<NSNumber *>(self, "_activated")) {
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
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        FBSSystemService *systemService = [%c(FBSSystemService) sharedService];
        NSSet *actions = [NSSet setWithObject:[%c(SBSRelaunchAction) actionWithReason:@"RestartRenderServer" options:(1 << 2) targetURL:nil]];

        [systemService sendActions:actions withResult:nil];
    } else {
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
                                    CFSTR("iNoahDevSearchDeletePreferencesChangedNotification"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    LoadPreferences();

    if (IS_IOS_BETWEEN(iOS_9_0, iOS_9_3_3))
        %init(iOS9);
    if (IS_IOS_BETWEEN(iOS_8_0, iOS_8_4))
        %init(iOS8);
    if (IS_IOS_BETWEEN(iOS_7_0, iOS_7_1))
        %init(iOS7)
}
