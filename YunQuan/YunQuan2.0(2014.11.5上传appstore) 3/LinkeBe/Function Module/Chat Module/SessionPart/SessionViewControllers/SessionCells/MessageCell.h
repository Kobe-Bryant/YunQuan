//
//  MessageCell.h
//  ql
//
//  Created by LazySnail on 14-6-6.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDImageCache.h"
#import "MessageData.h"
#import "OriginTimeStampCell.h"


//对话框最大宽度
#define DailogueWidth               180
//头像距屏幕两边间距
#define SideMargin                  10
//对话气泡内部间距
#define DailogueFrameMargin         ([self isKindOfClass:[PictureMessageCell class]] ? PictureCellFrameMargin : TextVoiceCellFrameMargin)
//图片气泡边缘高度
#define PictureCellFrameMargin      4.f
//文本语音气泡边缘高度
#define TextVoiceCellFrameMargin    8.f

//对话气泡的箭头长度
#define BubbleArrowLength           8.f

//名称和头像之间的间距
#define NamePortraitDistance        10.f

typedef enum{
    kSessionCellStyleSelf ,
    kSessionCellStyleOther
}kSessionCellStyle;

@class MessageData;


@interface MessageCell : OriginTimeStampCell
{
    UIImageView * _sessionBackView;
    UIImage *_sessionImageSelf;
    UIImage *_sessionImageOther;
    UILabel *_userName;
    UIImageView * _headImgView;
    UIView * _messageContentView;
    UIActivityIndicatorView * _indicatorView;
    UIImageView * _sendFaildFlag;
    SDImageCache *_sessionCellImgCache;
    BOOL * _isSendSuccess;
}

@property (nonatomic,retain) MessageData * msgObject;
@property (nonatomic,retain) UIView * messageContentView;
@property (nonatomic, assign) kSessionCellStyle style;

- (void)recieveMessageSendNoti:(NSNotification *)notif;
- (BOOL)judgeSendedNofityMessageWithNoti:(NSNotification *)noti;

@end
