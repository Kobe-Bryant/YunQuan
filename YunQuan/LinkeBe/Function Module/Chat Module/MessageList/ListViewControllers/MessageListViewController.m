//
//  MessageListViewController.m
//  ql
//
//  Created by yunlai on 14-2-26.
//  Copyright (c) 2014年 ChenFeng. All rights reserved.
//

//FrameWorkTool Import
#import "Common.h"
#import "Global.h"
#import "NetManager.h"
#import "SBJson.h"

#import "ChatMacro.h"
#import "PinYinForObjc.h"
#import "MessageListData.h"
#import "MessageListCellFactory.h"
#import "MessageListDataOperator.h"

#import "MessageListViewController.h"
#import "SessionViewController.h"
#import "UIViewController+NavigationBar.h"
#import "ContactSelectOrgViewController.h"
#import "TempChatManager.h"
#import "OriginData.h"
#import "MobClick.h"

@interface MessageListViewController () <UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate,MessageListDataOperatorDelegate,ContactViewDelegate,SessionViewDelegate,TempChatManagerDelegate>
{    
}

//主聊天列表table
@property (nonatomic, retain) UITableView *mainTableView;

//搜索栏
@property (nonatomic, retain) UISearchBar *searchBar;

//搜索最终数据
@property (nonatomic, retain) NSMutableArray *searchResults;

//列表数据
@property(nonatomic, retain) NSMutableArray * messageList;

//搜索控制器
@property (nonatomic, retain) UISearchDisplayController *searchControl;

//数据控制类
@property (nonatomic, assign) MessageListDataOperator *operator;

//空数据提示视图
@property (nonatomic, retain) UIView * noneDataNotifyView;

@end

@implementation MessageListViewController
@synthesize messageList = _messageList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.messageList = [[[NSMutableArray alloc]init]autorelease];
        self.searchResults = [[[NSMutableArray alloc] init]autorelease];
        self.operator = [MessageListDataOperator shareOperator];
        self.operator.delegate = self;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadInfoLists) name:TempCircleMemberChanged object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadInfoLists) name:TempCircleQuitScucess object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	//配置界面属性
    [self setUp];
    //加载navigation风格和聊天列表
    [self loadRightBarButton];
    [self loadMainView];
    [self loadSearchBar];
    int unreadCount = [MessageListDataOperator getAllUnreadMessageCount];
    NSLog(@"%d",unreadCount);
}

- (void)setUp
{
    self.view.backgroundColor = SessionTableBackColor;
    self.navigationItem.title = @"聊天";
    
    //在聊天界面设置主题
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = YES;
        
    }
}

