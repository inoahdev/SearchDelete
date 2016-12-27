//
//  Source/Headers/FrontBoardServices/FBSSystemService.h
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 inoahdev. All rights reserved.
//

#ifndef FRONTBOARDSERVICES_FBSSYSTEMSERVICE_H
#define FRONTBOARDSERVICES_FBSSYSTEMSERVICE_H

#import <CoreFoundation/CoreFoundation.h>

@interface FBSSystemService : NSObject
+ (instancetype)sharedService;
- (void)sendActions:(NSSet *)actions withResult:(id)result;
@end

#endif
