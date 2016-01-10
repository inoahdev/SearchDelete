#include "SearchDeleteRootListController.h"

@interface UIApplication ()
- (void)suspend;
@end

@implementation SearchDeleteRootListController
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"SearchDelete" target:self] retain];
	}

	return _specifiers;
}

- (void)respring {
    [[UIApplication sharedApplication] suspend];
    usleep(515000);

    [(SpringBoard *)[UIApplication sharedApplication] _relaunchSpringBoardNow];
}

- (void)twitter {
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:@"iNoahDev"]]];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific://user?screen_name=" stringByAppendingString:@"iNoahDev"]]];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:@"iNoahDev"]]];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:@"iNoahDev"]]];
	}
}

- (void)github {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/iNoahDev/SearchDelete"]];
}
@end