- (void)loadSearchBar{
    UISearchBar * tempSearch = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar = tempSearch;
    RELEASE_SAFE(tempSearch);
    self.searchBar.frame = CGRectMake(0.0f, 0.f, KUIScreenWidth, 40.0f);
    self.searchBar.placeholder=@"搜索";
	self.searchBar.delegate = self;
    //设置为聊天列表头
   // self.mainTableView.tableHeaderView = self.searchBar;
    
    //搜索控制器
    UISearchDisplayController *searchController = [[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];

    self.searchControl = searchController;
    RELEASE_SAFE(searchController);
    
    self.searchControl.active = NO;
    self.searchControl.searchResultsDataSource = self;
    self.searchControl.searchResultsDelegate = self;
    self.searchControl.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    
    [self.operator getFirstInWelcomeMessage];
    [self.operator getFirstInstallEmotion];
    //加载聊天列表数据
    [self loadInfoLists];
    [MobClick beginLogPageView:@"MessageListViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"MessageListViewPage"];
}

- (void)loadInfoLists
{
    if (self.messageList.count > 0) {
        [self.messageList removeAllObjects];
    }
    NSMutableArray *dbListDatas = [self.operator getDBMessageListDataArr];
    [self.messageList addObjectsFromArray:dbListDatas];
    [self judgeAndShowNoneView];
    [self.mainTableView reloadData];
}

- (void)judgeAndShowNoneView
{
    const float notifyIconWidth = 80;
    const float notifyIconHeight = 80;
    
    const float notifyLabelWidth = 100;
    const float notifyLabelHeight = 20;
    
    if (self.messageList.count == 0) {
        self.mainTableView.hidden = YES;
        if (self.noneDataNotifyView != nil) {
            self.noneDataNotifyView.hidden = NO;
        } else {
            CGRect oneViewRect = CGRectMake(0, 0, KUIScreenWidth, CGRectGetHeight(self.view.bounds));
            self.noneDataNotifyView = [[[UIView alloc]initWithFrame:oneViewRect]autorelease];
            
            CGRect chatIconRect = CGRectMake(KUIScreenWidth/2 - notifyIconWidth/2 , CGRectGetHeight(self.noneDataNotifyView.frame)/2 - notifyLabelHeight/2 - 44 - 24, notifyIconWidth,notifyIconHeight);
            UIImageView * chatIconImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pic_chat_default.png"]];
            chatIconImg.frame = chatIconRect;
            [self.noneDataNotifyView addSubview:chatIconImg];
            
            CGRect nofityLabelRect = CGRectMake(KUIScreenWidth/2 - notifyLabelWidth/2, CGRectGetMaxY(chatIconImg.frame), notifyLabelWidth, notifyLabelHeight);
            UILabel * nofityLabel = [[UILabel alloc]initWithFrame:nofityLabelRect];
            nofityLabel.backgroundColor = [UIColor clearColor];
            nofityLabel.text = @"暂时没有新消息";
            nofityLabel.textColor = LightTextGrayColor;
            nofityLabel.font = KQLboldSystemFont(14);
            nofityLabel.textAlignment = NSTextAlignmentCenter;
            [self.noneDataNotifyView addSubview:nofityLabel];
            RELEASE_SAFE(nofityLabel);
            RELEASE_SAFE(chatIconImg);

            [self.view addSubview:self.noneDataNotifyView];
            [self.view sendSubviewToBack:self.noneDataNotifyView];
        }
    } else {
        self.mainTableView.hidden = NO;
        self.noneDataNotifyView.hidden = YES;
    }
}

/**
 *  主页布局
 */
- (void)loadMainView{
    UITableView * tempTable = [[UITableView alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight - 44 - 49) style:UITableViewStylePlain];
    
    self.mainTableView = tempTable;
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.showsVerticalScrollIndicator = NO;
    self.mainTableView.separatorColor = SeparateLightColor;
    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.mainTableView.backgroundColor = SessionTableBackColor;
    if (IOS7_OR_LATER) {
        [self.mainTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    [self.view addSubview:self.mainTableView];
    
    RELEASE_SAFE(tempTable);
}

/**
 * 上bar右侧按钮
 */
- (void)loadRightBarButton{
    
    UIImage *rightImg = [UIImage imageNamed:@"ico_chat_write.png"];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(20, 7, 30, 30);
    [rightBtn setImage:rightImg forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnClickInChat) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem release];
}

#pragma mark - event Method
- (void)rightBtnClickInChat{
    [MobClick event:@"chat_new_chat_create"];
    
    MessageListData * turnListData = [MessageListData generateOriginListDataWithObjectID:0 andSessionType:SessionTypePerson];
    ContactSelectOrgViewController *contactVC = [[ContactSelectOrgViewController alloc]init];
    contactVC.delegate = self;
    contactVC.listData = turnListData;
    contactVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:contactVC animated:YES];
    RELEASE_SAFE(contactVC);
}

#pragma mark - UITableViewDelegate

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _searchControl.searchResultsTableView) {
        return _searchResults.count;
    }
    return _messageList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MessageListData * messageData = nil;
    //判断是否为搜索框数据
    if (tableView == _searchControl.searchResultsTableView)
    {
        messageData = [_searchResults objectAtIndex:indexPath.row];
        messageData.dataType = searchBarData;
    }else{
        messageData = [_messageList objectAtIndex:indexPath.row];
        messageData.dataType = tableViewData;
    }
    
    OriginCell * cell = [MessageListCellFactory cellFromData:messageData andTableView:tableView];
    if (messageData.dataType == searchBarData) {
        [cell freshWithInfoDic:messageData searchText:self.searchBar.text];
    } else {
        [cell freshWithInfoDic:messageData];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"chat_select_messageListItem"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (tableView == _searchControl.searchResultsTableView) {
        [_searchBar resignFirstResponder];
        [self turnToSessionViewControllerWithData:_searchResults[indexPath.row]];
    }else{
        [self turnToSessionViewControllerWithData:[_messageList objectAtIndex:indexPath.row]];
    }
}

- (void)turnToSessionViewControllerWithData:(MessageListData *)data
{
    SessionViewController * sessionViewController = [[SessionViewController alloc]init];
    sessionViewController.sessionDelegate = self;
    sessionViewController.listData = data;
    sessionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    sessionViewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:sessionViewController animated:YES];
    RELEASE_SAFE(sessionViewController);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete && tableView != _searchControl.searchResultsTableView) {
        
        MessageListData * deleteData = [self.messageList objectAtIndex:indexPath.row];
        [[MessageListDataOperator shareOperator]deleteDBRecordWithListData:deleteData];
        
        [self.messageList removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self judgeAndShowNoneView];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _searchControl.searchResultsTableView) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView: (UITableView *)tableView editingStyleForRowAtIndexPath: (NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)addChatListWithArr:(NSMutableArray *)resultArray
{
    //对所取数据按照最新的消息时间来排序
    self.messageList = resultArray;
    
    //移除noneView
    UIView* v = [self.view viewWithTag:10000];
    if (v) {
        [v removeFromSuperview];
    }

    //从新加载列表
    [self.mainTableView reloadData];
}


