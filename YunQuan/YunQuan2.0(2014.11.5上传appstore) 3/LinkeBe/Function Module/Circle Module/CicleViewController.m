//
//  CicleViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "CicleViewController.h"
#import "UIViewController+NavigationBar.h"
#import "RATreeView.h"
#import "RADataObject.h"
#import "Global.h"
#import "BusinessCardViewController.h"
#import "CicleLayerCell.h"
#import "CicleListCell.h"
#import "CicleMemberViewController.h"
#import "CicleListHeaderView.h"
#import "BusinessHelperViewController.h"
#import "Cicle_org_model.h"
#import "Circle_member_model.h"
#import "UIImageView+WebCache.h"
#import "SBJson.h"
#import "PinYinForObjc.h"
#import "MajorCircleManager.h"
#import "Cicle_member_list_model.h"

#import "Common.h"
#import "SelfBusinessCardViewController.h"
#import "OthersBusinessCardViewController.h"
#import "SessionDataOperator.h"
#import "TempChatMembersViewController.h"
#import "PinYinSort.h"
#import "AppDelegate.h"
#import "MobClick.h"

#define inviteTag  1100
#define sendTag    100
#define yellowViewTag 5000
#define yellowViewLableTag 5500

@interface CicleViewController ()<RATreeViewDelegate, RATreeViewDataSource,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,MajorCircleManagerDelegate>{
    
    RATreeView  *_treeView; // 二级或三级层级圈子
    UITableView *_oneLayerTableView; // 只有一级层级圈子
    int clickButtonTag;
}
//三级组织结构数据
@property (nonatomic, retain) NSMutableArray *data;
//搜索最终数据
@property (nonatomic, retain) NSMutableArray *searchResults;
//搜索栏
@property (nonatomic, retain) UISearchBar *searchBar;
//搜索控制器
@property (nonatomic, retain) UISearchDisplayController *searchControl;
//一级组织数据
@property (nonatomic, retain) NSDictionary *firstOrgDic;
//二级组织的数据 （可以根据这个数组是否存在来判断是否为 有层级和没层级）
@property (nonatomic, retain) NSMutableArray *secArray;
//所有组织成员
@property (nonatomic, retain) NSMutableArray *orgMembersArray;
//userId
@property (nonatomic, assign) long long objectID;
//新添成员字典
@property (nonatomic, retain) NSDictionary *newMembersDic;

@property (nonatomic, retain) NSMutableArray *tempArray;

@end

@implementation CicleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.searchResults = [[[NSMutableArray alloc]init] autorelease];
        self.data = [[[NSMutableArray alloc]init]autorelease];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshOrgData) name:NewCircleOrgChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshYellowViewData:) name:NewCircleMemberChanged object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"CicleViewPage"];
    
    self.tabBarController.tabBar.hidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"CicleViewPage"];
}

- (void)viewDidAppear:(BOOL)animated
{
    //    self.tabBarController.tabBar.hidden = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NewCircleMemberChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NewCircleOrgChanged object:nil];
    self.searchBar = nil;
    self.searchResults = nil;
    self.searchControl = nil;
    
    _treeView.delegate = nil;
    [_treeView release]; _treeView = nil;
    _oneLayerTableView.delegate =nil;
    [_oneLayerTableView release]; _oneLayerTableView = nil;
    
    self.firstOrgDic = nil;
    self.secArray = nil;
    self.orgMembersArray = nil;
    self.data = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
    
    Cicle_org_model *orgModel = [[Cicle_org_model alloc]init];
    orgModel.where = [NSString stringWithFormat:@"parentId = 0"];
    NSArray *firstOrgArr = [orgModel getList];
    self.firstOrgDic = [firstOrgArr firstObject];
    orgModel.where = [NSString stringWithFormat:@"parentId = %d",[[self.firstOrgDic objectForKey:@"id"] intValue]];
    orgModel.orderBy = @"position asc,id";
    self.secArray = [orgModel getList];
    self.navigationItem.title = [self.firstOrgDic objectForKey:@"name"]; //导航栏标题
    RELEASE_SAFE(orgModel);
    
    [self loadMembersData]; //成员数据
    
    //根据有没有二级组织个数判断 加载哪个表视图
    if ([self.secArray count]) {
        [self initWithRreeView];   // 三级组织层级
    } else {
        [self initWithOneLayerTableView];  //一级组织成员列表
    }
    
    [self initWithSearchBar];    //搜索栏
    
    [self loadOrgData]; //加载数据

    [self initYellowView];       //通知提醒小黄条
    
    [self initWithRightButton];  //导航栏右按钮
}


