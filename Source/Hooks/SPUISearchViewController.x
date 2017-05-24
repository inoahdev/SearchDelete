//
//  Source/Hooks/SPUISearchViewController.xm
//  SearchDelete
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#import <version.h>

#import "../Classes/SearchDeleteTweak.h"
#import "../Headers/FrontBoardServices/FBSSystemService.h"
#import "../Headers/SpringBoardServices/SBSRelaunchAction.h"

#import "SearchUISingleResultTableViewCell.h"
#import "SPUISearchViewController.h"

%group Common
%hook SPUISearchViewController
%new
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [alertView cancelButtonIndex]) {
		FBSSystemService *systemService = [FBSSystemService sharedService];
		SBSRelaunchAction *relaunchAction = [SBSRelaunchAction actionWithReason:@"RestartRenderServer"
																		options:SBSRelaunchOptionTransitionWithFadeToBlack
																	  targetURL:nil];

		[systemService sendActions:[NSSet setWithObject:relaunchAction] withResult:nil];
	} else {
		[self searchdelete_reload];
	}

	[[SearchDeleteTweak sharedInstance].currentJitteringCell searchdelete_stopJittering];
}
%end
%end

%group iOS10
%hook SPUISearchViewController
%new
- (void)searchdelete_reload {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		NSString *searchText = [[self searchHeader] searchField].text;
		SPSearchQueryContext *queryContext = [%c(SPSearchQueryContext) queryContextWithSearchString:searchText];

		queryContext.forceQueryEvenIfSame = YES;
		[self queryContextDidChange:queryContext allowZKW:YES];
	});
}
%end
%end

%group iOS9
%hook SPUISearchViewController
%new
- (void)searchdelete_reload {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[self _searchFieldEditingChanged];
	});
}
%end
%end

%ctor {
	%init(Common);

	if (IS_IOS_BETWEEN(iOS_10_0, iOS_10_2)) {
		%init(iOS10);
	} else if (IS_IOS_BETWEEN(iOS_9_0, iOS_9_3)) {
		%init(iOS9);
	}
}
