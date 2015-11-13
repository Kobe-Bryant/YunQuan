//
//  DynamicCommon.h
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#ifndef LinkeBe_DynamicCommon_h
#define LinkeBe_DynamicCommon_h

#import "LinkedBeHttpRequest.h"
#import "interface_LinkedBe.h"
#import "Global.h"
#import "pic_LinkedBe_Dynamic.h"
#import "UIImageView+WebCache.h"
#import "Common.h"

#import "SBJson.h"

#import "ObjectData.h"
#import "Circle_member_model.h"

//快速评论
typedef enum{
    FastCommentTypeUp = 1,//赞
    FastCommentTypeDown,//踩
}FastCommentType;

//动态类型
typedef enum{
    DynamicTypeTogether = 1,//聚聚
    DynamicTypePic,//图文
    DynamicTypeHave,//我有
    DynamicTypeWant,//我要
}DynamicType;

//评论类型
typedef enum{
    CommentTypeTop = 1,//赞
    CommentTypeHehe,//呵呵
    CommentTypeNormal,//普通
}CommentType;

//---------------------UI常量---------------------//

//动态模块图片占位背景色
#define DynamicCardBackGround           RGBACOLOR(197, 197, 197, 1)

//动态列表卡片左边距
#define DynamicCardEdge                 5.0f

//动态列表卡片间距
#define DynamicCardSpace                5.0f

//动态卡片头部高度
#define DynamicCardHeadHeight           40.0f

//动态卡片图片高度
#define DynamicCardImageHeight          270.0f

//动态卡片互动bar高度
#define DynamicCardHandleBarHeight      40.0f

//动态卡片名字颜色
#define DynamicCardNameColor            [UIColor blackColor]

//动态卡片文本色
#define DynamicCardTextColor            RGBACOLOR(136, 136, 136, 1)

//动态卡片底部数字色
#define DynamicCardButtomNumColor       [UIColor blackColor]

//动态卡片边框色
#define DynamicCardBordColor            RGBACOLOR(215, 217, 220, 1)

//动态列表背景色
#define DynamicListBackgrundColor       [UIColor whiteColor]

//动态权限聊聊按钮色
#define DynamicPermissionChatButtonTextColor    RGBACOLOR(48, 122, 208, 1)

//---------------------UI常量---------------------//

//----------------------消息文本----------------------//
//我有
#define HAVEMESSAGETEXT     @"你好，我很有兴趣了解。"

//我要
#define WANTMESSAGETEXT     @"你好，我对你的需求很有兴趣。"

//聚聚
#define TOGETHERMESSAGETEXT     @"你好，我要参加这个聚聚。"

//----------------------消息文本----------------------//

//默认头像
#define PLACEHOLDERIMAGE(x)    [[ObjectData objectFromMemberListWithID:x] getDefaultProtraitImg]

#endif
