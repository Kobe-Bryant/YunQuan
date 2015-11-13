//
//  SessinDataOperator.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

//该类主要做数据库读取和Http请求操作

#import <Foundation/Foundation.h>
#import "ChatMacro.h"
#import "MessageData.h"

@class MessageListData;
@class VoiceData;
@class SessionViewController;
@class CustomEmotionData;

@protocol SessionDataOperatorDelegate <NSObject>

- (void)receiveMessage:(MessageData *)message;

@end


@interface SessionDataOperator : NSObject

@property (nonatomic, assign) id <SessionDataOperatorDelegate> delegate;

@property (nonatomic, assign) SessionViewController * sessionViewController;

@property (nonatomic, assign) dispatch_queue_t dbModifyDispatchQueue;

+ (SessionDataOperator *)shareOperator;

/**
 *
 *  消息发送处理方法
 *
 */
//发送文本消息
- (MessageData *)sendTextDataWithText:(NSString *)text andMessageListData:(MessageListData *)listData;

//发送图片消息
- (NSMutableArray *)sendPictureDataWithImageArr:(NSMutableArray *)imgArr andMessageListData:(MessageListData *)listData;

//发送语音消息
- (MessageData *)sendVoiceDataWithVoiceData:(VoiceData *)voice andMessageListData:(MessageListData *)listData;

//发送自定义表情消息
- (MessageData *)sendCustomEmoticonDataWithCustomeEmoticonData:(CustomEmotionData *)emoticonData andMessageListData:(MessageListData *)listData;

//发送我有消息
- (MessageData *)sendiHaveMessageWitHaveID:(int)haveID andReceiverID:(long long)receiverID andtbDesc:(NSString *)tbDesc andtBurl:(NSString *)tbUrl andTxt:(NSString *)txt andMsgDesc:(NSString *)msgDesc;

//发送我要消息
- (MessageData *)sendiWantMessageWithWantID:(int)wantID andReceiverID:(long long)receiverID andtbDesc:(NSString *)tbDesc andtBurl:(NSString *)tbUrl andTxt:(NSString *)txt andMsgDesc:(NSString *)msgDesc;

//从新发送消息接口
- (void)resendMessageWithMessage:(MessageData *)message;

//发送聚一聚消息
- (MessageData *)sendGetheringMessageWithTempCircleID:(long long)tempCID andMessageID:(int)messageID andMsgTxt:(NSString *)txt andMsgDesc:(NSString *)msgDesc;

//发送消息成功后处理逻辑
- (void)receiveSendMessageSuccessWithDic:(NSDictionary *)dic;

//收到新消息逻辑
- (void)receiveNewMessageWithMessageData:(MessageData *)messageData;

//获取历史消息记录
- (NSMutableArray *)historyMessageArrWithCurrentPage:(int)currentPage forObjectID:(long long)objectID;

//外部模块调整聊天接口
+ (void)otherSystemTurnToSessionWithSender:(UIViewController *)viewController andObjectID:(long long)objectID andSessionType:(SessionType)sessionType isPopToRootViewController:(BOOL)rootPop isShowRightButton:(BOOL)rightButtonShow;

//点击头像跳转名片夹接口
- (void)turnToIntroduceCardViewControllerWithSender:(UIViewController *)viewController andObjectID:(long long)objectID;

//获取圈子成员数
- (NSInteger)getTempCircleMemberCountWithTempCircleID:(long long)tempCircleID;


@end
