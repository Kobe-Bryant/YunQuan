//
//  XHEmotionManagerView.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-5-3.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHEmotionManagerView.h"

#import "XHEmotionSectionBar.h"

#import "XHEmotionCollectionViewCell.h"
#import "XHEmotionCollectionViewFlowLayout.h"

#import "CustomEmojiView.h"
#import "CustomEmoticonView.h"
#import "emoji.h"
#import "ChatMacro.h"

@interface XHEmotionManagerView () <UICollectionViewDelegate, UICollectionViewDataSource, XHEmotionSectionBarDelegate,CustomEmojiViewDelegate,CustomEmoticonViewDelegate>

/**
 *  显示表情的collectView控件
 */
@property (nonatomic, weak) UICollectionView *emotionCollectionView;

/**
 *  显示页码的控件
 */
@property (nonatomic, weak) UIPageControl *emotionPageControl;

/**
 *  当前选择了哪类gif表情标识
 */
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, retain) CustomEmojiView * customEmojiView;

@property (nonatomic, retain) CustomEmoticonView * emoticonView;

/**
 *  配置默认控件
 */
- (void)setup;

@end

@implementation XHEmotionManagerView

- (void)reloadData
{
    if (self.selectedIndex < 1) {
        self.emotionCollectionView.hidden = YES;
        self.emoticonView.hidden = YES;
        [self emojiViewIfPresentWithSection:self.selectedIndex];
        self.emotionSectionBar.isShowEmotionSendButton = YES;
        [self.emotionSectionBar scorllToShowFirstButton];
    } else {
        self.emotionSectionBar.isShowEmotionSendButton = NO;
        self.emotionCollectionView.hidden = NO;
        self.customEmojiView.hidden = YES;
        self.emoticonView.hidden = NO;
        
        NSInteger numberOfEmotionManagers = [self.dataSource numberOfEmotionManagers];
        if (!numberOfEmotionManagers) {
            return ;
        }
        
        XHEmotionManager *emotionManager = [self.dataSource emotionManagerForColumn:self.selectedIndex];
    
        self.emoticonView.emoticonDataArray = emotionManager.emotions;
        
        UIView * frontView = nil;
        UIView * lastView = nil;
        
        XHEmotionManager *nextManager = [self.dataSource emotionManagerForColumn:self.selectedIndex + 1];
        
        XHEmotionManager *lastManager = [self.dataSource emotionManagerForColumn:self.selectedIndex - 1];
        
        if (self.selectedIndex == 1) {
            frontView = [CustomEmojiView getLastEmojiView];
        } else {
            frontView = [CustomEmoticonView getLastEmoticonViewWithEmoticonArray:lastManager.emotions andFrame:self.emoticonView.frame];
        }
        
        if (nextManager != nil) {
            lastView = [CustomEmoticonView getFirstEmoticonViewWithEmoticonArray:nextManager.emotions andFrame:self.emoticonView.frame];
        }
        
        self.emoticonView.frontView = frontView;
        self.emoticonView.lastView = lastView;
        [self.emoticonView reloadView];
    }
    self.emotionSectionBar.emotionManagers = [self.dataSource emotionManagersAtManager];
    [self.emotionSectionBar reloadData];
    
    [self freshEmotionPageControlPage];
}

