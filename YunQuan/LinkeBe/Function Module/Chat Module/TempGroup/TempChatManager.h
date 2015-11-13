//
//  TempContactManager.h
//  LinkeBe
//
//  Created by Dream on 14-9-27.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactModel.h"

@class TCCreateOrAddMemberData;

@protocol TempChatManagerDelegate <NSObject>

@optional
- (void)createTempChatSuccessWithCircleID:(long long)tempCircleID;

- (void)addMemberSuccessWithCircleID:(long long)tempCircleID;

- (void)refreshDetailInfoWithCircleID:(long long)tempCircleID;

- (void)quitTempCircleSuccess;

- (void)modifyTempChatNameSuccess:(NSDictionary *)dic;

@end

@interface TempChatManager : NSObject

+ (TempChatManager *)shareManager;

@property (nonatomic, assign) id <TempChatManagerDelegate>delegate;

//创建临时会话
- (void)createTempChatWithContactArr:(NSMutableArray *)contactArr;

//临时会话添加成员
- (void)addMembersToTempChat:(long long)tempChatId andMemberArr:(NSMutableArray *)contactArr;

//创建或添加临时圈子回调
- (void)createOrAddMemberAckWithDic:(NSDictionary *)ackDic andDataLocalID:(int)localID;

//临时会话成员变更处理
- (void)receiveMemberChangeWithCircleID:(long long)tempCircleID;

//临时会话信息变更通知处理
- (void)receiveInfoChangeWithCircleID:(long long)tempCircleID;

//主动退出临时会话
- (void)quitTempCircleWithCircleID:(long long)tempCircleID;

//主动退出临时会话回调
- (void)quitTempCircleSuccessWithLocalID:(int)localID;

//修改临时会话名称
- (void)modifyTempContactName:(long long)circleId  circleName:(NSString *)name;

- (void)retrieveTempCirleDetailWithTempCircleID:(long long)tempCircleID andWaitingData:(TCCreateOrAddMemberData *)waitingData;

//聚聚添加成员
- (void)addMembersToTogether:(long long)tempChatId andMemberArr:(NSMutableArray *)contactArr;

@end
