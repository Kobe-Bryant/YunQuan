//
//  LoginMessageDataManager.h
//  LinkeBe
//
//  Created by yunlai on 14-9-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpRequest.h"
#import "Global.h"

@protocol LoginMessageDataManagerDelegate <NSObject>

-(void)getLoginMessageHttpCallBack:(NSArray*) arr requestCallBackDic:(NSDictionary *)dic interface:(LinkedBe_WInterface) interface;

@end

@interface LoginMessageDataManager : NSObject<HttpRequestDelegate>

@property(nonatomic,assign) id<LoginMessageDataManagerDelegate> delegate;

//登陆和修改密码的
-(void) accessLoginMessageData:(NSMutableDictionary*) loginDic requestType:(LinkedBe_RequestType)requestType;

//发送验证码
-(void) accessSendAuthCodeService:(NSMutableDictionary *) authCodeDic;

-(void) accessValidatemobile:(NSMutableDictionary *) validatemobile;

//手机验证码验证
-(void) acessIdentifycode:(NSMutableDictionary *) authCodeDic;

//重置密码
-(void) acessResetPassword:(NSMutableDictionary *) resetPwd;

@end
