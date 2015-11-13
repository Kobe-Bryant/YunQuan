//
//  AssignCircleViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

/*
 *------------------说明-----------------
 *circlesArr记录所有二级组织和三级组织，用于填充和获取列表数据
 *indexPaths记录所有二级组织和三级组织在列表中得路径，用于全选
 *secIndexs记录所有得二级组织，用于选中时判断是否是二级组织
 *secAndThreeIndexs记录所有有三级组织得二级组织，和它得子组织，用于找到二级组织得子组织
 *threeIndexs记录所有得三级组织，主要用于把列表中得三级组织背景色弄灰色
 *selectedCircleArr用于记录已选
 */

#import "AssignCircleViewController.h"
#import "Global.h"
#import "AssignCircleCell.h"
#import "UIViewController+NavigationBar.h"
#import "Cicle_org_model.h"
#import "MobClick.h"

@interface AssignCircleViewController ()<UITableViewDataSource,UITableViewDelegate>{
    // 二级或三级层级圈子 btn_group_select_blue.png  btn_group_select_gray.png
    
    NSMutableArray* selectedCircleArr;
    
    NSMutableArray* circlesArr;
    
    UITableView *_assignTableView;
    
    //indexPaths
    NSMutableArray* indexPaths;
    
    //所有二级组织indexPaths
    NSMutableArray* secIndexs;
    
    //二级组织对应得子组织indexPaths
    NSMutableArray* secAndThreeIndexs;
    
    //所有三级组织indexPaths
    NSMutableArray* threeIndexs;
}

//一级组织数据
@property (nonatomic, retain) NSDictionary *firstOrgDic;
//二级组织的数据 （可以根据这个数组是否存在来判断是否为 有层级和没层级）
@property (nonatomic, retain) NSMutableArray *secArray;

@property(nonatomic,retain) UIImageView* iconImage;

@end

@implementation AssignCircleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"圈子";
     
    }
    return self;
}

- (void)dealloc
{
    [selectedCircleArr release];
    
    [circlesArr release];
    
    //indexPaths
    [indexPaths release];
    
    [_assignTableView release];
    
    //所有二级组织indexPaths
    [secIndexs release];
    
    [secAndThreeIndexs release];
    
    [threeIndexs release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [MobClick beginLogPageView:@"AssignCircleViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"AssignCircleViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavBar];//加载导航条
    
    [self loadData]; //加载数据
    
    [self initTableView]; //初始化tableview
    
}

- (void)initTableView {
    _assignTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
//    _assignTableView.backgroundColor = RGBACOLOR(249, 249, 249, 1);
    _assignTableView.backgroundColor = BACKGROUNDCOLOR;
    _assignTableView.delegate = self;
    _assignTableView.dataSource = self;
    _assignTableView.allowsMultipleSelection = YES;
    _assignTableView.tableHeaderView = [self initTableHeader];
    [self.view addSubview:_assignTableView];
}

-(void) initNavBar{
    //返回
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(assignBack) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
    
    //确认
    UIButton* moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(0, 0, 50, 30);
    [moreBtn setTitle:@"确认" forState:UIControlStateNormal];
    [moreBtn setTitleColor:BLUECOLOR forState:UIControlStateNormal];
    moreBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [moreBtn addTarget:self action:@selector(sureClick) forControlEvents:UIControlEventTouchUpInside];
    moreBtn.enabled = NO;
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem release];
}

