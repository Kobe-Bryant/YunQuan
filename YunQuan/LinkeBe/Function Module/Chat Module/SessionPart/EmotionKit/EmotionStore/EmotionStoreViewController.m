//
//  EmotionStoreViewController.m
//  ql
//
//  Created by LazySnail on 14-8-21.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "EmotionStoreViewController.h"
#import "SnailLoopScrollView.h"
#import "SnailEmotionCell.h"
#import "SnailTopLoopCell.h"
#import "EmotionStoreData.h"
#import "UIViewController+NavigationBar.h"
#import "EmotionDetailViewController.h"
#import "EmotionStoreManager.h"
#import "emoticon_store_info_model.h"
#import "emoticon_list_model.h"
#import "ChatMacro.h"
#import "SBJson.h"

#define PageControlWith                 40

@interface EmotionStoreViewController () <UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,EmotionStroeManagerDelegate,SnailEmotionCellDelegate,EmotionDetailViewControllerDelegate>
{
    
}

@property(nonatomic, retain) SnailLoopScrollView *scorllEmotionIntroduceView;

@property(nonatomic, retain) UITableView *emotionListView;

@property(nonatomic, retain) NSMutableArray *emotionListArr;

@property(nonatomic, retain) NSMutableArray *bannerUrlArr;

@property(nonatomic, retain) EmotionDetailViewController * detailViewController;

@property(nonatomic, retain) EmotionStoreManager * dataManager;

@end

@implementation EmotionStoreViewController

#pragma ViewControllerLifeCircle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //设置基本页面信息
    [self setup];
    
    //Get server data relese itself at delegate
    EmotionStoreManager * manager = [[EmotionStoreManager alloc]init];
    manager.delegate = self;
    [manager getEmotionStoreDataDic];
    self.dataManager = manager;
    RELEASE_SAFE(manager);
    
    [self loadStoreMainView];
}

- (void)setup
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"表情库";
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self setBackButtonAndMethodPopView];
}

- (void)loadStoreMainView
{
    [self getEmoticonDataAndBanners];
    
    CGRect nofiyLabelRect = CGRectMake(0, KUIScreenHeight - 40 - 44, KUIScreenWidth, 40);
    UILabel * nofityLabel = [[UILabel alloc]initWithFrame:nofiyLabelRect];
    nofityLabel.textAlignment = NSTextAlignmentCenter;
    nofityLabel.font = KQLSystemFont(15);
    nofityLabel.text = @"敬请期待更多丰富表情";
    nofityLabel.backgroundColor = [UIColor clearColor];
    nofityLabel.textColor = [UIColor grayColor];
    [self.view addSubview:nofityLabel];
    RELEASE_SAFE(nofityLabel);

    CGRect tableViewRect = CGRectMake(0, 0, KUIScreenWidth, KUIScreenHeight- 44);
    UITableView * emotionTable = [[UITableView alloc]initWithFrame:tableViewRect style:UITableViewStylePlain];
    emotionTable.backgroundColor = [UIColor clearColor];
    emotionTable.dataSource = self;
    emotionTable.delegate = self;
    emotionTable.separatorColor = [UIColor clearColor];
    
    if (IOS7_OR_LATER) {
        [emotionTable setSeparatorInset:UIEdgeInsetsZero];
    }
    
    [self.view addSubview:emotionTable];
    self.emotionListView = emotionTable;
    RELEASE_SAFE(emotionTable);
}

- (void)reloadMainView
{
    [self getEmoticonDataAndBanners];
    [self.emotionListView reloadData];
}

