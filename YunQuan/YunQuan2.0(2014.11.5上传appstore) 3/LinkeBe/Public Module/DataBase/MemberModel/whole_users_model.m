//
//  whole_users_model.m
//  ql
//
//  Created by LazySnail on 14-7-2.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "whole_users_model.h"

@implementation whole_users_model

+ (BOOL)insertOrUpdataUserInfoWithDic:(NSDictionary *)dic
{
    BOOL successJuger = NO;
    whole_users_model * listGeter = [whole_users_model new];
    listGeter.where = [dic objectForKey:@"user_account_name"];
    NSArray * currentList = [listGeter getList];
    if (currentList.count != 0) {
        
        NSMutableDictionary *updateDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [updateDic removeObjectForKey:@"user_account_name"];
        successJuger =  [listGeter updateDB:updateDic];
    } else{
        successJuger = [listGeter insertDB:dic];
    }
    RELEASE_SAFE(listGeter);
    return successJuger;
}

+ (NSDictionary *)selectUserInfoWithUserAccountName:(NSString *)userAccountName
{
    whole_users_model * listGeter = [whole_users_model new];
    listGeter.where = userAccountName;
    
    NSArray * list = [listGeter getList];
    RELEASE_SAFE(listGeter);
    if (list.count != 0) {
        return [list firstObject];
    } else {
        return nil;
    }
}

+ (NSNumber *)getPreviousOrgId
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:kPreviousOrgID];
}

@end
