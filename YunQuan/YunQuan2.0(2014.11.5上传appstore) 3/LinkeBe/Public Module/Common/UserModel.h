//
//  UserModel.h
//  LinkeBe
//
//  Created by yunlai on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject
+ (UserModel *)shareUser;

@property (nonatomic, retain) NSNumber *user_id;//用户ID
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *userPortrait;

@property (nonatomic, retain) NSNumber *org_id; //组织方ID
@property (nonatomic, retain) NSNumber *orgUserId;//组织方用户id

@property(nonatomic,retain) NSDictionary* secretInfo;       //小秘书信息
@property(nonatomic,retain) NSDictionary* organizationInfo; //组织方信息

@property(nonatomic,retain) NSDictionary* userInfo; //用户信息
@property(nonatomic,retain) NSString *realnameString ;//用户的姓名
@property(nonatomic,retain) NSString *portraitString ;//头像

@property(nonatomic,retain) NSString *clientIdString;//当前的用户的加密的id
@property(nonatomic,retain) NSString *clientSecretString;//当前的服务器加密的秘钥

@property(nonatomic,retain) NSString *access_tokenString;//当前的token的值
@property(nonatomic,retain) NSString *expires_inString; //当前的token过期的时间多少秒
@property(nonatomic,retain) NSDate *expires_limit_inDate; //从token到过期的时间点


@property(nonatomic,retain) NSString *privilegeBigImage;

//@property(nonatomic,retain) NSString *provinceString;//省份
//@property(nonatomic,retain) NSString *cityString; //城市
//@property(nonatomic,retain) NSString *tradeString; //行业

@property(nonatomic,assign) BOOL isBackGround;

@property(nonatomic,assign) BOOL isHavePermission;//是否有发布动态权限


- (void)saveUserInfo;

- (void)getUserInfo;

- (void)clearUserInfo;


+ (BOOL)isChineseLanguage;

+ (NSString *)currentLanguage;

+ (NSLocale *) currentLocale;

+ (NSString *)currentCountryCode;

+ (BOOL)isChinaLocaleCode;

@end
