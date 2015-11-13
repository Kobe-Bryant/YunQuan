//
//  MajorCicleProcess.h
//  LinkeBe
//
//  Created by Dream on 14-9-18.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MajorCicleProcess : NSObject

//三级组织
+ (NSArray *)getThreeCircleDataWith:(NSDictionary*) dic;

//组织成员
+ (NSArray *)getCircleMembwesDataWith:(NSDictionary*) dic;

//名片
+ (NSArray *)getBusinessCardDataWith:(NSDictionary *)dic;

//临时会话详情
+ (NSArray *)getDetailTempChatDataWith:(NSDictionary *)dic;

//x修改临时会话名称
+ (NSArray *)getModidyTempChatNameDataWith:(NSDictionary *)dic;

//商务助手
+ (NSArray *)getOrgToolsDataWith:(NSDictionary *)dic ;

//商务特权
+ (NSArray *)getSystemPrivilegeDataWith:(NSDictionary *)dic;

//注册邀请
+ (NSArray *)getUserInviteDataWith:(NSDictionary *)dic;

@end
