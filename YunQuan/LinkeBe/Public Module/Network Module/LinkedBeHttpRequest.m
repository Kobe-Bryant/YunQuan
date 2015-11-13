//
//  LinkedBeHttpRequest.m
//  LinkeBe
//
//  Created by yunlai on 14-9-9.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "LinkedBeHttpRequest.h"
#import "PKReachability.h"
#import "Global.h"
#import "NetManager.h"
#import "UserModel.h"

static PKReachability *_reachability = nil;
BOOL _reachabilityOn;

static inline PKReachability* defaultReachability () {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _reachability = [PKReachability reachabilityForInternetConnection];
    });
    
    return _reachability;
}

@implementation LinkedBeHttpRequest

+ (id)shareInstance{
    static LinkedBeHttpRequest *instance = nil;
    if (instance == nil) {
        instance = [[LinkedBeHttpRequest alloc] init];
    }
    return instance;
}

- (void)dealloc{
    [self stopInternerReachability];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id) init{
    self = [super init];
    if (self) {
        [self startInternetReachability];
    }
    
    return self;
}

#pragma mark ---Reachibility
- (void)startInternetReachability {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus) name:kReachabilityChangedNotification object:nil];
    
    if (!_reachabilityOn) {
        _reachabilityOn = TRUE;
        [defaultReachability() startNotifier];
    }
    
    [self checkNetworkStatus];
}

//网络监测
- (void)checkNetworkStatus {
    
    NetworkStatus internetStatus = [defaultReachability() currentReachabilityStatus];
    switch (internetStatus) {
        case NotReachable: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"网络异常,请检查网络设置" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            [alert release];
            break;
        }
            break;
        case ReachableViaWiFi:
        {
            NSLog(@"ReachableViaWiFi");
        }
            break;
        case ReachableViaWWAN: {
            NSLog(@"ReachableViaWWAN");
        }
            break;
        default:
            break;
    }
}

- (void)stopInternerReachability {
    
    _reachabilityOn = FALSE;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)cancelDelegate:(id)delegate{
    if (delegate == nil) {
        return;
    }
}

- (NSString *)getUrl{
    return HTTPURLPREFIX;
}

//token加密
-(void) requestAccessTokenDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)parameterString{
    NSString *url = [self getUrl];
    LinkedBe_WInterface interface = LinkedBe_Token_Secert;
    NSString *methodName = Login_Send_Client;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_POST];
}

//系统apns
-(void)requestSystemAPNSDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)parameterString{
    NSString *url = [self getUrl];
    LinkedBe_WInterface interface = LinkedBe_System_Apns;
    NSString *methodName = AppDelegate_System_Apns;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_GET];
}

//引导页面
-(void)requestSystemIndexDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)parameterString{
    NSString *url = [self getUrl];
    LinkedBe_WInterface interface = LinkedBe_System_Index;
    NSString *methodName = GUIDE_System_Index;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_GET];
}

//验证邀请码
-(void)requestUserInvitationcodeDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)parameterString{
    NSString *url = [self getUrl];
    LinkedBe_WInterface interface = LinkedBe_User_Invitationcode;
    NSString *methodName = REGISTER_User_InvitationCode;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_GET];
}

//重置密码 请求验证码
-(void)requestSendauthcodeDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)parameterString{
    NSString *url = [self getUrl];//@"http://192.168.1.195:8080/appapi";//
    LinkedBe_WInterface interface = LinkedBe_SendAuthcode;
    NSString *methodName = RESET_PASSWORD_SENDAUTHCODE;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_GET];
}

// 验证手机号是否注册过接口///user/validatemobile?mobile={mobile}
-(void)requestValidatemobileDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)parameterString{
    NSString *url = [self getUrl];
    LinkedBe_WInterface interface = LinkedBe_Validatemobile;
    NSString *methodName = RESET_PASSWORD_ValidateMobile;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_GET];
}

//重置密码 手机验证验证码
-(void)acessIdentifycodeDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)parameterString{
    NSString *url = [self getUrl];//@"http://192.168.1.195:8080/appapi";//
    LinkedBe_WInterface interface = LinkedBe_Identifycode;
    NSString *methodName = RESET_PASSWORD_Identifycode;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_GET];
}

//重置密码
-(void)accessResetPasswordDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)parameterString{
    NSString *url = [self getUrl];//@"http://192.168.1.195:8080/appapi";//
    LinkedBe_WInterface interface = LinkedBe_ResetPassword;
    NSString *methodName = RESET_PASSWORD_User_ResetPwd;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_POST];
}

/////////////--------动态-----------////////////////

