//
//  Source/Hooks/_SBAlertController.xm
//
//  Created by inoahdev on 12/26/16
//  Copyright © 2016 inoahdev. All rights reserved.
//

#import "../Headers/SpotlightUI/SPUISearchModel.h"
#import "../Headers/UIKit/UIAlertAction.h"
#import "../Headers/Theos/Version-Extensions.h"

#import "_SBAlertController.h"

#import "Global.h"
#import "SearchUISingleResultTableViewCell.h"
#import "SFSearchResult.h"
#import "SPUISearchViewController.h"

#define SBLocalizedString(key) [[NSBundle mainBundle] localizedStringForKey:key value:@"None" table:@"SpringBoard"]

%group iOS10
%hook _SBAlertController
- (void)addAction:(UIAlertAction *)action {
    if (![[self alertItem] isKindOfClass:%c(SBDeleteIconAlertItem)] || ![SearchDeleteTweak sharedInstance].currentJitteringCell) {
        return %orig();
    }

    SearchDeleteTweak *searchDelete = [SearchDeleteTweak sharedInstance];

    __block UIAlertActionHandler actionHandler = [action handler];
    UIAlertActionStyle actionStyle = [action style];

    if (actionStyle == UIAlertActionStyleCancel) {
        [actionHandler retain];

        action.handler = ^(UIAlertAction *action) {
            actionHandler(action);
            [actionHandler release];

            [searchDelete.currentJitteringCell searchdelete_stopJittering];
        };
    } else if (actionStyle == UIAlertActionStyleDestructive || [action.title isEqualToString:SBLocalizedString(@"DELETE_ICON_CONFIRM")]) {
        [actionHandler retain];

        action.handler = ^(UIAlertAction *action) {
            actionHandler(action);
            [actionHandler release];

            SearchUISingleResultTableViewCell *cell = [searchDelete currentJitteringCell];
            SFSearchResult *result = (SFSearchResult *)cell.result;

            SPUISearchViewController *searchViewController = [[%c(SPUISearchModel) sharedInstance] delegate];
            if ([result searchdelete_isSystemApplication] && ![[result searchdelete_applicationBundleIdentifier] hasPrefix:@"com.apple"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Respring"
                                                                message:@"A respring is required to fully delete System Applications. Until you respring, a non-functioning icon will exist on SpringBoard and Spotlight will still show results for the Application. Do you want to respring now?"
                                                               delegate:searchViewController
                                                      cancelButtonTitle:@"Later"
                                                      otherButtonTitles:@"Respring", nil];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert show];
                });
            } else {
                [cell searchdelete_stopJittering];
                [searchViewController searchdelete_reload];
            }
        };
    }

    %orig();
}
%end
%end

%ctor {
    if (IS_IOS_BETWEEN(iOS_10, iOS_10_1_1)) {
        %init(iOS10);
    }
}
