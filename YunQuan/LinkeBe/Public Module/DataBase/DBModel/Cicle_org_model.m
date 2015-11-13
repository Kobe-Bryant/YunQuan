//
//  Cicle_org_model.m
//  LinkeBe
//
//  Created by Dream on 14-9-22.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "Cicle_org_model.h"

@implementation Cicle_org_model

+ (BOOL)isOnlyFirstRankOrganization
{
    BOOL isOnlyFirstRankJudger = NO;
    Cicle_org_model * operator = [[Cicle_org_model alloc]init];
    operator.where = [NSString stringWithFormat:@"parentId = 0"];
    NSArray * arr = [operator getList];
    NSDictionary * firstRankDic = nil;
    if (arr.count > 0) {
        firstRankDic = [arr firstObject];
    }
    
    if (firstRankDic != nil) {
        operator.where = [NSString stringWithFormat:@"parentId = %@",[firstRankDic objectForKey:@"id"]];
        NSArray * subOrgArr = [operator getList];
        if (subOrgArr.count > 0) {
            isOnlyFirstRankJudger = NO;
        } else {
            isOnlyFirstRankJudger = YES;
        }
    }

    return isOnlyFirstRankJudger;
}

@end
