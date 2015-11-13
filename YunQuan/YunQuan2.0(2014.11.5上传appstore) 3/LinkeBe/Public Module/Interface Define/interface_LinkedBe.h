//
//  interface_LinkedBe.h
//  LinkeBe
//
//  Created by yunlai on 14-9-2.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//
//http错误码
typedef enum{
    SUCC = 0,
    ERROR = -1,
    INTERNAL_ERROR = 500,
    BAD_REQUEST = 400,
    METHOD_NOT_ALLOWED = 402,
    UNAUTHORIZED = 401,
    MISSING_PARAMETER = 410,
    PARAMETER_TYPE_ERROR = 411,
    ARGUMENT_NOT_VALID = 412,
    MISSION_REQUEST_PART = 413,
    NOT_CIRCLE_CREATOR = 4000,
    INVITATION_CODE_INVALID = 4001,
    VERIFICATION_CODE_INVALID = 4002,
    VERIFICATION_CODE_EXPIRED = 4003,
    USERNAME_PASSWORD_ERROR = 4004,
    USER_ALREADY_EXIST = 4005,
    USER_ALREADY_INVITED = 4006,
}LinkedBe_Error_Code;


//请求的类型post,get,put,delete
typedef enum{
    LinkedBe_GET            = 0,
    LinkedBe_POST,
    LinkedBe_PUT,
    LinkedBe_DELETE,
}LinkedBe_RequestType;

//接口类型标示的枚举
typedef enum
{
    LinkedBe_Token_Secert   = 0,                //秘钥
    LinkedBe_System_Apns,                       //系统apns
    LinkedBe_System_Index,                      //引导页面 add vincent
    LinkedBe_ORG_FlashScreen,                   //个性化闪屏幕
    LinkedBe_SendAuthcode,                      //发送手机邀请码
    LinkedBe_Invitation_Code,                   //验证邀请码
    LinkedBe_Set_Password,                      //设置密码 注册
    LinkedBe_Identifycode,                      //手机验证码验证
    LinkedBe_ResetPassword,                     //重置密码
    LinkedBe_User_Invitationcode,               //验证邀请码
    LinkedBe_Validatemobile,                    //验证手机号码是否在组织方后台
/////////////////////////////////////////////////////////////////////////////
    LinkedBe_USER_Login,                            //登录 add by vincent 2014.9.1
/////////////////////////////////////////////////////////////////////////////
    LinkedBe_NOTICE_INFO,                         //通知 add by Devin 2014.3.10
/////////////////////////////////////////////////////////////////////////////
    Linkedbe_DynamicList,                         //动态列表
    LinkedBe_Dynamic_detail,                      //动态详情
    LinkedBe_Publish_dynamic,                     //发布动态
    LinkedBe_Delete_dynamic,                      //删除动态
    LinkedBe_Comment_dynamic,                     //评论动态
    LinkedBe_Delete_comment,                      //删除评论
    LinkedBe_Comment_list,                        //评论列表
    LinkedBe_PermissionList,                      //权限列表
    LinkedBe_Join_together,                       //参加聚聚
    LinkedBe_My_Dynamic,                          //我的动态
//////////////////////////////////////////////////////////////////////////////
    LinkeBe_ThreeOrganization,                    //三级组织
    LinkeBe_OrganizationMembers,                  //组织成员
    
//    LinkeBe_TempOrganizationMembers,               //组织成员------
    
    LinkeBe_BusinessCard,                         //名片
    LinkeBe_DetailTempChat,                       //临时会话详情
    LinkeBe_ModifyTempChatName,                    //修改临时会话名称
    LinkedBe_Command_UploadData,
    LinkedBe_ORG_TOOLS,                         //商务助手
    LinkedBe_SYSTEM_PRIVILEGE,                  //组织特权
    LinkedBe_USER_INVITE,                       //用户邀请
/////////////////////////我的/////////////////////////////////////////////
    LinkedBe_Myself_PersonalData,                   //我的资料
    LinkedBe_Command_GetWelcomeMsg,
    LinkedBe_Member_LoginOut,                       //退出登录
    LinkedBe_Relevantme,                           //与我相关
    LinkedBe_MYSELF_UPDATEUSER,                     //修改资料
    LinkedBe_MYSELF_UPLOAD_IMAGE,                      //上传图片
    LinkedBe_MYSELF_UPLOAD_USERICON,                    //上传用户的头像
    LinkedBe_MYSELF_USER_LIVEAPPINFO,                    //上传用户liveApp
    /**
     *  自定义表情接口
     */
    LinkedBe_Command_GetEmotionList,
    LinkedBe_Command_GetEmotionDetail,
    LinkedBe_Command_GetEmotionMyEmoticonList,
    LinkedBe_Command_GetEmotionModifyPakageStatus,
    
    //消息设置
    LinkedBe_System_push,
    //用户消息设置列表
    LinkedBe_System_user_set,
} LinkedBe_WInterface;



