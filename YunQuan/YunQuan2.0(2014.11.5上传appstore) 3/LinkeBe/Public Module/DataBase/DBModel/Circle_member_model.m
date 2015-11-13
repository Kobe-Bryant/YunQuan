//
//  Circle_member_model.m
//  LinkeBe
//
//  Created by Dream on 14-9-18.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "Circle_member_model.h"

@implementation Circle_member_model

+ (NSDictionary *)getMemberDicWithUserID:(long long)userID
{
    Circle_member_model * geter = [[Circle_member_model alloc]init];
    geter.where = [NSString stringWithFormat:@"userId = %lld",userID];
    NSArray * list = [geter getList];
    NSDictionary * resultDic = nil;
    if (list.count > 0) {
        resultDic = [list firstObject];
    }
    RELEASE_SAFE(geter);
    return resultDic;
}

+ (NSMutableArray *)getActiveMembers {
    Circle_member_model *model = [[Circle_member_model alloc]init];
    model.where = [NSString stringWithFormat:@"state = 2"];
    NSMutableArray *arr = [model getList];
    
    RELEASE_SAFE(model);
    return arr;
}

+ (NSMutableArray *)getNoForbidMembers {
    Circle_member_model *model = [[Circle_member_model alloc]init];
    model.where = [NSString stringWithFormat:@"state < 3"];
    NSMutableArray *arr = [model getList];
    RELEASE_SAFE(model);
    return arr;
}

//更改成员数据
+(void) updatePortraitWithDic:(NSDictionary *)dic{
    Circle_member_model* model = [[Circle_member_model alloc] init];
    model.where = [NSString stringWithFormat:@"userId = %d",[[dic objectForKey:@"userId"] intValue]];
    [model updateDB:dic];
    
    [model release];
}

//获取成员头像地址
+(NSString*) getMemberPortraitWithUserId:(int) userId{
    Circle_member_model* model = [[Circle_member_model alloc] init];
    model.where = [NSString stringWithFormat:@"userId = %d",userId];
    NSArray* arr = [model getList];
    
    [model release];
    
    if (arr.count) {
        return [[arr firstObject] objectForKey:@"portrait"];
    }
    
    return nil;
}

+(NSMutableArray *)getActiveMembersWithOrgId:(long long)orgId {
    Circle_member_model *memberModel = [[Circle_member_model alloc]init];
    memberModel.where = [NSString stringWithFormat:@"orgId = %lld and state = 2",orgId];
    NSMutableArray *arr = [memberModel getList];
    RELEASE_SAFE(memberModel);
    return arr;
}

+(NSMutableArray *)getMembersWithOrgId:(long long)orgId {
    Circle_member_model *memberModel = [[Circle_member_model alloc]init];
    memberModel.where = [NSString stringWithFormat:@"orgId = %lld",orgId];
    NSMutableArray *arr = [memberModel getList];
    RELEASE_SAFE(memberModel);
    return arr;
}

@end
