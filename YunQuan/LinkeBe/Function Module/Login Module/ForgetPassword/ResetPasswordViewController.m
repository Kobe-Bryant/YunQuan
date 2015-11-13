//
//  ResetPasswordViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-22.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "Global.h"
#import "UIViewController+NavigationBar.h"
#import "LoginTableViewCell.h"
#import "MBProgressHUD.h"
#import "CommonProgressHUD.h"
#import "NSObject_extra.h"
#import "LoginMessageDataManager.h"
#import "LoginSendClientMessage.h"
#import "Common.h"
#import "ChooseOrganizationViewController.h"
#import "chooseOrg_model.h"
#import "WelcomeViewController.h"
#import "MobClick.h"

@interface ResetPasswordViewController ()<LoginMessageDataManagerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    UITableView *_tableView;
    
    UIButton *_loginBtn;
    
    MBProgressHUD *hudView;
}
@property (nonatomic,retain) UITextField *userNameField;
@property (nonatomic,retain) UITextField *pwdField;
@property(nonatomic,retain)NSArray *orgArray;

@end

@implementation ResetPasswordViewController
@synthesize userNameField,pwdField;
@synthesize mobileString;
@synthesize orgArray;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"ResetPasswordViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"ResetPasswordViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBACOLOR(249,249,249,1);

    self.title = @"重置密码";
    
    //点击退出键盘
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resigns)];
    [self.view addGestureRecognizer:closeTap];
    [closeTap release];
    
    [self creteaRightButton];
    
     [self mainView];
}

/**
 *  主界面
 */
- (void)mainView{
    UILabel *tipLablel = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, ScreenWidth, 20.0)];
    tipLablel.text = @"验证成功！请设置新密码";
    tipLablel.font = [UIFont systemFontOfSize:12.0];
    tipLablel.textAlignment = NSTextAlignmentLeft;
    tipLablel.textColor = [UIColor grayColor];
    [self.view addSubview:tipLablel];
    [tipLablel release];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0.f,50.f, ScreenWidth, 100.f)style:UITableViewStylePlain];
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    
    UILabel *tip = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(_tableView.frame) + 5, 230.f, 20.f)];
    tip.text = @"6-20位数字或字母组合,区分大小写";
    tip.font = KQLSystemFont(13);
    tip.textAlignment = NSTextAlignmentLeft;
    tip.textColor = [UIColor grayColor];
    tip.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tip];
    [tip release];
    
    // 登录按钮
    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginBtn.frame = CGRectMake(15, CGRectGetMaxY(_tableView.frame) + 45, ScreenWidth - 15 *2, 40.f);
    [_loginBtn setTitle:@"登  录" forState:UIControlStateNormal];
    _loginBtn.layer.cornerRadius = 3;
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginBtn setBackgroundColor:RGBACOLOR(26,161,230,1)];
    if (_loginBtn.state == UIControlStateHighlighted) {
        [_loginBtn setBackgroundColor:[UIColor colorWithRed:50/255.0 green:96/255.0 blue:188/255.0 alpha:1]];
    }
    [_loginBtn addTarget:self action:@selector(resetPwdAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
}


//重置密码
-(void)resetPwdAction{
    if ([Common connectedToNetwork]) {
        [self resigns];
        if ([self checkForm]) {
            [self hideHudView];
            
            NSMutableDictionary* requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.userNameField.text,@"username",
                                               self.pwdField.text,@"password",
                                               nil];
            LoginMessageDataManager* dlManager = [[LoginMessageDataManager alloc] init];
            dlManager.delegate = self;
            [dlManager acessResetPassword:requestDic];
        }
    }else{
        [self alertWithFistButton:@"确定" SencodButton:nil Message:@"网络不给力呀，请稍后重试"];
    }
}


/*
 *表单验证
 */

- (BOOL)checkForm {
    if ([self.userNameField.text isEqualToString:@""]||[self.userNameField.text isEqualToString:nil]||[self.userNameField.text length] == 0) {
        
        [self alertWithFistButton:nil SencodButton:@"确定" Message:@"账号不能为空！"];
        
        [self.userNameField becomeFirstResponder];
        
        return FALSE;
    }else if ([self.pwdField.text isEqualToString:@""]||[self.pwdField.text isEqualToString:nil]||[self.pwdField.text length] == 0) {
        
        [self alertWithFistButton:nil SencodButton:@"确定" Message:@"密码不能为空！"];
        
        [self.pwdField becomeFirstResponder];
        
        return FALSE;
    }else if ([self.pwdField.text length]<6||![self isValidPwdNumber:self.pwdField.text]) {
        
        [self alertWithFistButton:nil SencodButton:@"确定" Message:@"请设置6-20位数字或字母组合密码"];
        
        [self.pwdField becomeFirstResponder];
        
        return FALSE;
    } else{
        return TRUE;
    }
}

/**
 *  登录
 */
- (void)loginAction
{
    [self resigns];
    if ([self checkForm]) {
        [self hideHudView];
        hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"请稍候..."];
        
        NSMutableDictionary* requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.userNameField.text,@"username",
                                           self.pwdField.text,@"password",
                                           @"1",@"type",
                                           [self getUuidString],@"uuid",
                                           [[NSUserDefaults standardUserDefaults] objectForKey:LINKEDBE_TOKEN_KEY],@"token",
                                           nil];
        
        LoginMessageDataManager* dlManager = [[LoginMessageDataManager alloc] init];
        dlManager.delegate = self;
        [dlManager accessLoginMessageData:requestDic requestType:LinkedBe_POST];
    }
}

