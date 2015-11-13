//
//  UserModel.m
//  LinkeBe
//
//  Created by yunlai on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//
#import "UserModel.h"

@implementation UserModel
@synthesize user_id;
@synthesize org_id;
@synthesize orgUserId;
@synthesize secretInfo;
@synthesize organizationInfo;
@synthesize userInfo;
@synthesize clientIdString;
@synthesize clientSecretString;
@synthesize access_tokenString;
@synthesize expires_inString;
@synthesize expires_limit_inDate;
@synthesize isHavePermission;
@synthesize realnameString;//用户的姓名
@synthesize portraitString;//头像

@synthesize privilegeBigImage;

//@synthesize provinceString;//省份
//@synthesize cityString; //城市
//@synthesize tradeString;//行业

@synthesize isBackGround;

+ (UserModel *)shareUser
{
    static UserModel *user = nil;
    if (user == nil) {
        user = [[UserModel alloc] init];
        
    }
    return user;
}

+ (BOOL)isChineseLanguage
{
    NSRange range = [[UserModel currentLanguage] rangeOfString:@"zh-"];
    return range.length >0;
}

+ (NSString *)currentLanguage{
    NSArray *preferedLanguages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [preferedLanguages firstObject];
    return currentLanguage;
}

+ (NSLocale *) currentLocale{
    NSLocale *currentLocale = [NSLocale currentLocale];
    return currentLocale;
}

+ (NSString *)currentCountryCode
{
    NSString *code = [[UserModel currentLocale] objectForKey:NSLocaleCountryCode];
    return code;
}

+ (BOOL)isChinaLocaleCode
{
    NSRange range = [[UserModel currentCountryCode]rangeOfString:@"CN"];
    return range.length >0;
}



- (id)init{
    self = [super init];
    if (self) {
        [self getUserInfo];
    }
    return self;
}

- (void)clearUserInfo{
    self.user_id = nil;
    self.userName = nil;
    self.userPortrait = nil;
    self.org_id = nil;
    self.orgUserId = nil;
    self.secretInfo = nil;
    self.organizationInfo = nil;
    self.userInfo = nil;
    self.realnameString = nil;
    self.portraitString = nil;
    self.clientIdString = nil;
    self.clientSecretString = nil;
    self.access_tokenString = nil;
    self.expires_inString = nil;
    self.expires_limit_inDate = nil;
    [self saveUserInfo];
}
#pragma mark ---
- (void)saveUserInfo{
    //保存用户当前的信息 用于自动登录
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:self.user_id forKey:LikedBe_UserId];
    [userDefault setObject:self.org_id forKey:LikedBe_Org_Id];
    [userDefault setObject:self.orgUserId forKey:LikedBe_OrgUserId];
    [userDefault setObject:self.clientIdString forKey:LikedBe_ClientId];
    
    [userDefault setObject:self.clientSecretString forKey:LikedBe_ClientSecret];
    [userDefault setObject:self.access_tokenString forKey:LikedBe_Access_Token];
    [userDefault setObject:self.expires_inString forKey:LikedBe_Expires_In];
    [userDefault setObject:self.expires_limit_inDate forKey:LikedBe_Expires_Limit_In];
    [NSUserDefaults resetStandardUserDefaults];
}


- (void)getUserInfo{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    self.user_id = [userDefault objectForKey:LikedBe_UserId];
    self.org_id = [userDefault objectForKey:LikedBe_Org_Id];
    self.orgUserId = [userDefault objectForKey:LikedBe_OrgUserId];
    self.clientIdString = [userDefault objectForKey:LikedBe_ClientId];
    self.clientSecretString = [userDefault objectForKey:LikedBe_ClientSecret];
    self.access_tokenString = [userDefault objectForKey:LikedBe_Access_Token];
    self.expires_inString = [userDefault objectForKey:LikedBe_Expires_In];
    self.expires_limit_inDate = [userDefault objectForKey:LikedBe_Expires_Limit_In];
}

- (void)dealloc
{
    self.org_id = nil;
    self.user_id = nil;
    [super dealloc];
}

@end
