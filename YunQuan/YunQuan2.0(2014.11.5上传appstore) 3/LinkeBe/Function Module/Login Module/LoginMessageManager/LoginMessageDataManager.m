//
//  LoginMessageDataManager.m
//  LinkeBe
//
//  Created by yunlai on 14-9-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "LoginMessageDataManager.h"
#import "LinkedBeHttpRequest.h"
#import "LoginMessageDataProcess.h"
#import "Global.h"
#import "UserModel.h"


@implementation LoginMessageDataManager

//登陆和注册以及修改密码
-(void) accessLoginMessageData:(NSMutableDictionary*) loginDic requestType:(LinkedBe_RequestType)requestType{
    
    [[LinkedBeHttpRequest shareInstance] requsetUserLogin:self parameterDictionary:loginDic parameterArray:nil requestType:requestType];

}

//检测当前的手机号码是否已经在组织后台注册过了
-(void) accessValidatemobile:(NSMutableDictionary *) validatemobile{
    [[LinkedBeHttpRequest shareInstance] requestValidatemobileDelegate:self parameterDictionary:validatemobile parameterArray:nil parameterString:nil];
}

//发送验证码
-(void) accessSendAuthCodeService:(NSMutableDictionary *) authCodeDic{
    
    [[LinkedBeHttpRequest shareInstance] requestSendauthcodeDelegate:self parameterDictionary:authCodeDic parameterArray:nil parameterString:nil];
    
}

//手机验证码验证
-(void) acessIdentifycode:(NSMutableDictionary *) authCodeDic{
    [[LinkedBeHttpRequest shareInstance] acessIdentifycodeDelegate:self parameterDictionary:authCodeDic parameterArray:nil parameterString:nil];
    
}

//重置密码
-(void) acessResetPassword:(NSMutableDictionary *) resetPwd{
    [[LinkedBeHttpRequest shareInstance] accessResetPasswordDelegate:self parameterDictionary:resetPwd parameterArray:nil parameterString:nil];
}

#pragma mark - httpback
-(void)didFinishCommand:(NSDictionary *)jsonDic cmd:(int)commandid withVersion:(int)ver{
    NSArray* loginOrgArr = nil;
    
    switch (commandid) {
        case LinkedBe_USER_Login:
        {
            //保存当前的用户的id 和 clientId 和 clientSecret
            [[NSUserDefaults standardUserDefaults] setObject:[jsonDic objectForKey:@"userId"] forKey:LikedBe_UserId];
            [[NSUserDefaults standardUserDefaults] setObject:[jsonDic objectForKey:@"clientId"] forKey:LikedBe_ClientId];
            [[NSUserDefaults standardUserDefaults] setObject:[jsonDic objectForKey:@"clientSecret"] forKey:LikedBe_ClientSecret];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //        保存当前的用户的userid
            [UserModel shareUser].user_id = [[NSUserDefaults standardUserDefaults] objectForKey:LikedBe_UserId];
            [UserModel shareUser].clientIdString = [[NSUserDefaults standardUserDefaults] objectForKey:LikedBe_ClientId];            [UserModel shareUser].clientSecretString =  [[NSUserDefaults standardUserDefaults] objectForKey:LikedBe_ClientSecret];
            
            loginOrgArr = [LoginMessageDataProcess getOrgListDataWith:jsonDic];
        }
            break;
        case LinkedBe_SendAuthcode://发送验证码
        {
                      
        }
            break;
        case LinkedBe_Identifycode://验证验证码
        {
            
            
        }
            break;
        case LinkedBe_ResetPassword://重置密码
        {
            
        }
            break;
        case LinkedBe_Validatemobile://重置密码
        {
            
        }
            break;
        default:
            break;
    }
    [_delegate getLoginMessageHttpCallBack:loginOrgArr requestCallBackDic:jsonDic interface:commandid];
}


@end
