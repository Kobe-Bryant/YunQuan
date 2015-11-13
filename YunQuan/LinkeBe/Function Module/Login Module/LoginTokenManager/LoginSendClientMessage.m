//
//  LoginSendClientMessage.m
//  LinkeBe
//
//  Created by yunlai on 14-9-25.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "LoginSendClientMessage.h"
#import "UserModel.h"
#import "AppDelegate.h"
#import "LinkedBeHttpRequest.h"
#import "SnailSocketManager.h"
#import "NSObject_extra.h"

@implementation LoginSendClientMessage

- (id)init{
    self = [super init];
    if (self) {
   
    }
    return self;
}

-(void) accessLoginSendClientMessageData:(NSMutableDictionary *)loginDic requestType:(LinkedBe_RequestType)requestType{
    
    NSMutableDictionary* requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"client_credentials",@"grant_type",
                                       [UserModel shareUser].clientIdString,@"client_id",
                                       @"read write",@"scope",
                                       nil];
    
    [[LinkedBeHttpRequest shareInstance] requestAccessTokenDelegate:self parameterDictionary:requestDic parameterArray:nil parameterString:nil];

}

//时间超时
- (BOOL)overTimeLimit{
    if (![UserModel shareUser].user_id||![UserModel shareUser].orgUserId||![UserModel shareUser].org_id) {
        return NO;
    }else{
        NSTimeInterval secondsInterval= [[UserModel shareUser].expires_limit_inDate timeIntervalSinceDate:[NSDate date]];
        if (secondsInterval>0) {
            return YES;
        }else{
            [self alertWithFistButton:@"确定" SencodButton:nil Message:@"登录失败"];
            [self backLoginView];
            return NO;
        }
    }
  
    return NO;
}

-(void)backLoginView{

    [SnailSocketManager breakConnect];

    [[UserModel shareUser] clearUserInfo];
    
    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appdelegate initGuidePageVc];
}


-(NSString*)authorizationReturn{
    NSString *authorizationString;
    if ([self overTimeLimit]) {
        authorizationString = [NSString stringWithFormat:@"Bearer %@",[UserModel shareUser].access_tokenString];
    }else if([UserModel shareUser].clientIdString&&[UserModel shareUser].clientSecretString){
        authorizationString = [self encryptionString];
    }else{
        authorizationString = nil;
    }
    return authorizationString;
}

//第一次登陆的时候的取得数据
-(NSString*)encryptionString{
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", [UserModel shareUser].clientIdString, [UserModel shareUser].clientSecretString];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
    
    return authValue;
}

#pragma mark - httpback
-(void)didFinishCommand:(NSDictionary *)jsonDic cmd:(int)commandid withVersion:(int)ver{
    NSArray* loginOrgArr = nil;
    
    switch (commandid) {
        case LinkedBe_Token_Secert:
        {
//            获取当前的token成功以后，清楚当前客户端的id和secret
            [UserModel shareUser].clientIdString = nil;
            [UserModel shareUser].clientSecretString = nil;
            [[NSUserDefaults standardUserDefaults] setObject:[UserModel shareUser].clientIdString forKey:LikedBe_ClientId];
            [[NSUserDefaults standardUserDefaults] setObject:[UserModel shareUser].clientSecretString forKey:LikedBe_ClientSecret];
            
            [[NSUserDefaults standardUserDefaults] setObject:[jsonDic objectForKey:@"access_token"] forKey:LikedBe_Access_Token];
            [[NSUserDefaults standardUserDefaults] setObject:[jsonDic objectForKey:@"expires_in"] forKey:LikedBe_Expires_In];
            [[NSUserDefaults standardUserDefaults] setObject:[[NSDate date] dateByAddingTimeInterval:[[jsonDic objectForKey:@"expires_in"] intValue]] forKey:LikedBe_Expires_Limit_In];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //保存当前的用户的userid
            [UserModel shareUser].access_tokenString = [[NSUserDefaults standardUserDefaults] objectForKey:LikedBe_Access_Token];//[jsonDic objectForKey:@"access_token"];
            [UserModel shareUser].expires_inString = [[NSUserDefaults standardUserDefaults] objectForKey:LikedBe_Expires_In];//[jsonDic objectForKey:@"expires_in"];
            [UserModel shareUser].expires_limit_inDate = [[NSUserDefaults standardUserDefaults] objectForKey:LikedBe_Expires_Limit_In];//[[NSDate date] dateByAddingTimeInterval:[[jsonDic objectForKey:@"expires_in"] intValue]];
        }
            break;
        default:
            break;
    }
    [_delegate getLoginSendClientMessaHttpCallBack:loginOrgArr dic:jsonDic interface:LinkedBe_Token_Secert];
}


@end
