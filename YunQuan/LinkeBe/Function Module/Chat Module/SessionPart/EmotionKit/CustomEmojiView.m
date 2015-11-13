//
//  CustomEmojiView.m
//  ql
//
//  Created by LazySnail on 14-9-14.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "CustomEmojiView.h"
#import "emoji.h"

@interface CustomEmojiView() <UIScrollViewDelegate>
{
    
}

@property(nonatomic, retain) UIPageControl * customEmojiPageControl;

@property(nonatomic, retain) UIScrollView * mainScrollView;

@property(nonatomic, retain) UIView * lastView;

@end

@implementation CustomEmojiView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithLastView:(UIView *)lastView andFrame:(CGRect)frame
{
    self = [self initWithFrame:frame];
    self.userInteractionEnabled = YES;
    self.lastView = lastView;
    [self loadEmojiScrollViewWithLastView:lastView];
    return self;
}

- (void)loadEmojiScrollViewWithLastView:(UIView *)lastView
{
    //总表情数
    int faceCount = 100;
    //总表情页表情数
    int pageCount = 20;
    
    UIScrollView * mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f , 0.0f ,self.frame.size.width, self.frame.size.height)];
    mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width, mainScrollView.frame.size.height);
    mainScrollView.clipsToBounds = NO;
    mainScrollView.pagingEnabled = YES;
    mainScrollView.delegate = self;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    
    NSInteger pagePlus = 0;
    
    if (lastView != nil) {
        pagePlus = 1;
        lastView.frame = CGRectMake(self.frame.size.width * (faceCount/pageCount), 0, lastView.frame.size.width, lastView.frame.size.height);
        [mainScrollView addSubview:lastView];
    }
    mainScrollView.contentSize = CGSizeMake(self.frame.size.width * ((faceCount/pageCount) + pagePlus), self.frame.size.height);
    mainScrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:mainScrollView];

    int rowCount = 7;       //一行多少个表情
    int row = 3;
    int residueNum = 0;     //余数
    int divisibleNum = 0;   //页数
    
    CGFloat imgWidth = 30.0f;   //表情图片宽度
    CGFloat imgHeight = 30.0f;  //表情图片高度
    
    CGFloat buttonViewWidth = 320.0f - 40.0f;   //表情容器宽度
    CGFloat buttonViewHeight = 120.0f;          //表情容器高度
    
    CGFloat fixMarginWidth = imgWidth+((buttonViewWidth - (rowCount*imgWidth))/(rowCount-1));
    CGFloat fixMarginHeight = imgHeight+((buttonViewHeight - (row*imgHeight))/(row-1));
    
    for (int i=0 ; i < faceCount; i++)
    {
        residueNum = i%pageCount;
        divisibleNum = i/pageCount;
        if (residueNum == 0)
        {
            UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake( (mainScrollView.frame.size.width) * divisibleNum + 20.0f , 20.0f , buttonViewWidth, buttonViewHeight)];
            buttonView.tag = 10000 + divisibleNum;
            buttonView.backgroundColor = [UIColor clearColor];  // 调试 设置一下颜色
            [mainScrollView addSubview:buttonView];
            
            //最后添加删除按钮
            UIButton *delFaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            delFaceButton.frame = CGRectMake( (rowCount-1)*fixMarginWidth , (row-1)*fixMarginHeight , imgWidth , imgWidth);
            [delFaceButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
            [buttonView addSubview:delFaceButton];
            
            UIImage *delFaceButtonImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DeleteEmoticonBtn@2x" ofType:@"png"]];
            [delFaceButton setBackgroundImage:delFaceButtonImage forState:UIControlStateNormal];
        }
        
        UIView *buttonView = (UIView *)[mainScrollView viewWithTag:10000+divisibleNum];
        
        UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        faceButton.frame = CGRectMake( (residueNum%rowCount)*fixMarginWidth , (residueNum/rowCount)*fixMarginHeight , imgWidth , imgHeight);
        [faceButton addTarget:self action:@selector(selectedCustomFaceButton:) forControlEvents:UIControlEventTouchUpInside];
        faceButton.tag = i+20000;
        
        NSString * faceImagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Expression_%d@2x",i+1] ofType:@"png"];
        UIImage *faceButtonImage = [UIImage imageWithContentsOfFile:faceImagePath];
        [faceButton setBackgroundImage:faceButtonImage forState:UIControlStateNormal];
        [buttonView addSubview:faceButton];
    }
    
    UIPageControl * pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.frame.size.height -40, self.frame.size.width, 50)];
    pageControl.numberOfPages = faceCount/pageCount;
    pageControl.currentPage = 0;
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:0.471 alpha:1.000];
    pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.678 alpha:1.000];
    [self addSubview:pageControl];
    self.customEmojiPageControl = pageControl;
    RELEASE_SAFE(pageControl);
    self.mainScrollView = mainScrollView;
    RELEASE_SAFE(mainScrollView);
}