- (void)freshEmotionPageControlPage
{
    UIScrollView * currentScrollView = nil;
    if (!customFaceScrollView.hidden) {
        currentScrollView = customFaceScrollView;
    } else if (!self.emotionCollectionView.hidden) {
        currentScrollView = self.emotionCollectionView;
    }
    
    //每页宽度
    CGFloat pageWidth = currentScrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    NSInteger currentPage = floor((currentScrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    [self.emotionPageControl setCurrentPage:currentPage];
}

#pragma mark - Life cycle

- (void)setup {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = SessionTableBackColor;
    self.isShowEmotionSendButton = YES;
    self.isShowEmotionStoreButton = YES;
    
//    if (!_emotionCollectionView) {
//        UICollectionView *emotionCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kXHEmotionPageControlHeight - kXHEmotionSectionBarHeight) collectionViewLayout:[[XHEmotionCollectionViewFlowLayout alloc] init]];
//        emotionCollectionView.backgroundColor = self.backgroundColor;
//        [emotionCollectionView registerClass:[XHEmotionCollectionViewCell class] forCellWithReuseIdentifier:kXHEmotionCollectionViewCellIdentifier];
//        emotionCollectionView.showsHorizontalScrollIndicator = NO;
//        emotionCollectionView.showsVerticalScrollIndicator = NO;
//        [emotionCollectionView setScrollsToTop:NO];
//        emotionCollectionView.pagingEnabled = YES;
//        emotionCollectionView.delegate = self;
//        emotionCollectionView.dataSource = self;
//        [self addSubview:emotionCollectionView];
//        self.emotionCollectionView = emotionCollectionView;
//    }
    if (self.emoticonView == nil) {
        
        CGRect frontTestRect = CGRectMake(0, 0, KUIScreenWidth, 120);
        UIView * frontTestView = [[UIView alloc]initWithFrame:frontTestRect];
        frontTestView.backgroundColor = [UIColor blueColor];
        
        CGRect backViewRect = CGRectMake(0, 0, KUIScreenWidth, 120);
        UIView * backView = [[UIView alloc]initWithFrame:backViewRect];
        backView.backgroundColor = [UIColor redColor];
        
        CGRect customEmoticonRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - kXHEmotionSectionBarHeight);
        CustomEmoticonView * emoticonView = [[CustomEmoticonView alloc]initWithFrontView:frontTestView lastView:backView andFrame:customEmoticonRect];
        emoticonView.delegate = self;
        emoticonView.backgroundColor = [UIColor clearColor];
        [self addSubview:emoticonView];
        self.emoticonView = emoticonView;
    }
    
    if (!_emotionPageControl) {
        UIPageControl *emotionPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.emoticonView.frame) + 5, CGRectGetWidth(self.bounds), kXHEmotionPageControlHeight)];
        emotionPageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:0.471 alpha:1.000];
        emotionPageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.678 alpha:1.000];
        emotionPageControl.backgroundColor = self.backgroundColor;
        emotionPageControl.hidesForSinglePage = YES;
        emotionPageControl.defersCurrentPageDisplay = YES;
        [self addSubview:emotionPageControl];
        self.emotionPageControl = emotionPageControl;
    }
    
    if (!_emotionSectionBar) {
        XHEmotionSectionBar *emotionSectionBar = [[XHEmotionSectionBar alloc] initWithFrame:CGRectMake(0, self.frame.size.height - kXHEmotionSectionBarHeight, CGRectGetWidth(self.bounds), kXHEmotionSectionBarHeight) showEmotionStoreButton:self.isShowEmotionSendButton andShowSendButton:self.isShowEmotionSendButton];
        emotionSectionBar.delegate = self;
        emotionSectionBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        emotionSectionBar.backgroundColor = [UIColor colorWithWhite:0.886 alpha:1.000];
        [self addSubview:emotionSectionBar];
        self.emotionSectionBar = emotionSectionBar;
    }
}

- (void)awakeFromNib {
    [self setup];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)dealloc {
    self.emotionPageControl = nil;
    self.emotionSectionBar = nil;
    self.emotionCollectionView.delegate = nil;
    self.emotionCollectionView.dataSource = nil;
    self.emotionCollectionView = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self reloadData];
    }
}

#pragma mark - XHEmotionSectionBar Delegate

- (void)didSelecteEmotionManager:(XHEmotionManager *)emotionManager atSection:(NSInteger)section {
    if(section == self.selectedIndex){
        return;
    }
    self.selectedIndex = section;
    [self reloadData];
}

- (void)didSelecteSendButton
{
    [self.delegate sendMessage];
}

- (void)didSelectEmotionStoreButton
{
    [self.delegate openEmotionStore];
}

- (void)emojiViewIfPresentWithSection:(NSInteger)section
{
    // 判断所选表情页类型 0 emoji表情 1 系统表情 2 字符表情
    switch (section) {
        case 0:
        {
            [self changeToEmojiView];
        }
            break;
    }
    [self.emotionSectionBar reloadData];
}

- (void)changeToEmojiView
{
    if (self.customEmojiView == nil) {
        
        XHEmotionManager *emotionManager = [self.dataSource emotionManagerForColumn:self.selectedIndex + 1];
        
        CGRect emojiRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - kXHEmotionSectionBarHeight);
        NSArray * emoticonDataArr = emotionManager.emotions;
        UIView * testView = [CustomEmoticonView getFirstEmoticonViewWithEmoticonArray:emoticonDataArr andFrame:emojiRect];
        CustomEmojiView * emojiView = [[CustomEmojiView alloc]initWithLastView:testView andFrame:emojiRect];
        
        emojiView.backgroundColor = [UIColor clearColor];
        [self addSubview:emojiView];
        emojiView.delegate = self;
        self.customEmojiView = emojiView;

    } else {
        self.customEmojiView.hidden = NO;
    }
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.emotionCollectionView.contentSize = CGSizeMake(KUIScreenWidth * self.emotionPageControl.numberOfPages, self.emotionCollectionView.contentSize.height);

}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ((scrollView.contentOffset.x - 10) > (scrollView.contentSize.width - KUIScreenWidth) && velocity.x > 0 && self.selectedIndex < [self.dataSource numberOfEmotionManagers]) {
        [self.emotionSectionBar selectManagerWithIndex:self.selectedIndex +1];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if(!customFaceScrollView.hidden)
    {
        CGPoint offset = scrollView.contentOffset;
        self.emotionPageControl.currentPage = offset.x / customFaceScrollView.frame.size.width;
        return;
    }
    else if(!sysFaceScrollView.hidden)
    {
        CGPoint offset = scrollView.contentOffset;
        self.emotionPageControl.currentPage = offset.x / sysFaceScrollView.frame.size.width;
        return;
    }
    else if(!stringFaceScrollView.hidden)
    {
        CGPoint offset = scrollView.contentOffset;
        self.emotionPageControl.currentPage = offset.x / stringFaceScrollView.frame.size.width;
        return;
    }
    
    //每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    [self.emotionPageControl setCurrentPage:currentPage];
}

