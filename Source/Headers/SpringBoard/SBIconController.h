//
//  Source/Headers/SpringBoard/SBIconController.h
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 inoahdev. All rights reserved.
//

#ifndef SPRINGBOARD_SBICONCONTROLLER_H
#define SPRINGBOARD_SBICONCONTROLLER_H

#import "SBIconModel.h"
#import "SBIconView.h"
#import "SBIconViewMap.h"

@interface SBIconController : NSObject
+ (instancetype)sharedInstance;
- (void)iconCloseBoxTapped:(SBIconView *)icon;

@property(nonatomic) BOOL isEditing;
@property(nonatomic, strong) SBIconViewMap *homescreenIconViewMap;
@end

#endif
