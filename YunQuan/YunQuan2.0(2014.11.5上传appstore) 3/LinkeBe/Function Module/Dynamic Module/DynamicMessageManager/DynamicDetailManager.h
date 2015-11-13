//
//  DynamicDetailManager.h
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DynamicCommon.h"

@protocol DynamicDetailManagerDelegate <NSObject>

//动态列表网络请求回调
-(void) getDynamicDetailHttpCallBack:(NSArray*) arr interface:(LinkedBe_WInterface) interface;

@end

@interface DynamicDetailManager : NSObject

@property(nonatomic,assign) id<DynamicDetailManagerDelegate> delegate;

//动态详情
-(void) accessDynamicDetailWith:(NSDictionary*) dic;

//评论列表
-(void) accessCommentListWith:(NSDictionary*) dic;

//动态详情评论
-(void) accessDynamicDetailComment:(NSMutableDictionary*) dic;

//删除评论
-(void) accessCommentDeleteWith:(NSDictionary*) dic;

//删除动态
-(void) accessDynamicDeleteWith:(NSDictionary*) dic;

@end
