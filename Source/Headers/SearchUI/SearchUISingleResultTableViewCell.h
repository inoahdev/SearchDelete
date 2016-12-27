//
//  Source/Headers/SearchUI/SearchUISingleResultTableViewCell.h
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 inoahdev. All rights reserved.
//

#ifndef SEARCHUI_SEARCH_UI_SINGLE_RESULT_TABLE_VIEW_CELL_H
#define SEARCHUI_SEARCH_UI_SINGLE_RESULT_TABLE_VIEW_CELL_H

#import "SearchUIThumbnailView.h"

@interface SearchUISingleResultTableViewCell : UITableViewCell
@property (nonatomic, strong) SearchUIThumbnailView *thumbnailView;
@property (retain) UIView *thumbnailContainer;

@property(nonatomic, strong) id result;
@end

#endif
