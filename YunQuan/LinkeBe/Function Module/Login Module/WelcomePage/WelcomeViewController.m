//
//  WelcomeViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "WelcomeViewController.h"
#import "UIImageView+WebCache.h"
#import "UserModel.h"
#import "Global.h"
#import "AppDelegate.h"
#import "UIViewController+NavigationBar.h"
#import "Userinfo_model.h"
#import "SBJson.h"
#import "UserModel.h"
#import "LinkedBeHttpRequest.h"
#import "SnailSystemiMOperator.h"
#import "MajorCircleManager.h"
#import "MyselfMessageManager.h"
#import "DynamicListManager.h"
#import "TimeStamp_model.h"
#import "NSObject_extra.h"
#import "DBOperate.h"
#import "whole_users_model.h"
#import "TQRichTextView.h"
#import "SnailSocketManager.h"
#import "MobClick.h"

@interface WelcomeViewController (){
    UIImageView* welcomeImageV;
    UILabel* userNameLab;
    TQRichTextView* welcomeContentLab;
    UILabel* invitationName;
    
    UIButton* enterBtn;
}

@end

@implementation WelcomeViewController
@synthesize orgDataDic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBACOLOR(249,249,249,1);

    [self creteaRightButton];
    
    [self initMainView];
//    [self addDataInUI];
}

/**
 *  导航栏右边按钮
 */
- (void)creteaRightButton{
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    backButton.hidden = YES;
//    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [MobClick beginLogPageView:@"WelcomeViewPage"];

}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [MobClick endLogPageView:@"WelcomeViewPage"];
}

