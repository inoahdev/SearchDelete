//
//  Source/Hooks/Global.h
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 inoahdev. All rights reserved.
//

#ifndef HOOKS_GLOBAL_H
#define HOOKS_GLOBAL_H

#include <CoreFoundation/CoreFoundation.h>
#include <Foundation/Foundation.h>

#define SDDebugLog(FORMAT, ...) NSLog(@"[SearchDelete] " FORMAT, ##__VA_ARGS__)

@class SearchUISingleResultTableViewCell;
@interface SearchDeleteTweak : NSObject
+ (instancetype)sharedInstance;

// no nonatomic since this is called on multiple threads

@property BOOL isPresentingDeleteAlertItemFromSearch; // currentJitteringCell is nil when -[SBDeleteIconAlertItem alertController] is called
@property (copy) NSDictionary *preferences;
@property (copy) NSString *applicationID;
@property (nonatomic, retain) SearchUISingleResultTableViewCell *currentJitteringCell;
@end

#endif
