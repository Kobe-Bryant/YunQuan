//
//  ChatMacro.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-16.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#ifndef LinkeBe_ChatMacro_h
#define LinkeBe_ChatMacro_h

/**
 * 聊天模块通知名
 *
 *
 *
 */

#define SendMessageSuccess          @"SendMessageSuccess"
#define TempCircleMemberChanged     @"TempCircleMemberChanged"
#define TempCircleQuitScucess       @"TempCircleQuitScucess"

#define NewCircleMemberChanged      @"NewCircleMemberChanged"
#define NewCircleOrgChanged         @"NewCircleOrgChanged"
#define IMLoginSuccess              @"IMLoginSuccess"


/**
 *  CGDName Macro
 *
 *
 *
 */
#define DBModifyQueueName           "com.snail.db.modify.queue"



/**
 * 系统效果参数定义
 *
 *
 *
 */

typedef enum{
    RequestErrorCodeFailed = -2,
    RequestErrorCodeTimeOut = -1,
    RequestErrorCodeSuccess = 0,
}RequestErrorCode;

// 聊天消息时间label显示时间间隔
#define MessageShowTimeInterval     60 * 5
// 聊天上传图片压缩大小
#define ChatImgCompressionQuality   0.5f
// 聊天默认每次加载的消息数
#define ChatHistoryMessagePrePage   10
// 会话最大人数
#define TempChatMembersMaxNumber    100
// mid 时间戳附加大小
#define MessageMidPlus              1000000
// 提醒小红点宽度
#define MarkReadPointWidth          16
// 提醒小红点高度
#define MarkReadPointHeight         16
// 图片选择的最大数
#define QBImagePickerMaxSelectNum   9






/**
 *  MethodMacroDefine
 *
 *
 *
 *
 */
//  内存release置空
#define RELEASE_SAFE(x) if (x != nil) {[x release] ;x = nil;}

//  视图字体
#define KQLSystemFont(s)        [UIFont systemFontOfSize:s]
#define KQLboldSystemFont(s)    [UIFont boldSystemFontOfSize:s]

//  自我释放log
#define LOG_RELESE_SELF NSLog(@"Safe dealloc %@",self)




/**
 *  CorlorsDefine
 *
 *
 *
 */
#define LightGrayColor [UIColor colorWithWhite:0.4 alpha:1.0f]

#define SeparateLightColor [UIColor colorWithWhite:0.8 alpha:1.0f]

#define LightTextGrayColor  [UIColor colorWithWhite:0.6 alpha:1.0f]

//蓝色   按键色
#define COLOR_CONTROL [UIColor colorWithRed:0/255.0f green:160/255.0 blue:233/255.0 alpha:1.f]
//高亮按钮蓝色
#define HIGHTLIGHT_BLUE_CORLOR [UIColor colorWithRed:0.f/255.f green:122.f/255.f blue:255.f/255.f alpha:255.f/255.f]
//发送按钮置灰背景色
#define SendButtonGrayBackColor  [UIColor colorWithWhite:0.9f alpha:1.0f]

//发送按钮title 颜色
#define SendTitleHighLightColor [UIColor colorWithRed:217.f/255.f green:235.f/255.f blue:255.f/255.f alpha:1]
//发送按钮置灰颜色
#define SendTitleGrayColor [UIColor colorWithRed:117.f/255.f green:135.f/255.f blue:155.f/255.f alpha:1]

//聊天背景色
#define SessionTableBackColor [UIColor colorWithRed:249.f/255.f green:249.f/255.f blue:249.f/255.f alpha:1]



/**
 *  FrameAndSizeDefine
 *
 *
 *
 */

#define KUIScreenWidth          [UIScreen mainScreen].applicationFrame.size.width
#define KUIScreenHeight         [UIScreen mainScreen].applicationFrame.size.height
#define kSelfViewHeight         self.view.bounds.size.height
#define kSelfViewWidth          self.view.bounds.size.width

// 缩略图大小定义
#define kChatThumbnailSize      CGSizeMake(100, 100)


#endif