+ (UIView *)getLastEmojiView
{
    //总表情数
    int faceCount = 100;
    //总表情页表情数
    int pageCount = 20;
    
    int rowCount = 7;       //一行多少个表情
    int rank = 3;
    
    int residueNum = 0;     //余数
    
    CGFloat imgWidth = 30.0f;   //表情图片宽度
    CGFloat imgHeight = 30.0f;  //表情图片高度
    
    CGFloat buttonViewWidth = 320.0f - 40.0f;   //表情容器宽度
    CGFloat buttonViewHeight = 120.0f;          //表情容器高度
    
    CGFloat fixMarginWidth = imgWidth + ((buttonViewWidth - (rowCount * imgWidth))/(rowCount - 1));
    CGFloat fixMarginHeight = imgHeight + ((buttonViewHeight - (rank * imgHeight))/(rank - 1));
    
    CGRect lastViewRect = CGRectMake(20, 20, buttonViewWidth, buttonViewHeight);
    UIView * resultLastView = [[UIView alloc]initWithFrame:lastViewRect];
    resultLastView.backgroundColor = [UIColor clearColor];
    
    for (int i = faceCount - pageCount; i < faceCount;i++)
    {
        residueNum = i % pageCount;
        if (residueNum == 0)
        {
            //最后添加删除按钮
            UIButton *delFaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            delFaceButton.frame = CGRectMake( (rowCount-1)*fixMarginWidth , (rank - 1)*fixMarginHeight , imgWidth , imgWidth);
            [resultLastView addSubview:delFaceButton];
            
            UIImage *delFaceButtonImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DeleteEmoticonBtn@2x" ofType:@"png"]];
            [delFaceButton setBackgroundImage:delFaceButtonImage forState:UIControlStateNormal];
        }
        
        UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        faceButton.frame = CGRectMake( (residueNum%rowCount)*fixMarginWidth , (residueNum/rowCount)*fixMarginHeight , imgWidth , imgHeight);
        [faceButton addTarget:self action:@selector(selectedCustomFaceButton:) forControlEvents:UIControlEventTouchUpInside];
        faceButton.tag = i+20000;
        
        UIImage *faceButtonImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Expression_%d@2x",i+1] ofType:@"png"]];
        [faceButton setBackgroundImage:faceButtonImage forState:UIControlStateNormal];
        [resultLastView addSubview:faceButton];
    }
    return resultLastView;
}

//自定义按钮选中
- (void)selectedCustomFaceButton:(UIButton *)sender
{
    int index = sender.tag - 20000;
    if ([self.delegate respondsToSelector:@selector(putEmojiString:)])
    {
        NSString *faceImageName = [NSString stringWithFormat:@"Expression_%d@2x",index+1];
        NSArray *faceStringArray = [[emoji getCustomEmoji] allKeysForObject:faceImageName];
        if ([faceStringArray count] > 0)
        {
            NSString *faceString = [faceStringArray lastObject];
            [self.delegate putEmojiString:faceString];
        }
    }
}

- (void)deleteButtonClick
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(deleteString)]) {
        [self.delegate deleteString];
    }
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    NSInteger pageNum = offset.x / self.frame.size.width;
    if (pageNum <= self.customEmojiPageControl.numberOfPages) {
        self.customEmojiPageControl.currentPage = pageNum;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    NSInteger pageNum = offset.x / self.frame.size.width;
    if (pageNum == self.customEmojiPageControl.numberOfPages) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(shouldTurnToNextEmoticon)]) {
            scrollView.contentOffset = CGPointMake(offset.x - self.frame.size.width, 0);
            [self.delegate shouldTurnToNextEmoticon];
        }
    }
}

- (void)scrollToLastView
{
    if (self.lastView != nil) {
        [self.mainScrollView scrollRectToVisible:CGRectMake(CGRectGetMinX(self.lastView.frame), 0, 1, 1) animated:NO];
    }
}

- (void)dealloc
{
    self.customEmojiPageControl = nil;
    self.mainScrollView = nil;
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
