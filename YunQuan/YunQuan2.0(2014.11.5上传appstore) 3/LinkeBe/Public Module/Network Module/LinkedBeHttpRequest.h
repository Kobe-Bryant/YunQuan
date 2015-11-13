//
//  LinkedBeHttpRequest.h
//  LinkeBe
//
//  Created by yunlai on 14-9-9.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"

@interface LinkedBeHttpRequest : NSObject

/**
 [""] *	@brief
 [""] *
 [""] *	@return	网络请求的实例对象
 [""] */
+ (id)shareInstance;


/**
 [""] *	@brief
 [""] *
 [""] *	@param 	delegate 	调用接口的委托对象
 [""] *	@param 	parameterDictonary 	get的请求的方式 请求接口的参数
 [""] * @param  parameterArray   POST 的请求的方式 请求的接口的参数
 [""] *	@return	无
 [""] */
//发送token
-(void)requestAccessTokenDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)parameterString;

//引导页面
-(void)requestSystemIndexDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)parameterString;

//验证邀请码
-(void)requestUserInvitationcodeDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)parameterString;

//系统apns
-(void)requestSystemAPNSDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)parameterString;

//请求验证码
-(void)requestSendauthcodeDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)parameterString;

// 验证手机号是否注册过接口///user/validatemobile?mobile={mobile}
-(void)requestValidatemobileDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)parameterString;

//手机验证验证码
-(void)acessIdentifycodeDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)parameterString;

//重置密码
-(void)accessResetPasswordDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)parameterString;
/////////////--------动态-----------////////////////

//动态列表
-(void) requestDynamicListDelegate:(id) delegate parameterDictionary:(NSDictionary*) parameterDictionary;

//发布动态
-(void) requestPublishDynamicDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) dataList;

//动态详情
-(void) requestDynamicDetailDelegate:(id) delegate parameterDictionary:(NSDictionary*) parameterDictionary;

//删除动态
-(void) requestDeleteDynamicDelegate:(id) delegate parameterDictionary:(NSDictionary*) parameterDictionary;

//发表评论
-(void) requestPublishCommentDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary;

//删除评论
-(void) requestDeleteCommentDelegate:(id) delegate parameterDictionary:(NSDictionary*) parameterDictionary;

//评论列表
-(void) requestCommentListDelegate:(id) delegate parameterDictionary:(NSDictionary*) parameterDictionary;

//查询用户发布动态的权限
-(void) requestPublishPermissionWithDelegate:(id) delegate parameterDictionary:(NSDictionary*) paraDic;

//参加聚聚
-(void) requestJoinTogetherWithDelegate:(id) delegate parameterDictionary:(NSDictionary*) parameterDictionary;

//我的动态
-(void) requestMyDyanmicListWithDelegate:(id) delegate parameterDictionary:(NSDictionary*) parameterDictionary;

/////////////--------动态-----------////////////////

//三级组织列表
- (void)requestThreeOrganizationDelegate:(id)delegate parameterDictionary:(NSMutableDictionary *)parameterDictionary parameterArray:(NSArray *)parameterArray requestType:(LinkedBe_RequestType)requestType;
//组织成员
- (void)requestOrganizationMembersDelegate:(id)delegate parameterDictionary:(NSMutableDictionary *)parameterDictionary parameterArray:(NSArray *)parameterArray requestType:(LinkedBe_RequestType)requestType;

//名片
- (void)requestBusinessCardDelegate:(id)delegate parameterDictionary:(NSMutableDictionary *)parameterDictionary parameterArray:(NSArray *)parameterArray requestType:(LinkedBe_RequestType)requestType;

//商务特权
- (void)requestOrgToolsDelegate:(id)delegate parameterDictionary:(NSMutableDictionary *)parameterDictionary parameterArray:(NSArray *)parameterArray requestType:(LinkedBe_RequestType)requestType;

//组织特权
- (void)requestSystemPrivilegeDelegate:(id)delegate parameterDictionary:(NSMutableDictionary *)parameterDictionary parameterArray:(NSArray *)parameterArray requestType:(LinkedBe_RequestType)requestType;

//发送邀请
- (void)requestUserInviteDelegate:(id)delegate parameterDictionary:(NSMutableDictionary *)parameterDictionary parameterArray:(NSArray *)parameterArray requestType:(LinkedBe_RequestType)requestType;

//组织闪屏图片
-(void) requsetOrgSplash:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType; //add vincent 2014.9.22

//验证邀请码
-(void) requsetInvitationCode:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)methodName requestType:(LinkedBe_RequestType)requestType;

//设置密码 注册
-(void) requsetSetPassword:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType;

//登录接口 /user/login
-(void) requsetUserLogin:(id)delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType; //add vincent  2014.9.23

/*############################-我的-#######################################*/
//我的资料
-(void) requestMyself:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType;

//临时会话详情
- (void)requestDetailTempChatDelegate:(id)delegate parameterDictionary:(NSMutableDictionary *)parameterDictionary parameterArray:(NSArray *)parameterArray requestType:(LinkedBe_RequestType)requestType;

//退出登录
-(void)requestLoginOut:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType;

//与我相关
-(void)requestRelevantMe:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType;

//临时会话名称修改 add by devin 9.28
- (void)requestModifyTempChatNameDelegate:(id)delegate parameterDictionary:(NSMutableDictionary *)parameterDictionary parameterArray:(NSArray *)parameterArray requestType:(LinkedBe_RequestType)requestType;

//修改资料
-(void)requestUpdateUserInfo:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType;

//上传图片
-(void)requestUploadImage:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType;
//上传用户的头像
-(void)requestUploadUserIcon:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType;
//上传用户的liveApp /user/liveappinfo
-(void)requestUserLiveappinfo:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType;

//消息提醒设置
-(void) requestSystemPushWithDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray;

//获取用户设置信息
-(void) requestUserSettingInfoWithDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray;

@end
