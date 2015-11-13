
//
//  Cicle_member_list_model.h
//  LinkeBe
//
//  Created by Dream on 14-10-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "db_model.h"

@interface Cicle_member_list_model : db_model

+ (NSInteger)getMembersCountWithOrgId:(long long)orgId;

//根据组织获取成员 （可以获取不同组织的同一个人）
+ (NSMutableArray *)getMembersWithOrgId:(long long)orgId;

@end
