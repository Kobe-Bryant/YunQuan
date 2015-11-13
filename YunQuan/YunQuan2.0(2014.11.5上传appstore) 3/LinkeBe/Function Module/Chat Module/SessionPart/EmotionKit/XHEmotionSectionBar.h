//
//  XHEmotionSectionBar.h
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-5-3.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHEmotionManager.h"

@protocol XHEmotionSectionBarDelegate <NSObject>

/**
 *  点击某一类gif表情的回调方法
 *
 *  @param emotionManager 被点击的管理表情Model对象
 *  @param section        被点击的位置
 */
- (void)didSelecteEmotionManager:(XHEmotionManager *)emotionManager atSection:(NSInteger)section;

/*
 *  发送按钮的点击回调
 */
- (void)didSelecteSendButton;

/**
 *  表情商店按钮点击
 */
- (void)didSelectEmotionStoreButton;

@end

@interface XHEmotionSectionBar : UIView

@property (nonatomic, weak) id <XHEmotionSectionBarDelegate> delegate;

/**
 *  数据源
 */
@property (nonatomic, strong) NSArray *emotionManagers;

/**
 *  是否显示表情商店的按钮
 */
@property (nonatomic, assign) BOOL isShowEmotionStoreButton; // default is YES

/**
 *
 */
@property (nonatomic, assign) BOOL isShowEmotionSendButton;

- (instancetype)initWithFrame:(CGRect)frame showEmotionStoreButton:(BOOL)isShowEmotionStoreButtoned andShowSendButton:(BOOL)isShowSendButton;


/**
 *  根据数据源刷新UI布局和数据
 */
- (void)reloadData;

/**
 *  自动选择表情
 */
- (void)selectManagerWithIndex:(NSInteger)index;

- (void)scorllToShowFirstButton;

// 发送按钮置灰
- (void)graySendButton;

// 取消发送按钮置灰
- (void)enabelSendButton;

@end
