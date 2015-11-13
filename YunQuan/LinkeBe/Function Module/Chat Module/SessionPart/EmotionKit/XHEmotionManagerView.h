//
//  XHEmotionManagerView.h
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-5-3.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHEmotionManager.h"
#import "SnailMacro.h"
#import "XHEmotionSectionBar.h"
#import "EmoticonItemData.h"


#define kXHEmotionPerRowItemCount (kIsiPad ? 10 : 4)
#define kXHEmotionPageControlHeight 30
#define kXHEmotionSectionBarHeight 36

@protocol XHEmotionManagerViewDelegate <NSObject>

@optional
/**
 *  第三方gif表情被点击的回调事件
 *
 *  @param emotion   被点击的gif表情Model
 *  @param indexPath 被点击的位置
 */
- (void)didSelecteEmoticonItem:(EmoticonItemData *)emoticonItem atIndexPath:(NSIndexPath *)indexPath;

/*
 *  系统表情选择过后的回调时间
 */
- (void)faceView:(id)faceView didSelectAtString:(NSString *)faceString;

- (void)delFaceString;

- (void)sendMessage;

- (void)openEmotionStore;

@end

@protocol XHEmotionManagerViewDataSource <NSObject>

@required
/**
 *  通过数据源获取统一管理一类表情的回调方法
 *
 *  @param column 列数
 *
 *  @return 返回统一管理表情的Model对象
 */
- (XHEmotionManager *)emotionManagerForColumn:(NSInteger)column;

/**
 *  通过数据源获取一系列的统一管理表情的Model数组
 *
 *  @return 返回包含统一管理表情Model元素的数组
 */
- (NSArray *)emotionManagersAtManager;

/**
 *  通过数据源获取总共有多少类gif表情
 *
 *  @return 返回总数
 */
- (NSInteger)numberOfEmotionManagers;

@end

@interface XHEmotionManagerView : UIView
{
    UIScrollView *customFaceScrollView;
    UIScrollView *sysFaceScrollView;
    UIScrollView *stringFaceScrollView;
    int currentSelectedIndex;
    UIPageControl *customFacePageControll;
    UIPageControl *sysFacePageControll;
    UIPageControl *stringFacePageControll;

}

@property (nonatomic, weak) id <XHEmotionManagerViewDelegate> delegate;

@property (nonatomic, weak) id <XHEmotionManagerViewDataSource> dataSource;

/**
 *  管理多种类别gif表情的滚动试图
 */
@property (nonatomic, weak) XHEmotionSectionBar *emotionSectionBar;

/**
 *  是否显示发送按钮
 */
@property (nonatomic, assign) BOOL isShowEmotionSendButton; // default is YES

/**
 *  是否显示表情商店
 */
@property (nonatomic, assign) BOOL isShowEmotionStoreButton;

/**
 *  根据数据源刷新UI布局和数据
 */
- (void)reloadData;

//置灰发送按钮
- (void)graySendButton;

//恢复发送按钮
- (void)enabelSendButton;


@end
