//
//  SnailLoopScrollView.m
//  ql
//
//  Created by LazySnail on 14-8-21.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import "SnailLoopScrollView.h"
#import "UIImageView+WebCache.h"
#import "ChatMacro.h"

@interface SnailLoopScrollView () <UIScrollViewDelegate>
{
    
}

@property(nonatomic, retain) UIScrollView * imgScrollView;

@property(nonatomic, retain) NSMutableArray * scorllImgs;

@property(nonatomic, retain) UIPageControl * imgPageControl;

@property(nonatomic, assign) NSInteger currentPresentPage;

@property(nonatomic, retain) NSTimer * autoScrollTimer;

@end

@implementation SnailLoopScrollView

@synthesize isAutoLoopScroll = _isAutoLoopScroll;
@synthesize loopTimeInterval = _loopTimeInterval;

- (instancetype)initWithFrame:(CGRect)frame andImageUrls:(NSArray *)imgs isAutoLoop:(BOOL)isAutoLoop loopTimeInterval:(float)timeInterval
{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        //设置轮播图
        self.scorllImgs = [NSMutableArray arrayWithArray:imgs];
        [self.scorllImgs addObject:[imgs firstObject]];
        [self.scorllImgs insertObject:[imgs lastObject] atIndex:0];
        
        self.pageControlFrame = CGRectMake(KUIScreenWidth - 80, self.frame.size.height - 30, 80, 30);
        self.isAutoLoopScroll = isAutoLoop;
        self.loopTimeInterval = timeInterval;
        
        //添加scorllView
        UIScrollView * tempScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imgScrollView = tempScrollView;
        self.imgScrollView.pagingEnabled = YES;
        self.imgScrollView.contentSize = CGSizeMake(frame.size.width * self.scorllImgs.count, frame.size.height);
        self.imgScrollView.showsHorizontalScrollIndicator = NO;
        self.imgScrollView.showsVerticalScrollIndicator = NO;
        self.imgScrollView.delegate = self;
        self.imgScrollView.contentMode = UIViewContentModeScaleAspectFit;
        if (imgs.count <= 1) {
            self.imgScrollView.scrollEnabled = NO;
        }
        
        [self addImageViewsToScrollView];
        //设置初始状态
        [self.imgScrollView setContentOffset:CGPointMake(self.frame.size.width, 0)];
        [self addSubview:self.imgScrollView];
        RELEASE_SAFE(tempScrollView);
        
        //添加pageControler
        [self addPageControl];
    }
    return self;
}

- (void)setIsAutoLoopScroll:(BOOL)isAutoLoopScroll
{
    if (isAutoLoopScroll && self.autoScrollTimer == nil && self.scorllImgs.count > 3) {
        self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.loopTimeInterval target:self selector:@selector(autoScrollToNextImage) userInfo:nil repeats:YES];
    } else if(isAutoLoopScroll == NO) {
        [self.autoScrollTimer invalidate];
        self.autoScrollTimer = nil;
    }
    _isAutoLoopScroll = isAutoLoopScroll;
}

- (void)setLoopTimeInterval:(float)loopTimeInterval
{
    if (self.autoScrollTimer != nil) {
        [self.autoScrollTimer invalidate];
        self.autoScrollTimer = nil;
        
        self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:loopTimeInterval target:self selector:@selector(autoScrollToNextImage) userInfo:nil repeats:YES];
    }
    _loopTimeInterval = loopTimeInterval;
}

- (void)autoScrollToNextImage
{
    [self.imgScrollView setContentOffset:CGPointMake((self.currentPresentPage + 1) * self.frame.size.width, 0) animated:YES];
    self.currentPresentPage +=1;
}

- (void)addImageViewsToScrollView
{
    for (int i = 0; i < self.scorllImgs.count; i++) {
        UIImageView * imgView = [[UIImageView alloc]init];
        imgView.frame = CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, self.frame.size.height);
        imgView.tag = i;
        imgView.contentMode = UIViewContentModeScaleToFill;
        [imgView setNoSmoothEffectImageWithKeyStr:[self.scorllImgs objectAtIndex:i] placeholderImage:IMGREADFILE(@"img_landing_default220.png")];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageSelected:)];
        [tap setNumberOfTapsRequired:1];
        [tap setNumberOfTouchesRequired:1];
        [imgView addGestureRecognizer:tap];
        imgView.userInteractionEnabled = YES;
        
        RELEASE_SAFE(tap);
        [self.imgScrollView addSubview:imgView];
        RELEASE_SAFE(imgView);
    }
}

- (void)addPageControl
{
    if (self.scorllImgs.count > 3) {
        UIPageControl * tempPageControl = [[UIPageControl alloc]initWithFrame:self.pageControlFrame];
        tempPageControl.currentPage = 0;
        tempPageControl.numberOfPages = self.scorllImgs.count - 2;
        [tempPageControl addTarget:self action:@selector(pageControlValueChange) forControlEvents:UIControlEventValueChanged];
        tempPageControl.backgroundColor = [UIColor clearColor];
        self.imgPageControl = tempPageControl;
        [self addSubview:self.imgPageControl];
        RELEASE_SAFE(tempPageControl);

    }
}

- (void)imageSelected:(UITapGestureRecognizer *)sender
{
    UIView * imgView = [sender view];
    NSInteger viewTag = imgView.tag;
    NSInteger index = 0;
    if (viewTag == self.scorllImgs.count) {
        index = 0;
    }
    
    if (viewTag == 0) {
        index = self.scorllImgs.count -1;
    }
    
    [self.delegate imageSelectedWithPageIndex:index];
}

- (void)pageControlValueChange
{
    
}

#pragma mark - UIScrollViewDelegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    //是否滑动过半判断,如果滑动过半则更新当前page
    self.currentPresentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    self.imgPageControl.currentPage = self.currentPresentPage -1;
    
}

//自动滚动时回调检测，
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.currentPresentPage == 0) {
        [scrollView setContentOffset:CGPointMake((self.scorllImgs.count - 2) * self.frame.size.width, 0)];
        self.currentPresentPage = self.scorllImgs.count - 2;
    }
    
    if (self.currentPresentPage == self.scorllImgs.count - 1) {
        [scrollView setContentOffset:CGPointMake(self.frame.size.width, 0)];
        self.currentPresentPage = 1;
    }
}

//手动滚动时回调
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.currentPresentPage == 0) {
        [scrollView setContentOffset:CGPointMake((self.scorllImgs.count - 2) * self.frame.size.width, 0)];
        self.currentPresentPage = self.scorllImgs.count - 2;
    }
    
    if (self.currentPresentPage == self.scorllImgs.count - 1) {
        [scrollView setContentOffset:CGPointMake(self.frame.size.width, 0)];
        self.currentPresentPage = 1;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.autoScrollTimer invalidate];
    self.autoScrollTimer = nil;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.loopTimeInterval target:self selector:@selector(autoScrollToNextImage) userInfo:nil repeats:YES];
}

#pragma mark - Dealloc 

- (void)dealloc
{
    self.imgScrollView = nil;
    self.scorllImgs = nil;
    self.imgPageControl = nil;
    self.delegate = nil;
    if (self.autoScrollTimer != nil) {
        [self.autoScrollTimer invalidate];
        self.autoScrollTimer = nil;
    }
    [super dealloc];
}

@end
