//
//  whole_users_model.h
//  ql
//
//  Created by LazySnail on 14-7-2.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "application_db_model.h"

@interface whole_users_model : application_db_model

+ (BOOL)insertOrUpdataUserInfoWithDic:(NSDictionary *)dic;

+ (NSDictionary *)selectUserInfoWithUserAccountName:(NSString *)userAccountName;

+ (NSNumber *)getPreviousOrgId;

@end
