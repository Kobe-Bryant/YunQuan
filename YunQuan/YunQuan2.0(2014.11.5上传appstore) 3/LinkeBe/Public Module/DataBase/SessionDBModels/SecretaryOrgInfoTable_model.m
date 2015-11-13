//
//  SecretaryOrgInfoTable_model.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SecretaryOrgInfoTable_model.h"

@implementation SecretaryOrgInfoTable_model

+ (BOOL)insertOrUpdateInfoWithDic:(NSDictionary *)dic
{
    SecretaryOrgInfoTable_model * inserter = [[SecretaryOrgInfoTable_model alloc]init];
    inserter.where = [NSString stringWithFormat:@"uid = %lld",[[dic objectForKey:@"uid"] longLongValue]];
   return [db_model updateDataWithModel:inserter withDic:dic];
}

+ (NSDictionary *)getObjectInfoDicWithObject_type:(SpecialContect)type
{
    SecretaryOrgInfoTable_model * geter = [[SecretaryOrgInfoTable_model alloc]init];
    geter.where = [NSString stringWithFormat:@"type = %d",type];
    NSArray * list = [geter getList];
    NSDictionary * resultDic = nil;
    if (list.count > 0) {
        resultDic = [list firstObject];
    }
    return resultDic;
}

@end
