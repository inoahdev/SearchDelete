//
//  Source/Headers/SBAlertItemsControllerObserver.h
//
//  Created by inoahdev on 12/26/16
//  Copyright © 2016 inoahdev. All rights reserved.
//

#ifndef SPRINGBOARD_SBALERT_ITEMS_CONTROLLER_OBSERVER_H
#define SPRINGBOARD_SBALERT_ITEMS_CONTROLLER_OBSERVER_H

#include "SBAlertItemsController.h"

@protocol SBAlertItemsControllerObserver <NSObject>
- (void)alertItemsController:(SBAlertItemsController *)alertItemsController didDeactivateAlertItem:(SBDeleteIconAlertItem *)alertItem forReason:(int)reason;
- (void)alertItemsController:(SBAlertItemsController *)alertItemsController didActivateAlertItem:(SBDeleteIconAlertItem *)alertItem;
- (void)alertItemsController:(SBAlertItemsController *)alertItemsController willActivateAlertItem:(SBDeleteIconAlertItem *)alertItem;
@end

#endif
