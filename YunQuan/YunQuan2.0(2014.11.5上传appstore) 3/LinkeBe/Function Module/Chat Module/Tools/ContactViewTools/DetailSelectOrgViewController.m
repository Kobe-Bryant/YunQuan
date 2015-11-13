//
//  DetailSelectOrgViewController.m
//  LinkeBe
//
//  Created by Dream on 14-10-21.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "DetailSelectOrgViewController.h"
#import "SecondModel.h"
#import "ThirdModel.h"
#import "AssignCircleCell.h"
#import "Cicle_org_model.h"
#import "Circle_member_model.h"
#import "UIViewController+NavigationBar.h"
#import "Global.h"
#import "MobClick.h"

@interface DetailSelectOrgViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) UITableView *selectOrgTableView;

@property (nonatomic, retain) NSMutableArray *allOrgArray;
@property (nonatomic, retain) NSMutableArray *selectedMembersArray;

@end

@implementation DetailSelectOrgViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"选择组织";
        self.allOrgArray = [[[NSMutableArray alloc]init] autorelease];
        self.selectedMembersArray = [[[NSMutableArray alloc]init] autorelease];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"DetailSelectOrgViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"DetailSelectOrgViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
    [self loadleftButton]; // 返回按钮
    [self loadRightButton];
    
    [self loadData];
    
    [self loadTableView];
    
}

- (void)loadData {
    Cicle_org_model* firModel = [[Cicle_org_model alloc] init];
    firModel.where = [NSString stringWithFormat:@"parentId = 0"];
    firModel.orderBy = @"position asc,id";
    NSDictionary *firstOrgDic = [[firModel getList] firstObject];
    
    long long firOrgId = [[firstOrgDic objectForKey:@"id"] longLongValue];
    //二级组织查询
    firModel.where = [NSString stringWithFormat:@"parentId = %lld",firOrgId];
    NSArray *secArray = [firModel getList];

    if (secArray.count > 0) {
        for (NSDictionary *tempSecDic in secArray) {
            SecondModel *secModel = [[SecondModel alloc]init];
            secModel.orgId = [[tempSecDic objectForKey:@"id"] longLongValue];
            secModel.name = [tempSecDic objectForKey:@"name"];
            secModel.membersArray = [Circle_member_model getActiveMembersWithOrgId:secModel.orgId];
            secModel.selectedState = 0;
            secModel.childrenArray = [NSMutableArray arrayWithCapacity:0];
            [self.allOrgArray addObject:secModel];
            //三级组织查询
            firModel.where = [NSString stringWithFormat:@"parentId = %lld",secModel.orgId];
            firModel.orderBy = @"position asc,id";
            NSArray *thrArray = [firModel getList];
            if (thrArray.count > 0) {
                for (NSDictionary *tempThrDic in thrArray) {
                    ThirdModel *thrModel = [[ThirdModel alloc]init];
                    thrModel.orgId = [[tempThrDic objectForKey:@"id"] longLongValue];
                    thrModel.name = [tempThrDic objectForKey:@"name"];
                    thrModel.membersArray = [Circle_member_model getActiveMembersWithOrgId:thrModel.orgId];
                    thrModel.selectedState = 2;
                    [secModel.childrenArray addObject:thrModel];
                    [self.allOrgArray addObject:thrModel];
                    [thrModel release];
                }
            }
            [secModel release];
        }
    }
    [firModel release];
}