- (void)loadMembersData {
    //获取没被禁用或删除的人 （这个在请求时处理数据已经处理了）
    self.orgMembersArray = [Circle_member_model getNoForbidMembers];
}

- (void)loadOrgData {
    Cicle_org_model *orgModel = [[Cicle_org_model alloc]init];
    orgModel.where = [NSString stringWithFormat:@"parentId = %d",[[self.firstOrgDic objectForKey:@"id"] intValue]];
    orgModel.orderBy = @"position asc,id";
    self.secArray = [orgModel getList];

    if ([self.secArray count]) {
        NSMutableArray *secObjectArr = [NSMutableArray array];//存放二级组织的数据
        for (NSDictionary *tempSecDic in self.secArray) {
            long long secOrgId = [[tempSecDic objectForKey:@"id"] longLongValue];
            
            //搜索是否有三级成员
            orgModel.where = [NSString stringWithFormat:@"parentId = %lld",secOrgId];
            orgModel.orderBy = @"position asc,id";
            NSArray *thrArray = [orgModel getList];
            NSMutableArray *thrObjectArr = [NSMutableArray array]; //存放三级组织的数据
            if (thrArray.count > 0) {
                for (NSDictionary *tempThrDic in thrArray){
                    NSArray *thrArr = [Cicle_member_list_model getMembersWithOrgId:[[tempThrDic objectForKey:@"id"] longLongValue]];
                    RADataObject *thrObject =  [RADataObject dataObjectWithName:[tempThrDic objectForKey:@"name"] count:thrArr.count orgId:[[tempThrDic objectForKey:@"id"] integerValue] children:nil arrowPoint:YES];
                    [thrObjectArr addObject:thrObject];
                }
            }
            
            NSArray *secArr = [Cicle_member_list_model getMembersWithOrgId:[[tempSecDic objectForKey:@"id"] longLongValue]];
            RADataObject *secObject = [RADataObject dataObjectWithName:[tempSecDic objectForKey:@"name"] count:secArr.count orgId:[[tempSecDic objectForKey:@"id"] integerValue] children:thrObjectArr arrowPoint:YES];
            [secObjectArr addObject:secObject];
            
        }
        [self.data addObjectsFromArray:secObjectArr];
        RELEASE_SAFE(orgModel);
        [_treeView reloadData];
    } else {
        //只有一级成员
        [_oneLayerTableView reloadData];
    }
    [orgModel release];
    
}

#pragma mark -- 初始化 treeView 和 searchbar 及小黄条

- (void)initWithSearchBar{
    UISearchBar * tempSearch = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar = tempSearch;
    RELEASE_SAFE(tempSearch);
    self.searchBar.frame = CGRectMake(0.0f, 0.f, ScreenWidth, 44.0f);
	self.searchBar.placeholder=@"查找朋友";
	self.searchBar.delegate = self;
    //设置为聊天列表头
    UIView *tableHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, 44.0f)];
    if ([self.secArray count]) {
        _treeView.treeHeaderView = tableHeadView;
        [_treeView.treeHeaderView addSubview:self.searchBar];
    } else {
        _oneLayerTableView.tableHeaderView = tableHeadView;
        [_oneLayerTableView.tableHeaderView addSubview:self.searchBar];
    }
    RELEASE_SAFE(tableHeadView);
    //搜索控制器
    UISearchDisplayController *searchController = [[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
    self.searchControl = searchController;
    RELEASE_SAFE(searchController);
    self.searchControl.searchResultsDataSource = self;
    self.searchControl.searchResultsDelegate = self;
    self.searchControl.delegate = self;
}

- (void)initYellowView {
    UIView *yellowView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, 25.0)];
    yellowView.tag = yellowViewTag;
    yellowView.hidden = YES;
    yellowView.backgroundColor = RGBACOLOR(255, 254, 219, 1);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapYellowView)];
    [yellowView addGestureRecognizer:tap];
    [tap release];
    
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 25.0)];
    lable.tag = yellowViewLableTag;
    lable.font = [UIFont systemFontOfSize:15.0];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor = RGBACOLOR(102, 102, 102, 1);
    [yellowView addSubview:lable];
    [lable release];
    
    [self.view addSubview:yellowView];
    [yellowView release];
}