/*
 *键盘消失
 */
-(void)resigns{
    [self.userNameField resignFirstResponder];
    [self.pwdField resignFirstResponder];
}

/**
 *  导航栏右边按钮
 */
- (void)creteaRightButton{
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
}

- (void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//显示密码
-(void)clearPwdBtn:(UIGestureRecognizer *) gestureRecognizer{
    if (self.pwdField.secureTextEntry) {
        self.pwdField.secureTextEntry = NO;
    }else{
        self.pwdField.secureTextEntry = YES;
    }
}

-(void)chooseOrgOrWelcome{
    chooseOrg_model *orgMod = [[chooseOrg_model alloc]init];
    orgMod.where = nil;
    self.orgArray = [orgMod getList];
    RELEASE_SAFE(orgMod);
    
    if ([self.orgArray count]==1) {
        [self enterWelcomeViewController];
    }else{
        //  选择组织
        [self chooseOrgination];
    }
}

//选择组织
-(void)chooseOrgination{
    ChooseOrganizationViewController *chooseOrganizationVc = [[ChooseOrganizationViewController alloc] init];
    chooseOrganizationVc.orgArr = self.orgArray;
    [self.navigationController pushViewController:chooseOrganizationVc animated:YES];
    RELEASE_SAFE(chooseOrganizationVc);
}

//进入欢迎页面
- (void)enterWelcomeViewController
{
    WelcomeViewController* welcomVc = [[WelcomeViewController alloc] init];
    welcomVc.orgDataDic = [self.orgArray objectAtIndex:0];
    [self.navigationController pushViewController:welcomVc animated:NO];
    RELEASE_SAFE(welcomVc);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)sendLoginClientId{
    
    LoginSendClientMessage* sendClientMessage = [[LoginSendClientMessage alloc] init];
    [sendClientMessage accessLoginSendClientMessageData:nil requestType:LinkedBe_POST];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    LoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[LoginTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.contentView.backgroundColor =  [UIColor whiteColor];
        
    }
    switch (indexPath.row) {
        case 0:
        {
            self.userNameField = cell.loginField;
            //            self.userNameField.delegate=self;
            [self.userNameField setClearButtonMode:UITextFieldViewModeWhileEditing];
            self.userNameField.keyboardType = UIKeyboardTypeNumberPad;
            self.userNameField.placeholder = @"请输入手机号码";
            self.userNameField.tag = 1;
            self.userNameField.keyboardType = UIKeyboardTypeNumberPad;
            [self.userNameField becomeFirstResponder];
            self.userNameField.text = self.mobileString;
            self.userNameField.enabled = NO;
            cell.ico_clearImageView.hidden = YES;
            cell.textLabel.text = @"账号";
        }
            break;
            
        case 1:
        {
            self.pwdField = cell.loginField;
            self.pwdField.delegate=self;
            self.pwdField.placeholder = @"请输入密码";
            self.pwdField.tag = 2;
            [self.pwdField setClearButtonMode:UITextFieldViewModeWhileEditing];
            self.pwdField.keyboardType = UIKeyboardTypeNumberPad;
            self.pwdField.secureTextEntry = YES;
            self.pwdField.keyboardType = UIKeyboardTypeDefault;
            cell.ico_clearImageView.hidden = YES;
            cell.textLabel.text = @"新密码";
            
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearPwdBtn:)];
            [cell.ico_clearImageView addGestureRecognizer:tap];
            [tap release];
            
        }
            break;
            
        default:
            break;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    [cell.textLabel setBackgroundColor:[UIColor grayColor]];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (IOS7_OR_LATER) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    return cell;
}

- (void) hideHudView
{
    if (hudView) {
        [hudView hide:YES];
    }
}

//LoginMessageDataManagerdelete
-(void)getLoginMessageHttpCallBack:(NSArray*) arr requestCallBackDic:(NSDictionary *)dic interface:(LinkedBe_WInterface) interface{
    //过滤请求结果
    [self hideHudView];
    switch (interface) {
        case LinkedBe_USER_Login:
        {
            if ([dic objectForKey:@"errcode"]!=0) {
                [self alertWithFistButton:@"确定" SencodButton:nil Message:[dic objectForKey:@"errmsg"]];
            }else{
                //获取到当前的客户端的id和秘钥以后去请求token
                [self sendLoginClientId];
                
                /*
                 *          判断当前的用户是在几个组织里面 然后分别显示不同地方
                 */
                [self chooseOrgOrWelcome];
//                //  选择组织
//                [self chooseOrgination];
            }
        }
            break;
        case LinkedBe_Token_Secert:
        {
            //保存当前的用户的userid
        }
            break;
        case LinkedBe_ResetPassword://重置密码
        {
            if ([[dic objectForKey:@"errcode"] integerValue] == 0) {
                [self loginAction];
            }
        }
            break;
        default:
        break;
    }
}

#pragma mark - UITextFieldDelegate
#pragma mark - UITextFieldDelegate
// 键盘return按钮监听
//- (BOOL)textFieldShouldReturn:(UITextField *)textField{
//    return YES;
//}

//输入框开始编辑回调
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == self.pwdField) {
        LoginTableViewCell *cell = (LoginTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        cell.ico_clearImageView.hidden = NO;
    }
}

@end
