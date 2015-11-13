//
//  XHVoiceRecordHUD.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-5-13.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHVoiceRecordHUD.h"

#define kXHVoiceRecordPauseString       @"手指上滑，取消发送"
#define kXHVoiceRecordResaueString      @"松开手指，取消发送"
#define kSnailVoiceRecordCountdownStr      @"倒计时，即将发送"

#define selfViewMidX CGRectGetMidX(self.frame)
#define selfViewMidY CGRectGetMidY(self.frame)

@interface XHVoiceRecordHUD ()

@property (nonatomic, weak) UILabel *remindLabel;
@property (nonatomic, weak) UIImageView *microPhoneImageView;
@property (nonatomic, weak) UIImageView *cancelRecordImageView;
@property (nonatomic, weak) UIImageView *recordingHUDImageView;
@property (nonatomic, weak) UIImageView *timeLimitNumImageView;

/**
 *  逐渐消失自身
 *
 *  @param compled 消失完成的回调block
 */
- (void)dismissCompled:(void(^)(BOOL fnished))compled;

/**
 *  配置是否正在录音，需要隐藏和显示某些特殊的控件
 *
 *  @param recording 是否录音中
 */
- (void)configRecoding:(BOOL)recording;

/**
 *  根据语音输入的大小来配置需要显示的HUD图片
 *
 *  @param peakPower 输入音频的声音大小
 */
- (void)configRecordingHUDImageWithPeakPower:(CGFloat)peakPower;

/**
 *  配置默认参数
 */
- (void)setup;

@end

@implementation XHVoiceRecordHUD

- (void)startRecordingHUDAtView:(UIView *)view {
    CGPoint center = CGPointMake(CGRectGetWidth(view.frame) / 2.0, CGRectGetHeight(view.frame) / 2.0);
    self.center = center;
    [view addSubview:self];
    [self configRecoding:YES];
}

- (void)pauseRecord {
    [self configRecoding:YES];
    self.remindLabel.backgroundColor = [UIColor clearColor];
    self.remindLabel.text = kXHVoiceRecordPauseString;
}

- (void)resaueRecord {
    [self configRecoding:NO];
    self.remindLabel.backgroundColor = [UIColor colorWithRed:1.000 green:0.000 blue:0.000 alpha:0.630];
    self.remindLabel.text = kXHVoiceRecordResaueString;
}

- (void)stopRecordCompled:(void(^)(BOOL fnished))compled {
    [self dismissCompled:compled];
}

- (void)cancelRecordCompled:(void(^)(BOOL fnished))compled {
    [self dismissCompled:compled];
}

- (void)dismissCompled:(void(^)(BOOL fnished))compled {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
        compled(finished);
    }];
}

- (void)configRecoding:(BOOL)recording {
    self.microPhoneImageView.hidden = !recording;
    self.recordingHUDImageView.hidden = !recording;
    self.cancelRecordImageView.hidden = recording;
}

- (void)showCountdownAnimation{
    self.microPhoneImageView.hidden = YES;
    self.recordingHUDImageView.hidden = YES;
    self.cancelRecordImageView.hidden = YES;
    self.timeLimitNumImageView.hidden = NO;
    [self.timeLimitNumImageView startAnimating];
    self.remindLabel.text = kSnailVoiceRecordCountdownStr;
}

- (void)hideCountdownAnimation{
    [self.timeLimitNumImageView stopAnimating];
    self.timeLimitNumImageView.hidden = YES;
}

- (void)configRecordingHUDImageWithPeakPower:(CGFloat)peakPower {
    NSString *imageName = @"ico_common_point";
    if (peakPower >= 0 && peakPower <= 0.1) {
        imageName = [imageName stringByAppendingString:@"1"];
    } else if (peakPower > 0.1 && peakPower <= 0.2) {
        imageName = [imageName stringByAppendingString:@"2"];
    } else if (peakPower > 0.3 && peakPower <= 0.4) {
        imageName = [imageName stringByAppendingString:@"3"];
    } else if (peakPower > 0.4 && peakPower <= 0.5) {
        imageName = [imageName stringByAppendingString:@"4"];
    } else if (peakPower > 0.5 && peakPower <= 0.6) {
        imageName = [imageName stringByAppendingString:@"5"];
    } else if (peakPower > 0.7 && peakPower <= 0.8) {
        imageName = [imageName stringByAppendingString:@"6"];
    } else if (peakPower > 0.8 && peakPower <= 0.9) {
        imageName = [imageName stringByAppendingString:@"7"];
    } else if (peakPower > 0.9 && peakPower <= 1.0) {
        imageName = [imageName stringByAppendingString:@"8"];
    }
    self.recordingHUDImageView.image = [UIImage imageNamed:imageName];
}

