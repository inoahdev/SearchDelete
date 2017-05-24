//
//  Source/Hooks/SFSearchResult.xm
//  SearchDelete
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#import <version.h>

#import "../Classes/SearchDeleteTweak.h"
#import "../Headers/SpringBoard/SBApplicationController.h"
#import "../Headers/SpringBoard/SBApplicationIcon.h"

#import "SFSearchResult.h"

%group iOS10
%hook SFSearchResult
%new
- (BOOL)searchdelete_isSystemApplication {
    if (![self isLocalApplicationResult]) {
        return NO;
    }

    SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.applicationBundleIdentifier];
    if (!application) {
        return NO;
    }

    return [application isSystemApplication];
}

%new
- (BOOL)searchdelete_allowsUninstall {
    if (![self isLocalApplicationResult]) {
        return NO;
    }

    SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:[self applicationBundleIdentifier]];
    if (!application) {
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
            allowsUninstall = [icon allowsUninstall]; //CyDelete hooks this method to allow uninstallation

            [icon release];
        }
    }

    return allowsUninstall;
}

%end
%end

%ctor {
    if (IS_IOS_BETWEEN(iOS_10_0, iOS_10_2)) {
        %init(iOS10);
    }
}
