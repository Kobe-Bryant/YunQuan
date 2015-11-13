//
//  EmotionDetailViewController.m
//  ql
//
//  Created by LazySnail on 14-8-25.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import "EmotionDetailViewController.h"
#import "SnailLoopScrollView.h"
#import "SnailUICollectionViewFlowLayout.h"
#import "XHEmotionCollectionViewCell.h"
#import "EmotionStoreManager.h"
#import "EmoticonItemData.h"
#import "emoticon_detail_info_model.h"
#import "emoticon_item_list_model.h"
#import "SBJson.h"
#import "ChatMacro.h"
#import "UIViewController+NavigationBar.h"

const float headLoopHeight      =   160;

const float namePriceFront      =   16;

const float nameLabelMarign     =   10;
const float nameLabelWidth      =   100;
const float nameLabelHeight     =   20;

const float priceStateWidth     =   100;
const float priceStateHeight    =   20;

const float detailTextHeight    =   70;
const int   detailFront         =   14;

@interface EmotionDetailViewController() <UICollectionViewDataSource,UICollectionViewDelegate,EmotionStroeManagerDelegate>
{
    
}

@property (nonatomic, retain) UIScrollView * mainScrollView;

@property (nonatomic, retain) SnailLoopScrollView * headLoopView;

@property (nonatomic, retain) UILabel * nameLabel;

@property (nonatomic, retain) UILabel * priceLabel;

@property (nonatomic, retain) UITextView * detailText;

@property (nonatomic, retain) UICollectionView * emotionCollectionView;

@property (nonatomic, retain) UIButton * downLoadButton;

@property (nonatomic, retain) NSMutableArray * emotionItems;

@property (nonatomic, retain) NSMutableArray * bannerUrls;

@property (nonatomic, assign) EmotionStoreDataStatus status;

@end

@implementation EmotionDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
//    加载表情详情数据
    EmotionStoreManager * manager = [[EmotionStoreManager alloc]init];
    manager.delegate = self;
    [manager getemotionDetailDataForEmotionID:self.emotionData.emoticonID];
    self.title = self.emotionData.title;
    
    //加载详情滚动视图
    [self loadMainScrollView];
    //加载头滚动视图
    [self loadHeadLoopView];
    //加载详情视图
    [self loadMiddleDetailViews];
    //加载底部表情列表
    [self loadButtomEmotionCollectionView];
    //加载下载按钮
    [self loadDownloadButton];
    //从数据库读取表情数据 并刷新界面
    [self reloadDataAndMainView];
    
    //设置返回按钮
    [self setBackButtonAndMethodPopView];
}

- (void)getDetailDataFromDB
{
    NSDictionary * detailInfoDic = [emoticon_detail_info_model getLatestDetailInfoDic];
    if (detailInfoDic != nil) {
        self.detailText.text = [detailInfoDic objectForKey:@"description"];
        NSString * bannerJsonStr = [detailInfoDic objectForKey:@"thumbnails"];
        self.bannerUrls = [bannerJsonStr JSONValue];
        self.status = [[detailInfoDic objectForKey:@"status"]intValue];
        self.nameLabel.text = self.emotionData.title;
    }
    
    NSString * priceStr = nil;
    if (self.emotionData.price == 0) {
        priceStr = @"免 费";
    } else {
        priceStr = [NSString stringWithFormat:@"%f $",self.emotionData.price];
    }
    self.priceLabel.text = priceStr;
    
    NSMutableArray * emoticonItemList = [emoticon_item_list_model getAllItemWithEmoticonID:self.emotionData.emoticonID];
    if (emoticonItemList.count > 0) {
        NSMutableArray * emoticonItemDataArr = [NSMutableArray arrayWithCapacity:emoticonItemList.count];
        for (NSDictionary * emoticonItemDic in emoticonItemList) {
            EmoticonItemData * itemData = [[EmoticonItemData alloc]initWithDic:emoticonItemDic];
            [emoticonItemDataArr addObject:itemData];
            RELEASE_SAFE(itemData);
        }
        self.emotionItems = emoticonItemDataArr;
    }
 }

- (void)adjustCollectionViewHeight
{
    self.emotionCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.detailText.frame), KUIScreenWidth, KUIScreenHeight);
}

