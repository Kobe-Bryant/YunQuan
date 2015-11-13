//
//  LoginSendClientMessage.h
//  LinkeBe
//
//  Created by yunlai on 14-9-25.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpRequest.h"

@protocol LoginSendClientMessageDelegate <NSObject>

-(void)getLoginSendClientMessaHttpCallBack:(NSArray*)arr dic:(NSDictionary *)dic interface:(LinkedBe_WInterface) interface;

@end

@interface LoginSendClientMessage : NSObject<HttpRequestDelegate>
@property(nonatomic,assign) id<LoginSendClientMessageDelegate> delegate;

-(void) accessLoginSendClientMessageData:(NSMutableDictionary*) loginDic requestType:(LinkedBe_RequestType)requestType;

//判断当前的时间是否过期
-(BOOL)overTimeLimit;

-(NSString*)authorizationReturn;

//第一次登陆的时候的取得数据
-(NSString*)encryptionString;
@end