-(void) initMainView{
    welcomeImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    welcomeImageV.clipsToBounds = YES;
    if(isIPhone4){
        welcomeImageV.image = [UIImage imageNamed:@"i4_org_welcome.png"];
    }else{
        welcomeImageV.image = [UIImage imageNamed:@"i5_org_welcome.png"];
    }
    
    if ([[self.orgDataDic objectForKey:@"welcome_pic"] length]!=0) {
        if(isIPhone4){
            [welcomeImageV setImageWithURL:[NSURL URLWithString:[self.orgDataDic objectForKey:@"welcome_pic"]] placeholderImage:[UIImage imageNamed:@"i4_org_welcome.png"]];
        }else{
            [welcomeImageV setImageWithURL:[NSURL URLWithString:[self.orgDataDic objectForKey:@"welcome_pic"]] placeholderImage:[UIImage imageNamed:@"i5_org_welcome.png"]];
        }
    }
    [self.view addSubview:welcomeImageV];
    
    UIView *balckContentView = [[UIView alloc] init];
    balckContentView.clipsToBounds = YES;
    balckContentView.layer.cornerRadius = 2.0;
    balckContentView.backgroundColor = RGBACOLOR(58, 58, 58, 0.95);
    [self.view addSubview:balckContentView];
    
    userNameLab = [[UILabel alloc] init];
    userNameLab.frame = CGRectMake(5,5, ScreenWidth-30, 17);
    userNameLab.text = [NSString stringWithFormat:@"欢迎加入%@",[self.orgDataDic objectForKey:@"orgName"]];
    userNameLab.backgroundColor = [UIColor clearColor];
    userNameLab.textColor = [UIColor whiteColor];
    userNameLab.font = KQLboldSystemFont(14);
    [balckContentView addSubview:userNameLab];
    
    welcomeContentLab = [[TQRichTextView alloc] init];
    //设置一个行高上限
    CGSize size = CGSizeMake(ScreenWidth-50,400);
    welcomeContentLab.font = KQLboldSystemFont(13);
    welcomeContentLab.userInteractionEnabled = NO;
    
    NSString *contentString = [NSString stringWithFormat:@"%@",[self.orgDataDic objectForKey:@"welcome_content"]];
    CGSize labelsize = [contentString sizeWithFont:welcomeContentLab.font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    if ([[self.orgDataDic objectForKey:@"welcome_content"] length]!=0) {
        welcomeContentLab.text = [NSString stringWithFormat:@"%@",contentString];
    } else {
        welcomeContentLab.text = @"";
    }
    CGFloat commentSize = [TQRichTextView getRechTextViewHeightWithText:welcomeContentLab.text viewWidth:ScreenWidth-50 font:[UIFont systemFontOfSize:14] lineSpacing:2.5];
    welcomeContentLab.frame = CGRectMake(userNameLab.frame.origin.x + 10, CGRectGetMaxY(userNameLab.frame)+5, ScreenWidth-50, commentSize);
    welcomeContentLab.backgroundColor = [UIColor clearColor];
    welcomeContentLab.textColor = userNameLab.textColor;
    welcomeContentLab.lineSpacing = 2.5;
    [balckContentView addSubview:welcomeContentLab];
    
    invitationName = [[UILabel alloc] init];
    invitationName.frame = CGRectMake(userNameLab.frame.origin.x, CGRectGetMaxY(welcomeContentLab.frame)+5, ScreenWidth-40, 18);
    if ([[self.orgDataDic objectForKey:@"welcome_luokuan"] length]!=0) {
         invitationName.text = [NSString stringWithFormat:@"——%@",[self.orgDataDic objectForKey:@"welcome_luokuan"]];
    } else {
         invitationName.text = @"";
    }
    invitationName.backgroundColor = [UIColor clearColor];
    invitationName.textColor = userNameLab.textColor;
    invitationName.textAlignment = NSTextAlignmentRight;
    invitationName.font = KQLboldSystemFont(14);
    [balckContentView addSubview:invitationName];

     balckContentView.frame = CGRectMake(10, ScreenHeight-160-labelsize.height, ScreenWidth-20, labelsize.height+60);
    
    if ([[self.orgDataDic objectForKey:@"welcome_content"] length] == 0 || [[self.orgDataDic objectForKey:@"welcome_luokuan"] length] == 0) {
        balckContentView.frame = CGRectMake(10, ScreenHeight-160-labelsize.height + 20, ScreenWidth-20, labelsize.height+40);
        userNameLab.frame = CGRectMake(25,(labelsize.height+40 -17)/2, ScreenWidth-30, 17);
    }
    RELEASE_SAFE(balckContentView);
    [self initButtomView];
}

-(void) initButtomView{
    enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    enterBtn.frame = CGRectMake(10, ScreenHeight-90, ScreenWidth-20, 50);
    if ([[self.orgDataDic objectForKey:@"welcome_btn"] length]!=0) {
        [enterBtn setTitle:[NSString stringWithFormat:@"%@",[self.orgDataDic objectForKey:@"welcome_btn"]] forState:UIControlStateNormal];
    }else{
        [enterBtn setTitle:[NSString stringWithFormat:@"进入%@",[self.orgDataDic objectForKey:@"orgName"]] forState:UIControlStateNormal];
    }
    enterBtn.backgroundColor = RGBACOLOR(26,161,230,1);
    enterBtn.titleLabel.font = KQLboldSystemFont(14);
    [enterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enterBtn addTarget:self action:@selector(enterToMain) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:enterBtn];
}

-(void)enterViewController{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate initViewController];
}

- (void)progressHUD{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
    
    proView = [[UIProgressView alloc] initWithFrame:CGRectMake(100, 100, 140, 30)];
    
    [proView setProgressViewStyle:UIProgressViewStyleDefault]; //设置进度条类型
    
	HUD.customView = proView;
	
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;
	
    [HUD show:YES];

    proValue=0;
    
    if (!timer.isValid) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(changeProgress) userInfo:nil repeats:YES];
    }
}

-(void)changeProgress
{
    proValue += 0.3;

    if(proValue > 3)
    {
        //停用计时器
        [timer invalidate];
        timer = nil;
        
        [HUD hide:YES];
    
        [self enterViewController];
    }
    else
    {
        [proView setProgress:(proValue / 3)];//重置进度条
    }
}