//动态列表
-(void) requestDynamicListDelegate:(id) delegate parameterDictionary:(NSDictionary*) parameterDictionary{
    NSString *url = [self getUrl];
    NSString *methodName = DYNAMIC_LIST_URL;
    LinkedBe_WInterface interface = Linkedbe_DynamicList;
    
    methodName = [methodName stringByAppendingFormat:@"/%@/%@",[parameterDictionary objectForKey:@"orgUserId"],[parameterDictionary objectForKey:@"userId"]];
    
    NSMutableDictionary* param = [NSMutableDictionary dictionaryWithDictionary:parameterDictionary];
    [param removeObjectForKey:@"orgUserId"];
    [param removeObjectForKey:@"userId"];
    
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:param bodyUrlDataList:nil  byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_GET];
}

//发布动态
-(void) requestPublishDynamicDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) dataList{
    NSString *url = [self getUrl];
    NSString *methodName = DYNAMIC_PUBLISH_URL;
    LinkedBe_WInterface interface = LinkedBe_Publish_dynamic;
    
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:dataList  byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_POST];
}

//动态详情
-(void) requestDynamicDetailDelegate:(id) delegate parameterDictionary:(NSDictionary*) parameterDictionary{
    NSString *url = [self getUrl];
    NSString *methodName = DYNAMIC_DETAIL_URL;
    LinkedBe_WInterface interface = LinkedBe_Dynamic_detail;
    
    methodName = [methodName stringByAppendingFormat:@"/%@",[parameterDictionary objectForKey:@"publishId"]];
    
    NSMutableDictionary* param = [NSMutableDictionary dictionaryWithDictionary:parameterDictionary];
    [param removeObjectForKey:@"publishId"];
    
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:param bodyUrlDataList:nil  byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_GET];
}

//删除动态
-(void) requestDeleteDynamicDelegate:(id) delegate parameterDictionary:(NSDictionary*) parameterDictionary{
    NSString *url = [self getUrl];
    NSString *methodName = DYNAMIC_DELETE_URL;
    LinkedBe_WInterface interface = LinkedBe_Delete_dynamic;
    
    methodName = [methodName stringByAppendingFormat:@"/%@/%@",[parameterDictionary objectForKey:@"orgId"],[parameterDictionary objectForKey:@"publishId"]];
    
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:nil bodyUrlDataList:nil  byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_DELETE];
}

//发表评论
-(void) requestPublishCommentDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary{
    NSString *url = [self getUrl];
    NSString *methodName = DYNAMIC_COMMENT_PUBLISH_URL;
    LinkedBe_WInterface interface = LinkedBe_Comment_dynamic;
    
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:nil  byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_POST];
}

//删除评论
-(void) requestDeleteCommentDelegate:(id) delegate parameterDictionary:(NSDictionary*) parameterDictionary{
    NSString *url = [self getUrl];
    NSString *methodName = DYNAMIC_COMMENT_DELETE_URL;
    LinkedBe_WInterface interface = LinkedBe_Delete_comment;
    
    methodName = [methodName stringByAppendingFormat:@"/%@/%@",[parameterDictionary objectForKey:@"orgId"],[parameterDictionary objectForKey:@"commentId"]];
    
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:nil bodyUrlDataList:nil  byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_DELETE];
}

//评论列表
-(void) requestCommentListDelegate:(id) delegate parameterDictionary:(NSDictionary*) parameterDictionary{
    NSString *url = [self getUrl];
    NSString *methodName = DYNAMIC_COMMENT_LIST_URL;
    LinkedBe_WInterface interface = LinkedBe_Comment_list;
    
    methodName = [methodName stringByAppendingFormat:@"/%@/%@",[parameterDictionary objectForKey:@"orgId"],[parameterDictionary objectForKey:@"publishId"]];
    
    NSMutableDictionary* param = [NSMutableDictionary dictionaryWithDictionary:parameterDictionary];
    [param removeObjectForKey:@"orgId"];
    [param removeObjectForKey:@"publishId"];
    
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:param bodyUrlDataList:nil  byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_GET];
}

//查询用户发布动态权限
-(void) requestPublishPermissionWithDelegate:(id) delegate parameterDictionary:(NSDictionary*) paraDic{
    NSString *url = [self getUrl];
    NSString *methodName = DYNAMIC_PERMISSION_URL;
    LinkedBe_WInterface interface = LinkedBe_PermissionList;
    
    methodName = [methodName stringByAppendingFormat:@"/%@/%@",[paraDic objectForKey:@"orgId"],[paraDic objectForKey:@"orgUserId"]];
    
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:nil bodyUrlDataList:nil  byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_GET];
}

