//
//  Source/Headers/SpringBoard/SBIconViewMap.h
//  SearchDelete
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef SPRINGBOARD_SBICONVIEWMAP_H
#define SPRINGBOARD_SBICONVIEWMAP_H

#import "SBIcon.h"
#import "SBIconView.h"

@interface SBIconViewMap : NSObject
+ (instancetype)homescreenMap;

- (SBIconView *)iconViewForIcon:(SBIcon *)icon;
- (SBIconView *)mappedIconViewForIcon:(SBIcon *)icon;
@end

#endif
