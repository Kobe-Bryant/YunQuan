//
//  VoiceMessageCell.m
//  ql
//
//  Created by LazySnail on 14-6-26.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "VoiceMessageCell.h"
#import "SnailMessageVoiceFactory.h"
#import "XHAudioPlayerHelper.h"
#import "SnailCacheManager.h"
#import "amrFileCodec.h"
#import "MessageDataManager.h"

const float defaultVoiceViewLong = 50.f;
const float defaultVoiceContentHight = 20.f;
const float UnreadDistantWithDuration = 0.f;
const float UnreadIndicatorWidth = 10.f;

const float AudioPlayEffectViewWidth = 30;
const float AudioPlayEffectViewHeigth = 25;
const float AudioPlayEffectDistanceWithVoiceContentView = -5;

@interface VoiceMessageCell () <XHAudioPlayerHelperDelegate>
{
    
}

@property (nonatomic, retain) UILabel * durationLabel;

@property (nonatomic, retain) UIView * voiceContentView;

@property (nonatomic, retain) UIImageView * voiceEffectImgView;

@property (nonatomic, retain) UIView * playDetectorView;

@property (nonatomic, assign) XHAudioPlayerHelper * audioPlayerHelper;

@property (nonatomic, retain) UIView * unreadIndicator;

@end

@implementation VoiceMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        //初始化各大组件类
        UIView * contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, defaultVoiceContentHight)];
        UILabel * duration = [UILabel new];
        
        //赋值成员变量
        self.voiceContentView = contentView;
        self.voiceContentView.userInteractionEnabled = YES;
        self.durationLabel = duration;
        self.durationLabel.textAlignment = NSTextAlignmentCenter;
        self.durationLabel.textColor = [UIColor grayColor];
        self.durationLabel.font = KQLSystemFont(10);
        self.audioPlayerHelper = [XHAudioPlayerHelper shareInstance];
        
        //释放临时组件类
        RELEASE_SAFE(contentView);
        RELEASE_SAFE(duration);
        
    }
    return self;
}

+ (float)caculateCellHightWithMessageData:(MessageData *)data
{
    float textHeight = defaultVoiceContentHight + TextVoiceCellFrameMargin * 2 + 4;
    textHeight += [MessageCell caculateCellHightWithMessageData:data];
    
    return textHeight;
}

