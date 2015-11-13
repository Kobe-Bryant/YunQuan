//
//  Common.h
//  Profession
//
//  Created by MC374 on 12-8-7.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#define PI 3.1415926

// Whole System NotificationKey
#define kNotiUpdateLeftbarMark      @"updateLeftbarMark"
#define kNotiReceivePersonMessage   @"chatMessageReceive"
#define kNotiTipsMessageReceive     @"tipsMessageReceive"
#define kNotiConfirmJoinCircle      @"confirmJoinCircle"
#define kNotiCircleMessageSended    @"circleMessageSended"
#define kNotiCreateTempCircleFb     @"createTempCircleFb"
#define kNotiLoginSuccess           @"loginSuccess"
#define kNotiSendMessageSuccess     @"messageSendSuccess"
#define kNotiSendTempCircleMessage  @"SendTempCircleMessage"
#define kNotiUpdateTempCircleInfo   @"UpdateTempCircleInfo"
#define kNotiReceiveTempCircleMsg   @"ReceiveTempCircleMsg"
#define kNotiCircleMemberChange     @"CircleMemberChange"
#define kNotiTempCircleMmberChange  @"TempCircleMemberChange"
#define KNotiCircleInfoChange       @"circleInfoChangeNotify"
#define kNotiSubmitMessageSuccess   @"SubmitMessageSuccess"
#define kNotiCompelQuitMessage      @"CompelQuitMessage"
#define kNotiInviteMessageReceive   @"inviteMessageReceive"

#define KNotiQuitCircle             @"quitCircleNotify"
#define KNotiQuitTempCircle         @"quitTempCircleNotify"

#define KNotiCircleBeOut            @"circleBeOutNotify"

// 条件判断字符key
#define kChatTempCircle             @"ChatTempCircle "
#define KChatCircle                 @"ChatCircle"
#define kChatBoth                   @"ChatBoth"

//设置iOS 7 NavitagionView 边缘
#define SetNavigationEdgeExtendOne NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"7.0" options: NSNumericSearch];if (order == NSOrderedSame || order == NSOrderedDescending){self.edgesForExtendedLayout = UIRectEdgeNone;}

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "NSString+emoji.h"

//安全解析Http返回数据 block
typedef void(^ ParseMethod) (void);
typedef void(^ JudgeMethodBlack)(NSDictionary * theArr , ParseMethod theMethod);

typedef enum
{
    SortEnumAsc,                    // 升序
    SortEnumDesc,                   // 降序
}SortEnum;

typedef enum
{
    HomePageTypeNomal,
    HomePageTypeMy,                 //自己进入的云主页
    HomePageTypeCloud,              //其他进入云主页
    HomePageTypeMessage,            //联系列表进入云主页
}HomePageType;

typedef enum
{
    QrCodeViewTypePerson,           //个人二维码
    QrCodeViewTypeCircle,           //圈子二维码
}QrCodeViewType;

typedef enum
{
  
    CircleDetailTypeDefault,        //自己创建圈子未添加成员的详情
    CircleDetailTypeSelfAccess,     //自己创建添加了成员的圈子详情
    CircleDetailTypeOtherAccess,    //申请进入别人创建的圈子详情
    CircleDetailTypeTempDialogue,   //创建临时会话详情界面
}CircleDetailType;

typedef enum {
    MemberlistTypeOrg,              //组织成员列表
    MemberlistTypeCircle,           //圈子详细成员列表
}MemberlistType;

typedef enum {
    listEditTypeDefault,            //不是最近创建的圈子无法编辑
    listEditTypeShow,               //自己创建的圈子有编辑按钮
}listEditType;

typedef enum {
    SetPasswordViewTypeUpdate,      //重置密码
    SetPasswordViewTypeRegister,    //会员注册
}SetPasswordViewType;

typedef enum
{
    AccessPageTypeDefault,          // 所有动态
    AccessPageTypeMyDynamic,        // 个人发布的动态
    AccessPageTypeMysupplydemand,   // 个人我有我要
    AccessPageTypeAddMemberList,    // 添加成员联系人列表
    AccessPageTypeChoiceMember,     // 选择联系人列表
    AccessPageTypeChat,             // 选择联系人聊天
}AccessPageType;

typedef enum{                           // 聊天列表类型枚举
    MessageListTypeOrg = 1,             // 组织方消息
    MessageListTypeSecretory = 2,       // 小秘书消息
    MessageListTypePerson = 3,          // 个人单聊消息
    MessageListTypeCircle = 4,          // 圈子消息
    MessageListTypeTempCircle = 5,      // 临时圈子消息
    MessageListTypeWant = 6,            // 我有消息
    MessageListTypeHave = 7             // 我要消息
}MessageListType;



