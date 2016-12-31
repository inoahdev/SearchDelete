//
//  Source/Headers/FrontBoard/FBSystemService.h
//
//  Created by inoahdev on 12/29/16
//  Copyright © 2016 inoahdev. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

@interface FBSystemService : NSObject
+ (instancetype)sharedInstance;
- (void)exitAndRelaunch:(BOOL)relaunch withOptions:(NSInteger)options;
@end
