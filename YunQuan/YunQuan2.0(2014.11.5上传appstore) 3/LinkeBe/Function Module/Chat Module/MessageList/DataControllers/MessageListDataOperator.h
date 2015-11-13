//
//  MessageListDataOperator.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-18.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageData.h"
#import "MessageListData.h"

@protocol MessageListDataOperatorDelegate <NSObject>

- (void)getFirstInWelcomeMessageSuccessWithDataArr:(NSMutableArray *)dataArray;

- (void)receiveNewDataMessage:(MessageData *)message;

@end

@interface MessageListDataOperator : NSObject

@property (nonatomic, assign) id <MessageListDataOperatorDelegate> delegate;

+ (MessageListDataOperator *)shareOperator;

- (BOOL)isFirstInMessageListView;

//请求第一次进入聊天欢迎信息
- (void)getFirstInWelcomeMessage;

//判断首次安装，下载已安装表情
- (void)getFirstInstallEmotion;

/**
 *
 *  获取数据库列表
 */
- (NSMutableArray *)getDBMessageListDataArr;

- (void)listReceiveNewMessage:(MessageData *)message;

- (void)cleanUnreadSignForChatObjectID:(long long)objectID andSessionType:(SessionType)type;

/**
 *
 *  数据操作
 */
- (void)deleteDBRecordWithListData:(MessageListData *)listData;


//获取所有未读消息数
+ (NSInteger)getAllUnreadMessageCount;

@end
