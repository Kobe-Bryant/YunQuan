//
//  OtherLinkCell.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-19.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "OtherLinkCell.h"
#import "PictureMessageCell.h"

#define ContentViewWidth  220
#define TitleWidth        204

@implementation OtherLinkCell {

    int publishId;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setup];
    }
    return self;
}

-(void) setup{
    
    UIView *conV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ContentViewWidth, 100)];
    conV.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:conV];
    self.contentV = conV;
    RELEASE_SAFE(conV);
    
    UIView *bgV = [[UIView alloc] init];
    bgV.layer.cornerRadius = 3.0;
    bgV.layer.masksToBounds = YES;
    bgV.backgroundColor = [UIColor whiteColor];
    bgV.frame = CGRectMake(5, 40,ContentViewWidth - 10, 60);
    [_contentV addSubview:bgV];
    self.bgView = bgV;
    RELEASE_SAFE(bgV);
    
    UIImageView *whImageV = [[UIImageView alloc] init];
    whImageV.frame = CGRectMake(5, (_bgView.frame.size.height - 50) / 2, 50, 50);
    [_bgView addSubview:whImageV];
    self.iconView = whImageV;
    RELEASE_SAFE(whImageV);
    
    TQRichTextView *msgText = [[TQRichTextView alloc]init];
    msgText.frame = CGRectMake(6, 2, TitleWidth, 30);
    msgText.backgroundColor = [UIColor clearColor];
    msgText.font = KQLSystemFont(17);
    msgText.textColor = [UIColor colorWithRed:68.0f/255.0f green:68.0f/255.0f blue:68.0f/255.0f alpha:1.0f];
    [_contentV addSubview:msgText];
    self.msgTextView = msgText;
    RELEASE_SAFE(msgText);
    
    TQRichTextView *desLabel = [[TQRichTextView alloc] init];
    desLabel.frame = CGRectMake(CGRectGetMaxX(_iconView.frame) + 5,5, _bgView.frame.size.width - _iconView.frame.size.width - 13, _iconView.frame.size.height);
    desLabel.backgroundColor = [UIColor clearColor];
    desLabel.textColor = [UIColor darkGrayColor];
    desLabel.font = KQLSystemFont(13);
    [_bgView addSubview:desLabel];
    self.descriptionLabel = desLabel;
    RELEASE_SAFE(desLabel);
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterDynamicDetail)];
    [_contentV addGestureRecognizer:tap];
    [tap release];

    
}

+ (float)caculateCellHightWithMessageData:(MessageData *)data
{
    float textHeight = [OriginTimeStampCell caculateCellHightWithMessageData:data];
    CGSize textSize = [OtherLinkCell getTextContentSizeFromData:data];
    textHeight +=  textSize.height + DailogueFrameMargin*2 + textHeight;
    return textHeight + 25;
}

+ (CGSize)getTextContentSizeFromData:(MessageData *)data
{
    //获取文本内容并且计算本文长度
    NSString * messageStr =[data.sessionData valueForKey:@"txt"];
    
    //转换表情字符的长度
    NSString *lengStr = nil;
    if (messageStr) {
        lengStr = [OtherLinkCell translateLengthStringFromEmoj:messageStr];
    }
    
    CGSize textSize = [lengStr sizeWithFont:KQLSystemFont(17) constrainedToSize:CGSizeMake(TitleWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    
    float textHeight = [TQRichTextView getRechTextViewHeightWithText:messageStr viewWidth:TitleWidth font:KQLSystemFont(17) lineSpacing:1.0f];
    //width需要稍微加大点，不然单个表情时会导致绘制长度计算错误
    textSize = CGSizeMake(textSize.width + 5,textHeight + 18);
    return textSize;
}

- (void)freshWithInfoData:(MessageData *)data
{
    publishId = [[data.sessionData valueForKey:@"dataID"] intValue];
    
    NSString * timeStr = [Common makeSessionViewHumanizedTimeForWithTime:data.sendtime];
    self.timeLab.text = timeStr;
    self.msgTextView.text = [data.sessionData valueForKey:@"txt"];
    self.descriptionLabel.text = [data.sessionData valueForKey:@"msgdesc"];
    self.timeLab.text = timeStr;
    if (data.sessionData.objtype == DataMessageTypeIWant) {
        self.iconView.image = [UIImage imageNamed:@"ico_feed_write_have.png"];
    } else if(data.sessionData.objtype == DataMessageTypeIHave) {
        self.iconView.image = [UIImage imageNamed:@"ico_feed_write_want.png"];
    } else if (data.sessionData.objtype == DataMessageTypeTogether) {
        self.iconView.image = [UIImage imageNamed:@"ico_feed_write_party.png"];
    }
    
    // 获取消息类容的Size大小
    CGSize textSize = [OtherLinkCell getTextContentSizeFromData:data];
    
    NSLog(@"self.msgTextView.text = %@ textSize.height = %f textSize.width = %f",self.msgTextView.text,textSize.height,textSize.width);
    
    //重新定位位置 frame
    _contentV.frame =  CGRectMake(0, 0, ContentViewWidth,textSize.height + 50);
    _msgTextView.frame = CGRectMake(6, 2, TitleWidth, textSize.height);
    _bgView.frame = CGRectMake(0, textSize.height - 9,ContentViewWidth, 60);
    
    //赋值messageContentView 背景sessionBackView 的大小将会根据这个view的大小来作调整
    _messageContentView = _contentV;
    
    //获取Cell的类型 用于判断自己发送还是别人发送从而确定消息框位置
    [super freshWithInfoData:data];
    
    CGRect indicatorRect = CGRectMake(_sessionBackView.frame.origin.x - _indicatorView.frame.size.width, CGRectGetMidY(_sessionBackView.frame) - _indicatorView.frame.size.width/2, _indicatorView.frame.size.width, _indicatorView.frame.size.height);
    
    if (self.style == kSessionCellStyleSelf && _indicatorView != nil) {
        _indicatorView.frame = indicatorRect;
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

- (void)enterDynamicDetail {
    if ([self.delegate respondsToSelector:@selector(callBackEnterDynamicDetail:)]) {
        [self.delegate callBackEnterDynamicDetail:publishId];
    }
}

- (void)dealloc
{
    self.msgTextView = nil;
    self.timeLab = nil;
    self.descriptionLabel = nil;
    self.iconView = nil;
    self.bgView = nil;
    self.contentV = nil;
    [super dealloc];
}


@end
