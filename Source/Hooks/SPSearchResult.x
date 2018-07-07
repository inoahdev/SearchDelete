//
//  Source/Hooks/SPSearchResult.xm
//  SearchDelete
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#import <version.h>

#import "../Classes/SearchDeleteTweak.h"
#import "../Headers/SpringBoard/SBApplicationIcon.h"
#import "../Headers/SpringBoard/SBApplicationController.h"

#import "SPSearchResult.h"

%group iOS9
%hook SPSearchResult
%new
- (BOOL)searchdelete_isApplication {
    if (!self.bundleID || self.section_header) {
        SearchDeleteLogFormat(@"Either self.bundleID doesn't exist? (%@), or self.section_header is not nil (%@)", self.bundleID, self.section_header);
        return NO;
    }

    return ([[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleID] != nil);
}

%new
- (BOOL)searchdelete_isSystemApplication {
    if (!self.bundleID || self.section_header) {
        SearchDeleteLogFormat(@"Either self.bundleID doesn't exist? (%@), or self.section_header is not nil (%@)", self.bundleID, self.section_header);
        return NO;
    }

    SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleID];
    if (!application) {
        SearchDeleteLog(@"Unable to get application");
        return NO;
    }

    SBApplicationInfo *info = [application _appInfo];
    if (!info) {
        SearchDeleteLog(@"Unable to get application-info");
        return NO;
    }

    return [info systemApplication];
}

%new
- (BOOL)searchdelete_allowsUninstall {
    if (!self.bundleID || self.section_header) {
        SearchDeleteLogFormat(@"Either self.bundleID doesn't exist? (%@), or self.section_header is not nil (%@)", self.bundleID, self.section_header);
        return NO;
    }

    NSString *bundleIdentifier = [self bundleID];
    if (!bundleIdentifier) {
        SearchDeleteLog(@"bundleIdentifier is nil");
        return NO;
    }

    SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleIdentifier];
    if (!application) {
        SearchDeleteLogFormat(@"application for bundleIdentifier %@ is nil", bundleIdentifier);
        return NO;
    }

    __block BOOL allowsUninstall = false;

    if ([application respondsToSelector:@selector(isUninstallAllowed)]) {
        //-[SBApplication isUninstallAllowed] requires being run on the main thread, run specifically just in case we're not for some reason
        if (![NSThread isMainThread]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                allowsUninstall = [application isUninstallAllowed];
            });
        } else {
            allowsUninstall = [application isUninstallAllowed];
        }
    }

    if (!allowsUninstall) {
        if ([%c(SBApplicationIcon) respondsToSelector:@selector(allowsUninstall)]) {
            SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:application];
            allowsUninstall = [icon allowsUninstall]; //CyDelete hooks this method to allow uninstallation4

            [icon release];
        }
    }

    return allowsUninstall;
}
%end
%end

%ctor {
    if (IS_IOS_BETWEEN(iOS_9_0, iOS_9_3)) {
        %init(iOS9);
    }
}
