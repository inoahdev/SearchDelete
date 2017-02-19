//
//  Source/Hooks/SPUISearchViewController.h
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef HOOKS_SPUISEARCHVIEWCONTROLLER_H
#define HOOKS_SPUISEARCHVIEWCONTROLLER_H

#import "../Headers/SpotlightUI/SPUISearchViewController.h"

@interface SPUISearchViewController () <UIAlertViewDelegate>
- (BOOL)isActivated;
- (void)_searchFieldEditingChanged;
- (void)searchdelete_reload;
@end

#endif
