//
//  PublishPermissionViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "PublishPermissionViewController.h"

#import "DynamicCommon.h"
#import "PermissionCell.h"
#import "Dynamci_permission_model.h"

#import "UIViewController+NavigationBar.h"

#import "SessionViewController.h"
#import "MessageListData.h"

#import "OthersBusinessCardViewController.h"
#import "SelfBusinessCardViewController.h"
#import "MobClick.h"

@interface PublishPermissionViewController ()<PermissionCellDelegate>

@end

@implementation PublishPermissionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [MobClick beginLogPageView:@"PublishPermissionViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"PublishPermissionViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = YES;
    }
    
    self.title = @"发布动态";
    
    self.view.backgroundColor = BACKGROUNDCOLOR;
    
    [self initNavBar];
    
    [self getPermissionMembersData];
    
    [self initMainView];
    
	// Do any additional setup after loading the view.
}

//导航条
-(void) initNavBar{
    //返回
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(permissionBack) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
}

-(void) permissionBack{
    [self.navigationController popViewControllerAnimated:YES];
}

//获取有权限得数据
-(void) getPermissionMembersData{
    userArr = [[NSMutableArray alloc] init];
    [userArr addObjectsFromArray:[Dynamci_permission_model getPermissionMembers]];
}

//加载视图
-(void) initMainView{
    //table头部
    UIView* headView = [[UIView alloc] init];
    headView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 140);
    headView.backgroundColor = [UIColor clearColor];
    
    //警告图片
    UIImageView* alertImgV = [[UIImageView alloc] init];
    alertImgV.frame = CGRectMake((self.view.bounds.size.width - 50)/2, 25, 50, 50);
    alertImgV.image = IMGREADFILE(DynamicPic_permission_cue);
    [headView addSubview:alertImgV];
    
    //文本
    UILabel* alertLab1 = [[UILabel alloc] init];
    alertLab1.frame = CGRectMake(0, CGRectGetMaxY(alertImgV.frame) + 15, self.view.bounds.size.width, 20);
    alertLab1.font = [UIFont boldSystemFontOfSize:15];
    alertLab1.textColor = DynamicCardTextColor;
    alertLab1.textAlignment = NSTextAlignmentCenter;
//    alertLab1.text = @"发布动态权限暂未全员开放";点击聊聊，朋友代劳
    alertLab1.text = @"点 击 聊 聊 ， 朋 友 代 劳";
    alertLab1.backgroundColor = [UIColor clearColor];
    [headView addSubview:alertLab1];
    
//    UILabel* alertLab2 = [[UILabel alloc] init];
//    alertLab2.frame = CGRectMake(0, CGRectGetMaxY(alertLab1.frame), self.view.bounds.size.width, 20);
//    alertLab2.font = [UIFont boldSystemFontOfSize:15];
//    alertLab2.textColor = DynamicCardTextColor;
//    alertLab2.textAlignment = NSTextAlignmentCenter;
////    alertLab2.text = @"您可联系下面几个朋友代发";
//    alertLab2.backgroundColor = [UIColor clearColor];
//    [headView addSubview:alertLab2];
    
    [alertImgV release];
    [alertLab1 release];
//    [alertLab2 release];
    
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStyleGrouped];
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.backgroundColor = [UIColor clearColor];
    
    if (IOS7_OR_LATER) {
        tableview.separatorInset = UIEdgeInsetsMake(0, -20, 0, 0);
    }
    
    tableview.tableHeaderView = headView;
    [headView release];
    
    [self.view addSubview:tableview];
}

#pragma mark - tableview
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return userArr.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.0;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* permissionCellIden = @"permsCell";
    PermissionCell* cell = [tableview dequeueReusableCellWithIdentifier:permissionCellIden];
    if (cell == nil) {
        cell = [[[PermissionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:permissionCellIden] autorelease];
        
    }
    
    [cell writePermissionDataInCell:[userArr objectAtIndex:indexPath.row]];
    cell.delegate = self;
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableview deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - perssionCell
-(void) chatClickWithUserInfo:(NSDictionary *)userInfo{
    //进入聊天
    [self turnToSession:userInfo];
}

-(void) headClickWithUserId:(NSDictionary*) userInfo{
    //点击跳转名片页
    if ([[userInfo objectForKey:@"userId"] intValue] == [[UserModel shareUser].user_id intValue]) {
        SelfBusinessCardViewController *selfBusinessVC = [[SelfBusinessCardViewController alloc]init];
        [self.navigationController pushViewController:selfBusinessVC animated:YES];
        [selfBusinessVC release];
    } else {
        OthersBusinessCardViewController *otherBusinessVC = [[OthersBusinessCardViewController alloc]init];
        otherBusinessVC.orgUserId = [userInfo objectForKey:@"orgUserId"];
        [self.navigationController pushViewController:otherBusinessVC animated:YES];
        [otherBusinessVC release];
    }
}

#pragma mark - 跳转聊天
-(void) turnToSession:(NSDictionary*) dic{
    [MobClick event:@"feed_privilege_chat"];
    
    MessageListData * turnListData = [MessageListData generateOriginListDataWithObjectID:[[dic objectForKey:@"userId"] longLongValue] andSessionType:SessionTypePerson];
    
    SessionViewController * sessionViewController = [[SessionViewController alloc]init];
    sessionViewController.listData = turnListData;
//    sessionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self.navigationController pushViewController:sessionViewController animated:YES];
    RELEASE_SAFE(sessionViewController);
}

#pragma mark - http
-(void) accessPermissionUsers{
    
}

-(void)didFinishCommand:(NSDictionary *)jsonDic cmd:(int)commandid withVersion:(int)ver{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc{
    [tableview release];
    [userArr release];
    
    [super dealloc];
}

@end
