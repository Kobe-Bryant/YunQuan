//
//  RelateCell.h
//  LinkeBe
//
//  Created by Dream on 14-9-17.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQRichTextView.h"

@interface RelateCell : UITableViewCell

@property (nonatomic, retain) UIImageView *iconImage;
@property (nonatomic, retain) UILabel *nameLable;
@property (nonatomic, retain) TQRichTextView *commentLable;
@property (nonatomic, retain) UILabel *timeLable;

@property (nonatomic, retain) UIButton *loveBtn;  //点赞了

@property (nonatomic, retain) UIImageView *contentImage;
@property (nonatomic, retain) UILabel *contentLable;

@end