//参加聚聚
-(void) requestJoinTogetherWithDelegate:(id) delegate parameterDictionary:(NSDictionary*) parameterDictionary{
    NSString *url = [self getUrl];
    NSString *methodName = DYNAMIC_JOIN_TOGETHER_URL;
    LinkedBe_WInterface interface = LinkedBe_Join_together;
    
    methodName = [methodName stringByAppendingFormat:@"/%@",[parameterDictionary objectForKey:@"userId"]];
    
    NSMutableDictionary* param = [NSMutableDictionary dictionaryWithDictionary:parameterDictionary];
    [param removeObjectForKey:@"userId"];
    
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:param bodyUrlDataList:nil  byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_GET];
}

//我的动态
-(void) requestMyDyanmicListWithDelegate:(id) delegate parameterDictionary:(NSDictionary*) parameterDictionary{
    NSString *url = [self getUrl];
    NSString *methodName = DYNAMIC_MY_LIST_URL;
    LinkedBe_WInterface interface = LinkedBe_My_Dynamic;
    
    methodName = [methodName stringByAppendingFormat:@"/%@/%@",[parameterDictionary objectForKey:@"orgUserId"],[parameterDictionary objectForKey:@"userId"]];
    
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:nil bodyUrlDataList:nil  byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_GET];
}

/////////////--------动态-----------////////////////
//三级组织
- (void)requestThreeOrganizationDelegate:(id)delegate parameterDictionary:(NSMutableDictionary *)parameterDictionary parameterArray:(NSArray *)parameterArray requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = THREE_ORGANIZATION_URL;
    LinkedBe_WInterface interface = LinkeBe_ThreeOrganization;

    methodName = [methodName stringByAppendingFormat:@"/%@",[parameterDictionary objectForKey:@"orgId"]];
    [parameterDictionary removeObjectForKey:@"orgId"];
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray  byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//组织成员
- (void)requestOrganizationMembersDelegate:(id)delegate parameterDictionary:(NSMutableDictionary *)parameterDictionary parameterArray:(NSArray *)parameterArray requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = ORGANIZATION_MEMBERS_URL;
    LinkedBe_WInterface interface = LinkeBe_OrganizationMembers;
    
    methodName = [methodName stringByAppendingFormat:@"/%@/members",[parameterDictionary objectForKey:@"orgId"]];
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//名片
- (void)requestBusinessCardDelegate:(id)delegate parameterDictionary:(NSMutableDictionary *)parameterDictionary parameterArray:(NSArray *)parameterArray requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = BUSINESS_CARD_URL;
    LinkedBe_WInterface interface = LinkeBe_BusinessCard;
    
     methodName = [methodName stringByAppendingFormat:@"/%@",[parameterDictionary objectForKey:@"orgUserId"]];
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//组织闪屏
-(void) requsetOrgSplash:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = GUIDE_ORG_SPLASH;
    LinkedBe_WInterface interface = LinkedBe_ORG_FlashScreen;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//验证邀请码
-(void) requsetInvitationCode:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray parameterString:(NSString *)methodNamerString requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = methodNamerString;
    LinkedBe_WInterface interface = LinkedBe_Invitation_Code;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//设置密码 注册
-(void) requsetSetPassword:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType {
    NSString *url = [self getUrl];
    NSString *methodName = SET_PASSWORD_URL;
    LinkedBe_WInterface interface = LinkedBe_Set_Password;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
    
}

//登录 add vincent 2014.9.23
-(void) requsetUserLogin:(id)delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = LOGIN_USER_LOGIN_URL;
    LinkedBe_WInterface interface = LinkedBe_USER_Login;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//我的资料
-(void) requestMyself:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = [MYSELF_MEMBER_PERSONAL_URL stringByReplacingOccurrencesOfString:@"{orgUserId}" withString:[NSString stringWithFormat:@"%@",[UserModel shareUser].orgUserId]];
    LinkedBe_WInterface interface = LinkedBe_Myself_PersonalData;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//退出登录
-(void)requestLoginOut:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = MYSELF_MEMBER_LOGINOUT_URL;
    LinkedBe_WInterface interface = LinkedBe_Member_LoginOut;
    
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//与我相关
-(void)requestRelevantMe:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = [[MYSELF_RELEVANTME_URL stringByReplacingOccurrencesOfString:@"{orgId}" withString:[NSString stringWithFormat:@"%@",[UserModel shareUser].org_id]] stringByReplacingOccurrencesOfString:@"{userId}" withString:[NSString stringWithFormat:@"%@",[UserModel shareUser].user_id]];

    LinkedBe_WInterface interface = LinkedBe_Relevantme;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//临时会话详情 add by devin 9.28