@interface Common : NSObject

//公共函数:
+ (BOOL) connectedToNetwork;
+ (NSString*) TransformJson:(NSMutableDictionary*)sourceDic withLinkStr:(NSString*)strurl;
+ (NSString*) encodeBase64:(NSMutableData*)data;
+ (NSString*) URLEncodedString:(NSString*)input;
+ (NSString*) URLDecodedString:(NSString*)input;
+ (NSNumber*) getVersion:(int)commandId;
+ (NSNumber*) getVersion:(int)commandId desc:(NSString *)desc;
+ (BOOL) updateVersion:(int)commandId withVersion:(int)version withDesc:(NSString*)desc;

+ (NSNumber*) getCatVersion:(int)commandId withId:(int)cat_Id;
+ (BOOL) updateCatVersion:(int)commandId withVersion:(int)version withId:(int)cat_Id withDesc:(NSString*)desc;

+ (NSString*) getSecureString:(NSString *)keystring;
+ (NSString*) getMacAddress;
+ (void) setActivityIndicator:(bool)isShow;
+ (double) lantitudeLongitudeToDist:(double)lon1 Latitude1:(double)lat1 long2:(double)lon2 Latitude2:(double)lat2;
+ (NSString*)encryptPutString:(NSString*)input;

// 手机号码正则表达式
+ (BOOL)phoneNumberChecking:(NSString *)phone;

// 邮箱正则表达式
+ (BOOL) validateEmail:(NSString *)email;

// 判断是否有非法字符正则表达式
+ (BOOL)illegalCharacterChecking:(NSString *)text;

//动态获取内容的高度
+ (CGFloat)getTextHeight:(NSString *)contentStr textFont:(int)font textWidth:(float)width;


// 搜索框是否包含中文
+ (BOOL)isIncludeChineseInString:(NSString*)str;

// 提示框
+ (void)checkProgressHUD:(NSString *)value andImage:(UIImage *)img showInView:(UIView *)view;

// keywindow提示框
+ (void)checkProgressHUDShowInAppKeyWindow:(NSString *)value andImage:(UIImage *)img;

// 错误提示
+ (void)MsgBox:(NSString *)title messege:(NSString *)message cancel:(NSString *)cancel other:(NSString *)other delegate:(id)delegate;

// 根据时间戳转化时间
+ (NSString *)makeTime:(int)times withFormat:(NSString *)format;

//13位转10
+ (NSString *)makeTime13To10:(long long)times withFormat:(NSString *)format;

// 根据时间戳转化时间
+ (NSString *)makeShortTime:(int)times;

// 根据时间戳转化友好的时间
+ (NSString *)makeFriendTime:(int)times;

// 根据需求转化为会话列表消息友好时间
+ (NSString *)makeSessionViewMessageFriendTime:(int)times;

// 根据格式时间字符，转化时间
+ (long long)timeIntervalFromString:(NSString *)timeString andFormat:(NSString *)formatStr;

// 获取联系人字典数组中的前三个头像Json数组
+ (NSMutableDictionary *)generatePortraitNameDicJsonStrWithContactArr:(NSArray *)contactsArr;

// 安全解析返回的Http数据
+ (void)securelyparseHttpResultDic:(NSDictionary *)resultDic andMethod:(ParseMethod)method;

//安全解析返回http Block
+ (void)securelyParseHttpResultDic:(NSDictionary *)resultDic andParseBlock:(void (^)(void))block;

// 手机号码格式转化(15976894470 ---- 159-7689-4470)
+ (NSString*) phoneNumTypeTurnWith:(NSString*) phoneNum;

//add by vincent
+ (NSString *) abandonPhoneType:(NSString *) phoneNum;

//聊天列表人性化时间 过了一天显示昨天，过了两天显示周，在本周之外显示日期
+ (NSString *)makeMessageListHumanizedTimeForWithTime:(double)theTime;

//聊天会话框人性时间 和列表类似 只是每个时间后面都会有确切的时间段表示
+ (NSString *)makeSessionViewHumanizedTimeForWithTime:(double)theTime;

// 判断总定位功能是否开启
+ (BOOL)isLoctionOpen;

//http错误吗判断
+ (BOOL) TestERRCodeWith:(NSNumber*) errCode;

//屏蔽emoji
+(NSString*) placeEmoji:(NSString*) str;

//判断是否是emoji字符
+(BOOL) isEmoji:(NSString*) str;

@end