#pragma mark - back
-(void) assignBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - sure
-(void) sureClick{
    if (_delegate && [_delegate respondsToSelector:@selector(sureCallBack:)]) {
        [_delegate sureCallBack:selectedCircleArr];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)loadData {
    circlesArr = [[NSMutableArray alloc] init];
    
    selectedCircleArr = [[NSMutableArray alloc] init];
    
    secIndexs = [[NSMutableArray alloc] init];
    
    secAndThreeIndexs = [[NSMutableArray alloc] init];
    
    threeIndexs = [[NSMutableArray alloc] init];
    
    //接收外部传入的数据
    if (_selectArr) {
        [selectedCircleArr addObjectsFromArray:_selectArr];
        //选中已选圈子
    }
    
    Cicle_org_model* orgModel = [[Cicle_org_model alloc] init];
    orgModel.where = [NSString stringWithFormat:@"parentId = %d",0];
    self.firstOrgDic = [[orgModel getList] firstObject];
    
    int firOrgId = [[self.firstOrgDic objectForKey:@"id"] intValue];
    orgModel.where = [NSString stringWithFormat:@"parentId = %d",firOrgId];
    orgModel.orderBy = @"position asc,id";
    self.secArray = [orgModel getList];
    
    //三级组织，并插入对应二级下面
    
    int k = 0;
    
    for (int i = 0;i < self.secArray.count;i++) {
        [circlesArr addObject:_secArray[i]];
        [secIndexs addObject:[NSIndexPath indexPathForRow:k inSection:0]];
        
        NSDictionary* secDic = _secArray[i];
        orgModel.where = [NSString stringWithFormat:@"parentId = %d",[[secDic objectForKey:@"id"] intValue]]
        ;
        orgModel.orderBy = @"position asc,id";
        NSArray* tmpArr = [orgModel getList];
        NSMutableArray* thArr = [NSMutableArray arrayWithCapacity:0];
        if (tmpArr.count) {
            [circlesArr addObjectsFromArray:[orgModel getList]];
            
            [thArr addObject:[NSIndexPath indexPathForRow:k inSection:0]];
            
            k++;
            
            for (int j = 0; j < tmpArr.count; j++) {
                
                [thArr addObject:[NSIndexPath indexPathForRow:k inSection:0]];
                
                //三级
                [threeIndexs addObject:[NSIndexPath indexPathForRow:k inSection:0]];
                
                k++;
            }
        }else{
            [thArr addObject:[NSIndexPath indexPathForRow:k inSection:0]];
            k++;
        }
        [secAndThreeIndexs addObject:thArr];
    }
    
    [orgModel release];
    
    [self getAllIndexPath];
    
}

//all indexPath
-(void) getAllIndexPath{
    indexPaths = [[NSMutableArray alloc] init];
    for (int i = 0; i < circlesArr.count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
}

-(UIView*) initTableHeader{
    UIView* headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 60+55)] autorelease];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UIImageView* imageV = [[UIImageView alloc] init];
    UIImage* groupImg = IMGREADFILE(@"group_logo1.png");
    imageV.frame = CGRectMake(15, (60 - groupImg.size.height)/2, groupImg.size.width, groupImg.size.height);
    imageV.image = groupImg;
    [headerView addSubview:imageV];
    [imageV release];
    
    UILabel* firstNameLable = [[UILabel alloc]initWithFrame:CGRectMake(90, 15, 250.f, 30.f)];
    firstNameLable.backgroundColor = [UIColor clearColor];
    firstNameLable.font = [UIFont systemFontOfSize:16.0];
    firstNameLable.textColor = RGBACOLOR(52, 52, 52, 1);
    firstNameLable.text = [self.firstOrgDic objectForKey:@"name"];
    [headerView addSubview:firstNameLable];
    [firstNameLable release];
    
    //直线
    UIImage *lineImg1 = [UIImage imageNamed:@"img_group_underline.png"];
    UIImageView* lineImage1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 60, 320, 0.5)];
    lineImage1.image = lineImg1;
    [headerView addSubview:lineImage1];
    [lineImage1 release];
    
    UIImage *icon = [UIImage imageNamed:@"btn_chat_normal.png"];
    UIImage *highlightedIcon = [UIImage imageNamed:@"btn_chat_set.png"];
    self.iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(15,60 + (55 - icon.size.height)/2 , icon.size.width, icon.size.height)];
    self.iconImage.image = icon;
    self.iconImage.highlightedImage = highlightedIcon;
    [headerView addSubview:self.iconImage];
    
    if (_selectArr == nil) {
        self.iconImage.highlighted = YES;
    }
    
    //部门名称
    UILabel* nameLable = [[UILabel alloc]initWithFrame:CGRectMake(50, 60+12.0, 250.f, 30.f)];
    nameLable.backgroundColor = [UIColor clearColor];
    nameLable.font = [UIFont systemFontOfSize:16.0];
    nameLable.textColor = RGBACOLOR(52, 52, 52, 1);
    nameLable.text = @"全部成员";
    [headerView addSubview:nameLable];
    [nameLable release];
    
    //直线
    UIImage *lineImg = [UIImage imageNamed:@"img_group_underline.png"];
    UIImageView* lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 60 + 55, 320, 0.5)];
    lineImage.image = lineImg;
    [headerView addSubview:lineImage];
    [lineImage release];
    
    UIButton* allButton = [UIButton buttonWithType:UIButtonTypeCustom];
    allButton.backgroundColor = [UIColor clearColor];
    allButton.frame = CGRectMake(0, 60, ScreenWidth, 55);
    [allButton addTarget:self action:@selector(allButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:allButton];
    
    return headerView;
}

