//
//  MessageListData.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-17.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "MessageListData.h"
#import "SBJson.h"
#import "SpeakerData.h"
#import "MessageData.h"



@implementation MessageListData

+ (MessageListData *)generateOriginListDataWithObjectID:(long long)objectID andSessionType:(SessionType)type
{
    MessageListData * turnListData = [[MessageListData alloc]init];
    turnListData.ObjectID = objectID;
   
    
    //为了保证唯一性 会话对象的属性由 sessionType 确定，而Messagedata只存在于latestMessage中
    //所以仿照一个消息对象带入会话对象属性
    MessageData * simulateLatestMessage = [[MessageData alloc]init];
    simulateLatestMessage.sessionType = type;
    simulateLatestMessage.objectID = objectID;
    
    turnListData.latestMessage = simulateLatestMessage;
    
    ObjectData * object = [ObjectData objectForLatestMessage:simulateLatestMessage];
    turnListData.title = object.objectName;
    turnListData.portrairt = object.objectPortrait;
    RELEASE_SAFE(simulateLatestMessage);
    return [turnListData autorelease];
}

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [self init];
    if (self) {
        self.ObjectID = [[dic objectForKey:@"object_id"]longLongValue];
        self.latestMessage = [[[MessageData alloc]initWithDBDic:[[dic objectForKey:@"latest_message"] JSONValue]]autorelease];
        self.unreadCount = [[dic objectForKey:@"unread_count"]intValue];
        ObjectData * object = [ObjectData objectForLatestMessage:self.latestMessage];
        self.title = object.objectName;
        self.portrairt = object.objectPortrait;
    }
    return self;
}

- (NSMutableDictionary *)getResoreDic
{
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithLongLong:self.ObjectID],@"object_id",
                                      [NSNumber numberWithInt:self.latestMessage.sessionType],@"session_type",
                                      [NSNumber numberWithInt:self.unreadCount],@"unread_count",
                                      [[self.latestMessage getRestoreDBDic] JSONRepresentation],@"latest_message",
                                      nil];
    return resultDic;
}

- (MessageData *)generateSendOriginData
{
    MessageData * messageData = [[MessageData alloc]init];
    messageData.objectID = self.ObjectID;
    messageData.sessionType = self.latestMessage.sessionType;
    messageData.operationType = MessageOperationTypeSend;
    messageData.sendtime = [self getCurrentTimeStamp];
    messageData.msgid = [self getCurrentTimeStamp] * MessageMidPlus;
    messageData.statusType = MessageStatusTypeSendFailed;
    ObjectData * selfObject = [ObjectData objectFromMemberListWithID:[[[UserModel shareUser] user_id] longLongValue]];
    messageData.speaker = (SpeakerData *)selfObject;
    
    [messageData judgeShowTimeIndicator];
    return [messageData autorelease];
}

- (NSTimeInterval)getCurrentTimeStamp
{
    NSTimeInterval resultTime = [[NSDate date]timeIntervalSince1970];
    return resultTime;
}

- (void)dealloc
{
    self.portrairt = nil;
    self.title = nil;
    self.latestMessage = nil;
    [super dealloc];
}

@end
