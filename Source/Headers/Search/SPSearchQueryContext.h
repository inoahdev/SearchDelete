//
//  Source/Headers/Search/SPSearchQueryContext.h
//  SearchDelete
//
//  Created by inoahdev on 12/26/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef SEARCH_SPSEARCHQUERYCONTEXT_H
#define SEARCH_SPSEARCHQUERYCONTEXT_H

#import <CoreFoundation/CoreFoundation.h>

@interface SPSearchQueryContext : NSObject
+ (instancetype)queryContextWithSearchString:(NSString *)searchString;
@property (nonatomic) BOOL forceQueryEvenIfSame;
@end

#endif