-(void) enterToMain{
    if ([Common connectedToNetwork]) {
        [self progressHUD];
        
        //    保存当前的组织id 和用户组织id
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:[[self.orgDataDic objectForKey:@"id"] longLongValue]] forKey:LikedBe_Org_Id];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:[[self.orgDataDic objectForKey:@"orgUserId"] longLongValue]] forKey:LikedBe_OrgUserId];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [UserModel shareUser].org_id = [[NSUserDefaults standardUserDefaults] objectForKey:LikedBe_Org_Id];
        [UserModel shareUser].orgUserId = [[NSUserDefaults standardUserDefaults] objectForKey:LikedBe_OrgUserId];
        
        //插入当前选择的组织id 用于下次自动登录
        NSString * userAccountName = [[NSUserDefaults standardUserDefaults] objectForKey:kPreviousUserName];
        [[NSUserDefaults standardUserDefaults] setObject:[UserModel shareUser].org_id forKey:kPreviousOrgID];
        
        NSNumber * orgIdNumber = [NSNumber numberWithLongLong:[[[UserModel shareUser]org_id] longLongValue]];
        NSDictionary * wholeUpdateDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         userAccountName,@"user_account_name",
                                         orgIdNumber,@"previous_choose_org",
                                         nil];
        
        // 存储当前用户选择组织信息并创建相应的数据库
        [whole_users_model insertOrUpdataUserInfoWithDic:wholeUpdateDic];
        
        //创建用户数据库
        if (![[NSFileManager defaultManager]fileExistsAtPath:[FileManager getUserDBPath]]) {
            [DBOperate createUserDB];
        };
        
        //Modify by snail
        [SnailSocketManager connectToServer];
        
        //  ------------------------------------请求圈子数据--------------------------------------
        MajorCircleManager *manager = [[MajorCircleManager alloc]init];
        LinkedBe_TsType orgts = ORGANIZATIONTS;
        long long orgTs = [TimeStamp_model getTimeStampWithType:orgts];
        NSMutableDictionary *orgDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [UserModel shareUser].org_id,@"orgId",
                                       [UserModel shareUser].orgUserId,@"orgUserId",
                                       [NSNumber numberWithLongLong:orgTs],@"ts",
                                       nil];
        [manager accessThreeOrganization:orgDic];
        
        //----------------------------------请求圈子成员数据--------------------------------------
        MajorCircleManager *memberManager = [[MajorCircleManager alloc]init];
        LinkedBe_TsType memberts = MEMBERTS;
        long long memberTs = [TimeStamp_model getTimeStampWithType:memberts];
        
        NSMutableDictionary *memberDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [UserModel shareUser].org_id,@"orgId",
                                          [UserModel shareUser].user_id,@"userId",
                                          [NSNumber numberWithLongLong:memberTs],@"ts",
                                          nil];
        [memberManager accessOrganizationMembers:memberDic];
        
        //------------------------------------请求我的--------------------------------------
        LinkedBe_TsType myselfTsType = MYSELFINFORPROCESS;
        long long myselfTs = [TimeStamp_model getTimeStampWithType:myselfTsType];
        NSMutableDictionary *selfDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLongLong:myselfTs],@"ts", nil];
        MyselfMessageManager* dlManager = [[MyselfMessageManager alloc] init];
        [dlManager accessMyselfMessageData:selfDic];
        
        //------------------------------------获取用户设置--------------------------------------
        MyselfMessageManager* usManager = [[MyselfMessageManager alloc] init];
        usManager.delegate = nil;
        [usManager accessUserSetInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:[UserModel shareUser].user_id,@"userId", nil]];
        
        //    赋值当前用户的头像和姓名
        Userinfo_model *userInfoModel = [[Userinfo_model alloc]init];
        NSString *dicString = [[[userInfoModel getList] firstObject] objectForKey:@"content"];
        NSDictionary *userinfoDic = [dicString JSONValue];
        
        [UserModel shareUser].realnameString = [userinfoDic objectForKey:@"realname"];
        [UserModel shareUser].portraitString = [userinfoDic objectForKey:@"portrait"];
        
    }else{
        [self alertWithFistButton:@"确定" SencodButton:nil Message:@"网络不给力呀，请稍后重试"];

    }
}

-(void) dealloc{
    RELEASE_SAFE(welcomeImageV);
    RELEASE_SAFE(welcomeContentLab);
    RELEASE_SAFE(userNameLab);
    RELEASE_SAFE(welcomeContentLab);
    RELEASE_SAFE(invitationName);
    [super dealloc];
}
@end