- (void)freshWithInfoData:(MessageData *)data
{
    self.voiceObject = (VoiceData *)data.sessionData;
    
    NSInteger contentWidth = [self caculateContentWithMessageData:data];
    
    self.voiceContentView.frame = CGRectMake(0, 0, contentWidth, defaultVoiceContentHight);
    self.voiceContentView.backgroundColor = [UIColor clearColor];
    
    self.messageContentView = self.voiceContentView;
    [super freshWithInfoData:data];
    
    UIImageView * playEffectImg = [SnailMessageVoiceFactory messageVoiceAnimationImageViewWithBubbleMessageType:self.style];
    
    float playEffectHeight = CGRectGetHeight(_voiceContentView.bounds)/2 - AudioPlayEffectViewHeigth/2;
    
    switch (self.style) {
        case kSessionCellStyleSelf:{
            playEffectImg.frame = (CGRect){.origin = (CGPoint){CGRectGetWidth(_voiceContentView.frame) - CGRectGetWidth(playEffectImg.frame) - AudioPlayEffectDistanceWithVoiceContentView, playEffectHeight},.size = (CGSize){.width = AudioPlayEffectViewWidth,.height = AudioPlayEffectViewHeigth}};
             _indicatorView.frame = CGRectMake(_sessionBackView.frame.origin.x - _indicatorView.frame.size.width - 10,
                                               CGRectGetMidY(_sessionBackView.frame) - _indicatorView.frame.size.width/2,
                                               _indicatorView.frame.size.width,
                                               _indicatorView.frame.size.height);
            self.durationLabel.frame = CGRectMake(CGRectGetMinX(_sessionBackView.frame) - 20, CGRectGetMinY(_sessionBackView.frame), 20, 30);
            self.durationLabel.textColor = [UIColor grayColor];
            self.durationLabel.backgroundColor = [UIColor clearColor];
            self.durationLabel.textAlignment = NSTextAlignmentCenter;
            self.durationLabel.font = KQLSystemFont(10);
            self.durationLabel.text = [NSString stringWithFormat:@"%d''",(int)self.voiceObject.duration];
            [self.contentView addSubview:self.durationLabel];
            
            if (_sendFaildFlag != nil) {
                CGRect faildFlagFrame = _sendFaildFlag.frame;
                _sendFaildFlag.frame = CGRectMake(faildFlagFrame.origin.x - 15, faildFlagFrame.origin.y, faildFlagFrame.size.width, faildFlagFrame.size.height);
            }
            
            [self removeExistUnreadIndicator];
        }
            break;
        case kSessionCellStyleOther:{
            playEffectImg.frame = CGRectMake(AudioPlayEffectDistanceWithVoiceContentView, playEffectHeight, AudioPlayEffectViewWidth, AudioPlayEffectViewHeigth);
            _indicatorView.frame = CGRectMake(CGRectGetMaxX(_sessionBackView.frame) + _indicatorView.frame.size.width + 10,
                                              CGRectGetMidY(_sessionBackView.frame) - _indicatorView.frame.size.width/2,
                                              _indicatorView.frame.size.width,
                                              _indicatorView.frame.size.height);
            self.durationLabel.frame = CGRectMake(CGRectGetMaxX(_sessionBackView.frame), CGRectGetMinY(_sessionBackView.frame), 20, 30);
            self.durationLabel.textColor = [UIColor grayColor];
            self.durationLabel.backgroundColor = [UIColor clearColor];
            self.durationLabel.font = KQLSystemFont(10);
            self.durationLabel.textAlignment = NSTextAlignmentCenter;
            self.durationLabel.text = [NSString stringWithFormat:@"''%d",(int)self.voiceObject.duration];
            [self.contentView addSubview:self.durationLabel];
            
            //添加语音未读标识
            VoiceData * voiceData = self.voiceObject;
            
            if (voiceData.dataStatus == OriginDataStatusUnread) {
                if (self.unreadIndicator == nil && [self.unreadIndicator superview]== nil) {
                    CGRect rect = CGRectMake(CGRectGetMaxX(self.durationLabel.frame)
                                             + UnreadDistantWithDuration,
                                             CGRectGetMidY(self.durationLabel.frame)
                                             - UnreadIndicatorWidth/2 -5,
                                             UnreadIndicatorWidth,
                                             UnreadIndicatorWidth);
                    UIView * unreadIndicator = [[UIView alloc]initWithFrame:rect];
                    unreadIndicator.layer.cornerRadius = 5.f;
                    unreadIndicator.layer.masksToBounds = YES;
                    self.unreadIndicator = unreadIndicator;
                    self.unreadIndicator.backgroundColor = [UIColor redColor];
                    [self.contentView addSubview:self.unreadIndicator];
                    RELEASE_SAFE(unreadIndicator);
                }
            } else {
                [self removeExistUnreadIndicator];
            }
        }
            break;
        default:
            break;
    }
    if (self.voiceEffectImgView ) {
        [self.voiceEffectImgView removeFromSuperview];
    }
    self.voiceEffectImgView = playEffectImg;
    [_voiceContentView addSubview:playEffectImg];

    UIView * playDetectorView = [[UIView alloc]init];
    playDetectorView.frame = CGRectMake(-10, -10, CGRectGetWidth(_voiceContentView.frame) + 20, CGRectGetHeight(_voiceContentView.frame) + 20);
    playDetectorView.alpha = 0.4f;
    [_voiceContentView addSubview:playDetectorView];
    playDetectorView.userInteractionEnabled = YES;
    self.playDetectorView = playDetectorView;
    RELEASE_SAFE(playDetectorView);
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playCurrentVoice)];
    [self.playDetectorView addGestureRecognizer:tapGesture];
    RELEASE_SAFE(tapGesture);
}

- (void)removeExistUnreadIndicator
{
    if (self.unreadIndicator != nil && [self.unreadIndicator superview]!=nil) {
        [self.unreadIndicator removeFromSuperview];
        self.unreadIndicator = nil;
    }
}

