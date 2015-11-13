//
//  DynamicIMManager.h
//  LinkeBe
//
//  Created by yunlai on 14-9-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SessionDataOperator.h"
#import "TempChatManager.h"

@protocol DynamicIMDelegate <NSObject>

//删除动态回调
-(void) receiveDynamicDeleteWithDic:(NSDictionary*) dic;

@end

typedef void(^ReceiveCallBackBlock)(void);
typedef void(^DyanmicDeleteNotify)(void);

@interface DynamicIMManager : NSObject

@property(nonatomic,assign) id<DynamicIMDelegate> DimDelegate;

@property(nonatomic,assign) long long circleId;
@property(nonatomic,retain) NSDictionary* msgDic;//发送聚聚消息数据
@property(nonatomic,assign) BOOL isNew;
@property(nonatomic,copy) ReceiveCallBackBlock callBackBlock;
@property(nonatomic,assign) int tabbarSelectIndexWhenHaveNew;

+(id) shareManager;

@property(nonatomic,copy) DyanmicDeleteNotify ddeleteNotifyBlock;

//加入临时会话
-(void) addToTempContact:(NSDictionary*) dic msgDic:(NSDictionary*) msgdic  block:(ReceiveCallBackBlock) block;

//发送聚聚消息
-(void) sendTogetherMessage:(NSDictionary*) dic;

//发送我有消息
-(void) sendHaveMessage:(NSDictionary*) dic block:(ReceiveCallBackBlock) block;

//发送我要消息
-(void) sendWantMessage:(NSDictionary*) dic block:(ReceiveCallBackBlock) block;

//发送我有消息回调
-(void) receiveHaveCallBack:(NSDictionary*) dic;

//发送我要消息回调
-(void) receiveWantCallBack:(NSDictionary*) dic;

//加入临时会话回调
-(void) receiveAddToTempContact:(NSDictionary*) dic;

//发送聚聚消息回调
-(void) receiveTogetherMessage:(NSDictionary*) dic;

//新动态提醒
-(void) receiveNewDynamicNotify:(NSDictionary*) dic;

//取消新动态红点
-(void) cancelNewDynamicNotify;

//删除动态消息处理
-(void) receiveDynamicDeleteNotify:(NSDictionary*) dic;

@end
