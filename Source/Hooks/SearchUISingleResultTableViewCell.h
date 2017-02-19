//
//  Source/Hooks/SearchUISingleResultTableView.h
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef HOOKS_SEARCH_UI_SINGLE_RESULT_TABLEVIEW_CELL_H
#define HOOKS_SEARCH_UI_SINGLE_RESULT_TABLEVIEW_CELL_H

#import "../Headers/SearchUI/SearchUISingleResultTableViewCell.h"

@interface SearchUISingleResultTableViewCell () <UIAlertViewDelegate>
- (void)searchdelete_longPressGestureRecognizer:(UILongPressGestureRecognizer *)recognizer;

- (NSString *)searchdelete_applicationBundleIdentifier;
- (CALayer *)searchdelete_iconImageViewLayer;

- (void)searchdelete_startJittering;
- (BOOL)searchdelete_isJittering;
- (void)searchdelete_stopJittering;
@end

#endif
