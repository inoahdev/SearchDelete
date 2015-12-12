#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <substrate.h>
#import <dlfcn.h>

#import "Interfaces.h"

#define kiOS7 (kCFCoreFoundationVersionNumber >= 847.20 && kCFCoreFoundationVersionNumber <= 847.27)
#define kiOS8 (kCFCoreFoundationVersionNumber >= 1140.10 && kCFCoreFoundationVersionNumber >= 1145.15)
#define kiOS9 (kCFCoreFoundationVersionNumber == 1240.10)

static NSString *const kSearchDeleteJitterTransformAnimationKey = @"kSearchDeleteJitterTransformAnimationKey";
static NSString *const kSearchDeleteJitterPositionAnimationKey = @"kSearchDeleteJitterPositionAnimationKey";

static const char *kSearchDeleteAssossciatedObjectSingleResultTableViewCellIsJitteringKey;
static const char *kSearchDeleteAssossciatedObjectSearchUITableViewDeleteIconAlertItemKey;

static NSDictionary *prefs = nil;
static CFStringRef applicationID = CFSTR("com.noahdev.searchdelete");

#define SDDebugLog(FORMAT, ...) NSLog(@"[SearchDelete: %s - %i] %@", __FILE__, __LINE__, [NSString stringWithFormat:FORMAT, ##__VA_ARGS__])

static void LoadPreferences() {
    if (CFPreferencesAppSynchronize(applicationID)) { //sharedRoutine - MSGAutoSave8
        CFArrayRef keyList = CFPreferencesCopyKeyList(applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) ?: CFArrayCreate(NULL, NULL, 0, NULL);
        prefs = (__bridge NSDictionary *)CFPreferencesCopyMultiple(keyList, applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

        CFRelease(keyList);
    }
}

%group iOS9
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
                                                                                            action:@selector(searchDelete_longPressGestureRecognizer:)];
    longPress.minimumPressDuration = 0.5; //TODO:find system default
    longPress.cancelsTouchesInView = YES;

    if (![self.gestureRecognizers containsObject:longPress]) {
        [self addGestureRecognizer:longPress];
    }
}

%new
- (void)searchDelete_longPressGestureRecognizer:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state != UIGestureRecognizerStateBegan || ![prefs[@"kEnabledLongPress"] boolValue]) {
        return;
    }

    if (![self.result searchdelete_allowsUninstall]) {
        return;
    }


    SBIconModel *model = (SBIconModel *)[[%c(SBIconController) sharedInstance] model];
    SBIcon *icon = [model expectedIconForDisplayIdentifier:self.result.bundleID];

    if ([self.result isSystemApplication]) { //Use CyDelete
        [[%c(SBIconController) sharedInstance] iconCloseBoxTapped:icon]; //Have CyDelete record identifier before activating alert
    }

    SBDeleteIconAlertItem *alertItem = [[[%c(SBDeleteIconAlertItem) alloc] initWithIcon:icon] autorelease];
    [[%c(SBAlertItemsController) sharedInstance] activateAlertItem:alertItem];

    objc_setAssociatedObject([%c(SPUISearchViewController) sharedInstance], &kSearchDeleteAssossciatedObjectSearchUITableViewDeleteIconAlertItemKey, alertItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    //add animations
    if ([prefs[@"kJitter"] boolValue]) {
        [self searchdelete_startJittering];
    }
}

%new
- (void)searchdelete_startJittering {
    [self.thumbnailContainer.layer addAnimation:[%c(SBIconView) _jitterTransformAnimation] forKey:kSearchDeleteJitterTransformAnimationKey];
    [self.thumbnailContainer.layer addAnimation:[%c(SBIconView) _jitterPositionAnimation] forKey:kSearchDeleteJitterPositionAnimationKey];

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

    if ([self.textAreaView.layer animationForKey:kSearchDeleteJitterTransformAnimationKey]) {
        [self.textAreaView.layer removeAnimationForKey:kSearchDeleteJitterTransformAnimationKey];
    }

    if ([self.textAreaView.layer animationForKey:kSearchDeleteJitterPositionAnimationKey]) {
        [self.textAreaView.layer removeAnimationForKey:kSearchDeleteJitterPositionAnimationKey];
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

    SBApplication *application = [[[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleID] retain];
    SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:application];

    if (![icon isKindOfClass:%c(SBApplicationIcon)]) {
        return NO;
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
%end

//ugly implementation
%hook UIAlertController
- (void)_dismissAnimated:(BOOL)animated triggeringAction:(UIAlertAction *)action triggeredByPopoverDimmingView:(BOOL)dimmingView {
    %orig();

    if (self != [(SBDeleteIconAlertItem *)objc_getAssociatedObject([%c(SPUISearchViewController) sharedInstance], &kSearchDeleteAssossciatedObjectSearchUITableViewDeleteIconAlertItemKey) alertController]) {
        return;
    }

    if (![[%c(SPUISearchViewController) sharedInstance] isActivated] || ![prefs[@"kEnabledLongPress"] boolValue] || ![prefs[@"kJitter"] boolValue]) {
        return;
    }

    UITableView *tableView = MSHookIvar<UITableView *>([%c(SPUISearchViewController) sharedInstance], "_tableView");
    if (!tableView) {
        return;
    }

    if (self._cancelAction != action) {
        return;
    }

    for (NSInteger j = 0; j < [tableView numberOfSections]; j++) {
        for (NSInteger i = 0; i < [tableView numberOfRowsInSection:j]; i++) {
            SearchUISingleResultTableViewCell *cell = (SearchUISingleResultTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];

            if (![cell isKindOfClass:%c(SearchUISingleResultTableViewCell)]) {
                continue;
            }

            SearchUISingleResultTableViewCell *tableViewCell = (SearchUISingleResultTableViewCell *)cell;

            if (![tableViewCell searchdelete_isJittering]) {
                continue;
            }

            [tableViewCell searchdelete_stopJittering];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [[%c(SPUISearchViewController) sharedInstance] performSelector:@selector(_searchFieldEditingChanged)];
            });
        }
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
