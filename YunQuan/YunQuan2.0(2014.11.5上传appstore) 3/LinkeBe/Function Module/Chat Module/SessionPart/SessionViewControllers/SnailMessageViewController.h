//
//  SnailVedioViewController.h
//  VoiceRecorderDemo
//
//  Created by LazySnail on 14-6-20.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XHMessageTableView.h"
#import "SnailMessageInputView.h"
#import "XHShareMenuItem.h"
#import "XHShareMenuView.h"
#import "XHEmotionManagerView.h"
#import <CoreLocation/CoreLocation.h>

// 用于判断是否自动滚动到底部cell



@protocol SnailMessageTableViewControllerDelegate <NSObject>

@optional
/**
 *  发送文本消息的回调方法
 *
 *  @param text   目标文本字符串
 *  @param sender 发送者的名字
 *  @param date   发送时间
 */
- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date;

/**
 *  发送图片消息的回调方法
 *
 *  @param photo  目标图片对象，后续有可能会换
 *  @param sender 发送者的名字
 *  @param date   发送时间
 */
- (void)didSendPhoto:(UIImage *)photo fromSender:(NSString *)sender onDate:(NSDate *)date;

/**
 *  发送视频消息的回调方法
 *
 *  @param videoConverPhoto 目标视频的封面图
 *  @param videoPath        目标视频本地路径
 *  @param sender           发送者的名字
 *  @param date             发送时间
 */
- (void)didSendVideoConverPhoto:(UIImage *)videoConverPhoto videoPath:(NSString *)videoPath fromSender:(NSString *)sender onDate:(NSDate *)date;

/**
 *  发送语音消息的回调方法
 *
 *  @param voicePath        目标语音本地路径
 *  @param voiceDuration    目标语音时长
 *  @param sender           发送者的名字
 *  @param date             发送时间
 */
- (void)didSendVoice:(NSString *)voicePath voiceDuration:(NSString*)voiceDuration fromSender:(NSString *)sender onDate:(NSDate *)date;

/**
 *  发送第三方表情消息的回调方法
 *
 *  @param facePath 目标第三方表情的本地路径
 *  @param sender   发送者的名字
 *  @param date     发送时间
 */
- (void)didSendEmotion:(NSString *)emotionPath fromSender:(NSString *)sender onDate:(NSDate *)date;

/**
 *  发送地理位置的回调方法
 *
 *  @param geoLocationsPhoto 目标显示默认图
 *  @param geolocations      目标地理信息
 *  @param location          目标地理经纬度
 *  @param sender            发送者
 *  @param date              发送时间
 */
- (void)didSendGeoLocationsPhoto:(UIImage *)geoLocationsPhoto geolocations:(NSString *)geolocations location:(CLLocation *)location fromSender:(NSString *)sender onDate:(NSDate *)date;

/**
 *  是否显示时间轴Label的回调方法
 *
 *  @param indexPath 目标消息的位置IndexPath
 *
 *  @return 根据indexPath获取消息的Model的对象，从而判断返回YES or NO来控制是否显示时间轴Label
 */
- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath;


/**
 *  协议回掉是否支持用户手动滚动
 *
 *  @return 返回YES or NO
 */
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling;

/**
 *  判断是否支持下拉加载更多消息
 *
 *  @return 返回BOOL值，判定是否拥有这个功能
 */
- (BOOL)shouldLoadMoreMessagesScrollToTop;

/**
 *  下拉加载更多消息，只有在支持下拉加载更多消息的情况下才会调用。
 */
- (void)loadMoreMessagesScrollTotop;

@end

@interface SnailMessageViewController : UIViewController <XHShareMenuViewDelegate,XHEmotionManagerViewDelegate>
{
    XHMessageTableView * _messageTableView;
}

/**
 *  用于显示消息的TableView
 */
@property (nonatomic, strong) XHMessageTableView *messageTableView;

/**
 *  自定义表情视图
 */
@property (nonatomic, weak, readwrite) XHEmotionManagerView * emotionManagerView;

/**
 *  子类作为父类的代理
 */
@property (nonatomic, assign) id <SnailMessageTableViewControllerDelegate> delegate;

#pragma mark - Message View Controller Default stup
/**
 *  是否允许手势关闭键盘，默认是允许
 */
@property (nonatomic, assign) BOOL allowsPanToDismissKeyboard; // default is YES

/**
 *  是否允许发送语音
 */
@property (nonatomic, assign) BOOL allowsSendVoice; // default is YES

/**
 *  是否允许发送多媒体
 */
@property (nonatomic, assign) BOOL allowsSendMultiMedia; // default is YES

/**
 *  是否支持发送表情
 */
@property (nonatomic, assign) BOOL allowsSendFace; // default is YES

/**
 *  是否正在加载更多旧的消息数据
 */
@property (nonatomic, assign) BOOL loadingMoreMessage;

/**
 *  输入框的样式，默认为扁平化
 */
@property (nonatomic, assign) SnailMessageInputViewStyle inputViewStyle;

/**
 *  输入框视图
 */
@property (nonatomic, retain) SnailMessageInputView * messageInputView;

/**
 *  用于限制聊天列表滚动到底部
 */
@property (nonatomic, assign) BOOL shouldScrollToLastCell;

/**
 *  放下输入栏方法 
 */
- (void)layoutOtherMenuViewHiden:(BOOL)hide;

/**
 * 滚动聊天列表到底部
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

/**
 * 空消息判断，如果为空则展示提示框
 */

- (BOOL)judgeNilMessageAndShowAlertForText:(NSString *)text;

/**
 *  从新加载自定义表情数据
 */
- (void)loadEmotionView;

@end
