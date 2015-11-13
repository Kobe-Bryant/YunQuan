//
//  MyselfMessageManager.h
//  LinkeBe
//
//  Created by yunlai on 14-9-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpRequest.h"
#import "Global.h"

@protocol MyselfMessageManagerDelegate <NSObject>

-(void)getMyselfMessageManagerHttpCallBack:(NSArray*) arr requestCallBackDic:(NSDictionary *)dic interface:(LinkedBe_WInterface) interface;

@end
@interface MyselfMessageManager : NSObject<HttpRequestDelegate>

@property(nonatomic,assign) id<MyselfMessageManagerDelegate> delegate;

//请求我的资料
-(void) accessMyselfMessageData:(NSMutableDictionary*) loginDic;

//退出登录
-(void) accessLoginOutMessageData:(NSMutableDictionary*) loginOutDic;

//请求与我有关的数据
-(void) accessRelevantMeData:(NSMutableDictionary*) relevantMeDic;

//修改资料
-(void) accessUpdateUserInfoData:(NSMutableDictionary *) updateDic;

//上传图片
-(void) accessUploadImage:(NSMutableDictionary *) updateDic parameterArray:(NSArray *)parameterArray;

//上传用户图像
-(void)accessUploadUserIcon:(NSMutableDictionary *) updateDic parameterArray:(NSArray *)parameterArray;

//上报当前用户liveApp的信息 /user/liveappinfo
-(void)accessUploadUserLiveappinfo:(NSMutableDictionary *) updateDic parameterArray:(NSArray *)parameterArray;

//消息提醒设置
-(void) accessSystemPush:(NSMutableDictionary*) paramDic;

//用户消息列表
-(void) accessUserSetInfo:(NSMutableDictionary*) paramDic;

@end