#pragma mark - ContectSelectOrgDelegate

- (void)callBackSelectedMembers:(NSMutableArray *)array
{
    if (array.count == 1) {
        ContactModel * selectContact = [array firstObject];
        
        MessageListData * turnListData = [MessageListData generateOriginListDataWithObjectID:selectContact.userId andSessionType:SessionTypePerson];
        
        [self turnToSessionViewControllerWithData:turnListData];
    } else if (array.count > 1){
        [self createTempChatWithContacts:array];
    }
}

- (void)callBackPassMembers:(NSMutableArray *)array {
   [self createTempChatWithContacts:array];
}

- (void)createTempChatWithContacts:(NSMutableArray *)contactArr
{
    [[TempChatManager shareManager]createTempChatWithContactArr:contactArr];
    [TempChatManager shareManager].delegate = self;
}

#pragma mark- TempChatManagerDelegate

- (void)createTempChatSuccessWithCircleID:(long long)tempCircleID
{
    MessageListData * tempTurnListData = [MessageListData generateOriginListDataWithObjectID:tempCircleID andSessionType:SessionTypeTempCircle];
    
    [self turnToSessionViewControllerWithData:tempTurnListData];
}

- (void)refreshDetailInfoWithCircleID:(long long)tempCircleID{
    [self loadInfoLists];
}

