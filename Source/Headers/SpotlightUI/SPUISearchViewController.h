//
//  Source/Headers/SpotlightUI/SPUISearchViewController.h
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 inoahdev. All rights reserved.
//

#ifndef SPOTLIGHTUI_SPUISEARCHVIEWCONTROLLER_H
#define SPOTLIGHTUI_SPUISEARCHVIEWCONTROLLER_H

#import "../Search/SPSearchQueryContext.h"
#import "SPUISearchHeader.h"

@interface SPUISearchViewController : UIViewController
+ (instancetype)sharedInstance;
- (SPUISearchHeader *)searchHeader;
- (void)queryContextDidChange:(SPSearchQueryContext *)queryContext allowZKW:(BOOL)zkw;
@end

#endif
