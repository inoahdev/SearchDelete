//
//  Source/Headers/SearchUI/SearchUISingleResultTableViewCell.h
//  SearchDelete
//
//  Created by inoahdev on 12/25/16
//  Copyright © 2016 - 2017 inoahdev. All rights reserved.
//

#ifndef SEARCHUI_SEARCHUISEARCHUISINGLERESULTTABLEVIEWCELL_H
#define SEARCHUI_SEARCHUISEARCHUISINGLERESULTTABLEVIEWCELL_H

#import "SearchUIThumbnailView.h"

@interface SearchUISingleResultTableViewCell : UITableViewCell
@property (nonatomic, strong) SearchUIThumbnailView *thumbnailView;
@property (retain) UIView *thumbnailContainer;

@property(nonatomic, strong) id result;
@end

#endif
