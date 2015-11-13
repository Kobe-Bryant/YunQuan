//
//  VerifyViewController.m
//  ql
//
//  Created by yunlai on 14-2-22.
//  Copyright (c) 2014年 ChenFeng. All rights reserved.
//

#import "VerifyViewController.h"
#import "UIImageScale.h"
#import "VerifyTableViewCell.h"
#import "UIImageView+WebCache.h"

#import "Global.h"
#import "UIViewController+NavigationBar.h"
#import "RegisterSetPwdViewController.h"
#import "UserModel.h"
#import "LoginViewController.h"
#import "MobClick.h"

@interface VerifyViewController ()
{
    UITableView *_mainTable;
}
@end

#define kleftPadding 20.f
#define kpadding 15.f

@implementation VerifyViewController
@synthesize inviteeDic = _inviteeDic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"VerifyViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"VerifyViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = RGBACOLOR(249,249,249,1);
    self.title = @"邀请函";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
    
    [self mainView];
}

-(void) backTo{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

/**
 *  主界面布局
 */
- (void)mainView{
    
    _mainTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 40.f, ScreenWidth, 226.f) style:UITableViewStylePlain];
    _mainTable.backgroundColor = [UIColor clearColor];
    _mainTable.delegate = self;
    _mainTable.dataSource = self;
    _mainTable.scrollEnabled = NO;
    [self.view addSubview:_mainTable];
    
    // 信息
    UILabel* _topLabel = [[UILabel alloc]initWithFrame:CGRectMake(10.f, CGRectGetMaxY(_mainTable.frame) + 20, 300.f, 30.f)];
    _topLabel.backgroundColor = [UIColor clearColor];
    _topLabel.text = [NSString stringWithFormat:@"加入  %@",[self.inviteeDic objectForKey:@"orgName"]];
    _topLabel.font = KQLSystemFont(15);
    _topLabel.textAlignment = NSTextAlignmentCenter;
    _topLabel.textColor = [UIColor grayColor];
    [self.view addSubview:_topLabel];
    
    UIButton *verifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [verifyBtn setFrame:CGRectMake(15.f, CGRectGetMaxY(_mainTable.frame) + 70.f, ScreenWidth - 30.f, 40.f)];
    [verifyBtn setTitle:@"接受邀请" forState:UIControlStateNormal];
    [verifyBtn setBackgroundColor:RGBACOLOR(26,161,230,1)];
    [verifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [verifyBtn addTarget:self action:@selector(acceptVerify) forControlEvents:UIControlEventTouchUpInside];
    verifyBtn.layer.cornerRadius = 5;
    [self.view addSubview:verifyBtn];
    RELEASE_SAFE(_topLabel);
    
}

// 接受邀请
- (void)acceptVerify{
    if ([[self.inviteeDic objectForKey:@"registered"] integerValue]==1) {
        LoginViewController *loginVc = [[LoginViewController alloc] init];
        loginVc.mobileString = [self.inviteeDic objectForKey:@"mobile"];
        [self.navigationController pushViewController:loginVc animated:YES];
        [loginVc release];
    }else{
        RegisterSetPwdViewController *setPwd = [[RegisterSetPwdViewController alloc]init];
        setPwd.registerSetDic = self.inviteeDic;
        [self.navigationController pushViewController:setPwd animated:YES];
        RELEASE_SAFE(setPwd);
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 88.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.f;
    }else{
        return 50.f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f,
                                                             ScreenWidth, 50.f)];
    bgView.backgroundColor = [UIColor colorWithRed:232/255.0 green:237/255.0 blue:241/255.0 alpha:1.f];
    
    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(55.f, -15.f, 1.3, 79.f)];
    line.backgroundColor = [UIColor colorWithRed:0/255.0f green:160/255.0 blue:233/255.0 alpha:1.f];
    [bgView addSubview:line];
    [line release];
    
    UIImageView *inviteImg = [[UIImageView alloc]initWithFrame:CGRectMake(40.f, 10.f, 30, 30.f)];
    inviteImg.image = [UIImage imageNamed:@"pic_invite.png"];
    inviteImg.layer.cornerRadius = 15;
    inviteImg.clipsToBounds = YES;
    [bgView addSubview:inviteImg];
    RELEASE_SAFE(inviteImg);
    
    return [bgView autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    VerifyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[VerifyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //保存org_id
            [UserModel shareUser].org_id = [[self.inviteeDic objectForKey:@"invitorOrg"] objectForKey:@"orgId"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (indexPath.section) {
                case 0:
                {
                    //邀请人信息
                    cell.usernameLabel.text = [[self.inviteeDic objectForKey:@"invitorOrg"] objectForKey:@"name"];//[self.inviteeDic objectForKey:@"invitorName"];
                    CGRect frame = cell.usernameLabel.frame;
                    cell.usernameLabel.frame = CGRectMake(frame.origin.x, 30, 200, 30);
                    NSURL *urlImg = [NSURL URLWithString:[self.inviteeDic objectForKey:@"invitorPortrait"]];
                    [cell.headView setImageWithURL:urlImg placeholderImage:IMGREADFILE(DEFAULT_MALE_PORTRAIT)];
                }
                    break;
                case 1:
                {
                    //被邀请人信息
                    cell.usernameLabel.text = [self.inviteeDic objectForKey:@"inviteeName"];
                    cell.userPosition.text = [[self.inviteeDic objectForKey:@"inviteeOrg"] objectForKey:@"name"];
                    cell.headView.image = IMGREADFILE(@"pic_you.png");
                }
                    break;
                default:
                    break;
            }
           
        });
    });
    
    if (IOS7_OR_LATER) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    return cell;
}

- (void)dealloc
{
    RELEASE_SAFE(_mainTable);
    [super dealloc];
}


@end
