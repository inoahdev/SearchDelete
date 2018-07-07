//
//  Source/Hooks/SearchUISingleResultTableViewCell.xm
//  SearchDelete
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#import <version.h>
#import "../Classes/SearchDeleteTweak.h"

#import "../Headers/SpringBoard/SBIconController.h"
#import "../Headers/SpringBoard/SBIconModel.h"
#import "../Headers/SpringBoard/SBIconViewMap.h"

#import "SFSearchResult.h"
#import "SPSearchResult.h"

#import "SearchUISingleResultTableViewCell.h"

static NSString *const kSearchDeleteJitterTransformAnimationKey = @"kSearchDeleteJitterTransformAnimationKey";
static NSString *const kSearchDeleteJitterPositionAnimationKey = @"kSearchDeleteJitterPositionAnimationKey";

static const double kSearchDeleteLongPressDelayTime = 0.75;
static const char *kSearchDeleteAssociatedObjectSingleResultTableViewCellIsJitteringKey;

%group Common
%hook SearchUISingleResultTableViewCell
%new
- (void)searchdelete_startJittering {
    [[SearchDeleteTweak sharedInstance] setCurrentJitteringCell:self];

    CALayer *iconImageLayer = [self searchdelete_iconImageViewLayer];
    if (![iconImageLayer animationForKey:kSearchDeleteJitterTransformAnimationKey]) {
        [iconImageLayer addAnimation:[%c(SBIconView) _jitterTransformAnimation] forKey:kSearchDeleteJitterTransformAnimationKey];
    }

    if (![iconImageLayer animationForKey:kSearchDeleteJitterPositionAnimationKey]) {
        [iconImageLayer addAnimation:[%c(SBIconView) _jitterPositionAnimation] forKey:kSearchDeleteJitterPositionAnimationKey];
    }

    objc_setAssociatedObject(self, &kSearchDeleteAssociatedObjectSingleResultTableViewCellIsJitteringKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (BOOL)searchdelete_isJittering {
    return ([objc_getAssociatedObject(self, &kSearchDeleteAssociatedObjectSingleResultTableViewCellIsJitteringKey) boolValue]);
}

%new
- (void)searchdelete_stopJittering {
    CALayer *iconImageLayer = [self searchdelete_iconImageViewLayer];
    if ([iconImageLayer animationForKey:kSearchDeleteJitterTransformAnimationKey]) {
        [iconImageLayer removeAnimationForKey:kSearchDeleteJitterTransformAnimationKey];
    }

    if ([iconImageLayer animationForKey:kSearchDeleteJitterPositionAnimationKey]) {
        [iconImageLayer removeAnimationForKey:kSearchDeleteJitterPositionAnimationKey];
    }

    objc_setAssociatedObject(self, &kSearchDeleteAssociatedObjectSingleResultTableViewCellIsJitteringKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [[SearchDeleteTweak sharedInstance] setCurrentJitteringCell:nil];
}

%end
%end

%group iOS10
%hook SearchUISingleResultTableViewCell
- (void)layoutSubviews {
    %orig();

    SearchDeleteTweak *searchDelete = [SearchDeleteTweak sharedInstance];
    SFSearchResult *result = self.result;

    if (![searchDelete isEnabled]) {
        SearchDeleteLog(@"SearchDelete is not enabled");
        return;
    }

    if (![result isKindOfClass:%c(SFSearchResult)]) {
        SearchDeleteLog(@"Cell is not a SFSearchResult");
        return;
    }

    if (![result searchdelete_allowsUninstall]) {
        SearchDeleteLog(@"Cell does not allow uninstall")
        return;
    }

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(searchdelete_longPressGestureRecognizer:)];
    longPress.minimumPressDuration = kSearchDeleteLongPressDelayTime;
    longPress.cancelsTouchesInView = YES;

    if (![self.gestureRecognizers containsObject:longPress]) {
        [self addGestureRecognizer:longPress];
    }
}

%new
- (NSString *)searchdelete_applicationBundleIdentifier {
    return [self.result applicationBundleIdentifier];
}

%new
- (CALayer *)searchdelete_iconImageViewLayer {
    return [self.thumbnailView imageView].layer;
}

%end
%end

%group iOS9_3Plus
%hook SearchUISingleResultTableViewCell
%new
- (void)searchdelete_longPressGestureRecognizer:(UILongPressGestureRecognizer *)recognizer {
    SearchDeleteTweak *searchDelete = [SearchDeleteTweak sharedInstance];
    if (![searchDelete isEnabled]) {
        SearchDeleteLog(@"SearchDelete is not enabled")
        return;
    }

    if (recognizer.state != UIGestureRecognizerStateBegan) {
        SearchDeleteLog(@"Recognizer is not in its begin state");
        return;
    }

    id result = self.result;
    if (![result searchdelete_allowsUninstall]) {
        SearchDeleteLog(@"Cell does not allow uninstall")
        return;
    }

    SBIconController *iconController = [%c(SBIconController) sharedInstance];
    SBIconModel *model = MSHookIvar<SBIconModel *>(iconController, "_iconModel");

    if (!model) {
        return;
    }

    SBIconViewMap *homescreenMap = [iconController homescreenIconViewMap];
    if (!homescreenMap) {
        SearchDeleteLog(@"homescreenMap is nil")
        return;
    }

    NSString *bundleIdentifier = [self searchdelete_applicationBundleIdentifier];
    if (!bundleIdentifier) {
        SearchDeleteLog(@"cell's bundleIdentifier is nil");
        return;
    }

    SBIcon *icon = [model expectedIconForDisplayIdentifier:bundleIdentifier];
    if (!icon) {
        SearchDeleteLogFormat(@"An SBIcon for bundleIdentifier %@ is nil", bundleIdentifier);
        return;
    }

    SBIconView *iconView = [homescreenMap iconViewForIcon:icon];
    if (!iconView) {
        SearchDeleteLogFormat(@"iconView for SBIcon for bundleIdentifier %@ is nil", bundleIdentifier);
        return;
    }

    //add animations
    if ([searchDelete shouldJitter]) {
        [self searchdelete_startJittering];
    }

    [iconController iconCloseBoxTapped:iconView];
}
%end
%end

%group iOS9_2Down
%hook SearchUISingleResultTableViewCell
%new
- (void)searchdelete_longPressGestureRecognizer:(UILongPressGestureRecognizer *)recognizer {
    SearchDeleteTweak *searchDelete = [SearchDeleteTweak sharedInstance];
    if (![searchDelete isEnabled]) {
        SearchDeleteLog(@"SearchDelete is not enabled")
        return;
    }

    if (recognizer.state != UIGestureRecognizerStateBegan) {
        SearchDeleteLog(@"SearchDelete is not enabled")
        return;
    }

    id result = self.result;
    if (![result searchdelete_allowsUninstall]) {
        SearchDeleteLog(@"Cell does not allow uninstall")
        return;
    }

    SBIconController *iconController = [%c(SBIconController) sharedInstance];
    SBIconModel *model = MSHookIvar<SBIconModel *>(iconController, "_iconModel");

    if (!model) {
        SearchDeleteLog(@"SBIconModel of SBIconController is nil");
        return;
    }

    SBIconViewMap *homescreenMap = [%c(SBIconViewMap) homescreenMap];
    if (!homescreenMap) {
        SearchDeleteLog(@"homescreenMap is nil");
        return;
    }

    NSString *bundleIdentifier = [self searchdelete_applicationBundleIdentifier];
    if (!bundleIdentifier) {
        SearchDeleteLog(@"Cel''s bundleIdentifier is nil");
        return;
    }

    SBIcon *icon = [model expectedIconForDisplayIdentifier:bundleIdentifier];
    if (!icon) {
        SearchDeleteLogFormat(@"icon for bundleIdentifier %@ is nil", bundleIdentifier);
        return;
    }

    SBIconView *iconView = [homescreenMap iconViewForIcon:icon];
    if (!iconView) {
        SearchDeleteLogFormat(@"icon for bundleIdentifier %@ is nil", bundleIdentifier);
        return;
    }

    //add animations
    if ([searchDelete shouldJitter]) {
        [self searchdelete_startJittering];
    }

    [iconController iconCloseBoxTapped:iconView];
}

%end
%end

%group iOS9
%hook SearchUISingleResultTableViewCell
- (void)layoutSubviews {
    %orig();

    SearchDeleteTweak *searchDelete = [SearchDeleteTweak sharedInstance];
    SPSearchResult *result = self.result;

    if (![searchDelete isEnabled]) {
        SearchDeleteLog(@"SearchDelete is not enabled")
        return;
    }

    if (![result isKindOfClass:%c(SPSearchResult)]) {
        SearchDeleteLog(@"Cell is not a SPSearchResult");
        return;
    }

    if (![result searchdelete_allowsUninstall]) {
        SearchDeleteLog(@"Cell does not allow uninstall")
        return;
    }

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(searchdelete_longPressGestureRecognizer:)];
    longPress.minimumPressDuration = kSearchDeleteLongPressDelayTime;
    longPress.cancelsTouchesInView = YES;

    if (![self.gestureRecognizers containsObject:longPress]) {
        [self addGestureRecognizer:longPress];
    }
}

%new
- (NSString *)searchdelete_applicationBundleIdentifier {
    return [self.result bundleID];
}

- (CALayer *)searchdelete_iconImageViewLayer {
    return [self.thumbnailContainer layer];
}
%end
%end

%ctor {
    %init(Common);

    if (IS_IOS_BETWEEN(iOS_9_3, iOS_10_2)) {
        %init(iOS9_3Plus);
    }

    if (IS_IOS_BETWEEN(iOS_10_0, iOS_10_2)) {
        %init(iOS10);
    } else {
        if (IS_IOS_BETWEEN(iOS_9_0, iOS_9_2)) {
            %init(iOS9_2Down);
        }

        %init(iOS9);
    }
}
