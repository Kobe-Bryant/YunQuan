//
//  BusinessHelperViewController.m
//  LinkeBe
//
//  Created by Dream on 14-9-15.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "BusinessHelperViewController.h"
#import "UIViewController+NavigationBar.h"
#import "Global.h"
#import "BusHelperCell.h"
#import "PrivilegeViewController.h"
#import "MajorCircleManager.h"
#import "UserModel.h"
#import "MBProgressHUD.h"
#import "CommonProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "scanViewController.h"
#import "SessionDataOperator.h"
#import "SecretarySingleton.h"
#import "NSObject+SBJson.h"
#import "BrowserViewController.h"
//#import "WarmTipsViewController.h"
#import "MobClick.h"

@interface BusinessHelperViewController ()<MajorCircleManagerDelegate,UITableViewDelegate,UITableViewDataSource> {
    UITableView *_businessHelperTableView;
    
     MBProgressHUD *hudView;
}
@property(nonatomic,retain)NSArray *orgToolsArray;

@end

@implementation BusinessHelperViewController
@synthesize orgToolsArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"商务助手";
    }
    return self;
}

- (void)dealloc
{
    [_businessHelperTableView release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"BusinessHelperViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"BusinessHelperViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
    
    [self creteaBackButton]; //返回按钮
    
    [self initWithTableView]; //初始化tableview

    //    请求商务工具数据
    [self accessToolsList];
}

//请求组织特权的数据
-(void)accessToolsList{
    [self hideHudView];
    
    hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"请稍候..."];
    
    MajorCircleManager *manager = [[MajorCircleManager alloc]init];
    manager.delegate = self;
    [manager accessOrgTools:nil];
}

- (void)initWithTableView {
    _businessHelperTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, self.view.bounds.size.height-64-60) style:UITableViewStylePlain];
    _businessHelperTableView.delegate = self;
    _businessHelperTableView.dataSource = self;
    _businessHelperTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_businessHelperTableView setBackgroundColor:BACKGROUNDCOLOR];
    [self.view addSubview:_businessHelperTableView];
    
     [self initWithBottomButton];
}

//初始化小秘书
//-(void) initButtomView{
//    UIView* btmView = [[UIView alloc] init];
//    if (IOS7_OR_LATER) {
//        btmView.frame = CGRectMake(20, self.view.bounds.size.height - 64 - 60 - 20, self.view.bounds.size.width - 20*2, 60);
//    }else {
//        btmView.frame = CGRectMake(20, self.view.bounds.size.height - 64 - 60 , self.view.bounds.size.width - 20*2, 60);
//    }
//    
//    btmView.backgroundColor = [UIColor clearColor];
//    btmView.layer.borderColor = [UIColor whiteColor].CGColor;
//    btmView.layer.borderWidth = 1.0;
//    btmView.layer.cornerRadius = btmView.bounds.size.height/2;
//    btmView.clipsToBounds = YES;
//    btmView.backgroundColor = [UIColor colorWithRed:149/255.0 green:178/255.0 blue:188/255.0 alpha:1.0];
//    [self.view addSubview:btmView];
//    
//    UIImageView* secImagev = [[UIImageView alloc] init];
//    secImagev.frame = CGRectMake(5, 5, btmView.bounds.size.height - 5*2, btmView.bounds.size.height - 5*2);
//    [secImagev setImage:[UIImage imageNamed:@"kf.jpg"]];
////    [secImagev setImageWithURL:[NSURL URLWithString:[[Global sharedGlobal].secretInfo objectForKey:@"portrait"]] placeholderImage:IMG(@"kf.jpg")];
//    secImagev.layer.cornerRadius = secImagev.bounds.size.height/2;
//    secImagev.clipsToBounds = YES;
//    [btmView addSubview:secImagev];
//    
//    UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(secImagev.frame) + 10, 5, btmView.bounds.size.width - 60 - 30 - 10, btmView.bounds.size.height - 5*2)];
//    lab.backgroundColor = [UIColor clearColor];
//    lab.text = SECpromptText;
//    lab.font = KQLboldSystemFont(14);
//    lab.textColor = [UIColor darkGrayColor];
//    lab.numberOfLines = 2;
//    lab.lineBreakMode = NSLineBreakByWordWrapping;
//    [btmView addSubview:lab];
//    
//    [lab release];
//    
//    UITapGestureRecognizer* tapOnBtm = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTips)];
//    [btmView addGestureRecognizer:tapOnBtm];
//    [tapOnBtm release];
//    
//    [secImagev release];
//    [btmView release];
//}

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
    [MobClick event:@"circle_plugins_secretary"];
    //跳转小秘书
    [SessionDataOperator otherSystemTurnToSessionWithSender:self andObjectID:[SecretarySingleton shareSecretary].secretaryID andSessionType:SessionTypePerson isPopToRootViewController:NO isShowRightButton:NO];
}

