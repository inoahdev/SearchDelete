#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <substrate.h>
#import <version.h>

#import "Interfaces.h"

extern "C" id objc_retain(id obj);
extern "C" void objc_release(id obj);

#define SBLocalizedString(key) [[NSBundle mainBundle] localizedStringForKey:key value:@"None" table:@"SpringBoard"]
#define SDDebugLog(FORMAT, ...) NSLog(@"[SearchDelete] %s:%i DEBUG:%@", __FILE__, __LINE__, [NSString stringWithFormat:FORMAT, ##__VA_ARGS__])

static NSString *const kSearchDeleteJitterTransformAnimationKey = @"kSearchDeleteJitterTransformAnimationKey";
static NSString *const kSearchDeleteJitterPositionAnimationKey = @"kSearchDeleteJitterPositionAnimationKey";

static SearchUISingleResultTableViewCell *currentJitteringCell = nil;
static const char *kSearchDeleteAssossciatedObjectSingleResultTableViewCellIsJitteringKey;

static NSDictionary *preferences = nil;
static CFStringRef applicationID = nil;

bool respondsToSelector(Class cls, SEL selector, bool inst = false) {
    if (!cls || !selector) {
        return false;
    }

    if (!inst) {
        return class_getClassMethod(cls, selector);
    }

    return class_getInstanceMethod(cls, selector);
}

bool respondsToSelector(NSObject *inst, SEL selector) {
    if (!inst || !selector) {
        return false;
    }

    return class_getInstanceMethod(object_getClass(inst), selector);
}

