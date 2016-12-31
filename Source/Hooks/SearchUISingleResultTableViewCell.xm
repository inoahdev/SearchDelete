//
//  Source/Hooks/SearchUISingleResultTableViewCell.xm
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 inoahdev. All rights reserved.
//

#include "../Headers/SpringBoard/SBIconController.h"
#include "../Headers/SpringBoard/SBIconModel.h"
#include "../Headers/SpringBoard/SBIconViewMap.h"

#include "../Headers/Theos/Version-Extensions.h"

#include "Global.h"
#include "SFSearchResult.h"
#include "SPSearchResult.h"

#include "SearchUISingleResultTableViewCell.h"

static NSString *const kSearchDeleteJitterTransformAnimationKey = @"kSearchDeleteJitterTransformAnimationKey";
static NSString *const kSearchDeleteJitterPositionAnimationKey = @"kSearchDeleteJitterPositionAnimationKey";

static const char *kSearchDeleteAssossciatedObjectSingleResultTableViewCellIsJitteringKey;

%group Common
%hook SearchUISingleResultTableViewCell
%new
- (void)searchdelete_longPressGestureRecognizer:(UILongPressGestureRecognizer *)recognizer {
    SearchDeleteTweak *searchDelete = [SearchDeleteTweak sharedInstance];
    if (recognizer.state != UIGestureRecognizerStateBegan || ![searchDelete isEnabled]) {
        return;
    }

    id result = self.result;
    if (![result searchdelete_allowsUninstall]) {
        return;
    }

    SBIconController *iconController = [%c(SBIconController) sharedInstance];
    SBIconModel *model = MSHookIvar<SBIconModel *>(iconController, "_iconModel");

    if (!model) {
        return;
    }

    SBIconViewMap *homescreenMap = nil;
    if ([iconController respondsToSelector:@selector(homescreenIconViewMap)]) {
        homescreenMap = [iconController homescreenIconViewMap];
    } else if ([%c(SBIconViewMap) respondsToSelector:@selector(homescreenMap)]) {
        homescreenMap = [%c(SBIconViewMap) homescreenMap];
    } else {
        return;
    }

    SBIcon *icon = [model expectedIconForDisplayIdentifier:[self searchdelete_applicationBundleIdentifier]];
    if (!icon) {
        return;
    }

    SBIconView *iconView = [homescreenMap mappedIconViewForIcon:icon];
    if (!iconView) {
        iconView = [homescreenMap iconViewForIcon:icon];
        if (!iconView) {
            return;
        }
    }

    //add animations
    if ([searchDelete shouldJitter]) {
        [self searchdelete_startJittering];
    }

    [iconController iconCloseBoxTapped:iconView];
}

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

    objc_setAssociatedObject(self, &kSearchDeleteAssossciatedObjectSingleResultTableViewCellIsJitteringKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (BOOL)searchdelete_isJittering {
    return ([objc_getAssociatedObject(self, &kSearchDeleteAssossciatedObjectSingleResultTableViewCellIsJitteringKey) boolValue]);
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

    objc_setAssociatedObject(self, &kSearchDeleteAssossciatedObjectSingleResultTableViewCellIsJitteringKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

    if (![searchDelete isEnabled] || ![result isKindOfClass:%c(SFSearchResult)]) {
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
- (NSString *)searchdelete_applicationBundleIdentifier {
    return [self.result applicationBundleIdentifier];
}

%new
- (CALayer *)searchdelete_iconImageViewLayer {
    return [self.thumbnailView imageView].layer;
}

%end
%end

%group iOS9
%hook SearchUISingleResultTableViewCell
- (void)layoutSubviews {
    %orig();

    SearchDeleteTweak *searchDelete = [SearchDeleteTweak sharedInstance];
    SPSearchResult *result = self.result;

    if (![searchDelete isEnabled] || ![result isKindOfClass:%c(SPSearchResult)]) {
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

    if (IS_IOS_BETWEEN(iOS_10, iOS_10_1_1)) {
        %init(iOS10);
    } else if (IS_IOS_BETWEEN(iOS_9_0, iOS_9_3)) {
        %init(iOS9);
    }
}
