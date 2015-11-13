//
//  PrivilegeViewController.m
//  LinkeBe
//
//  Created by Dream on 14-9-15.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "PrivilegeViewController.h"
#import "UIViewController+NavigationBar.h"
#import "PrivilegeHeaderView.h"
#import "PrivilegeCell.h"
#import "Global.h"
#import "PrivilegeDetailViewController.h"
#import "CommonProgressHUD.h"
#import "MajorCircleManager.h"
#import "Userinfo_model.h"
#import "SBJson.h"
#import "UIImageView+WebCache.h"
#import "SessionDataOperator.h"
#import "SecretarySingleton.h"
#import "MobClick.h"

@interface PrivilegeViewController ()<MajorCircleManagerDelegate,UITableViewDelegate,UITableViewDataSource>{
    
    UITableView *_privilegeTableView;
    NSArray *_backImageArray;//   背景图片
    NSArray *_iconImageArray; // 标签图组

    NSArray *privilegeArray;
    MBProgressHUD *hudView;
    PrivilegeHeaderView *headerView;
}
@property(nonatomic,retain)NSArray *privilegeArray;
@end

@implementation PrivilegeViewController
@synthesize titleStr;
@synthesize privilegeArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"特权列表";
        
        _backImageArray = [[NSArray alloc] initWithObjects:
                     @"bg_tool_blue",
                     @"bg_tool_orange",
                     @"bg_tool_oray",
                     nil];
        _iconImageArray = [[NSArray alloc] initWithObjects:
                  @"ico_tool_discount",
                  @"img_tool_free",
                  @"ico_tool_card",
                  nil];
        
    }
    return self;
}

- (void)dealloc
{
    [_backImageArray release];
    [_iconImageArray release];
    [_privilegeTableView release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"PrivilegeViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"PrivilegeViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self creteaBackButton]; //返回按钮
    
    [self accessPrivilege];
    
    [self initWithTableView]; //初始化tableview
    
    [self initWithBottomButton];
}

//请求组织特权
-(void)accessPrivilege{
    [self hideHudView];
    hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"请稍候..."];
    NSMutableDictionary *privilegeDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [UserModel shareUser].org_id,@"orgId",
                                   [UserModel shareUser].user_id,@"userId",
                                   @"0",@"ts",
                                   nil];
    MajorCircleManager *manager = [[MajorCircleManager alloc]init];
    manager.delegate = self;
    [manager accessSystemPrivilege:privilegeDic];
}

- (void)initWithTableView {
    _privilegeTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight - 64- 60) style:UITableViewStylePlain];
    _privilegeTableView.delegate = self;
    _privilegeTableView.dataSource = self;
    _privilegeTableView.tableHeaderView = [self initWithHeaderView];
    _privilegeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_privilegeTableView setBackgroundColor:BACKGROUNDCOLOR];
    [self.view addSubview:_privilegeTableView];
}

- (void)initWithBottomButton {
    UIButton *bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (IOS7_OR_LATER) {
        bottomBtn.frame = CGRectMake(0, self.view.bounds.size.height - 64 - 60, self.view.bounds.size.width, 60);
    } else {
        bottomBtn.frame = CGRectMake(0, self.view.bounds.size.height - 64 - 40, self.view.bounds.size.width, 60);
    }
    bottomBtn.backgroundColor = [UIColor whiteColor];
    bottomBtn.layer.borderWidth = 0.5f;
    bottomBtn.layer.borderColor = RGBACOLOR(200, 200, 200, 1).CGColor;
    //    [bottomBtn setFrame:CGRectMake(0.f, ScreenHeight - 64 - 50, ScreenWidth, 50.f)];
    [bottomBtn setImage:[UIImage imageNamed:@"ico_common_chat62.png"] forState:UIControlStateNormal];
    [bottomBtn setTitle:@"还想要什么特权？请戳这儿吧！" forState:UIControlStateNormal];
    [bottomBtn setTitleColor:RGBACOLOR(0, 160, 233, 1) forState:UIControlStateNormal];
    [bottomBtn addTarget:self action:@selector(bottomBtnSend) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomBtn];
}

//跳转小秘书
-(void) bottomBtnSend{
    //跳转小秘书
    [SessionDataOperator otherSystemTurnToSessionWithSender:self andObjectID:[SecretarySingleton shareSecretary].secretaryID andSessionType:SessionTypePerson isPopToRootViewController:NO isShowRightButton:NO];
}


- (UIView *) initWithHeaderView {
    headerView = [[PrivilegeHeaderView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 200)];
    return headerView;
}

-(void)loadHeaderData{
    NSString* imagePath = [UserModel shareUser].privilegeBigImage;
    
    [headerView.bgImageView setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:@"img_landing_default220.png"]];
    
    Userinfo_model *userInfoModel = [[Userinfo_model alloc]init];
    NSString *dicString = [[[userInfoModel getList] firstObject] objectForKey:@"content"];
    
    headerView.nameLable.text = [[dicString JSONValue] objectForKey:@"realname"];
    
    if ([[[dicString JSONValue] objectForKey:@"sex"] intValue] == 0) {
        [headerView.iconImage setImageWithURL:[NSURL URLWithString:[[dicString JSONValue] objectForKey:@"portrait"]] placeholderImage:[UIImage imageNamed:@"ico_default_portrait_male.png"]]; //成员头像
    }else{
        [headerView.iconImage setImageWithURL:[NSURL URLWithString:[[dicString JSONValue] objectForKey:@"portrait"]] placeholderImage:[UIImage imageNamed:@"ico_default_portrait_female.png"]]; //成员头像
    }
        
    headerView.positionLable.text = [[dicString JSONValue] objectForKey:@"companyRole"];;
}

#pragma mark -- UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.privilegeArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"PrivilegeCell";
    PrivilegeCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[PrivilegeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dic = [[[self.privilegeArray objectAtIndex:indexPath.row] objectForKey:@"content"] JSONValue];
    cell.backImage.image = [UIImage imageNamed:_backImageArray[indexPath.row%3]];
    cell.iconImage.image = [UIImage imageNamed:_iconImageArray[indexPath.row%3]];
    cell.titleLable.text = [dic objectForKey:@"title"];
    
    return cell;
}

#pragma mark -- UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PrivilegeDetailViewController *privilegeDetailVC = [[PrivilegeDetailViewController alloc]init];
    privilegeDetailVC.privilegeDetailDic = [[[self.privilegeArray objectAtIndex:indexPath.row] objectForKey:@"content"] JSONValue];//[self.privilegeArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:privilegeDetailVC animated:YES];
    [privilegeDetailVC release];

}

#pragma mark --  各种手势按钮点击事件

//返回按钮
- (void)creteaBackButton{
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
}

- (void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) hideHudView
{
    if (hudView) {
        [hudView hide:YES];
    }
}

- (void)getCircleViewHttpCallBack:(NSArray *)arr interface:(LinkedBe_WInterface)interface{
    [self hideHudView];
    if (interface == LinkedBe_SYSTEM_PRIVILEGE) {
        
        self.privilegeArray = arr;
        
        [self loadHeaderData];
        [_privilegeTableView reloadData];
    }
}
@end
