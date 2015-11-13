//
//  XHEmotionSectionBar.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-5-3.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHEmotionSectionBar.h"
#import "SDImageCache.h"
#import "EmotionStoreManager.h"
#import "ChatMacro.h"

#define kSnailStoreManagerItemWidth     60
#define kSnailSendButtonWidth           60
#define kSnailSelectItemWidth           60

@interface XHEmotionSectionBar ()

@property (nonatomic, weak) UIScrollView *sectionBarScrollView;

@property (nonatomic, weak) UIButton *sendButton;

@property (nonatomic, weak) UIButton *storeButton;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation XHEmotionSectionBar

- (void)sectionButtonClicked:(UIButton *)sender {
    
    self.selectedIndex = sender.tag;
    if ([self.delegate respondsToSelector:@selector(didSelecteEmotionManager:atSection:)]) {
        NSInteger section = sender.tag;
        if (section < self.emotionManagers.count) {
            [self.delegate didSelecteEmotionManager:[self.emotionManagers objectAtIndex:section] atSection:section];
        }
    }
}

- (void)storeButtonSelected:(UIButton *)sender
{
    UIView * newLabel = [sender viewWithTag:10000];
    if (newLabel != nil) {
        [newLabel removeFromSuperview];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"emoticonFirst"];
    }
    
    if ([self.delegate respondsToSelector:@selector(didSelectEmotionStoreButton)]) {
        [self.delegate didSelectEmotionStoreButton];
    }
}

- (UIButton *)createSelectButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, kSnailSelectItemWidth, CGRectGetHeight(self.bounds));
    [button addTarget:self action:@selector(sectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)selectManagerWithIndex:(NSInteger)index
{
    self.selectedIndex = index;
    UIView * selectButton = [self.sectionBarScrollView viewWithTag:index];
    if (index != 0) {
        [self.sectionBarScrollView scrollRectToVisible:selectButton.frame animated:YES];
    }

    if ([self.delegate respondsToSelector:@selector(didSelecteEmotionManager:atSection:)]) {
        NSInteger section = index;
        if (section < self.emotionManagers.count) {
            [self.delegate didSelecteEmotionManager:[self.emotionManagers objectAtIndex:section] atSection:section];
        }
    }
}

- (void)scorllToShowFirstButton
{
    CGRect firstButtonRect = CGRectMake(0, 0, kSnailSendButtonWidth, CGRectGetHeight(self.bounds));
    [self.sectionBarScrollView scrollRectToVisible:firstButtonRect animated:YES];
}

- (void)reloadData {
    if (!self.emotionManagers.count)
        return;
    
    if (self.isShowEmotionSendButton == NO) {
        CGRect newRect = CGRectMake(self.sectionBarScrollView.frame.origin.x, self.sectionBarScrollView.frame.origin.y, self.bounds.size.width - kSnailSelectItemWidth , self.sectionBarScrollView.frame.size.height);
        self.sectionBarScrollView.frame = newRect;
        self.sendButton.hidden = YES;
    } else {
        self.sendButton.hidden = NO;
        CGRect newRect = CGRectMake(self.sectionBarScrollView.frame.origin.x, self.sectionBarScrollView.frame.origin.y, self.bounds.size.width - self.sendButton.frame.size.width *2, self.sectionBarScrollView.frame.size.height);
        self.sectionBarScrollView.frame = newRect;
    }
    
    [self.sectionBarScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (XHEmotionManager *emotionManager in self.emotionManagers) {
        NSInteger index = [self.emotionManagers indexOfObject:emotionManager];
        UIButton *sectionButton = [self createSelectButton];
        sectionButton.tag = index;
        sectionButton.titleLabel.font = [UIFont systemFontOfSize:14];
        sectionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        sectionButton.titleLabel.textColor = [UIColor blackColor];
        
        UIImage * buttonImg = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:emotionManager.emotionIcon];
        if (buttonImg == nil) {
            NSData * imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:emotionManager.emotionIcon]];
            buttonImg = [UIImage imageWithData:imgData];
            [[SDImageCache sharedImageCache]storeImage:buttonImg forKey:emotionManager.emotionIcon toDisk:YES];
        }
        
        if (buttonImg == nil) {
            buttonImg = IMGREADFILE(emotionManager.emotionIcon);
        }
        
        sectionButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [sectionButton setImage:buttonImg forState:UIControlStateNormal];
        sectionButton.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        sectionButton.layer.borderWidth = 0.3f;
        if (sectionButton.tag == self.selectedIndex) {
            sectionButton.backgroundColor = [UIColor colorWithRed:180.f/225.f green:180.f/225.f  blue:180.f/225.f  alpha:1.0f];
        } else {
            sectionButton.backgroundColor = [UIColor whiteColor];
        }
        
        CGRect sectionButtonFrame = sectionButton.frame;
        sectionButtonFrame.origin.x = index * (CGRectGetWidth(sectionButtonFrame));
        sectionButton.frame = sectionButtonFrame;
        
        [self.sectionBarScrollView addSubview:sectionButton];
    }
    
    [self.sectionBarScrollView setContentSize:CGSizeMake(self.emotionManagers.count * kSnailSelectItemWidth, CGRectGetHeight(self.bounds))];
}