#pragma mark - tableview
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return circlesArr.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35.0;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"仅以下成员可见";
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([threeIndexs containsObject:indexPath]) {
        cell.backgroundColor = RGBACOLOR(249, 249, 249, 1);
    }else{
        cell.backgroundColor = [UIColor whiteColor];
    }
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CicleLayerCell";
    AssignCircleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[AssignCircleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSDictionary* dic = [circlesArr objectAtIndex:indexPath.row];
    cell.nameLable.text = [dic objectForKey:@"name"];
    
    if ([selectedCircleArr containsObject:dic]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.iconImage.highlighted = NO;
    
    if ([secIndexs containsObject:indexPath]) {
        for (NSArray* arr in secAndThreeIndexs) {
            if ([arr containsObject:indexPath]) {
                int i = 0;
                for (NSIndexPath* index in arr) {
                    [selectedCircleArr removeObject:[circlesArr objectAtIndex:index.row]];
                    
                    [tableView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
                    if (i != 0 && arr.count != 0) {
                        [selectedCircleArr addObject:[circlesArr objectAtIndex:index.row]];
                    }
                    i++;
                }
            }
        }
        
    }else{
        [selectedCircleArr addObject:[circlesArr objectAtIndex:indexPath.row]];
    }
    
    NSLog(@"--select:%@--",selectedCircleArr);
//    [selectedCircleArr addObject:[circlesArr objectAtIndex:indexPath.row]];
    
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([secIndexs containsObject:indexPath]) {
        for (NSArray* arr in secAndThreeIndexs) {
            if ([arr containsObject:indexPath]) {
                for (NSIndexPath* index in arr) {
                    [tableView deselectRowAtIndexPath:index animated:NO];
                    [selectedCircleArr removeObject:[circlesArr objectAtIndex:index.row]];
                }
            }
        }
        
    }else{
        for (NSArray* arr in secAndThreeIndexs) {
            if ([arr containsObject:indexPath]) {
                NSIndexPath* index = [arr firstObject];
                [tableView deselectRowAtIndexPath:index animated:NO];
                [selectedCircleArr removeObject:[circlesArr objectAtIndex:index.row]];
            }
        }
        
        [selectedCircleArr removeObject:[circlesArr objectAtIndex:indexPath.row]];
    }
    
    NSLog(@"--deselect:%@--",selectedCircleArr);
    
//    [selectedCircleArr removeObject:[circlesArr objectAtIndex:indexPath.row]];
}

#pragma mark - 全部
-(void) allButtonClick{
    self.iconImage.highlighted = !self.iconImage.highlighted;
    if (self.iconImage.highlighted) {
        for (NSIndexPath* indexPath in indexPaths) {
            [_assignTableView deselectRowAtIndexPath:indexPath animated:NO];
        }
        [selectedCircleArr removeAllObjects];
        
    }
}

@end
