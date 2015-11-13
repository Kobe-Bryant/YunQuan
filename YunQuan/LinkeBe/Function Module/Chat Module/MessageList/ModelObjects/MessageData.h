//
//  MessageData.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-17.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionDataFactory.h"
#import "SpeakerData.h"

//消息发送类型
typedef enum {
    MessageOperationTypeSend = 1,
    MessageOperationTypeReceive
}MessageOperationType;

// 列表消息类型
typedef enum{                           // 聊天列表类型枚举
    SessionTypePerson = 1,          // 个人单聊消息
    SessionTypeTempCircle = 2,      // 临时圈子消息
}SessionType;

typedef enum
{
    MessageStatusTypeSendFailed = 1,
    MessageStatusTypeSending = 2,
    MessageStatusTypeSendSuccessed = 3
}MessageStatusType;

@class MessageData;

@protocol MessageDataDelegate <NSObject>

- (void)messageDataStatusChange:(MessageData *)messageData;

@end


@interface MessageData : NSObject <NSCopying>

//发送方id
//@property (nonatomic, assign) long long  senderID;
//接收方id
//@property (nonatomic, assign) long long  receiverID;
//聊天对象id
@property (nonatomic, assign) long long objectID;

//Location ID
@property (nonatomic, assign) long long locmsgid;
//是否显示时间
@property (nonatomic, assign) BOOL showTimeSign;
//接收消息时受到的消息id 服务器生成
@property (nonatomic, assign) long long msgid;
//发送消息时间
@property (nonatomic, assign) int sendtime;
//发送状态标识
@property (nonatomic, assign) MessageStatusType statusType;
//会话类型
@property (nonatomic, assign) SessionType sessionType;
//消息操作类型 发送 或者 接收
@property (nonatomic, assign) MessageOperationType operationType;
//发送时生成的压缩发送二进制数据 (用于图片和语音上传)
@property (nonatomic, retain) NSData * sendData;
//代理
@property (nonatomic, assign) id <MessageDataDelegate> delegate;


//发送用户信息
@property (nonatomic, retain) ObjectData * speaker;

//聊天消息类型对象
@property (nonatomic, retain) OriginData * sessionData;

- (instancetype)initWithDBDic:(NSDictionary *)dic;

- (instancetype)initWithIMReceiverDic:(NSDictionary *)dic andObjectID:(long long)objectID;

- (NSMutableDictionary *)getRestoreDBDic;

- (NSDictionary *)getiMSendDic;

- (void)judgeShowTimeIndicator;

- (BOOL)judgeHaveBeenReceived;

@end