static void LoadPreferences() {
    if (!applicationID) {
        applicationID = CFStringCreateWithCString(CFAllocatorGetDefault(), "com.inoahdev.searchdelete", kCFStringEncodingUTF8);
    }

    if (preferences) {
        preferences = nil;
    }

    if (CFPreferencesAppSynchronize(applicationID)) { //sharedRoutine - MSGAutoSave8
        if (access("/private/var/mobile/Library/Preferences/com.inoahdev.searchdelete.plist", F_OK) != -1) {
            CFArrayRef keyList = CFPreferencesCopyKeyList(applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
            if (keyList) {
                preferences = objc_retain((__bridge id)CFPreferencesCopyMultiple(keyList, applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
                CFRelease(keyList);
            }
        }
    }

    if (!preferences) {
        preferences = @{@"kEnabledLongPress" : @YES,
                        @"kJitter"           : @YES};
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

    if (![preferences[@"kEnabledLongPress"] boolValue] || object_getClass(self.result) != %c(SPSearchResult)) {
        return;
    }

    SPSearchResult *result = self.result;

    if (!respondsToSelector(result, @selector(searchdelete_allowsUninstall))) {
        return;
    }

    if (![result searchdelete_allowsUninstall]) {
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
    if (recognizer.state != UIGestureRecognizerStateBegan || ![preferences[@"kEnabledLongPress"] boolValue]) {
        return;
    }

    SPSearchResult *result = self.result;
    if (![result searchdelete_allowsUninstall]) {
        return;
    }

    SBIconController *iconController = [%c(SBIconController) sharedInstance];
    SBIconModel *model = MSHookIvar<SBIconModel *>(iconController, "_iconModel");

    if (!model) {
        return;
    }

    SBIcon *icon = [model expectedIconForDisplayIdentifier:result.bundleID];

    Class _SBIconViewMap = %c(SBIconViewMap);
    if (!_SBIconViewMap) {
        return;
    }

    SBIconViewMap *homescreenMap = nil;

    if (respondsToSelector(iconController, @selector(homescreenMap))) {
        homescreenMap = [iconController homescreenMap];
    } else if (respondsToSelector(_SBIconViewMap, @selector(homescreenMap))) {
        homescreenMap = [_SBIconViewMap homescreenMap];
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

    [iconController iconCloseBoxTapped:iconView];

    //add animations
    if ([preferences[@"kJitter"] boolValue]) {
        [self searchdelete_startJittering];
    }
}

%new
- (void)searchdelete_startJittering {
    currentJitteringCell = self;

    Class _SBIconView = %c(SBIconView);
    if (!_SBIconView) {
        return;
    }

    if (![self.thumbnailContainer.layer animationForKey:kSearchDeleteJitterTransformAnimationKey]) {
        [self.thumbnailContainer.layer addAnimation:[_SBIconView _jitterTransformAnimation] forKey:kSearchDeleteJitterTransformAnimationKey];
    }

    if (![self.thumbnailContainer.layer animationForKey:kSearchDeleteJitterPositionAnimationKey]) {
        [self.thumbnailContainer.layer addAnimation:[_SBIconView _jitterPositionAnimation] forKey:kSearchDeleteJitterPositionAnimationKey];
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
    if (!self.bundleID || self.section_header) {
        return NO;
    }

    SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleID];
    if (!application) {
        return NO;
    }

    SBApplicationInfo *info = MSHookIvar<SBApplicationInfo *>(info, "_appInfo");
    if (!info) {
        return NO;
    }

    return MSHookIvar<bool>(info, "_isSystemApplication");
}

%new
- (BOOL)searchdelete_allowsUninstall {
    if (![self searchdelete_isApplication]) {
        return NO;
    }

    SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleID];
    if (!application) {
        return NO;
    }

    BOOL allowsUninstall = false;

    if (respondsToSelector(application, @selector(isUninstallAllowed))) {
        allowsUninstall = [application performSelectorOnMainThread:@selector(isUninstallAllowed) withObject:nil waitUntilDone:YES];
    }

    if (!allowsUninstall) {
        Class _SBApplicationIcon = %c(SBApplicationIcon);
        if (!respondsToSelector(_SBApplicationIcon, @selector(allowsUninstall), true)){
            SBApplicationIcon *icon = [[_SBApplicationIcon alloc] initWithApplication:application];
            allowsUninstall = [icon allowsUninstall]; //CyDelete hooks this method to allow uninstallation4

            if (!allowsUninstall && respondsToSelector(application, @selector(iconAllowsUninstall:))) {
                allowsUninstall = [application iconAllowsUninstall:icon]; //support the Apple Store app with a 'com.apple.' bundleID which is broken by CyDelete
            }
        }
    }

    return allowsUninstall;
}
%end

%hook SPUISearchViewController
%new
- (BOOL)isActivated {
    if (NSNumber *activated = MSHookIvar<NSNumber *>(self, "_activated")) {
        return [(__bridge NSNumber *)activated boolValue];
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
        Class _FBSystemService = %c(FBSSystemService);
        Class _SBSRelaunchAction = %c(SBSRelaunchAction);

        if (_FBSystemService && _SBSRelaunchAction) {
            FBSSystemService *systemService = [_FBSystemService sharedService];
            NSSet *actions = [NSSet setWithObject:[_SBSRelaunchAction actionWithReason:@"RestartRenderServer" options:(1 << 2) targetURL:nil]];

            [systemService sendActions:actions withResult:nil];
        } else {
            UIApplication *application = [UIApplication sharedApplication];
            if (respondsToSelector(application, @selector(_relaunchSpringboardNow))) {
                [(SpringBoard *)application _relaunchSpringboardNow];
            } else if (respondsToSelector(application, @selector(_tearDownNow))) {
                [(SpringBoard *)application _tearDownNow];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"Unable to respring, as the main respring methods used in SearchDelete are not found. Please send the developer an email containing your iOS Device type, and iOS Version to help fix this issue"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
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
                                    CFStringCreateWithCString(kCFAllocatorDefault, "iNoahDevSearchDeletePreferencesChangedNotification", kCFStringEncodingUTF8),
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

%dtor {
    if (applicationID) {
        CFRelease(applicationID);
    }

    if (preferences) {
        objc_release(preferences);
    }
}
