//
//  Source/Classes/SearchDeleteTweak.h
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef CLASSES_SEARCHDELETETWEAK_H
#define CLASSES_SEARCHDELETETWEAK_H

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <os/log.h>

#ifdef DEBUG
    static os_log_t os_log_key;
    #define SDDebugLog(FORMAT, ...) do { \
        NSString *__format__os__log__string__ = [NSString stringWithFormat:FORMAT, ##__VA_ARGS__]; \
        os_log_debug(os_log_key, "%s", __format__os__log__string__.UTF8String); \
        \
        [__format__os__log__string__ release]; \
    } while (false)
#else
    #define SDDebugLog(FORMAT, ...)
#endif

@class SearchUISingleResultTableViewCell;
@interface SearchDeleteTweak : NSObject
+ (instancetype)sharedInstance;

- (BOOL)isEnabled;
- (BOOL)shouldJitter;

@property (retain) SearchUISingleResultTableViewCell *currentJitteringCell;
@end

#endif
