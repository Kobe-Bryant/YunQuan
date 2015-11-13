//
//  CustomEmoticonView.h
//  ql
//
//  Created by LazySnail on 14-9-14.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EmoticonItemData;

@protocol CustomEmoticonViewDelegate <NSObject>

- (void)emoticonViewShouldTurnToNextEmoticon;

- (void)emoticonViewShouldTurnToLastEmoticon;

- (void)emoticonSelectEmotionWithData:(EmoticonItemData *)emoticonData;

@end

@interface CustomEmoticonView : UIView

@property(nonatomic, retain) UIView * frontView;

@property(nonatomic, retain) UIView * lastView;

@property(nonatomic, retain) NSArray * emoticonDataArray;

@property(nonatomic, assign) id <CustomEmoticonViewDelegate> delegate;

+ (UIView *)getFirstEmoticonViewWithEmoticonArray:(NSArray *)emoticonArr andFrame:(CGRect)frame;

+ (UIView *)getLastEmoticonViewWithEmoticonArray:(NSArray *)emoticonArr andFrame:(CGRect)frame;

- (instancetype)initWithFrontView:(UIView *)frontView lastView:(UIView *)lastView andFrame:(CGRect)frame;

- (void)scrollToFrontView;

- (void)scrollToLastView;

- (void)reloadView;

@end
