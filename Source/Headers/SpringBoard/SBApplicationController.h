//
//  Source/Headers/SpringBoard/SBApplicationController.h
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef SPRINGBOARD_SBAPPLICATION_CONTROLLER_H
#define SPRINGBOARD_SBAPPLICATION_CONTROLLER_H

#import "SBApplication.h"

@interface SBApplicationController
+ (nonnull instancetype)sharedInstance;
- (nullable SBApplication *)applicationWithBundleIdentifier:(nonnull NSString *)bundleIdentifier;
@end

#endif
