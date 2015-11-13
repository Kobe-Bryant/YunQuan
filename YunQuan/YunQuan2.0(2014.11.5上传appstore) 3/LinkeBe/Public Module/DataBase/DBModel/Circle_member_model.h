//
//  Circle_member_model.h
//  LinkeBe
//
//  Created by Dream on 14-9-18.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "db_model.h"

@interface Circle_member_model : db_model

+ (NSDictionary *)getMemberDicWithUserID:(long long)userID;

//选择激活成员
+ (NSMutableArray *)getActiveMembers;

+ (NSMutableArray *)getNoForbidMembers;

//更改成员数据
+(void) updatePortraitWithDic:(NSDictionary*) dic;

//获取成员头像地址
+(NSString*) getMemberPortraitWithUserId:(int) userId;

//根据组织id选择对应激活成员
+(NSMutableArray *)getActiveMembersWithOrgId:(long long)orgId;

//根据组织id所有成员
+(NSMutableArray *)getMembersWithOrgId:(long long)orgId;


@end
