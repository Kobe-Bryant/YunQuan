//
//  DynamicListManager.h
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DynamicCommon.h"

@protocol DynamicListManagerDelegate <NSObject>

@optional
//动态列表网络请求回调
-(void) getDynamicListHttpCallBack:(NSArray*) arr interface:(LinkedBe_WInterface) interface;

@end

@interface DynamicListManager : NSObject

@property(nonatomic,assign) id<DynamicListManagerDelegate> delegate;

//请求动态列表
-(void) accessDynamicList:(NSMutableDictionary*) dic;

//发送快捷评论
-(void) accessDynamicListCommentwithParam:(NSMutableDictionary*) param;

//查询发布动态权限
-(void) checkPublishPermissionWithParam:(NSDictionary*) param;

//请求我的动态
-(void) accessMyDynamic:(NSMutableDictionary*) dic;

@end