#pragma UICollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    XHEmotionManager *emotionManager = [self.dataSource emotionManagerForColumn:self.selectedIndex];
    NSInteger count = emotionManager.emotions.count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XHEmotionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kXHEmotionCollectionViewCellIdentifier forIndexPath:indexPath];
    
    XHEmotionManager *emotionManager = [self.dataSource emotionManagerForColumn:self.selectedIndex];
    cell.emoticonItem = emotionManager.emotions[indexPath.row];
    
    return cell;
}

#pragma mark - UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(didSelecteEmoticonItem:atIndexPath:)]) {
        XHEmotionManager *emotionManager = [self.dataSource emotionManagerForColumn:self.selectedIndex];
        [self.delegate didSelecteEmoticonItem:emotionManager.emotions[indexPath.row] atIndexPath:indexPath];
    }
}

#pragma mark - CustomEmojiViewDelegate ActionMethod

//删除
- (void)deleteString
{
    if ([self.delegate respondsToSelector:@selector(delFaceString)])
    {
        [self.delegate delFaceString];
    }
}

//输入表情
- (void)putEmojiString:(NSString *)str
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(faceView:didSelectAtString:)]) {
        [self.delegate faceView:nil didSelectAtString:str];
    }
}

//自动跳转到下一个自定义表情
- (void)shouldTurnToNextEmoticon
{
    [self.emotionSectionBar selectManagerWithIndex:self.selectedIndex +1];
}

#pragma mark - CustomEmoticonViewDelegate 

- (void)emoticonViewShouldTurnToNextEmoticon
{
    [self.emotionSectionBar selectManagerWithIndex:self.selectedIndex +1];
}

- (void)emoticonViewShouldTurnToLastEmoticon
{
    [self.emotionSectionBar selectManagerWithIndex:self.selectedIndex - 1];
    if (!self.customEmojiView.hidden) {
        [self.customEmojiView scrollToLastView];
    }
    
    if (!self.emoticonView.hidden) {
        [self.emoticonView scrollToLastView];
    }
}

- (void)emoticonSelectEmotionWithData:(EmoticonItemData *)emoticonData
{
    [self.delegate didSelecteEmoticonItem:emoticonData atIndexPath:nil];
}

//自定义按钮选中
-(void)selectedCustomFaceButton:(UIButton *)sender
{
    int index = sender.tag - 20000;
    if ([self.delegate respondsToSelector:@selector(faceView: didSelectAtString:)])
    {
        NSString *faceImageName = [NSString stringWithFormat:@"Expression_%d@2x",index+1];
        NSArray *faceStringArray = [[emoji getCustomEmoji] allKeysForObject:faceImageName];
        if ([faceStringArray count] > 0)
        {
            NSString *faceString = [faceStringArray lastObject];
            [self.delegate faceView:self didSelectAtString:faceString];
        }
    }
}

//系统按钮选中
-(void)selectedSysFaceButton:(UIButton *)sender
{
    //int index = sender.tag - 20000;
    if ([self.delegate respondsToSelector:@selector(faceView: didSelectAtString:)])
    {
        NSString *faceString = sender.titleLabel.text;
        [self.delegate faceView:self didSelectAtString:faceString];
    }
}

//符号按钮选中
-(void)selectedStringFaceButton:(UIButton *)sender
{
    //int index = sender.tag - 20000;
    if ([self.delegate respondsToSelector:@selector(faceView: didSelectAtString:)])
    {
        NSString *faceString = sender.titleLabel.text;
        [self.delegate faceView:self didSelectAtString:faceString];
    }
}

- (void)graySendButton
{
    [self.emotionSectionBar graySendButton];
}

- (void)enabelSendButton
{
    [self.emotionSectionBar enabelSendButton];
}

@end