- (void)getEmoticonDataAndBanners
{
    NSString * jsonStr = [[emoticon_store_info_model getLatestData] objectForKey:@"thumbnails"];
    self.bannerUrlArr = [jsonStr JSONValue];
    
    NSMutableArray * emoticonsDataArr = [emoticon_list_model getAllEmoticons];
    NSMutableArray * emoticonsArr = [[NSMutableArray alloc]initWithCapacity:8];
    for (NSDictionary * emoticonDic in emoticonsDataArr) {
        EmotionStoreData * data = [[EmotionStoreData alloc]initWithDic:emoticonDic];
        [emoticonsArr addObject:data];
        RELEASE_SAFE(data);
    }
    
    self.emotionListArr = emoticonsArr;
    RELEASE_SAFE(emoticonsArr);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.scorllEmotionIntroduceView.isAutoLoopScroll = self.bannerUrlArr > 0;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.scorllEmotionIntroduceView.isAutoLoopScroll = NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return self.emotionListArr.count;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellSection = indexPath.section;
    UITableViewCell * cell = nil;
    switch (cellSection) {
        case 0:
        {
            NSString * topCellIdentify = @"TopCell";
            SnailTopLoopCell * topCell = [tableView dequeueReusableCellWithIdentifier:topCellIdentify];
            if (topCell == nil) {
                topCell = [[SnailTopLoopCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topCellIdentify];
            }
            
            [topCell refreshCellWithImgArray:self.bannerUrlArr];
            self.scorllEmotionIntroduceView = (SnailLoopScrollView *)topCell.scorllLoopView;
            cell = topCell;
        }
            break;
        case 1:
        {
            NSString * cellIndetify = @"SnailEmotionCell";
            SnailEmotionCell * listCell = [tableView dequeueReusableCellWithIdentifier:cellIndetify];
            if (listCell == nil) {
                listCell = [[[SnailEmotionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetify] autorelease];
            }
            EmotionStoreData * emotionData = [self.emotionListArr objectAtIndex:indexPath.row];
            listCell.accessoryType = UITableViewCellAccessoryNone;
            [listCell freshCellWithEmotionData:emotionData];
            listCell.index = indexPath;
            listCell.delegate = self;
            listCell.showsReorderControl = YES;
            cell = listCell;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate 

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 160;
            break;
        case 1:
            return 85;
            break;
        default:
            return 85;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"chat_detail_emoticon_detail"];
    EmotionDetailViewController * detailView = [[EmotionDetailViewController alloc]init];
    detailView.emotionData = [self.emotionListArr objectAtIndex:indexPath.row];
    detailView.delegate = self;
    [self.navigationController pushViewController:detailView animated:YES];
    self.detailViewController = detailView;
    RELEASE_SAFE(detailView);
}

#pragma mark - EmotionStoreManagerDelegate

- (void) getEmotionStoreDataSuccessWithDic:(NSDictionary *)dataDic sender:(EmotionStoreManager *)sender
{
    //Load main view
    [self reloadMainView];
    self.dataManager = nil;
}

- (void)getEmotionStoreDataFailed:(EmotionStoreManager *)sender
{
    self.dataManager = nil;
}

#pragma mark - SnailEmoticonCellDelegate

- (void)emoticonCelldownloadEmoticonSuccess
{
    [self getEmoticonDataAndBanners];

    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(downloadEmoticonSuccess)]) {
        
        [self.delegate downloadEmoticonSuccess];
        if (self.detailViewController != nil) {
            [self.detailViewController downloadEmoticonSuccess];
        }
    }
}

#pragma mark - EmotionDetailViewControllerDelegate
- (void)detailDownloadEmotionWithData:(EmotionStoreData *)emotionData
{
    NSInteger index = [self.emotionListArr indexOfObject:emotionData];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:1];
    SnailEmotionCell * cell = (SnailEmotionCell *)[self.emotionListView cellForRowAtIndexPath:indexPath];
    [cell downloadEmoticon];
}

#pragma mark - Dealloc
- (void)dealloc
{
    LOG_RELESE_SELF;
    self.dataManager.delegate = nil;
    self.dataManager = nil;
    self.emotionListArr = nil;
    self.emotionListView = nil;
    self.scorllEmotionIntroduceView = nil;
    [super dealloc];
}

@end
