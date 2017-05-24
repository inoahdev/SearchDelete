//
//  Source/Headers/SpringBoard/SBApplicationIcon.h
//  SearchDelete
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef SPRINGBOARD_SBAPPLICATIONICON_H
#define SPRINGBOARD_SBAPPLICATIONICON_H

#import "SBApplication.h"
#import "SBIcon.h"

@interface SBApplicationIcon : SBIcon
- (instancetype)initWithApplication:(SBApplication *)application;
- (BOOL)allowsUninstall;
@end

#endif
