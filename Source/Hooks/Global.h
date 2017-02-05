//
//  Source/Hooks/Global.h
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 inoahdev. All rights reserved.
//

#ifndef HOOKS_GLOBAL_H
#define HOOKS_GLOBAL_H

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

#define SDDebugLog(FORMAT, ...) NSLog(@"[SearchDelete] " FORMAT, ##__VA_ARGS__)

@class SearchUISingleResultTableViewCell;
@interface SearchDeleteTweak : NSObject
+ (instancetype)sharedInstance;

- (BOOL)isEnabled;
- (void)setIsEnabled:(BOOL)enabled;

- (BOOL)shouldJitter;
- (void)setShouldJitter:(BOOL)jitter;

@property (retain) SearchUISingleResultTableViewCell *currentJitteringCell;
@end

#endif
