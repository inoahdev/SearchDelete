//
//  Source/Hooks/Global.h
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef HOOKS_GLOBAL_H
#define HOOKS_GLOBAL_H

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <os/log.h>

static os_log_t os_log_key;
#define SDDebugLog(FORMAT, ...) do { \
    NSString *__format__os__log__string__ = [NSString stringWithFormat:FORMAT, ##__VA_ARGS__]; \
    os_log_debug(os_log_key, "%s", __format__os__log__string__.UTF8String); \
    \
    [__format__os__log__string__ release]; \
} while (false)

@class SearchUISingleResultTableViewCell;
@interface SearchDeleteTweak : NSObject
+ (instancetype)sharedInstance;

- (BOOL)isEnabled;
- (BOOL)shouldJitter;

@property (retain) SearchUISingleResultTableViewCell *currentJitteringCell;
@end

#endif