#pragma mark - Lefy cycle

- (void)setup {
    if (!_sectionBarScrollView) {
        CGFloat scrollWidth = CGRectGetWidth(self.bounds);
        if (self.isShowEmotionSendButton) {
//            scrollWidth -= kSnailSendButtonWidth;
        }
        
        if (self.isShowEmotionStoreButton) {
            scrollWidth -= kSnailStoreManagerItemWidth;
        }
        
        UIScrollView *sectionBarScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(kSnailStoreManagerItemWidth, 0, scrollWidth, CGRectGetHeight(self.bounds))];
        [sectionBarScrollView setScrollsToTop:NO];
        sectionBarScrollView.showsVerticalScrollIndicator = NO;
        sectionBarScrollView.showsHorizontalScrollIndicator = NO;
        sectionBarScrollView.pagingEnabled = NO;
        sectionBarScrollView.backgroundColor = [UIColor colorWithRed:245.f/255.f green:245.f/255.f  blue:245.f/255.f  alpha:1.0f];
        [self addSubview:sectionBarScrollView];
        _sectionBarScrollView = sectionBarScrollView;
        self.layer.borderWidth = 0.3f;
        self.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    }
    
    if (self.isShowEmotionSendButton)
    {
        UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendButton.frame = CGRectMake(0, 0, kSnailSendButtonWidth, CGRectGetHeight(self.bounds));
        [sendButton addTarget:self.delegate action:@selector(didSelecteSendButton) forControlEvents:UIControlEventTouchUpInside];

        CGRect sendButtonFrame = sendButton.frame;
        sendButtonFrame.origin.x = CGRectGetWidth(self.bounds) - kSnailSendButtonWidth;
        sendButton.frame = sendButtonFrame;
        
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        sendButton.titleLabel.font = KQLboldSystemFont(14);
        [sendButton setTitleColor:SendTitleHighLightColor forState:UIControlStateNormal];
        sendButton.backgroundColor = HIGHTLIGHT_BLUE_CORLOR;
        
        [self addSubview:sendButton];
        self.sendButton = sendButton;
    }
    
    if (self.isShowEmotionStoreButton) {
        UIButton *tempStoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tempStoreButton.frame = CGRectMake(0, 0, kSnailStoreManagerItemWidth, CGRectGetHeight(self.bounds));;
        [tempStoreButton addTarget:self action:@selector(storeButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage * backImg = [UIImage imageCwNamed:@"ico_chat_store.png"];
        [tempStoreButton setBackgroundImage:backImg forState:UIControlStateNormal];
        tempStoreButton.backgroundColor = [UIColor whiteColor];
        tempStoreButton.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        tempStoreButton.layer.borderWidth = 0.3f;
        
        [self addSubview:tempStoreButton];
        self.storeButton = tempStoreButton;
        
        EmotionStoreManager * storeManager = [[EmotionStoreManager alloc]init];
        
        if ([storeManager newEmoticonNotifyJudge]) {
            CGRect labelRect = CGRectMake(CGRectGetWidth(self.storeButton.frame)/2, 0,30, 15);
            UILabel * label = [[UILabel alloc]initWithFrame:labelRect];
            label.layer.cornerRadius = 7.0f;
            label.backgroundColor = [UIColor redColor];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.tag = 10000;
            label.text = @"New";
            label.font = KQLSystemFont(12);
            [self.storeButton addSubview:label];
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame showEmotionStoreButton:(BOOL)isShowEmotionStoreButtoned andShowSendButton:(BOOL)isShowSendButton {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.isShowEmotionStoreButton = isShowEmotionStoreButtoned;
        self.isShowEmotionSendButton = isShowSendButton;
        
        [self setup];
    }
    return self;
}

- (void)dealloc {
    self.emotionManagers = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self reloadData];
    }
}

- (void)graySendButton
{
    self.sendButton.backgroundColor = SendButtonGrayBackColor;
    self.sendButton.userInteractionEnabled = NO;
    [self.sendButton setTitleColor:SendTitleGrayColor forState:UIControlStateNormal];
}

- (void)enabelSendButton
{
    self.sendButton.backgroundColor = HIGHTLIGHT_BLUE_CORLOR;
    self.sendButton.userInteractionEnabled = YES;
    [self.sendButton setTitleColor:SendTitleHighLightColor forState:UIControlStateNormal];
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
