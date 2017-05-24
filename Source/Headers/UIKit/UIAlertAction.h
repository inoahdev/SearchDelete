//
//  Source/Headers/UIKit/UIAlertAction.h
//  SearchDelete
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef UIKIT_UIALERTACTION_H
#define UIKIT_UIALERTACTION_H

#import <UIKit/UIKit.h>

typedef void (^UIAlertActionHandler)(UIAlertAction *action);

@interface UIAlertAction ()
@property (nonatomic, strong) UIAlertActionHandler handler;
@end

#endif
