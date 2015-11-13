//
//  DynamicDetailDataProcess.h
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DynamicDetailDataProcess : NSObject

//获取动态详情数据
+(NSArray*) getDynamicDetailDataWith:(NSDictionary*) dic;

//获取动态详情评论回馈
+(NSArray*) getDynamicDetailCommentBackWith:(NSDictionary*) dic;

//评论列表
+(NSArray*) getCommentListWith:(NSDictionary*) dic;

//删除评论回馈
+(NSArray*) getCommentDeleteBackWith:(NSDictionary*) dic;

//删除动态
+(NSArray*) getDynamicDeleteBackWith:(NSDictionary*) dic;

@end
