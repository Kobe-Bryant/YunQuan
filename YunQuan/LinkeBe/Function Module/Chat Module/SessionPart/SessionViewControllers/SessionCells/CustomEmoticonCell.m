//
//  CustomEmoticonCell.m
//  ql
//
//  Created by LazySnail on 14-9-2.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import "CustomEmoticonCell.h"
#import "CustomEmotionData.h"
#import "UIImageView+WebCache.h"

const float emoticonWidth = 100;
const float emoticonHeight = 100;

@interface CustomEmoticonCell () <CustomEmotionDataDelegate>
{
    
}

@property (nonatomic, retain) UIImageView * emoticonView;

@end

@implementation CustomEmoticonCell

+ (float)caculateCellHightWithMessageData:(MessageData *)data
{
    float timeLabelHight = [OriginTimeStampCell caculateCellHightWithMessageData:data];
    float cellHeight = timeLabelHight + emoticonHeight;
    return cellHeight;
}

- (void)freshWithInfoData:(MessageData *)data
{
    CustomEmotionData *customData = (CustomEmotionData *)data.sessionData;
    customData.delegate = self;

    CGRect emoticonRect = CGRectMake(0, 0, emoticonWidth, emoticonHeight);
    UIImageView * emoticonView = [[UIImageView alloc]initWithFrame:emoticonRect];
    [emoticonView setImageWithURL:[NSURL URLWithString:customData.emotionUrl] placeholderImage:nil];
    
    self.emoticonView = emoticonView;
    
    //复用时移除老的View
    if (self.messageContentView != nil) {
        [self.messageContentView removeFromSuperview];
        self.messageContentView = nil;
    }
    self.messageContentView = emoticonView;
    [super freshWithInfoData:data];
    _sessionBackView.image = nil;
    
    RELEASE_SAFE(emoticonView);
    
    //加载发送loading
    
    CGRect indicatorRect;
    if (_indicatorView != nil) {
        indicatorRect = CGRectMake(CGRectGetMinX(_sessionBackView.frame) + CGRectGetWidth(_sessionBackView.frame)/2 - CGRectGetWidth(_indicatorView.frame)/2, CGRectGetMaxY(_sessionBackView.frame) - CGRectGetWidth(_sessionBackView.frame)/2 - CGRectGetWidth(_indicatorView.frame)/2, _indicatorView.frame.size.width, _indicatorView.frame.size.height);
        _indicatorView.frame = indicatorRect;
    }
    [customData getGifImg];
}

#pragma mark - CustomEmoticonDataDelegate

- (void)getGifUIImageSuccessWithUIImage:(UIImage *)gifImg
{
    self.emoticonView.image = gifImg;
}

- (void)dealloc
{
    LOG_RELESE_SELF;
    self.emoticonView = nil;
    [super dealloc];
}

@end
