#include "../Headers/FrontBoard/FBSystemService.h"
#include "SearchDeleteRootListController.h"

@implementation SearchDeleteRootListController
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"SearchDelete" target:self] retain];
	}

	return _specifiers;
}

- (void)openURL:(NSURL *)url {
	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Wdeprecated-declarations"

	UIApplication *application = [UIApplication sharedApplication];
	if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
		[application openURL:url options:@{} completionHandler:nil];
	} else {
		[application openURL:url];
	}

	#pragma clang diagnostic pop
}

- (void)twitter {
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		[self openURL:[NSURL URLWithString:@"tweetbot:///user_profile/inoahdev"]];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
		[self openURL:[NSURL URLWithString:@"twitterrific://user?screen_name=inoahdev"]];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[self openURL:[NSURL URLWithString:@"twitter://user?screen_name=inoahdev"]];
	} else {
		[self openURL:[NSURL URLWithString:@"https://mobile.twitter.com/inoahdev"]];
	}
}

- (void)github {
    [self openURL:[NSURL URLWithString:@"https://github.com/inoahdev/SearchDelete"]];
    [self openURL:[NSURL URLWithString:@"https://github.com/inoahdev/SearchDelete"]];
}
@end
