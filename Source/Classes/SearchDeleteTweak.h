//
//  Source/Classes/SearchDeleteTweak.h
//  SearchDelete
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef CLASSES_SEARCHDELETETWEAK_H
#define CLASSES_SEARCHDELETETWEAK_H

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

#ifdef DEBUG
    #define SearchDeleteLog(str) \
    do { \
        NSString *formattedString = [[NSString alloc] initWithFormat:@"%s " str, __PRETTY_FUNCTION__]; \
        [[SearchDeleteTweak sharedInstance] logString:formattedString]; \
        \
        [formattedString release]; \
    } while (false);
    
    #define SearchDeleteLogFormat(str, ...) \
    do { \
        NSString *formattedString = [[NSString alloc] initWithFormat:@"%s " str, __PRETTY_FUNCTION__, ##__VA_ARGS__]; \
        [[SearchDeleteTweak sharedInstance] logString:formattedString]; \
        \
        [formattedString release]; \
    } while (false);
#else
    #define SearchDeleteLog(str)
    #define SearchDeleteLogFormat(str, ...)
#endif

@class SearchUISingleResultTableViewCell;
@interface SearchDeleteTweak : NSObject
+ (instancetype)sharedInstance;

- (BOOL)isEnabled;
- (BOOL)shouldJitter;

#ifdef DEBUG
- (void)logString:(NSString *)string;
#endif

@property (retain) SearchUISingleResultTableViewCell *currentJitteringCell;
@end

#endif
