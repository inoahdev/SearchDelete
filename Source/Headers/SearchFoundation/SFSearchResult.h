//
//  Source/Headers/SearchFoundation/SFSearchResult.h
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef SEARCHFOUNDATION_SFSEARCH_RESULT_H
#define SEARCHFOUNDATION_SFSEARCH_RESULT_H

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

@interface SFSearchResult : NSObject
@property (nonatomic) BOOL isLocalApplicationResult;
@property (nonatomic, strong) NSString *applicationBundleIdentifier;
@property (nonatomic, strong) NSString *title;
@end

#endif
