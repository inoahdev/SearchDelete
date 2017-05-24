//
//  Source/Headers/Search/SPSearchResult.h
//  SearchDelete
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef SEARCH_SPSEARCHRESULT_H
#define SEARCH_SPSEARCHRESULT_H

#import <CoreFoundation/CoreFoundation.h>

@interface SPSearchResult : NSObject
@property(nonatomic, strong) NSString *title;
@property(nonatomic, copy) NSString *bundleID;
@property(nonatomic, strong) NSString *section_header;
@end

#endif
