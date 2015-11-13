//
//  SnailEmotionCell.m
//  ql
//
//  Created by LazySnail on 14-8-22.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import "SnailEmotionCell.h"
#import "UIImageView+WebCache.h"
#import "EmotionStoreData.h"
#import "DDProgressView.h"
#import "EmotionStoreManager.h"
#import "ChatMacro.h"

#define DownloadButtonWidth         60
#define DownloadButtonHeight        32

@interface SnailEmotionCell ()<EmotionStroeManagerDelegate>
{
    
}

@property (nonatomic, retain) UIImageView *thumbIcon;

@property (nonatomic, retain) UIButton *downLoadButton;

@property (nonatomic, retain) UILabel *emotionDetailLabel;

@property (nonatomic, retain) UILabel *emotionTitleLabel;

@property (nonatomic, retain) UIView *separatorView;

@property (nonatomic, retain) UIImageView *emotionAccessoryView;
//进度条
@property(nonatomic,retain) DDProgressView *progressView;

@property(nonatomic,retain) EmotionStoreData *emoticondata;

@end

@implementation SnailEmotionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView * thumbImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        thumbImg.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:thumbImg];
        self.thumbIcon = thumbImg;
        RELEASE_SAFE(thumbImg);
        
        UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 20, 100, 20)];
        titleLabel.text = @"红星闪闪";
        titleLabel.font = KQLSystemFont(15);
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.numberOfLines = 0;
        titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:titleLabel];
        self.emotionTitleLabel = titleLabel;
        RELEASE_SAFE(titleLabel);
        
        CGRect detailRect = CGRectMake(100, 45, 160, 40);
        UILabel * detailLabel = [[UILabel alloc]initWithFrame:detailRect];
        detailLabel.text = @"一切为了革命";
        detailLabel.font = KQLSystemFont(14);
        detailLabel.textColor = [UIColor grayColor];
        detailLabel.numberOfLines = 0;
        detailLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:detailLabel];
        self.emotionDetailLabel = detailLabel;
        RELEASE_SAFE(detailLabel);
        
        CGRect buttonFrame = CGRectMake(self.frame.size.width - DownloadButtonWidth - 10, self.frame.size.height /2, DownloadButtonWidth, DownloadButtonHeight);
        UIButton *tempButton = [[UIButton alloc]initWithFrame:buttonFrame];
        tempButton.backgroundColor = COLOR_CONTROL;
        [tempButton addTarget:self action:@selector(downloadEmoticon) forControlEvents:UIControlEventTouchUpInside];
        tempButton.layer.cornerRadius = 3.0f;
        tempButton.layer.masksToBounds = YES;
        
        UILabel * infoLabel = [[UILabel alloc]initWithFrame:tempButton.bounds];
        infoLabel.font = KQLboldSystemFont(14);
        infoLabel.text = @"下载";
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.textColor = [UIColor whiteColor];
        
        [tempButton addSubview:infoLabel];
        
        [self.contentView addSubview:tempButton];
        self.downLoadButton = tempButton;
        RELEASE_SAFE(infoLabel);
        RELEASE_SAFE(tempButton);
        
        UIView * separatorView = [[UIView alloc]initWithFrame:CGRectMake(0, 80.0f, KUIScreenWidth, 0.5f)];
        separatorView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
        [self addSubview:separatorView];
        self.separatorView = separatorView;
        RELEASE_SAFE(separatorView);
        
        UIImageView * accessoryView = [[UIImageView alloc]initWithImage:IMGREADFILE(@"ico_chat_tick.png")];
        accessoryView.frame = self.downLoadButton.frame;
        accessoryView.contentMode = UIViewContentModeScaleAspectFit;
        self.emotionAccessoryView = accessoryView;
        [self addSubview:accessoryView];
        [self sendSubviewToBack:accessoryView];
        RELEASE_SAFE(accessoryView);
        
        //初始化进度条
        CGRect progressRect = CGRectMake(self.frame.size.width - DownloadButtonWidth - 10, 40, DownloadButtonWidth, DownloadButtonHeight);
        DDProgressView *pv = [[DDProgressView alloc] initWithFrame:progressRect];

        self.progressView = pv;
        [self.progressView setOuterColor:[UIColor clearColor]];
        [self.progressView setInnerColor:[UIColor lightGrayColor]];
        [self.progressView setEmptyColor:[UIColor darkGrayColor]];
        RELEASE_SAFE(pv);
        
        self.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)freshCellWithEmotionData:(EmotionStoreData *)emotionData
{
    [self.thumbIcon setNoSmoothEffectImageWithKeyStr:emotionData.iconUrl placeholderImage:IMGREADFILE(@"img_landing_default220.png")];
    
    self.emotionTitleLabel.text = emotionData.title;
    self.emotionDetailLabel.text = emotionData.subtitle;
    if (emotionData.status == EmotionStoreDataStatusDownloaded) {
        self.downLoadButton.hidden = YES;
    } else {
        self.emotionAccessoryView.hidden = YES;
    }
    
    self.emoticondata = emotionData;
}

- (void)downloadEmoticon
{
    NSLog(@"Downloading ");
    
    [MobClick event:@"chat_detail_emoticon_download"];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.downLoadButton.hidden = YES;
    [self addSubview:self.progressView];
    
    [self downloadEmotionPacket];
}

//下载zip包
-(void) downloadEmotionPacket{
    EmotionStoreManager* emanager = [[EmotionStoreManager alloc] init];
    emanager.delegate = self;
   [emanager downLoadEmotionWithParam:self.emoticondata andBlock:^{} progress:(UIProgressView *)self.progressView];
}

#pragma mark - dowmLoadEmotion
-(void) downLoadEmotionSuccess{
    [self.progressView removeFromSuperview];
    
    NSLog(@"emotion cell delegate %@",self.delegate);
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.downLoadButton.hidden = YES;
    self.emotionAccessoryView.hidden = NO;
    [self.delegate emoticonCelldownloadEmoticonSuccess];
}

-(void) dowmLoadEmotionFailed{
    [self.progressView removeFromSuperview];
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.downLoadButton.hidden = YES;
}

#pragma mark - Dealloc 

- (void)dealloc
{
    self.emotionDetailLabel = nil;
    self.downLoadButton = nil;
    [super dealloc];
}

@end
