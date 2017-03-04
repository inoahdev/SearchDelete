//
//  Source/Hooks/SFSearchResult.h
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef HOOKS_SFSEARCHRESULT_H
#define HOOKS_SFSEARCHRESULT_H

#import "../Headers/SearchFoundation/SFSearchResult.h"

@interface SFSearchResult ()
- (BOOL)searchdelete_isApplication;
- (BOOL)searchdelete_isSystemApplication;
- (BOOL)searchdelete_allowsUninstall;
@end

#endif
