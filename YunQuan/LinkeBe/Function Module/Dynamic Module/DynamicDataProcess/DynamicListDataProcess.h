//
//  DynamicListDataProcess.h
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DynamicListDataProcess : NSObject

//获取动态列表数据
+(NSArray*) getDynamicListDataWith:(NSDictionary*) dic;

//获取快速评论请求回馈
+(NSArray*) getDynamicListFastCommonBackWith:(NSDictionary*) dic;

//查询用户发布动态权限
+(NSArray*) getPermissionListWith:(NSDictionary*) dic;

//获取我的动态列表
+(NSArray*) getMyDynamicWith:(NSDictionary*) dic;

@end
