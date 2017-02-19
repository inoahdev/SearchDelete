//
//  Source/Headers/SpringBoard/SBIconModel.h
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef SPRINGBOARD_SBICONMODEL_H
#define SPRINGBOARD_SBICONMODEL_H

#import "SBIcon.h"

@interface SBIconModel : NSObject
- (SBIcon *)expectedIconForDisplayIdentifier:(NSString *)identifier; //why not bundle identifier?
@end

#endif