- (void)loadTableView {
    UITableView *tempTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
    tempTableView.backgroundColor = [UIColor clearColor];
    tempTableView.delegate = self;
    tempTableView.dataSource = self;
    tempTableView.allowsMultipleSelection = YES;
    tempTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tempTableView];
    self.selectOrgTableView = tempTableView;
    RELEASE_SAFE(tempTableView);
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allOrgArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"AssignCircleCell";
    AssignCircleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[AssignCircleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    
    OrgModel *orgModel = [self.allOrgArray objectAtIndex:indexPath.row];
    cell.nameLable.text = orgModel.name;
    
    if (orgModel.childrenArray.count > 0) {
        int count = 0;
        for (ThirdModel *thrMol in orgModel.childrenArray) {
            count += thrMol.membersArray.count;
        }
        cell.countLable.text = [NSString stringWithFormat:@"%d",count];
    } else {
        cell.countLable.text = [NSString stringWithFormat:@"%d",orgModel.membersArray.count];
    }
    if (orgModel.selectedState == 0) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.lineImage.frame = CGRectMake(0, 54.5, ScreenWidth, 0.5);

        cell.nameLable.frame = CGRectMake(50, 12.0, 250.f, 30.f);
    } else {
        cell.contentView.backgroundColor = RGBACOLOR(249, 249, 249, 1);
        cell.lineImage.frame = CGRectMake(15, 54.5, ScreenWidth - 15, 0.5);
        cell.nameLable.frame = CGRectMake(65, 12.0, 250.f, 30.f);
    }
    
    return cell;
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [MobClick event:@"chat_select_orgs_selectOrg"];
    
    OrgModel *orgModel = [self.allOrgArray objectAtIndex:indexPath.row];
    if (orgModel.selectedState == 0 ) {
        if (orgModel.childrenArray.count > 0) {
            for (ThirdModel *thrMol in orgModel.childrenArray) {
                for (NSDictionary *dic in thrMol.membersArray) {
                    if (![self.selectedMembersArray containsObject:dic]) {
                        [self.selectedMembersArray addObject:dic];
                    }
                }
            }
            
            for (int i = 0; i < self.allOrgArray.count; i ++) {
                ThirdModel *thrModel = [self.allOrgArray objectAtIndex:i];
                if ([orgModel.childrenArray containsObject:thrModel]) {
                    thrModel.selectedState = 3;
                     NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
                     [tableView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
        } else {//没有三级组织的情况
            [self.selectedMembersArray addObjectsFromArray:orgModel.membersArray];
        }
    } else { //点击的是三级组织
        orgModel.selectedState = 3; //表示三级被选中
        
        if (orgModel.membersArray.count > 0) {
            [self.selectedMembersArray addObjectsFromArray:orgModel.membersArray];
        }
        for (int i = 0; i < self.allOrgArray.count; i ++) {
            SecondModel *secModel = [self.allOrgArray objectAtIndex:i];
            if ([secModel.childrenArray containsObject:orgModel]){
                if ([SecondModel secondOrgIsSelected:secModel.childrenArray]) {
                    NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
                    [tableView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
                } else {
                    NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
                    [tableView deselectRowAtIndexPath:index animated:NO];
                }
            }
        }
    }
    [self loadRightButton];
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    OrgModel *orgModel = [self.allOrgArray objectAtIndex:indexPath.row];
    if (orgModel.selectedState == 0 ) {
        if (orgModel.childrenArray.count > 0) {
            for (ThirdModel *thrMol in orgModel.childrenArray) {
                [self.selectedMembersArray removeObjectsInArray:thrMol.membersArray];
            }
            
            for (int i = 0; i < self.allOrgArray.count; i ++) {
                ThirdModel *thrModel = [self.allOrgArray objectAtIndex:i];
                if ([orgModel.childrenArray containsObject:thrModel]) {
                    thrModel.selectedState = 2;
                    NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
                    [tableView deselectRowAtIndexPath:index animated:NO];
                }
            }
        } else { //没有三级组织的情况
            [self.selectedMembersArray removeObjectsInArray:orgModel.membersArray];
        }
    } else { //点击的是三级组织
        orgModel.selectedState = 2; //表示三级被取消
        
        if (orgModel.membersArray.count > 0) {
            [self.selectedMembersArray removeObjectsInArray:orgModel.membersArray];
        }
        for (int i = 0; i < self.allOrgArray.count; i ++) {
            SecondModel *secModel = [self.allOrgArray objectAtIndex:i];
            if ([secModel.childrenArray containsObject:orgModel]){

                if ([SecondModel secondOrgIsSelected:secModel.childrenArray]) {
                    NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
                    [tableView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
                } else {
                    NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
                    [tableView deselectRowAtIndexPath:index animated:NO];
                }
            }
        }
    }
    [self loadRightButton];
}


#pragma mark - UINavigationItem

//返回按钮
- (void)loadleftButton{
    //返回按钮
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
}

//右按钮
- (void)loadRightButton {
    UIButton* moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreBtn setTitleColor:BLUECOLOR forState:UIControlStateNormal];
    moreBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    moreBtn.frame = CGRectMake(0, 0, 60, 30);
    if (self.selectedMembersArray.count == 0) {
        [moreBtn setTitle:@"确认(0)" forState:UIControlStateNormal];
    } else {
        [moreBtn setTitle:[NSString stringWithFormat:@"确定(%d)",self.selectedMembersArray.count] forState:UIControlStateNormal];
    }
    [moreBtn addTarget:self action:@selector(sureClick) forControlEvents:UIControlEventTouchUpInside];
    moreBtn.enabled = NO;
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem release];
    
}

- (void)backTo {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sureClick {
    if (self.selectedMembersArray.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"有效成员不足，无法创建群聊" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    } else {
        if (self.selectedMembersArray.count > 100) {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"人数已满" message:@"圈子人员数已达上限100人" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            RELEASE_SAFE(alertView);
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(CallBackSureSelect:)]) {
                [self.navigationController popViewControllerAnimated:NO];
                [self.delegate CallBackSureSelect:self.selectedMembersArray];
            }
        }
    }
}

- (void)dealloc
{
    self.selectedMembersArray = nil;
    self.allOrgArray = nil;
    self.selectOrgTableView = nil;
    [super dealloc];
}


@end
