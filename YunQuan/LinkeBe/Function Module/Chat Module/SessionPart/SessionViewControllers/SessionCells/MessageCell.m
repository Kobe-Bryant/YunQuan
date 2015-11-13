//
//  MessageCell.m
//  ql
//
//  Created by LazySnail on 14-6-6.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "MessageCell.h"
#import "UIImageView+WebCache.h"
#import "PictureMessageCell.h"

const float portraitWidth = 35.0f;
const float portraitHeight = 35.0f;
const float faildFlagDistanceWithDailogue = 5.0f;

@interface MessageCell () <MessageDataDelegate>
{
    
}

@end

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor clearColor];
    
    if (self) {
        // Initialization code
        //用户名字
        _userName = [UILabel new];
        _userName.font = KQLSystemFont(12);
        _userName.textColor = [UIColor grayColor];
        _userName.backgroundColor = [UIColor clearColor];
        
        //用户头像
        _headImgView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _headImgView.backgroundColor = [UIColor clearColor];
        _headImgView.userInteractionEnabled = YES;
        _headImgView.layer.cornerRadius = 5;
        _headImgView.layer.borderWidth = 0.5f;
        _headImgView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0].CGColor;
        _headImgView.clipsToBounds = YES;
        
        //add vincent
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImgViewTapGesture)];
        [_headImgView addGestureRecognizer:tap];
        RELEASE_SAFE(tap);
        
        //消息背景框
        _sessionBackView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _sessionBackView.backgroundColor = [UIColor clearColor];
        _sessionBackView.userInteractionEnabled = YES;
        
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:
                                                    self
                                                    action:@selector(handleLongPress:)];
        [recognizer setMinimumPressDuration:0.4];
        [_sessionBackView addGestureRecognizer:recognizer];
        RELEASE_SAFE(recognizer);
        
        [self.contentView addSubview:_userName];
        [self.contentView addSubview:_headImgView];
        [self.contentView addSubview:_sessionBackView];
        
        //图片缓存器
        _sessionCellImgCache = [SDImageCache sharedImageCache];      
    }
    return self;
}

#pragma mark - Copying
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action == @selector(copy:))
        return YES;
    
    return [super canPerformAction:action withSender:sender];
}

- (void)copy:(id)sender
{
    NSString * copyStr = [self.msgObject.sessionData valueForKey:@"txt"];
    if (copyStr) {
        [[UIPasteboard generalPasteboard] setString:copyStr];
    }
    [self resignFirstResponder];
}

/*
 其实扩展的时候不需要在这里添加，直接添加在这个方法里
 -(BOOL)canPerformAction:(SEL)action withSender:(id)sender
 if(action == @selector(copy:)|| action == @selector(select:) )即可 add by devin
 
 UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"扩展Item项" action:@selector(more)];
 NSArray *itemArr = [NSArray arrayWithObjects:copyItem, nil];
 添加自定义方法的时候需要在canperformAction里加入 action == @selector(more)判断
 */
#pragma mark - Gestures
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if(longPress.state != UIGestureRecognizerStateBegan
       || ![self becomeFirstResponder])
    return;
    
    if (self.msgObject.sessionData.objtype == DataMessageTypeText) {
        NSString * messageTextStr = [self.msgObject.sessionData valueForKey:@"txt"];
        //只有文本才有复制，图片录音没有
        if (messageTextStr != nil) {
            CGRect targetRect = [self convertRect:_messageContentView.frame
                                         fromView:_sessionBackView];
            
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            [menuController setMenuVisible:YES animated:YES];
            [menuController setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
        }
    }
}

-(void)headImgViewTapGesture{
    //找到window最前面的ViewController
    [self.delegate portraitViewHaveClickedWithMessageData:self.msgObject];
}

- (void)recieveMessageSendNoti:(NSNotification *)noti
{
    [self judgeSendedNofityMessageWithNoti:noti];
   }