//*****************************各个模块的ts***************************
typedef enum{
    MEMBERTS            = 0, //成员ts
    ORGANIZATIONTS ,          //组织ts
    MYSELFINFORPROCESS,       //我的个人资料的ts
    WELCOMEMESSAGE,
    RELATEMETS,              //与我相关
    
}LinkedBe_TsType;


//发送客户端id和秘钥
#define Login_Send_Client                    @"/oauth/token"

//系统的apns
#define AppDelegate_System_Apns                 @"/system/apns"

//个性化页闪屏
#define GUIDE_ORG_SPLASH                        @"/org/splash"

//引导页面
#define GUIDE_System_Index                       @"/system/index"

//登陆接口
#define LOGIN_USER_LOGIN_URL                    @"/user/login"//  add vincent 2014.9.1

//注册接口
//#define 
#define INVITATION_CODE_URL                     @"/user/invitationcode/{code}"
#define SET_PASSWORD_URL                        @"/user/register"
#define REGISTER_User_InvitationCode            @"/user/invitationcode"

//重置密码
#define RESET_PASSWORD_SENDAUTHCODE             @"/user/sendauthcode"
#define RESET_PASSWORD_Identifycode             @"/user/identifycode"
#define RESET_PASSWORD_User_ResetPwd            @"/user/resetpwd"
#define RESET_PASSWORD_ValidateMobile            @"/user/validatemobile"

//圈子接口
#define THREE_ORGANIZATION_URL                  @"/org"        //三级组织
#define ORGANIZATION_MEMBERS_URL                @"/org"        //组织成员
#define BUSINESS_CARD_URL                       @"/member/card"//名片
#define DETAILTEMPCHAT_URL                      @"/tempsession"//临时会话详情
#define TEMPCHAT_NAME_URL                       @"/tempsession/name" //修改临时会话名称
#define ORG_TOOLS                               @"/org/{orgId}/tools"
#define SYSTEM_PRIVILEGE                        @"/system/privilege"
#define USER_INVITE                             @"/user/invite"
//聊天接口



//动态接口
/////////////////////////////////////////////////
//动态列表 get
#define DYNAMIC_LIST_URL                    @"/publish/list"

//动态详情 get
#define DYNAMIC_DETAIL_URL                  @"/publish"

//发布动态 post
#define DYNAMIC_PUBLISH_URL                 @"/publish/add"

//删除动态 delete
#define DYNAMIC_DELETE_URL                  @"/publish/delete"

//评论动态 put
#define DYNAMIC_COMMENT_PUBLISH_URL         @"/publish/comment/add"

//删除评论 delete
#define DYNAMIC_COMMENT_DELETE_URL          @"/publish/comment/delete"

//评论列表 get
#define DYNAMIC_COMMENT_LIST_URL            @"/publish/comment/list"

//发布动态权限
#define DYNAMIC_PERMISSION_URL              @"/publish/getrole"

//参加聚聚
#define DYNAMIC_JOIN_TOGETHER_URL           @"/publish/joingathering"

//我的动态
#define DYNAMIC_MY_LIST_URL                 @"/publish/getmypublish"

/////////////////////////////////////////////////

//我的接口
#define MYSELF_MEMBER_PERSONAL_URL       @"/member/{orgUserId}"
#define MYSELF_MEMBER_LOGINOUT_URL       @"/user/logout"
#define MYSELF_RELEVANTME_URL           @"/publish/relevantme/{orgId}/{userId}"
#define MYSELF_UPDATEUSER_URL           @"/member/{orgUserId}"
#define MYSELF_UPLOAD_USERICON          @"/member/avatar/{orgUserId}"
#define MYSELF_UPLOAD_IMAGE             @"/upload"
#define MYSELF_USER_LIVEAPPINFO         @"/user/liveappinfo"

//消息设置
#define SYSTEM_PUSH_URL         @"/system/push"

//用户设置列表
#define SYSTEM_USER_SET_URL     @"/system/getsetting"
