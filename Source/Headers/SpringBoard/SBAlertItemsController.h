//
//  Source/Headers/SBAlertItemsController.h
//
//  Created by inoahdev on 12/26/16
//  Copyright © 2016 inoahdev. All rights reserved.
//
//

#ifndef SPRINGBOARD_SBALERTITEMSCONTROLLER_H
#define SPRINGBOARD_SBALERTITEMSCONTROLLER_H

#include "SBDeleteIconAlertItem.h"

@protocol SBAlertItemsControllerObserver;
@interface SBAlertItemsController : NSObject
+ (instancetype)sharedInstance;

- (void)activateAlertItem:(SBDeleteIconAlertItem *)alertItem animated:(BOOL)animated;
- (void)addObserver:(id<SBAlertItemsControllerObserver>)arg1;
@end

#endif
