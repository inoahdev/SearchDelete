//
//  Source/Headers/SpotlightUI/SPUISearchModel.h
//  SearchDelete
//
//  Created by inoahdev on 12/26/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef SPOTLIGHTUI_SPUISEARCHMODEL_H
#define SPOTLIGHTUI_SPUISEARCHMODEL_H

#import "SPUISearchViewController.h"

@interface SPUISearchModel : NSObject
+ (instancetype)sharedInstance;
- (SPUISearchViewController *)delegate;
@end

#endif