- (BOOL)judgeSendedNofityMessageWithNoti:(NSNotification *)noti
{
    NSDictionary *retDic = [noti object];
    NSLog(@"In message cell Message Sended With dic %@ ",retDic);
    
    //通过locmsigid 来判断消息的发送成功 并从待确认的已发消息队列中移除
    if ([[retDic objectForKey:@"rcode"]intValue] == 0) {
        long locmsgid = [[retDic objectForKey:@"locmsgid"]longValue];
        if (self.msgObject.locmsgid == locmsgid)
        {
            self.msgObject.statusType = MessageStatusTypeSendSuccessed;
            // 将已发消息展现在界面上
            [_indicatorView stopAnimating];
            [_indicatorView removeFromSuperview];
            RELEASE_SAFE(_indicatorView);
            
            [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotiSendMessageSuccess object:nil];
            return YES;
        }
    }
    return NO;
}


-(void)freshWithInfoData:(MessageData *)data
{
    [super freshWithInfoData:data];
    
    self.style = data.operationType == MessageOperationTypeSend ? kSessionCellStyleSelf : kSessionCellStyleOther;
    self.msgObject = data;
    data.delegate = self;
    
    //添加消息内容视图
    if (_messageContentView != nil) {
        [_sessionBackView addSubview:_messageContentView];
    }
    
    //判断消息数据类型 如果是发送状态1 数据则打开进度视图
    if (self.msgObject.statusType ==  MessageStatusTypeSending)
    {
        if (_indicatorView == nil) {
            //添加进度指示器
            _indicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
            _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            _indicatorView.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:_indicatorView];
        }
        [_indicatorView startAnimating];

        //添加信息发送成功监听器
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(recieveMessageSendNoti:) name:kNotiSendMessageSuccess object:nil];
    } else {
        if (_indicatorView != nil) {
            [_indicatorView removeFromSuperview];
            RELEASE_SAFE(_indicatorView);
        }
    }
   
    //判断消息是否加发送失败标识
    if (self.msgObject.statusType == MessageStatusTypeSendFailed)
    {
        if (_sendFaildFlag == nil && [_sendFaildFlag superview] == nil) {
            //如果该消息未发送成功则显示未发送成功提示
            UIImage * faildFlag = [UIImage imageNamed:@"ico_chat_error.png"];
            _sendFaildFlag = [[UIImageView alloc]initWithImage:faildFlag];
            _sendFaildFlag.layer.cornerRadius = 5;
            _sendFaildFlag.layer.masksToBounds = YES;
            _sendFaildFlag.userInteractionEnabled = YES;
            [self.contentView addSubview:_sendFaildFlag];
            
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resendButtonTap)];
            [_sendFaildFlag addGestureRecognizer:tapGesture];
            RELEASE_SAFE(tapGesture);
            
        }
    } else {
        if (_sendFaildFlag != nil) {
            [_sendFaildFlag removeFromSuperview];
            RELEASE_SAFE(_sendFaildFlag);
        }
    }
    _userName.text = self.msgObject.speaker.objectName;
    
    float namelength = _userName.text.length * 20;
    CGSize nameSize = [_userName.text sizeWithFont:KQLSystemFont(12) constrainedToSize:CGSizeMake(namelength, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    
    CGRect portraitRect;
    CGRect messageContentRect;
    CGRect sessionBackRect;
    CGRect faildFlagRect = _sendFaildFlag.frame;
    CGRect userNameRect = CGRectZero;
    ObjectData * speckerOject = nil;
    
    float sessionBackWidth = CGRectGetWidth(_messageContentView.bounds) + (DailogueFrameMargin*2 + BubbleArrowLength);
    float sessionBackHeight = CGRectGetHeight(_messageContentView.bounds) + DailogueFrameMargin * 2;
    
    switch (self.style)
    {
        case kSessionCellStyleSelf:
        {
            //获取自己的头像
            speckerOject = [ObjectData objectFromMemberListWithID:[[[UserModel shareUser] user_id] longLongValue]];
            
            portraitRect = CGRectMake(KUIScreenWidth - portraitWidth - SideMargin, CGRectGetMaxY(self.timeLabel.frame), portraitWidth,portraitHeight);
        
            if (_sessionImageSelf == nil) {
                _sessionImageSelf = [UIImage imageNamed:@"bg_chat_dialog_blue.png"];
                _sessionImageSelf = [[_sessionImageSelf stretchableImageWithLeftCapWidth:25 topCapHeight:25]retain];
            }
            _sessionBackView.image = _sessionImageSelf;
            
            messageContentRect = (CGRect){.origin = {.x = DailogueFrameMargin,.y = DailogueFrameMargin},.size = _messageContentView.frame.size};
            
            sessionBackRect = CGRectMake(KUIScreenWidth - sessionBackWidth - (SideMargin + portraitWidth),CGRectGetMinY(portraitRect),sessionBackWidth,sessionBackHeight);
            
            float faildFlagX = sessionBackRect.origin.x - _sendFaildFlag.frame.size.width - faildFlagDistanceWithDailogue;
            float faildFlagY = CGRectGetMidY(sessionBackRect) - _sendFaildFlag.frame.size.height/2;
            
            faildFlagRect = CGRectMake(faildFlagX,faildFlagY,_sendFaildFlag.frame.size.width, _sendFaildFlag.frame.size.height);
            
            _userName.hidden = YES;
        }
            break;
            
        case kSessionCellStyleOther:
        {
            //获取别人的头像
            speckerOject = self.msgObject.speaker;
        
            portraitRect = CGRectMake(SideMargin, CGRectGetMaxY(self.timeLabel.frame), portraitWidth,portraitHeight);
            
            if (_sessionImageOther == nil) {
                _sessionImageOther = [UIImage imageNamed:@"bg_chat_dialog_white.png"];
                _sessionImageOther = [[_sessionImageOther stretchableImageWithLeftCapWidth:25 topCapHeight:25]retain];
            }
            _sessionBackView.image = _sessionImageOther;
            
            //由于聊天背景的会话泡泡左边比较宽 因此需要调整内容的位置左边间距设为20 px 使其局中
            messageContentRect = (CGRect){.origin = {.x = BubbleArrowLength + DailogueFrameMargin,.y = DailogueFrameMargin},.size = _messageContentView.frame.size};
            
            switch (data.sessionType) {
                case SessionTypePerson:
                {
                    userNameRect =  CGRectMake(CGRectGetMaxX(portraitRect) + BubbleArrowLength,CGRectGetMaxY(self.timeLabel.frame), nameSize.width + 20,0);;
                    _userName.hidden = YES;
                }
                    break;
                case SessionTypeTempCircle:
                {
                    userNameRect = CGRectMake(CGRectGetMaxX(portraitRect) + BubbleArrowLength,CGRectGetMaxY(self.timeLabel.frame), nameSize.width + 20, nameSize.height +5);
                    _userName.hidden = NO;

                }
                    break;
                default:
                    break;
            }
            
            sessionBackRect = CGRectMake(CGRectGetMaxX(portraitRect) ,CGRectGetMaxY(userNameRect), sessionBackWidth,sessionBackHeight);

        }
            break;
    }
    
    //设置头像图片
    [_headImgView setNoSmoothEffectImageWithKeyStr:speckerOject.objectPortrait placeholderImage:[speckerOject getDefaultProtraitImg]];
    
    _headImgView.frame = portraitRect;
    _headImgView.backgroundColor = [UIColor clearColor];
    _messageContentView.frame = messageContentRect;
    _sessionBackView.frame = sessionBackRect;
    _sendFaildFlag.frame = faildFlagRect;
    _userName.frame = userNameRect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - MessageDataDelegate

- (void)messageDataStatusChange:(MessageData *)messageData
{
    if ([self.msgObject isEqual:messageData]) {
        [self freshWithInfoData:messageData];
    }
}

#pragma mark - UITapGestureRecognizerMethod

- (void)resendButtonTap
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"是否重发消息" message:nil delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    [alert show];
    RELEASE_SAFE(alert);
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self.delegate resendMessageWithMessage:self.msgObject];
    }
}

#pragma mark- Dealloc

- (void)dealloc
{
    RELEASE_SAFE(_sessionBackView);
    RELEASE_SAFE(_sessionImageSelf);
    RELEASE_SAFE(_sessionImageOther);
    RELEASE_SAFE(_userName);
    RELEASE_SAFE(_headImgView);
    RELEASE_SAFE(_indicatorView);
    
    self.msgObject = nil;
    [super dealloc];
}

@end
