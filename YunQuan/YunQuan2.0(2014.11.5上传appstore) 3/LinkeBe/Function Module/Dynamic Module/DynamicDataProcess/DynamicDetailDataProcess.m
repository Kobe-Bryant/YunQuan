//
//  DynamicDetailDataProcess.m
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "DynamicDetailDataProcess.h"

#import "Dynamic_card_model.h"

@implementation DynamicDetailDataProcess

//获取动态详情数据
+(NSArray*) getDynamicDetailDataWith:(NSDictionary*) dic{
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:0];
    
    if (dic) {
        NSNumber* ts = [dic objectForKey:@"ts"];
        
        NSDictionary* publishDic = [dic objectForKey:@"publish"];
        
        if (publishDic) {
            //获取动态详情数据并更新本地数据库
            int publishId = [[publishDic objectForKey:@"id"] intValue];
            int type = [[publishDic objectForKey:@"type"] intValue];
            long long created = [[publishDic objectForKey:@"createdTime"] longLongValue];
            
            NSDictionary* pDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:publishId],@"id",
                                  [NSNumber numberWithInt:type],@"type",
                                  [NSNumber numberWithLongLong:created],@"createdTime",
                                  [publishDic JSONRepresentation],@"content",
                                  ts,@"ts",
                                  nil];
            
            //更换用户头像
            [Circle_member_model updatePortraitWithDic:[NSDictionary dictionaryWithObjectsAndKeys:
                                                        [pDic objectForKey:@"userId"],@"userId",
                                                        [pDic objectForKey:@"portrait"],@"portrait",nil]];
            
            //插入数据库
            [Dynamic_card_model insertOrUpdateDynamicCardWithContentDic:pDic];
            
            [arr addObject:publishDic];
        }
    }
    
    return arr;
}

//获取动态详情评论回馈
+(NSArray*) getDynamicDetailCommentBackWith:(NSDictionary*) dic{
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:0];
    
    if (dic) {
        [arr addObject:dic];
    }
    
    return arr;
}

//评论列表
+(NSArray*) getCommentListWith:(NSDictionary*) dic{
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:0];
    
    if (dic) {
        [arr addObject:dic];
    }
    
    return arr;
}

//删除评论回馈
+(NSArray*) getCommentDeleteBackWith:(NSDictionary*) dic{
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:0];
    
    if (dic) {
        [arr addObject:dic];
    }
    
    return arr;
}

//删除动态回馈
+(NSArray*) getDynamicDeleteBackWith:(NSDictionary *)dic{
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:0];
    
    if (dic) {
        [arr addObject:dic];
    }
    
    return arr;
}

@end
