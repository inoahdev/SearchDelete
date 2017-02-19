//
//  Source/Headers/SpringBoard/SBApplication.h
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef SPRINGBOARD_SBAPPLICATION_H
#define SPRINGBOARD_SBAPPLICATION_H

#import "SBApplicationInfo.h"
#import "SBIcon.h"

@interface SBApplication : NSObject
- (BOOL)isSystemApplication;
- (Class)iconClass;
- (BOOL)iconAllowsUninstall:(SBIcon *)icon;
- (SBApplicationInfo *)_appInfo;

@property(nonatomic, getter=isUninstallAllowed) BOOL uninstallAllowed;
@end

#endif
