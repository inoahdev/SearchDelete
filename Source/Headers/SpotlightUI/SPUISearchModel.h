//
//  Source/Headers/SpotlightUI/SPUISearchModel.h
//
//  Created by inoahdev on 12/26/16
//  Copyright © 2016 inoahdev. All rights reserved.
//

#ifndef SPOTLIGHTUI_SPUISEARCHMODEL_H
#define SPOTLIGHTUI_SPUISEARCHMODEL_H

#import "SPUISearchViewController.h"

@interface SPUISearchModel : NSObject
+ (instancetype)sharedInstance;
- (SPUISearchViewController *)delegate;
@end

#endif