- (void)setPeakPower:(CGFloat)peakPower {
    _peakPower = peakPower;
    [self configRecordingHUDImageWithPeakPower:peakPower];
}

- (void)setup {
    self.backgroundColor = [UIColor blackColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10;
    
    if (!_remindLabel) {
        UILabel *remindLabel= [[UILabel alloc] initWithFrame:CGRectMake(selfViewMidX - 60,CGRectGetMaxY(self.frame) - 20, 120.0, 21.0)];
        remindLabel.textColor = [UIColor whiteColor];
        remindLabel.font = [UIFont systemFontOfSize:13];
        remindLabel.layer.masksToBounds = YES;
        remindLabel.layer.cornerRadius = 4;
        remindLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        remindLabel.backgroundColor = [UIColor clearColor];
        remindLabel.text = kXHVoiceRecordPauseString;
        remindLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:remindLabel];
        _remindLabel = remindLabel;
    }
    
    if (!_microPhoneImageView) {
        UIImageView *microPhoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(selfViewMidX - 50, selfViewMidY - 95, 100, 170)];
        microPhoneImageView.image = [UIImage imageNamed:@"ico_common_record.png"];
        microPhoneImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        microPhoneImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:microPhoneImageView];
        _microPhoneImageView = microPhoneImageView;
    }
    
    if (!_recordingHUDImageView) {
        UIImageView *recordHUDImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMidX(_microPhoneImageView.frame) - 45, CGRectGetMidY(_microPhoneImageView.frame) - 85.0, 100.0, 170.0)];
        recordHUDImageView.image = [UIImage imageNamed:@"ico_common_point1.png"];
        recordHUDImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        recordHUDImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:recordHUDImageView];
        _recordingHUDImageView = recordHUDImageView;
    }
    
    if (!_cancelRecordImageView) {
        UIImageView *cancelRecordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(19.0, 7.0, 100.0, 100.0)];
        cancelRecordImageView.image = [UIImage imageNamed:@"RecordCancel"];
        cancelRecordImageView.hidden = YES;
        cancelRecordImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        cancelRecordImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:cancelRecordImageView];
        _cancelRecordImageView = cancelRecordImageView;
    }
    
    if (!self.timeLimitNumImageView) {
        NSMutableArray * animationArrs = [[NSMutableArray alloc]initWithCapacity:10];
        for (int i = 10; i>=0; i--) {
            NSString *imgName = [NSString stringWithFormat:@"img_chat_%d.png",i];
            UIImage *numImg = [UIImage imageCwNamed:imgName];
            [animationArrs addObject:numImg];
        }
        
        UIImageView *timeLimitNumImageView = [[UIImageView alloc]initWithFrame:CGRectMake(19.0, CGRectGetMidY(self.bounds) - 60, 100.0, 100.0)];
        timeLimitNumImageView.image = [UIImage imageCwNamed:@"img_chat_10.png"];
        timeLimitNumImageView.contentMode = UIViewContentModeScaleAspectFit;
        timeLimitNumImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        timeLimitNumImageView.hidden = YES;
        timeLimitNumImageView.animationImages = animationArrs;
        timeLimitNumImageView.animationDuration = 11.0f;
        timeLimitNumImageView.animationRepeatCount = 1;
        timeLimitNumImageView.backgroundColor = [UIColor clearColor];
        self.timeLimitNumImageView = timeLimitNumImageView;
        [self addSubview:self.timeLimitNumImageView];
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
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
