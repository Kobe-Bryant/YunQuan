//
//  message_push_model.m
//  LinkeBe
//
//  Created by yunlai on 14-10-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "message_push_model.h"

@implementation message_push_model

//更新状态
+(void) updateOrInsertPushStatus:(NSDictionary*) dic{
    message_push_model* model = [[message_push_model alloc] init];
    int userId = [[dic objectForKey:@"userId"] intValue];
    model.where = [NSString stringWithFormat:@"userId = %d",userId];
    if ([model getList].count) {
        [model updateDB:dic];
    }else{
        [model insertDB:dic];
    }
    
    [model release];
}

//获取用户的推送设置信息
+(NSDictionary*) getMessagePushInfoWithUserId:(int) userId{
    NSDictionary* dic = nil;
    
    message_push_model* model = [[message_push_model alloc] init];
    model.where = [NSString stringWithFormat:@"userId = %d",userId];
    NSArray* arr = [model getList];
    
    [model release];
    
    if (arr.count) {
        dic = [arr firstObject];
    }
    
    return dic;
}

@end