#pragma mark - UISearchBarDelegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    self.searchBar.showsCancelButton = YES;
    for (UIView *view in [self.searchBar.subviews[0] subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton* cancelbutton = (UIButton* )view;
            [cancelbutton setTitle:@"取消" forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    [self.searchResults removeAllObjects];
    NSMutableArray* allContactAndCompanyArr = [NSMutableArray arrayWithCapacity:self.messageList.count];
    for (MessageListData *messageData in self.messageList) {
        NSString* str = [NSString stringWithFormat:@"%@-%@",messageData.title,[messageData.latestMessage.sessionData dataListDescreption]];
        NSLog(@"str = %@",str);
        [allContactAndCompanyArr addObject:str];
    }

    //不包含中文的搜索
    if (self.searchBar.text.length > 0 && ![Common isIncludeChineseInString:self.searchBar.text]) {
        for (int i=0; i<allContactAndCompanyArr.count; i++) {
          
            if ([Common isIncludeChineseInString:allContactAndCompanyArr[i]]) {
                
                // 转换为拼音
                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:allContactAndCompanyArr[i]];
                
                // 搜索是否在转换后拼音中
                NSRange titleResult=[tempPinYinStr rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
                
                if (titleResult.length>0) {
                    
                    [_searchResults addObject:_messageList[i]];
                    
                }else{
                    // 转换为拼音的首字母
                    NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:allContactAndCompanyArr[i]];
                    
                    // 搜索是否在范围中
                    NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
                    
                    if (titleHeadResult.length>0) {
                        [_searchResults addObject:_messageList[i]];
                    }
                }
            }
            else {
                NSRange titleResult=[allContactAndCompanyArr[i] rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
                
                if (titleResult.length>0) {
                    [_searchResults addObject:_messageList[i]];
                }
            }
        }
        // 搜索中文
    } else if (self.searchBar.text.length>0 && [Common isIncludeChineseInString:self.searchBar.text]) {
        
        for (int i=0; i<allContactAndCompanyArr.count; i++) {
            NSString *tempStr = allContactAndCompanyArr[i];
            
            NSRange titleResult=[tempStr rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
            
            if (titleResult.length>0) {
                [_searchResults addObject:[_messageList objectAtIndex:i]];
            }
        }
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if ([_searchResults count] == 0) {
        UITableView *tableView1 = self.searchControl.searchResultsTableView;
        for( UIView *subview in tableView1.subviews ) {
            if([subview isKindOfClass:[UILabel class]]) {
                UILabel *lbl = (UILabel*)subview; // sv changed to subview.
                lbl.text = [NSString stringWithFormat:@"没有找到\"%@\"相关的联系人",self.searchBar.text];
            }
        }
    }
    return YES;

}

#pragma mark - EmotionStoreManagerDelegate
//- (void)getEmotionStoreDataSuccessWithDic:(NSDictionary *)dataDic sender:(EmotionStoreManager *)sender
//{
//    NSArray * emoticonsArr = [dataDic objectForKey:@"emoticons"];
//    for (NSDictionary * emoticonDic in emoticonsArr) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSInteger emoticonID = [[emoticonDic objectForKey:@"emoticon_id"]integerValue];
//            EmotionStoreManager * detailManager = [[EmotionStoreManager alloc]init];
//            detailManager.delegate = self;
//            BOOL sign = [detailManager judgeShouldAndLoadDownloadedDetailEmoticonWithEmoticonID:emoticonID];
//            if (!sign) {
//                RELEASE_SAFE(detailManager);
//            }
//        });
//    }
//    RELEASE_SAFE(sender);
//}

#pragma mark - MessageListOperatorDelegate 

- (void)getFirstInWelcomeMessageSuccessWithDataArr:(NSMutableArray *)dataArray
{
    for (MessageListData * data in dataArray) {
        [self insertMessageWithMessageData:data AtIndex:0];
    }
//    [self judgeAndShowNoneView];
}

- (void)receiveNewDataMessage:(MessageData *)message
{
    [self loadInfoLists];
}

- (void)insertMessageWithMessageData:(MessageListData *)listData AtIndex:(NSInteger)index
{
    [self.messageList insertObject:listData atIndex:index];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    [self.mainTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TempCircleMemberChanged object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TempCircleQuitScucess object:nil];
    self.searchBar = nil;
    self.searchResults = nil;
    self.searchControl = nil;
    self.messageList = nil;
    self.mainTableView = nil;
    self.noneDataNotifyView = nil;
    self.operator = nil;
    [super dealloc];
}
@end
