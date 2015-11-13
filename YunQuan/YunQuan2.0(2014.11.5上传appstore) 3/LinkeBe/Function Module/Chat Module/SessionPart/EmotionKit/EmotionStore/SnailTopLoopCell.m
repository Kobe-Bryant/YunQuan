//
//  SnailTopLoopCell.m
//  ql
//
//  Created by LazySnail on 14-9-13.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "SnailTopLoopCell.h"
#import "SnailLoopScrollView.h"
#import "ChatMacro.h"

#define EmotionIntroduceViewHeight      160

@interface SnailTopLoopCell ()
{
    
}

@end

@implementation SnailTopLoopCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshCellWithImgArray:(NSMutableArray *)imgArray;
{
    if (self.scorllLoopView != nil) {
        [self.scorllLoopView removeFromSuperview];
        self.scorllLoopView = nil;
    }
    
    //添加新表情介绍滚动视图
    if (imgArray.count > 0) {
        CGRect topLoopViewRect = CGRectMake(0, 0, KUIScreenWidth, EmotionIntroduceViewHeight);
        
        SnailLoopScrollView * tempTopLoopView = [[SnailLoopScrollView alloc]initWithFrame:topLoopViewRect andImageUrls:imgArray isAutoLoop:imgArray.count > 1 loopTimeInterval:3.0f];
        
        self.scorllLoopView = tempTopLoopView;
        [self.contentView addSubview:tempTopLoopView];
        RELEASE_SAFE(tempTopLoopView);
    }
}

- (void)dealloc
{
    self.scorllLoopView = nil;
    [super dealloc];
}

@end
