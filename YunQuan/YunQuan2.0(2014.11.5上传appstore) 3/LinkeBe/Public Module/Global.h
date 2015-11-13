//
//  Global.h
//  LinkeBe
//
//  Created by yunlai on 14-9-1.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

/*引入各个模块的图片资源头文件*/
#import "pic_LinkeBe_Login.h" /*登录页面的图片资源*/
#import "pic_LinkeBe_PhoneBook.h"/*圈子页面的图片资源*/
#import "pic_LinkedBe_Dynamic.h"/*动态页面的图片资源*/
#import "pic_LinkedBe_Myself.h"/*我的页面的图片资源*/
#import "pic_LinkedBe_Chat.h"/*聊天的页面的图片资源*/
#import "pic_LinkedBe_Common.h"/*公用的页面的图片资源*/

/*********************接口*********************/
#import "interface_LinkedBe.h"
#import "UIImageScale.h"
#import "TimeStamp_LinkedBe.h" /*时间戳*/

#define LinkeBe_ENVIRONMENT 5//0:int 开发环境 1:stg 外网测试环境 2:prd 生产环境  3:内网测试环境  999:挡板环境  5外网域名

/*********************int环境*********************/ 
#if LinkeBe_ENVIRONMENT==0
#define HTTPURLPREFIX @"http://192.168.1.57:8080/appapi"
#define SOCKETIP      @"192.168.1.55"
#define SOCKETPORT    8100
#define LIGHTAPPURL   @"http://yunquan.yunlai.cn/common/index/company_app"//企业开通轻App链接
#define SERVICEDELEGATE @"http://yunquan.yunlai.cn/common/index/agreement"
#define LikeBe_COURSE @"" //其他的接口的，例如微课程的接口，如果当前的接口和 HTTPURLPREFIX 这个接口的不一样可以分别在当前的对应的环境下添加.

/*********************stg环境*********************/
#elif LinkeBe_ENVIRONMENT==1
#define HTTPURLPREFIX   @"http://182.254.189.127:8080/appapi" //Java 服务器地址
#define SOCKETIP        @"182.254.189.127" // iM 服务器地址
#define SOCKETPORT      8100
#define LIGHTAPPURL   @"http://yunquan.yunlai.cn/common/index/company_app"//企业开通轻App链接
#define SERVICEDELEGATE @"http://yunquan.yunlai.cn/common/index/agreement"

/*********************prd环境*********************/
#elif LinkeBe_ENVIRONMENT==2
#define HTTPURLPREFIX @"http://ql.yunlai.cn:8080/appapi"//Java 服务器地址
#define SOCKETIP      @"im.yunlai.cn"   // iM 服务器地址
#define SOCKETPORT    8100
#define LIGHTAPPURL   @"http://yunquan.yunlai.cn/common/index/company_app"//企业开通轻App链接
#define SERVICEDELEGATE @"http://yunquan.yunlai.cn/common/index/agreement"

/*********************内网测试环境*********************/
#elif LinkeBe_ENVIRONMENT==3
#define HTTPURLPREFIX @"http://192.168.1.47:8080/appapi"////Java 服务器地址
#define SOCKETIP      @"192.168.1.45"   // iM 服务器地址
#define SOCKETPORT    8100
#define LIGHTAPPURL   @"http://yunquan.yunlai.cn/common/index/company_app"//企业开通轻App链接
#define SERVICEDELEGATE @"http://yunquan.yunlai.cn/common/index/agreement"

/*********************本地主机*********************/
#elif LinkeBe_ENVIRONMENT==4
#define HTTPURLPREFIX @"http://192.168.1.195:8080/appapi"
#define SOCKETIP      @"192.168.1.55"
#define SOCKETPORT    8100
#define LIGHTAPPURL   @"http://yunquan.yunlai.cn/common/index/company_app"//企业开通轻App链接
#define SERVICEDELEGATE @"http://yunquan.yunlai.cn/common/index/agreement"

