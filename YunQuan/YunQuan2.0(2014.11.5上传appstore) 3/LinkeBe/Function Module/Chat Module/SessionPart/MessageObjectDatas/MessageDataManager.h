//
//  MessageDataManager.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageData.h"

@interface MessageDataManager : NSObject


+ (MessageDataManager *)shareMessageDataManager;

//存储消息数据到数据库 用于圈子消息 和单聊
- (BOOL)restoreData:(MessageData *)msgdata;

//刷新数据库消息数据
- (BOOL)updateData:(MessageData *)msgData;

//根据消息类型talk_type和聊天双方id来删除对应的聊天数据
+ (BOOL)deleteChatDBdataWithTalkType:(SessionType) talkType andObjectID:(long long)objectID;

//删除数据库对应消息记录
+ (BOOL)deleteDBChatMessage:(MessageData *)data;

+ (MessageData *)generateSendModelData;

@end
