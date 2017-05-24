//
//  Source/Headers/SpringBoardServices/SBSRelaunchAction.h
//  SearchDelete
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef SPRINGBOARDSERVICES_SBSRELAUNCHACTION_H
#define SPRINGBOARDSERVICES_SBSRELAUNCHACTION_H

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, SBSRelaunchOptions) {
    SBSRelaunchOptionNone                       = 0,
    SBSRelaunchOptionRestartRenderServer        = (1 << 0), // also relaunch backboardd
    SBSRelaunchOptionTransitionWithSnapshot     = (1 << 1),
    SBSRelaunchOptionTransitionWithFadeToBlack  = (1 << 2),
};

@interface SBSRelaunchAction
+ (instancetype)actionWithReason:(NSString *)reason options:(SBSRelaunchOptions)options targetURL:(NSURL *)target;
@end

#endif
