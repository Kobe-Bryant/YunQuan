//
//  Cicle_member_list_model.m
//  LinkeBe
//
//  Created by Dream on 14-10-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "Cicle_member_list_model.h"
#import "Circle_member_model.h"

@implementation Cicle_member_list_model

+ (NSInteger)getMembersCountWithOrgId:(long long)orgId {
    Cicle_member_list_model *model = [[Cicle_member_list_model alloc]init];
    model.where = [NSString stringWithFormat:@"orgId = %lld",orgId];
    NSArray *arr = [model getList];
    [model release];
    return arr.count;
}

+ (NSMutableArray *)getMembersWithOrgId:(long long)orgId {
    NSMutableArray *memberArray = [NSMutableArray array];
    
    Cicle_member_list_model *model = [[Cicle_member_list_model alloc]init];
    Circle_member_model *memberModel = [[Circle_member_model alloc]init];
    model.where = [NSString stringWithFormat:@"orgId = %lld",orgId];
    NSArray *arr = [model getList];
    if (arr.count > 0) {
        for (NSDictionary *dic in arr) {
            memberModel.where = [NSString stringWithFormat:@"userId = %lld and state < 3",[[dic objectForKey:@"userId"] longLongValue]];
            NSArray *array = [memberModel getList];
            if (array.count > 0) {
                NSDictionary *firstDic = [array firstObject];
                [memberArray addObject:firstDic];
            }
           
        }
    }
    [model release];
    [memberModel release];
    return memberArray;
}

@end