//播放声音消息 并展现动画效果
- (void)playCurrentVoice
{
    if ([[[XHAudioPlayerHelper shareInstance]delegate] isEqual:self] ) {
        if ([[XHAudioPlayerHelper shareInstance]isPlaying]) {
            [[XHAudioPlayerHelper shareInstance]stopAudio];
            return;
        }
    }
    VoiceData * voiceData = (VoiceData *)self.msgObject.sessionData;
    
    if (voiceData.dataStatus == OriginDataStatusUnread) {
        voiceData.dataStatus = OriginDataStatusReaded;
        [[MessageDataManager shareMessageDataManager]updateData:self.msgObject];
        [self removeExistUnreadIndicator];
    }
    
    NSString * voiceUrlStr = self.voiceObject.url;
    
    NSString * suffixStr = [voiceUrlStr substringFromIndex:(voiceUrlStr.length - 11)];
    NSString * currentVoiceFileName = nil;
    if (![suffixStr isEqualToString:@"MySound.amr"]) {
        currentVoiceFileName = [SnailCacheManager getVoiceCachePathForKey:self.voiceObject.url];
    } else {
        currentVoiceFileName = self.voiceObject.url;
    }
    
    BOOL isExist = [[NSFileManager defaultManager]fileExistsAtPath:currentVoiceFileName];
    
    if (isExist) {
        [self setDelegateAndPlayOrPuaseVoiceWithName:currentVoiceFileName orVoiceData:nil];
    } else {
        [SnailCacheManager getAndCacheDataFromUrlStr:self.voiceObject.url complation:^(NSData *voiceData) {
            
            [self setDelegateAndPlayOrPuaseVoiceWithName:currentVoiceFileName orVoiceData:voiceData];
            RELEASE_SAFE(voiceData);
        }];
    }
}

- (void)setDelegateAndPlayOrPuaseVoiceWithName:(NSString *)voicePathName orVoiceData:(NSData *)voiceData
{
    //收到播放请求 先判断是否有声音消息正在播放 如果有则先暂停
    if ([[XHAudioPlayerHelper shareInstance]isPlaying]) {
        [[XHAudioPlayerHelper shareInstance]stopAudio];
        
        //如果点击的cell就是当前播放的cell 则停止播放
        if (([[[XHAudioPlayerHelper shareInstance]delegate] isEqual:self])) {
            [[XHAudioPlayerHelper shareInstance]setDelegate:nil];
            return;
        }
    }
    
    [[XHAudioPlayerHelper shareInstance] setDelegate:self];
    NSData * cafVoiceData = nil;
    if (voiceData != nil) {
        cafVoiceData = DecodeAMRToWAVE(voiceData);
        
        [[XHAudioPlayerHelper shareInstance]managerAudioWithData:cafVoiceData toPlay:YES];
    } else {
        //            [[XHAudioPlayerHelper shareInstance]managerAudioWithFileName:voicePathName toPlay:YES];
        NSData * armVoiceData = [NSData dataWithContentsOfFile:voicePathName];
        cafVoiceData = DecodeAMRToWAVE(armVoiceData);
        [[XHAudioPlayerHelper shareInstance]managerAudioWithData:cafVoiceData toPlay:YES];
    }

}

- (NSInteger )caculateContentWithMessageData:(MessageData *) messageData
{
    VoiceData * voice = (VoiceData *)messageData.sessionData;
    NSInteger width =  defaultVoiceViewLong + ((voice.duration/60.0f) * defaultVoiceViewLong);
    return width;
}

#pragma mark - XHAudioPlayerHelperDelegate

- (void)didAudioPlayerBeginPlay:(AVAudioPlayer*)audioPlayer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.voiceEffectImgView startAnimating];
    });
}

- (void)didAudioPlayerStopPlay:(AVAudioPlayer*)audioPlayer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.voiceEffectImgView stopAnimating];
        [self.delegate voiceMessageDidFinishedPlay:self];
    });
}

- (void)didAudioPlayerPausePlay:(AVAudioPlayer*)audioPlayer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.voiceEffectImgView stopAnimating];
    });
}

- (void)dealloc
{
    [[XHAudioPlayerHelper shareInstance] setDelegate:nil];
    [super dealloc];
}


@end