- (void)initWithRreeView {
    //两级或三级层级圈子
    if (IOS7_OR_LATER) {
        _treeView = [[RATreeView alloc] initWithFrame:CGRectMake(0,0, ScreenWidth, ScreenHeight)style:RATreeViewStylePlain];
    } else {
       _treeView = [[RATreeView alloc] initWithFrame:CGRectMake(0,0, ScreenWidth, ScreenHeight - 49 -44 -20)style:RATreeViewStylePlain];
    }
    _treeView.delegate = self;
    _treeView.dataSource = self;
    _treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
    [self.view addSubview:_treeView];
}

- (void)initWithOneLayerTableView {
   //一级层级圈子
    _oneLayerTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
    _oneLayerTableView.delegate = self;
    _oneLayerTableView.dataSource = self;
    [self.view addSubview:_oneLayerTableView];

}

- (void)initWithRightButton {
    UIImage *rightImg = [UIImage imageNamed:@"ico_group_tool.png"];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(20, 7, 30, 30);
    [rightBtn setImage:rightImg forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem release];
}

#pragma mark -- TreeView Data Source 数据源

- (NSInteger)numberOfTreeViewInSection:(RATreeView *)treeView {
    return 1;
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        return [self.data count];
    }
    RADataObject *data = item;
    return [data.children count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item {
    RADataObject *data = item;
    if (item == nil) {
        return [self.data objectAtIndex:index];
    }
    return [data.children objectAtIndex:index];
}

//是否展开层级
- (BOOL)treeView:(RATreeView *)treeView shouldItemBeExpandedAfterDataReload:(id)item treeDepthLevel:(NSInteger)treeDepthLevel {
    return YES;
}

- (void)treeView:(RATreeView *)treeView willDisplayCell:(UITableViewCell *)cell forItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo{
    if(treeNodeInfo.treeDepthLevel == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    } else {
        cell.backgroundColor = BACKGROUNDCOLOR;
    }
}

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo {
    
    static NSString *identifier = @"CicleLayerCell";
    CicleLayerCell *cell = [treeView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[CicleLayerCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:identifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.nameLable.text = ((RADataObject *)item).name;  //名称
    
    if (((RADataObject *)item).count > 0) {
        cell.countLable.text = [NSString stringWithFormat:@"%d",((RADataObject *)item).count]; //成员个数
    }else{
        cell.countLable.text = @"0"; //成员个数
    }

    if (treeNodeInfo.treeDepthLevel == 0){
        if (((RADataObject *)item).children && ((RADataObject *)item).children.count){
            cell.countLable.text = nil;
        }
        cell.countLable.frame = CGRectMake(280 - 5*cell.countLable.text.length, (53 - 20)/2, 50.f, 20.f);
        cell.nameLable.frame = CGRectMake(20, 11.0,cell.nameLable.frame.size.width, cell.nameLable.frame.size.height);
        cell.countLable.textColor = RGBACOLOR(136, 136, 136, 1);
        cell.nameLable.textColor = RGBACOLOR(53, 53, 53, 1);
        cell.lineImage.frame = CGRectMake(0, 52.5, 320, 0.5);
    } else {
        cell.countLable.frame = CGRectMake(280 - 5*cell.countLable.text.length, (44 - 20)/2, 50.f, 20.f);
        cell.nameLable.frame = CGRectMake(30, 9.0,cell.nameLable.frame.size.width, cell.nameLable.frame.size.height);
        cell.countLable.textColor = RGBACOLOR(204, 204, 204, 1);
        cell.nameLable.textColor = RGBACOLOR(136, 136, 136, 1);
        cell.lineImage.frame = CGRectMake(30, 42.5, 300, 0.5);
    }
    
    cell.arrowImage.hidden = YES;
    cell.arrowSimpleImage.hidden = YES;
    
    if (treeNodeInfo.treeDepthLevel == 0) {
        if (!((RADataObject *)item).children.count) {
            UIImage *image = [UIImage imageNamed:@"ico_group_arrow1.png"];
            cell.arrowImage.frame = CGRectMake(285,(53 - image.size.height)/2 , image.size.width, image.size.height);
            cell.arrowImage.image = image;
            cell.arrowImage.hidden = NO;
        } else {
            if (((RADataObject *)item).isExpand) {
                cell.arrowSimpleImage.hidden = NO;
                UIImage *image = [UIImage imageNamed:@"ico_group_down.png"];
                cell.arrowSimpleImage.image = image;
            } else {
                cell.arrowSimpleImage.hidden = NO;
                UIImage *image = [UIImage imageNamed:@"ico_group_normal.png"];
                cell.arrowSimpleImage.image = image;
            }
        }
    }else if (treeNodeInfo.treeDepthLevel == 1) {
         UIImage *image = [UIImage imageNamed:@"ico_group_arrow2.png"];
         cell.arrowImage.frame = CGRectMake(285,(44 - image.size.height)/2 , image.size.width, image.size.height);
         cell.arrowImage.image = image;
         cell.arrowImage.hidden = NO;
    }
    return cell;
    
}

#pragma mark -- TreeView Delegate 代理

- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    if(treeNodeInfo.treeDepthLevel == 0) {
        return 53.0;
    } else if(treeNodeInfo.treeDepthLevel == 1){
        return 44.0;
    }
    return 0.0;
}

-(void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInf indexPathInTreeView:(NSIndexPath *)indexPath{
    
    if (treeNodeInf.treeDepthLevel == 0) {
        if (((RADataObject *)item).children.count){
            [MobClick event:@"cicle_twoHaveSuns"];
        } else {
            [MobClick event:@"cicle_twoNotHaveSuns"];
            [MobClick event:@"circle_member_list"];
            CicleMemberViewController *cicleMemberVC = [[CicleMemberViewController alloc]init];
            cicleMemberVC.orgName = ((RADataObject *)item).name;
            cicleMemberVC.orgId = ((RADataObject *)item).orgId;
            [cicleMemberVC setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:cicleMemberVC animated:YES];
            [cicleMemberVC release];
        }
    } else if(treeNodeInf.treeDepthLevel == 1) {
        [MobClick event:@"cicle_threeOrg"];
        [MobClick event:@"circle_member_list"];
        CicleMemberViewController *cicleMemberVC = [[CicleMemberViewController alloc]init];
        cicleMemberVC.orgName = ((RADataObject *)item).name;
        cicleMemberVC.orgId = ((RADataObject *)item).orgId;
        [cicleMemberVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:cicleMemberVC animated:YES];
        [cicleMemberVC release];
    }
}

- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    RADataObject *object = (RADataObject *)item;
    object.isExpand = YES;
    CicleLayerCell * selectCell = (CicleLayerCell *)[treeView cellForItem:item];
    UIImage *image = [UIImage imageNamed:@"ico_group_down.png"];
    selectCell.arrowSimpleImage.image = image;
  
}

- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    RADataObject *object = (RADataObject *)item;
    object.isExpand = NO;
    CicleLayerCell * selectCell = (CicleLayerCell *)[treeView cellForItem:item];
    UIImage *image = [UIImage imageNamed:@"ico_group_normal.png"];
    selectCell.arrowSimpleImage.image = image;

}


#pragma mark -- UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchControl.searchResultsTableView) {
        return [_searchResults count];
        
    } else if (tableView == _oneLayerTableView) {
        return [self.orgMembersArray count];
        
    }
    return section;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _oneLayerTableView) {
        static NSString *identifier2 = @"CicleListCell";
        CicleListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
        if (!cell) {
            cell = [[[CicleListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSDictionary *dic = nil;
        if ([self.orgMembersArray count]) {
            dic = [self.orgMembersArray objectAtIndex:indexPath.row];
        }
        self.tempArray = self.orgMembersArray;
        cell.nameLable.text = [dic objectForKey:@"realname"];  //成员名称
        NSURL* urlStr = [NSURL URLWithString:[dic objectForKey:@"portrait"]];
        if ([[dic objectForKey:@"sex"] intValue] == 0) {
            [cell.listNameImage setImageWithURL:urlStr placeholderImage:[UIImage imageNamed:@"ico_default_portrait_male.png"]];
        } else {
            [cell.listNameImage setImageWithURL:urlStr placeholderImage:[UIImage imageNamed:@"ico_default_portrait_female.png"]];
        }
            
        //根据名字排版职位的UI排布
        CGSize listNameWidth = [cell.nameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:16.0] constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
        cell.positionLable.frame = CGRectMake(MIN(60 + listNameWidth.width + 10, 180), 2.0, 80, 30.f); //职位
            
        cell.positionLable.text = [dic objectForKey:@"companyRole"];  //职位
            
        cell.companyLable.text = [dic objectForKey:@"companyName"]; //公司名称
        
        //点击变已邀请
        cell.inviteLable.hidden = YES;
        cell.inviteLable.tag = inviteTag + indexPath.row;
        
        /* 0未邀请 1已邀请 2已激活(正常使用状态)
         *  3禁用 4删除 ，大于2从本地数据库删除
        */
        //这里单独拿出来原因是。。。
        NSDictionary *stateDic = nil;
        if ([self.orgMembersArray count]) {
            stateDic = [self.orgMembersArray objectAtIndex:indexPath.row];
        }
        cell.sendBtn.hidden = YES;
        if ([[stateDic objectForKey:@"state"] intValue] == 0) {
            cell.sendBtn.hidden = NO;
            [cell.sendBtn setTitle:@"邀请" forState:UIControlStateNormal];
            
        } else if([[stateDic objectForKey:@"state"] intValue] == 1) {
            cell.inviteLable.hidden = NO;
            
        } else if([[stateDic objectForKey:@"state"] intValue] == 2) {
            cell.sendBtn.hidden = NO;
            [cell.sendBtn setTitle:@"聊聊" forState:UIControlStateNormal];
            
        } else {
            NSLog(@"大于2 回调里处理了");
        }
        if ([[dic objectForKey:@"userId"] intValue] == [[UserModel shareUser].user_id intValue]) {
            cell.sendBtn.hidden = YES;
            cell.inviteLable.hidden = YES;
        }
        cell.sendBtn.tag = sendTag + indexPath.row;
        [cell.sendBtn addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    } else if (tableView == self.searchControl.searchResultsTableView){
    
        static NSString *searchCell = @"CicleListCell";
        CicleListCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCell];
        if (!cell) {
            cell = [[[CicleListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCell]autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        NSDictionary *dic = nil;
        if ([_searchResults count]) {
            dic = [_searchResults objectAtIndex:indexPath.row];
        }
        self.tempArray = _searchResults;
        cell.nameLable.text = [dic objectForKey:@"realname"];
        cell.companyLable.text = [dic objectForKey:@"companyName"];
        //根据名字排版职位的UI排布
        CGSize listNameWidth = [cell.nameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:16.0] constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
        cell.positionLable.frame = CGRectMake(MIN(60 + listNameWidth.width + 10, 180), 2.0, 250.f, 30.f); //职位
        
        cell.positionLable.text = [dic objectForKey:@"companyRole"];  //职位
        
        //    姓名字体的变化 add vincent
        if ([[dic objectForKey:@"realname"] rangeOfString:_searchBar.text].location != NSNotFound) {
            if ([dic objectForKey:@"realname"]) {
                NSRange rang1 = [[dic objectForKey:@"realname"] rangeOfString:_searchBar.text];
                NSMutableAttributedString  *numStr = [[NSMutableAttributedString alloc] initWithString:[dic objectForKey:@"realname"]];
                [numStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:rang1];
                cell.nameLable.attributedText = numStr;
                [numStr release];
            }
        }
        //    公司名字的字体的颜色的变化 add vincent
            if ([[dic objectForKey:@"companyName"] rangeOfString:_searchBar.text].location != NSNotFound) {
                if ([dic objectForKey:@"companyName"]) {
                NSRange rang1 = [[dic objectForKey:@"companyName"] rangeOfString:_searchBar.text];
                NSMutableAttributedString  *numStr = [[NSMutableAttributedString alloc] initWithString:[dic objectForKey:@"companyName"]];
                [numStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:rang1];
                cell.companyLable.attributedText = numStr;
                [numStr release];
                }
            }
    
        NSURL* urlStr = [NSURL URLWithString:[dic objectForKey:@"portrait"]];
        if ([[dic objectForKey:@"sex"] intValue] == 0) {
            [cell.listNameImage setImageWithURL:urlStr placeholderImage:[UIImage imageNamed:@"ico_default_portrait_male.png"]];
        } else {
          [cell.listNameImage setImageWithURL:urlStr placeholderImage:[UIImage imageNamed:@"ico_default_portrait_female.png"]];
        }
        
        //点击变已邀请
        cell.inviteLable.hidden = YES;
        cell.inviteLable.tag = inviteTag + indexPath.row;
        
        /* 0未邀请 1已邀请 2已激活(正常使用状态)
         *  3禁用 4删除 ，大于2从本地数据库删除
         */
        //这里单独拿出来原因是。。。
        NSDictionary *stateDic = nil;
        if ([_searchResults count]) {
            stateDic = [_searchResults objectAtIndex:indexPath.row];
        }
        cell.sendBtn.hidden = YES;
        if ([[stateDic objectForKey:@"state"] intValue] == 0) {
            cell.sendBtn.hidden = NO;
            [cell.sendBtn setTitle:@"邀请" forState:UIControlStateNormal];
            
        } else if([[stateDic objectForKey:@"state"] intValue] == 1) {
            cell.inviteLable.hidden = NO;
            
        } else if([[stateDic objectForKey:@"state"] intValue] == 2) {
            cell.sendBtn.hidden = NO;
            [cell.sendBtn setTitle:@"聊聊" forState:UIControlStateNormal];
            
        } else {
            NSLog(@"大于2 回调里处理了");
        }
        if ([[dic objectForKey:@"userId"] intValue] == [[UserModel shareUser].user_id intValue]) {
            cell.sendBtn.hidden = YES;
            cell.inviteLable.hidden = YES;
        }
        cell.sendBtn.tag = sendTag + indexPath.row;
        [cell.sendBtn addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    return nil;
}

#pragma mark -- UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = nil;
    if (tableView == self.searchControl.searchResultsTableView) {
        dic = [_searchResults objectAtIndex:indexPath.row];
      
    } else {
        dic = [self.orgMembersArray objectAtIndex:indexPath.row];
    }
    //跳转名片
    if ([[dic objectForKey:@"userId"] intValue] == [[UserModel shareUser].user_id intValue]) {
        SelfBusinessCardViewController *selfBusinessVC = [[SelfBusinessCardViewController alloc]init];
        selfBusinessVC.hidesBottomBarWhenPushed = YES;
        selfBusinessVC.bussinessType = TabbarBussinessType;
        [self.navigationController pushViewController:selfBusinessVC animated:YES];
        [selfBusinessVC release];
    } else {
        OthersBusinessCardViewController *otherBusinessVC = [[OthersBusinessCardViewController alloc]init];
        otherBusinessVC.orgUserId = [dic objectForKey:@"orgUserId"];
        otherBusinessVC.hidesBottomBarWhenPushed = YES;
        otherBusinessVC.bussinessType = TabbarBussinessType;
        [self.navigationController pushViewController:otherBusinessVC animated:YES];
        [otherBusinessVC release];
    }
  
}

#pragma mark -- UISearchBarDelegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    
    [MobClick event:@"circle_list_member_search"];
    self.searchBar.showsCancelButton = YES;
    self.tabBarController.tabBar.hidden = YES;

    for (UIView *view in [self.searchBar.subviews[0] subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton* cancelbutton = (UIButton* )view;
            [cancelbutton setTitle:@"取消" forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    self.tabBarController.tabBar.hidden = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_searchResults removeAllObjects];
    
    //获取所有联系人数据
    NSArray *allContactsArr = [Circle_member_model getNoForbidMembers];
    
    NSMutableArray* allContactAndCompanyArr = [NSMutableArray arrayWithCapacity:0];
    
    if ([allContactsArr count]) {
        for (NSDictionary *Dic in allContactsArr) {
            NSString* str = [NSString stringWithFormat:@"%@-%@-%@",[Dic objectForKey:@"realname"],[Dic objectForKey:@"companyName"],[Dic objectForKey:@"companyRole"]];
            [allContactAndCompanyArr addObject:str];
        }
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
                    
                    [_searchResults addObject:allContactsArr[i]];
                    
                }else{
                    // 转换为拼音的首字母
                    NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:allContactAndCompanyArr[i]];
                    
                    // 搜索是否在范围中
                    NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
                    
                    if (titleHeadResult.length>0) {
                        [_searchResults addObject:allContactsArr[i]];
                    }
                }
            }
            else {
                
                NSRange titleResult=[allContactAndCompanyArr[i] rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
                
                if (titleResult.length>0) {
                    [_searchResults addObject:allContactsArr[i]];
                }
            }
        }
        // 搜索中文
    } else if (self.searchBar.text.length>0 && [Common isIncludeChineseInString:self.searchBar.text]) {
        
        for (int i=0; i<allContactAndCompanyArr.count; i++) {
            NSString *tempStr = allContactAndCompanyArr[i];
            
            NSRange titleResult=[tempStr rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
            
            if (titleResult.length>0) {
                [_searchResults addObject:[allContactsArr objectAtIndex:i]];
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
    } else {
        NSMutableDictionary *sortDic= [PinYinSort accordingFirstLetterFromPinYin:_searchResults];
        [_searchResults removeAllObjects];
        NSArray *keyArray = [[sortDic allKeys] sortedArrayUsingSelector:@selector(compare:)];
        if (keyArray.count > 0) {
            for (int i = 0; i < [sortDic allKeys].count; i ++) {
                [_searchResults addObjectsFromArray:[sortDic objectForKey:[keyArray objectAtIndex:i]]];
            }
        }
    }
    return YES;
}

#pragma mark --  各种手势按钮点击事件

//小黄条点击事件
- (void)tapYellowView {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.newCicleLable.hidden = YES;
    
    //点击后更新事件
    long long ts = [[self.newMembersDic objectForKey:@"ts"] longLongValue];
    LinkedBe_TsType tsType = MEMBERTS;
    [TimeStamp_model insertOrUpdateType:tsType time:ts];
    
    UIView *yellowView = [self.view viewWithTag:yellowViewTag];
    yellowView.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        if ([self.secArray count]) {
            _treeView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        } else {
            _oneLayerTableView.frame = CGRectMake(0.f, 0, ScreenWidth, ScreenHeight);
        }
        
    }];
    
    TempChatMembersViewController *tempMembersVC = [[TempChatMembersViewController alloc]init];
    tempMembersVC.hidesBottomBarWhenPushed = YES;
    tempMembersVC.membersDic = self.newMembersDic;
    tempMembersVC.typePush = yellowViewType;
    [self.navigationController pushViewController:tempMembersVC animated:YES];
    [tempMembersVC release];
}

//商务助手
- (void)rightBtnClick {
    [MobClick event:@"circle_plugins"];
    BusinessHelperViewController *busHelperVC = [[BusinessHelperViewController alloc]init];
    busHelperVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:busHelperVC animated:YES];
    [busHelperVC release];
}

//组织变更
- (void)refreshOrgData {
    [self.data removeAllObjects];
    [self loadMembersData];
    [self loadOrgData];
}

//成员变更
- (void)refreshYellowViewData:(NSNotification *)notification{
    NSLog(@"notification.object = %@",notification.object);
    self.newMembersDic = notification.object;
    
    [self.data removeAllObjects];
    [self loadMembersData];
    [self loadOrgData];
    
    NSArray *memberArray = [self.newMembersDic objectForKey:@"members"];
    if (memberArray.count > 0) {
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.newCicleLable.hidden = NO;
        
        UIView *yellowView = [self.view viewWithTag:yellowViewTag];
        yellowView.hidden = NO;
        
        UILabel *yellowLable = (UILabel *)[self.view viewWithTag:yellowViewLableTag];
        yellowLable.text = [NSString stringWithFormat:@"有%d个新成员加入圈子",memberArray.count];
        
        //根据有没有二级组织个数判断 加载哪个表视图
        if ([self.secArray count]) {
            _treeView.frame = CGRectMake(0, yellowView.frame.size.height, ScreenWidth, ScreenHeight - yellowView.frame.size.height);
        } else {
            _oneLayerTableView.frame = CGRectMake(0.f, yellowView.frame.size.height, ScreenWidth, ScreenHeight - yellowView.frame.size.height);
        }
    }
}

//一级成员邀请 聊聊点击按钮
- (void)send:(UIButton *)sender {
    UIButton *button = (UIButton *)sender;
//    CicleListCell *cell = (CicleListCell *)sender.superview.superview;
    clickButtonTag = button.tag;
    NSDictionary *dicStr = [self.tempArray objectAtIndex:sender.tag - sendTag];
    self.objectID = [[dicStr objectForKey:@"userId"] longLongValue];
    if ([button.titleLabel.text isEqualToString:@"邀请"]) {
        MajorCircleManager *manager = [[MajorCircleManager alloc]init];
        manager.delegate = self;
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [UserModel shareUser].user_id,@"userId",
                                    [dicStr objectForKey:@"userId"],@"inviteeId",
                                    [dicStr objectForKey:@"orgId"],@"orgId",
                                    nil];
        [manager accessUserInvite:dic];
        
    } else if ([button.titleLabel.text isEqualToString:@"聊聊"]){
        [SessionDataOperator otherSystemTurnToSessionWithSender:self andObjectID:self.objectID andSessionType:SessionTypePerson isPopToRootViewController:NO isShowRightButton:YES];
    }
}

#pragma mark --  各种手势按钮点击事件
- (void)getCircleViewHttpCallBack:(NSArray *)arr interface:(LinkedBe_WInterface)interface{
    if (interface == LinkedBe_USER_INVITE) {
        NSDictionary *dic = nil;
        if ([arr count] > 0) {
            dic = [arr objectAtIndex:0];
        }

        if ([dic objectForKey:@"errcode"]) {
            if ([[dic objectForKey:@"errcode"] intValue] ==0) {
                UIButton *button =(UIButton *) [self.view viewWithTag:clickButtonTag];
                button.hidden = YES;
                UILabel *lable = (UILabel *)[self.view viewWithTag:clickButtonTag + (inviteTag - sendTag)];
                lable.hidden = NO;
                [Common checkProgressHUDShowInAppKeyWindow:@"发送邀请成功" andImage: [UIImage imageNamed:@"ico_group_right.png"]];
                
                Circle_member_model *model = [[Circle_member_model alloc]init];
                model.where = [NSString stringWithFormat:@"userId = %lld",self.objectID];
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithLongLong:self.objectID],@"userId",
                                     [NSNumber numberWithInteger:1],@"state",
                                     nil];
                [model updateDB:dic];
                RELEASE_SAFE(model);
                
            }else if([[dic objectForKey:@"errcode"] intValue] ==4006 || [[dic objectForKey:@"errcode"] intValue] ==-1){
                [Common checkProgressHUDShowInAppKeyWindow:[dic objectForKey:@"errmsg"] andImage: [UIImage imageNamed:@"ico_group_wrong.png"]];
            }
            
        } else {
            [Common checkProgressHUDShowInAppKeyWindow:@"网络连接失败，请重试" andImage:[UIImage imageNamed:@"ico_group_wrong.png"]];
        }

    }
}


@end