#pragma mark -- UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.orgToolsArray.count-1)/2+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   static NSString *identifier = @"BusHelperCell";
    BusHelperCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[BusHelperCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSInteger row = indexPath.row;
    for (NSInteger i = 0; i < 2; i++){
        //奇数
        if (row*2+i>self.orgToolsArray.count-1)
        {
            break;
        }
        NSDictionary* orgToolsdic = [[[self.orgToolsArray objectAtIndex:row*2+ i] objectForKey:@"content"] JSONValue];

        if (i==0) {
            cell.leftView.titleLable.text = [orgToolsdic objectForKey:@"name"];
            cell.leftView.tag = 3000+ row*2 + i;
            [cell.leftView.iconImage setImageWithURL:[orgToolsdic objectForKey:@"img"] placeholderImage:[UIImage imageNamed:@"img_landing_default220.png"]];
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(BusinseeViewTaped:)];
            [cell.leftView addGestureRecognizer:tapRecognizer];
            [tapRecognizer release];
        }else {
            cell.rightView.titleLable.text = [orgToolsdic objectForKey:@"name"];;
            [cell.rightView.iconImage setImageWithURL:[orgToolsdic objectForKey:@"img"] placeholderImage:[UIImage imageNamed:@"img_landing_default220.png"]];
            cell.rightView.tag = 3000+ row*2 + i;
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(BusinseeViewTaped:)];
            [cell.rightView addGestureRecognizer:tapRecognizer];
            [tapRecognizer release];
            
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

#pragma mark -- UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 126.0;
}

#pragma mark --  各种手势按钮点击事件

//无数据页面
-(void) addNoneLabView{
    UILabel* noneLab = [[UILabel alloc] init];
    noneLab.text = @"组织暂未添加商务助手";
    noneLab.frame = CGRectMake(0, 100, self.view.bounds.size.width, 30);
//    noneLab.center = self.view.center;
    noneLab.textAlignment = NSTextAlignmentCenter;
    noneLab.textColor = [UIColor lightGrayColor];
    [self.view addSubview:noneLab];
    [noneLab release];
}


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

- (void)BusinseeViewTaped:(UITapGestureRecognizer *)recognizer {
    NSInteger tag = [recognizer view].tag-3000;
    
    NSDictionary* orgToolsdic = [[[self.orgToolsArray objectAtIndex:tag] objectForKey:@"content"] JSONValue];
    /*
 *  1是本地插件（扫一扫），2为服务端配置本地插件(特权)，3是HTML5插件(微课堂)
 */
    int orgType = [[orgToolsdic objectForKey:@"type"] intValue];
    switch (orgType) {
        case 1:
        {
            //（扫一扫）
            [MobClick event:@"circle_plugins_scan"];
            scanViewController *scanView = [[scanViewController alloc]init];
            [self.navigationController pushViewController:scanView animated:YES];
            RELEASE_SAFE(scanView);
        }
            break;
        case 2:
        {
            //特权
            [MobClick event:@"circle_plugins_privileges"];
            PrivilegeViewController *privilegeVC = [[PrivilegeViewController alloc]init];
            privilegeVC.titleStr = [orgToolsdic objectForKey:@"name"];
            [self.navigationController pushViewController:privilegeVC animated:YES];
            [privilegeVC release];
        }
            break;
        case 3:
        {
            //3是HTML5插件(微课堂)
            [MobClick event:@"circle_plugins_liveapp"];
            BrowserViewController* browserVC = [[BrowserViewController alloc] init];
            browserVC.hidesBottomBarWhenPushed = YES;
            browserVC.pushType = MyselfPush;
            browserVC.webvieUrl = [orgToolsdic objectForKey:@"adminUrl"];
            browserVC.webTitle = @"场景应用";

            [self.navigationController pushViewController:browserVC animated:YES];
            [browserVC release];
        }
            break;
        default:
            break;
    }
}

- (void) hideHudView
{
    if (hudView) {
        [hudView hide:YES];
    }
}
- (void)getCircleViewHttpCallBack:(NSArray *)arr interface:(LinkedBe_WInterface)interface{
    [self hideHudView];
    if (interface == LinkedBe_ORG_TOOLS) {
        if ([arr count]==0) {
            [self addNoneLabView];
        }else {
            self.orgToolsArray = arr;

            [_businessHelperTableView reloadData];
        }
    }
}

@end
