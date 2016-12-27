//
//  Source/Hooks/SPSearchResult.xm
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 inoahdev. All rights reserved.
//

#include "../Headers/SpringBoard/SBApplicationIcon.h"
#include "../Headers/SpringBoard/SBApplicationController.h"

#include "../Headers/Theos/Version-Extensions.h"

#include "Global.h"
#include "SPSearchResult.h"

%group iOS9
%hook SPSearchResult
%new
- (BOOL)searchdelete_isApplication {
    if (!self.bundleID || self.section_header) {
        SDDebugLog(@"Either self.bundleID doesn't exist? (%@), or self.section_header is not nil (%@)", self.bundleID, self.section_header);
        return NO;
    }

    return ([[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleID] != nil);
}

%new
- (BOOL)searchdelete_isSystemApplication {
    if (!self.bundleID || self.section_header) {
        SDDebugLog(@"Either self.bundleID doesn't exist? (%@), or self.section_header is not nil (%@)", self.bundleID, self.section_header);
        return NO;
    }

    SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleID];
    if (!application) {
        SDDebugLog(@"Unable to get application");
        return NO;
    }

    SBApplicationInfo *info = [application _appInfo];
    if (!info) {
        SDDebugLog(@"Unable to get application-info");
        return NO;
    }

    return [info systemApplication];
}

%new
- (BOOL)searchdelete_allowsUninstall {
    if (!self.bundleID || self.section_header) {
        SDDebugLog(@"Either self.bundleID doesn't exist? (%@), or self.section_header is not nil (%@)", self.bundleID, self.section_header);
        return NO;
    }

    SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleID];
    if (!application) {
        SDDebugLog(@"Result is not an application");
        return NO;
    }

    __block BOOL allowsUninstall = false;

    if ([application respondsToSelector:@selector(isUninstallAllowed)]) {
        //-[SBApplication isUninstallAllowed] requires being run on the main thread, run specifically just in case we're not for some reason
        if (![NSThread isMainThread]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                allowsUninstall = [application isUninstallAllowed];
            });
        } else {
            allowsUninstall = [application isUninstallAllowed];
        }
    } else {
        SDDebugLog(@"application does not respond to selector \"isUninstallAllowed\"");
    }

    if (!allowsUninstall) {
        if ([%c(SBApplicationIcon) respondsToSelector:@selector(allowsUninstall)]) {
            SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:application];
            allowsUninstall = [icon allowsUninstall]; //CyDelete hooks this method to allow uninstallation4
        } else {
            SDDebugLog(@"SBApplicationIcon does not respond to selector \"allowsUninstall\"");
        }
    }

    SDDebugLog(@"Uninstalling is allowed? (%s)", allowsUninstall ? "YES" : "NO");
    return allowsUninstall;
}
%end
%end

%ctor {
    if (IS_IOS_BETWEEN(iOS_9_0, iOS_9_3)) {
        %init(iOS9);
    }
}