- (void)reloadMainView
{
    if (self.headLoopView != nil) {
        [self.headLoopView removeFromSuperview];
        self.headLoopView = nil;
    }
    
    [self loadHeadLoopView];
    [self.emotionCollectionView reloadData];
    int heightNum = ceil((double)self.emotionItems.count/4.0f);
    
    NSString * textStr = self.detailText.text;
    CGSize textSize = [textStr sizeWithFont:KQLSystemFont(detailFront) constrainedToSize:CGSizeMake(KUIScreenWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    
    self.detailText.frame = (CGRect){.origin = self.detailText.frame.origin,.size = CGSizeMake(textSize.width + 13, textSize.height)};

    self.emotionCollectionView.frame = (CGRect){.origin = (CGPoint){.x = 0,.y = CGRectGetMaxY(self.detailText.frame) + 10},.size = self.emotionCollectionView.frame.size};
    
    self.mainScrollView.contentSize = CGSizeMake(KUIScreenWidth, CGRectGetMaxY(self.detailText.frame) + heightNum * 130 + CGRectGetHeight(self.downLoadButton.frame));
}

- (void)loadMainScrollView{
    CGRect mainScorllViewRect = CGRectMake(0, 0, KUIScreenWidth, KUIScreenHeight);
    UIScrollView * tempMainScroll = [[UIScrollView alloc]initWithFrame: mainScorllViewRect];
    tempMainScroll.backgroundColor = [UIColor whiteColor];
    tempMainScroll.alwaysBounceVertical = YES;
    tempMainScroll.showsHorizontalScrollIndicator = NO;
    tempMainScroll.showsVerticalScrollIndicator = NO;
    [self.view addSubview:tempMainScroll];
    self.mainScrollView = tempMainScroll;
    RELEASE_SAFE(tempMainScroll);
}

- (void)loadHeadLoopView
{
    if ([self.bannerUrls isKindOfClass:[NSArray class]] && self.bannerUrls.count > 0) {
        CGRect loopRect = CGRectMake(0, 0, KUIScreenWidth, headLoopHeight);
        SnailLoopScrollView * tempLoopView = [[SnailLoopScrollView alloc]initWithFrame:loopRect andImageUrls:self.bannerUrls isAutoLoop:YES loopTimeInterval:3.0f];
        [self.mainScrollView addSubview:tempLoopView];
        self.headLoopView = tempLoopView;
        RELEASE_SAFE(tempLoopView);
    }
}

- (void)loadMiddleDetailViews
{
    CGRect nameRect = CGRectMake(nameLabelMarign, headLoopHeight + nameLabelMarign, nameLabelWidth
    , nameLabelHeight);
    UILabel * nameLabel = [[UILabel alloc]initWithFrame:nameRect];
    nameLabel.font = KQLboldSystemFont(namePriceFront);
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.text = @"美女包";
    [self.mainScrollView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    RELEASE_SAFE(nameLabel);
    
    CGRect priceStateRect = CGRectMake(KUIScreenWidth - nameLabelMarign - priceStateWidth, headLoopHeight + nameLabelMarign, priceStateWidth, priceStateHeight);
    UILabel * priceStateLabel = [[UILabel alloc]initWithFrame:priceStateRect];
    priceStateLabel.font = KQLboldSystemFont(namePriceFront);
    priceStateLabel.backgroundColor = [UIColor clearColor];
    priceStateLabel.text = @"永久免费";
    priceStateLabel.textAlignment = NSTextAlignmentRight;
    priceStateLabel.textColor = [UIColor blackColor];
    [self.mainScrollView addSubview:priceStateLabel];
    self.priceLabel = priceStateLabel;
    RELEASE_SAFE(priceStateLabel);
    
    CGRect detailTextRect = CGRectMake(0, headLoopHeight + nameLabelMarign * 2 + nameLabelHeight, KUIScreenWidth, detailTextHeight);
    UITextView * detailTextView = [[UITextView alloc]initWithFrame:detailTextRect];
    detailTextView.font = KQLSystemFont(detailFront);
    detailTextView.backgroundColor = [UIColor clearColor];
    detailTextView.textColor = [UIColor colorWithWhite:0.4 alpha:1.0f];
    detailTextView.text = @"这是一个美女云集的时代";
    detailTextView.userInteractionEnabled = NO;
    [self.mainScrollView addSubview:detailTextView];
    self.detailText = detailTextView;
    RELEASE_SAFE(detailTextView);
}

- (void)loadButtomEmotionCollectionView
{
    SnailUICollectionViewFlowLayout * collectionViewLayout = [[SnailUICollectionViewFlowLayout alloc]init];
    UICollectionView *emotionCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.detailText.frame),KUIScreenWidth,KUIScreenHeight ) collectionViewLayout:collectionViewLayout];
    RELEASE_SAFE(collectionViewLayout);
    
    emotionCollectionView.backgroundColor = [UIColor colorWithRed:232.f/255.f green:237.f/255.f blue:242.f/255.f alpha:1.0f];
    [emotionCollectionView registerClass:[XHEmotionCollectionViewCell class] forCellWithReuseIdentifier:kXHEmotionCollectionViewCellIdentifier];
    emotionCollectionView.showsHorizontalScrollIndicator = NO;
    emotionCollectionView.showsVerticalScrollIndicator = NO;
    [emotionCollectionView setScrollsToTop:NO];
    emotionCollectionView.scrollEnabled = NO;
    emotionCollectionView.delegate = self;
    emotionCollectionView.dataSource = self;
    [self.mainScrollView addSubview:emotionCollectionView];
    self.emotionCollectionView = emotionCollectionView;
    RELEASE_SAFE(emotionCollectionView);
}