- (void)requestDetailTempChatDelegate:(id)delegate parameterDictionary:(NSMutableDictionary *)parameterDictionary parameterArray:(NSArray *)parameterArray requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = DETAILTEMPCHAT_URL;
    LinkedBe_WInterface interface = LinkeBe_DetailTempChat;
    
    methodName = [methodName stringByAppendingFormat:@"/%@",[parameterDictionary objectForKey:@"circleId"]];
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//临时会话名称修改 add by devin 9.28
- (void)requestModifyTempChatNameDelegate:(id)delegate parameterDictionary:(NSMutableDictionary *)parameterDictionary parameterArray:(NSArray *)parameterArray requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = TEMPCHAT_NAME_URL;
    LinkedBe_WInterface interface = LinkeBe_ModifyTempChatName;
    
    methodName = [methodName stringByAppendingFormat:@"/%@",[parameterDictionary objectForKey:@"circleId"]];
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//修改资料
-(void)requestUpdateUserInfo:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = MYSELF_UPDATEUSER_URL;
    methodName = [methodName stringByReplacingOccurrencesOfString:@"{orgUserId}" withString:[NSString stringWithFormat:@"%@",[UserModel shareUser].orgUserId]];
    LinkedBe_WInterface interface = LinkedBe_MYSELF_UPDATEUSER;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//上传图片
-(void)requestUploadImage:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = MYSELF_UPLOAD_IMAGE;
    LinkedBe_WInterface interface = LinkedBe_MYSELF_UPLOAD_IMAGE;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//上传用户的头像
-(void)requestUploadUserIcon:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = MYSELF_UPLOAD_USERICON;
    methodName = [methodName stringByReplacingOccurrencesOfString:@"{orgUserId}" withString:[NSString stringWithFormat:@"%@",[UserModel shareUser].orgUserId]];
    LinkedBe_WInterface interface = LinkedBe_MYSELF_UPLOAD_USERICON;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//商务助手
- (void)requestOrgToolsDelegate:(id)delegate parameterDictionary:(NSMutableDictionary *)parameterDictionary parameterArray:(NSArray *)parameterArray requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = ORG_TOOLS;
    methodName = [methodName stringByReplacingOccurrencesOfString:@"{orgId}" withString:[NSString stringWithFormat:@"%@",[UserModel shareUser].org_id]];
    LinkedBe_WInterface interface = LinkedBe_ORG_TOOLS;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//组织特权
- (void)requestSystemPrivilegeDelegate:(id)delegate parameterDictionary:(NSMutableDictionary *)parameterDictionary parameterArray:(NSArray *)parameterArray requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = SYSTEM_PRIVILEGE;
    LinkedBe_WInterface interface = LinkedBe_SYSTEM_PRIVILEGE;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//发送邀请
- (void)requestUserInviteDelegate:(id)delegate parameterDictionary:(NSMutableDictionary *)parameterDictionary parameterArray:(NSArray *)parameterArray requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = USER_INVITE;
    LinkedBe_WInterface interface = LinkedBe_USER_INVITE;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//上传用户的liveApp 
-(void)requestUserLiveappinfo:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray requestType:(LinkedBe_RequestType)requestType{
    NSString *url = [self getUrl];
    NSString *methodName = MYSELF_USER_LIVEAPPINFO;
    LinkedBe_WInterface interface = LinkedBe_MYSELF_USER_LIVEAPPINFO;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:requestType];
}

//消息提醒设置
-(void) requestSystemPushWithDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray{
    NSString *url = [self getUrl];
    NSString *methodName = SYSTEM_PUSH_URL;
    LinkedBe_WInterface interface = LinkedBe_System_push;
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:parameterDictionary bodyUrlDataList:parameterArray byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_PUT];
}

//获取用户设置信息
-(void) requestUserSettingInfoWithDelegate:(id) delegate parameterDictionary:(NSMutableDictionary*) parameterDictionary parameterArray:(NSArray*) parameterArray{
    NSString *url = [self getUrl];
    NSString *methodName = SYSTEM_USER_SET_URL;
    LinkedBe_WInterface interface = LinkedBe_System_user_set;
    
    methodName = [methodName stringByAppendingFormat:@"/%@",[parameterDictionary objectForKey:@"userId"]];
    
    [[NetManager sharedManager] sendRequestWithEnvironment:url bodyUrlDictionary:nil bodyUrlDataList:nil byMethodName:methodName byInterface:interface byCallBackDelegate:delegate SSL:NO requestType:LinkedBe_GET];
}

@end
