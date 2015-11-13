//
//  sessionInfoCell.m
//  ql
//
//  Created by LazySnail on 14-4-28.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "TextMessageCell.h"
#import "TQRichTextView.h"
#import "RegexKitLite.h"
#import "TQRichTextEmojiRun.h"
#import "PictureMessageCell.h"

const int textFront = 16;

@interface TextMessageCell ()
{
}

@property (nonatomic, retain) TQRichTextView *msgTextView;

@end

@implementation TextMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    //文本消息内容框
    self.msgTextView = [[[TQRichTextView alloc]initWithFrame:CGRectZero]autorelease];
    self.msgTextView.backgroundColor = [UIColor clearColor];
    self.msgTextView.font = KQLSystemFont(textFront);
    self.msgTextView.textColor = [UIColor colorWithRed:68.0f/255.0f green:68.0f/255.0f blue:68.0f/255.0f alpha:1.0f];
    
    return self;
}

+ (float)caculateCellHightWithMessageData:(MessageData *)data
{    
    float textHeight = [OriginTimeStampCell caculateCellHightWithMessageData:data];
    CGSize textSize = [TextMessageCell getTextContentSizeFromData:data];
    textHeight =  textSize.height + TextVoiceCellFrameMargin*2 + textHeight;
    return textHeight;
}

+ (CGSize)getTextContentSizeFromData:(MessageData *)data
{
    //获取文本内容并且计算本文长度
    NSString * messageStr =[data.sessionData valueForKey:@"txt"];
    
    //转换表情字符的长度
    NSString *lengStr = [TextMessageCell translateLengthStringFromEmoj:messageStr];
    
    CGSize textSize = [lengStr sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(DailogueWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    
    float textHeight = [TQRichTextView getRechTextViewHeightWithText:messageStr viewWidth:textSize.width font:KQLSystemFont(textFront) lineSpacing:1.0f];
    //width需要稍微加大点，不然单个表情时会导致绘制长度计算错误
    textSize = CGSizeMake(textSize.width + 5,textHeight);
    return textSize;
}

- (void)freshWithInfoData:(MessageData *)data
{
    self.msgTextView.text = [data.sessionData valueForKey:@"txt"];
    self.msgTextView.lineSpacing = 1.0f;
    
    // 获取消息类容的Size大小
    CGSize textSize = [TextMessageCell getTextContentSizeFromData:data];
    
    self.msgTextView.frame = CGRectMake(10,10,textSize.width,textSize.height);
    
    //赋值messageContentView 背景sessionBackView 的大小将会根据这个view的大小来作调整
    _messageContentView = self.msgTextView;
    
    //获取Cell的类型 用于判断自己发送还是别人发送从而确定消息框位置
    [super freshWithInfoData:data];
    
    CGRect indicatorRect = CGRectMake(_sessionBackView.frame.origin.x - _indicatorView.frame.size.width, CGRectGetMidY(_sessionBackView.frame) - _indicatorView.frame.size.width/2, _indicatorView.frame.size.width, _indicatorView.frame.size.height);

    if (self.style == kSessionCellStyleSelf && _indicatorView != nil) {
        _indicatorView.frame = indicatorRect;
    }
    
    switch (self.style) {
        case kSessionCellStyleSelf:
        {
            self.msgTextView.textColor = [UIColor whiteColor];
        }
            break;
        case kSessionCellStyleOther:
        {
            self.msgTextView.textColor = [UIColor blackColor];
        }
        default:
            break;
    }
    
}

// 将表情字符转换为正常字符长度
+ (NSString *)translateLengthStringFromEmoj:(NSString *)emojStr
{
    NSMutableArray * changeRangeArr = [NSMutableArray arrayWithCapacity:3];
    NSMutableString * resultStr = [NSMutableString stringWithString:emojStr];
    
    [TQRichTextEmojiRun analyzeText:emojStr runsArray:&changeRangeArr];
    for (TQRichTextEmojiRun * textEmojiRunObj in changeRangeArr) {
        [resultStr replaceOccurrencesOfString:textEmojiRunObj.originalText
                                   withString:@"aa]"
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, [resultStr length])];
    }
    return [[resultStr retain]autorelease];
}

- (void)dealloc
{
    RELEASE_SAFE(_userName);
    RELEASE_SAFE(_headImgView);
    RELEASE_SAFE(_sessionBackView);
    RELEASE_SAFE(_sessionImageSelf);
    RELEASE_SAFE(_sessionImageOther);
    self.msgTextView = nil;
    [super dealloc];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