- (void)loadDownloadButton
{
    CGRect downloadButtonRect = CGRectMake(0, KUIScreenHeight - 88, KUIScreenWidth, 44);
    UIButton * downloadButton = [[UIButton alloc]initWithFrame:downloadButtonRect];
    downloadButton.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
    downloadButton.titleLabel.textAlignment = NSTextAlignmentCenter;

    NSString * buttonStr = nil;
    switch (self.emotionData.status) {
        case EmotionStoreDataStatusDownloaded:
        {
            buttonStr = @"已下载";
            downloadButton.enabled = NO;
        }
            break;
        case EmotionStoreDataHaveBeenRemove:
            buttonStr = @"下载";
            break;
        case EmotionStoreDataStatusDownloading:
        {
            buttonStr = @"下载中..";
            downloadButton.enabled = NO;
        }
            break;
        case EmotionStoreDataStatusNormal:
            buttonStr = @"下载";
            break;
        default:
            break;
    }
    
    [downloadButton setTitle:buttonStr forState:UIControlStateNormal];
    [downloadButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [downloadButton addTarget:self action:@selector(haveClickDownLoadButton) forControlEvents:UIControlEventTouchUpInside];
    self.downLoadButton = downloadButton;
    [self.view addSubview:downloadButton];
    RELEASE_SAFE(downloadButton);
}

- (void)haveClickDownLoadButton
{
    [self.downLoadButton setTitle:@"下载中.." forState:UIControlStateNormal];
    self.downLoadButton.enabled = NO;
    if ([self.delegate respondsToSelector:@selector(detailDownloadEmotionWithData:)]) {
        [self.delegate detailDownloadEmotionWithData:self.emotionData];
    }
}

- (void)downloadEmoticonSuccess
{
    [Common checkProgressHUDShowInAppKeyWindow:@"下载成功" andImage:nil];
    [self.downLoadButton setTitle:@"已下载" forState:UIControlStateNormal];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = self.emotionItems.count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XHEmotionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kXHEmotionCollectionViewCellIdentifier forIndexPath:indexPath];
    
    EmoticonItemData *emoticon = [self.emotionItems objectAtIndex:indexPath.row];
    cell.emoticonItem = emoticon;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - EmotonStoreManagerDelegate 

- (void)getEmoticonDetailDataSuccessWithSender:(EmotionStoreManager *)sender
{
    //读取数据库历史数据
    [self reloadDataAndMainView];
}

- (void)reloadDataAndMainView
{
    [self getDetailDataFromDB];
    [self adjustCollectionViewHeight];
    [self reloadMainView];
}

- (void)getEmoticonDetailDataFailed:(EmotionStoreManager *)sender
{
    RELEASE_SAFE(sender);
}

- (void)dealloc
{
    LOG_RELESE_SELF;
    self.headLoopView = nil;
    self.nameLabel = nil;
    self.priceLabel = nil;
    self.detailText = nil;
    self.emotionCollectionView = nil;
    self.downLoadButton = nil;
    self.emotionItems = nil;
    self.emotionData = nil;
    [super dealloc];
}


@end