/*********************外网域名环境*********************/
#elif LinkeBe_ENVIRONMENT==5
#define HTTPURLPREFIX   @"http://yq.yunlai.cn/appapi" //Java 服务器地址
#define SOCKETIP        @"imv2.yunlai.cn" // iM 服务器地址
#define SOCKETPORT      8100
#define LIGHTAPPURL   @"http://yq.yunlai.cn/common/index/company_app"//企业开通轻App链接
#define SERVICEDELEGATE @"http://yq.yunlai.cn/common/index/agreement"

/*********************挡板环境*********************/
#elif LinkeBe_ENVIRONMENT==999
#define HTTPURLPREFIX @"http://192.168.0.2"
#define SOCKETIP      @"192.168.1.55" // iM 服务器地址
#define SOCKETPORT    8100
#define LIGHTAPPURL   @"http://yunquan.yunlai.cn/common/index/company_app"//企业开通轻App链接
#endif

//默认Http请求timeout时限
#define kHttpTimeOutTime        30

// KeyWindow
#define APPKEYWINDOW                [[UIApplication sharedApplication] keyWindow]

//网络请求加密key
#define SignSecureKey       @"QLAPP906"

// 内存release置空
#define RELEASE_SAFE(x) if (x != nil) {[x release] ;x = nil;}

//iphone4s和iphone5的适配
#define isIPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define isIPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define StateBarHeight 20
#define NavigationBarHeight 44
#define MainHeight (ScreenHeight - StateBarHeight - NavigationBarHeight)
#define MainWidth ScreenWidth

#define IOS7_OR_LATER   ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)
#define IOS6_OR_LATER   ([[[UIDevice currentDevice] systemVersion] doubleValue]>=6.0 && [[[UIDevice currentDevice] systemVersion] doubleValue] < 7.0)
#define IOS8_OR_LATER   ([[[UIDevice currentDevice] systemVersion] doubleValue]>=8.0)

// 视图字体
#define KQLSystemFont(s)        [UIFont systemFontOfSize:s]
#define KQLboldSystemFont(s)    [UIFont boldSystemFontOfSize:s]

//RGB获得颜色
#define kColorRGB(R,G,B,A) [UIColor colorWithRed:R green:G blue:B alpha:A]

// 颜色值
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

// 读取本地图片地址
#define IMGREADFILE(imageName) [UIImage imageCwNamed:imageName]

//////////////////////共用颜色配置booky////////////////////////////
//蓝色
#define BLUECOLOR   RGBACOLOR(0,161,227,1)
//黑色
#define BALCKCOLOR      [UIColor colorWithRed:58.0/255.0 green:58.0/255.0 blue:58.0/255.0 alpha:1.0]
//灰色
#define DARKCOLOR   [UIColor darkGrayColor]
//背景色
#define BACKGROUNDCOLOR     RGBACOLOR(249,249,249,1)
//////////////////////////////////////////////////

//前一次登录的用户名Key
#define kPreviousUserName       @"PreviousUserName"

//应用系统数据库名
#define AppDataBaseName     @"LinkeBe.db"

//前一次登录的用户名Key
#define kPreviousUserName       @"PreviousUserName"

//前一次登陆的组织id
#define kPreviousOrgID          @"PreviousOrgID"

//版本ID KEY
#define APP_SOFTWARE_VER_KEY @"app_ver"

//版本ID 当前版本号
#define CURRENT_APP_VERSION 5

//token号 key
#define LINKEDBE_TOKEN_KEY @"token_key"


//是否弹出更新提醒 key
#define IS_SHOW_UPDATE_ALERT @"is_show_update_alert"

#define SECpromptText @"您想要什么工具呢 请在这里吩咐我吧"

//保存用户当前的信息 用于自动登录

#define LikedBe_UserId              @"userId"
#define LikedBe_ClientId            @"clientId"
#define LikedBe_ClientSecret        @"clientSecret"
#define LikedBe_Access_Token        @"accessToken"
#define LikedBe_Expires_In          @"expiresIn"
#define LikedBe_Expires_Limit_In    @"expiresLimitIn"
#define LikedBe_Org_Id              @"Org_Id"
#define LikedBe_OrgUserId           @"OrgUserId"


