//
//  LoginViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "LoginViewController.h"
#import "Global.h"
#import "UIViewController+NavigationBar.h"
#import "LoginTableViewCell.h"
#import "ForgetPasswordViewController.h"
#import "NSObject_extra.h"
#import "LinkedBeHttpRequest.h"
#import "LoginMessageDataManager.h"
#import "CommonProgressHUD.h"
#import "MBProgressHUD.h"
#import "ChooseOrganizationViewController.h"
#import "UserModel.h"
#import "LoginSendClientMessage.h"
#import "Common.h"
#import "chooseOrg_model.h"
#import "WelcomeViewController.h"
#import "MobClick.h"

@interface LoginViewController ()<LoginMessageDataManagerDelegate,UITextFieldDelegate>
{
    UITableView *_tableView;
    
    UIButton *_loginBtn;
    
    MBProgressHUD *hudView;
}
@property (nonatomic,retain) UITextField *userNameField;
@property (nonatomic,retain) UITextField *pwdField;
@property (nonatomic, retain) NSString *userNameStr;


@property(nonatomic,retain)NSArray *orgArray;

@end

@implementation LoginViewController
@synthesize userNameField,pwdField;
@synthesize orgArray;
@synthesize mobileString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [MobClick beginLogPageView:@"LoginViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"LoginViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBACOLOR(249,249,249,1);
    self.title = @"登录";
    
    [self creteaRightButton];
    
    [self mainView];
    
    //点击退出键盘
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeKeyBoard)];
    [self.view addGestureRecognizer:closeTap];
    [closeTap release];
}

/**
 *  主界面
 */
- (void)mainView{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0.f,40.f, ScreenWidth, 100.f)style:UITableViewStylePlain];
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    // 忘记密码
    UIButton *_forgetPwd = [UIButton buttonWithType:UIButtonTypeCustom];
    _forgetPwd.frame = CGRectMake(10, _tableView.frame.size.height+_tableView.frame.origin.y+8, 60, 25);
    [_forgetPwd setTitle:@"忘记密码" forState:UIControlStateNormal];
    [_forgetPwd setBackgroundColor:[UIColor clearColor]];
    _forgetPwd.titleLabel.font = KQLSystemFont(12);
    [_forgetPwd setTitleColor:RGBACOLOR(26,161,230,1) forState:UIControlStateNormal];
    [_forgetPwd addTarget:self action:@selector(forgetPwdClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_forgetPwd];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, _forgetPwd.frame.size.height+_forgetPwd.frame.origin.y-6, 50, 1)];
    lineLabel.backgroundColor = RGBACOLOR(26,161,230,1);
    [self.view addSubview:lineLabel];
    [lineLabel release];
    
    
    // 登录按钮
    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginBtn.frame = CGRectMake(15, CGRectGetMaxY(_tableView.frame) + 55, ScreenWidth - 15 *2, 48.f);
    [_loginBtn setTitle:@"登  录" forState:UIControlStateNormal];
    _loginBtn.layer.cornerRadius = 3;
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginBtn setBackgroundColor:RGBACOLOR(28,145,233,1)];
    if (_loginBtn.state == UIControlStateHighlighted) {
        [_loginBtn setBackgroundColor:[UIColor colorWithRed:50/255.0 green:96/255.0 blue:188/255.0 alpha:1]];
    }
    [_loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
    
}

/*
 *表单验证
 */

- (BOOL)checkForm {
    //6-20位由字母 数字 组成判断
    NSString *regex = @"^[A-Za-z0-9]{6,20}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([self.userNameField.text isEqualToString:@""]||[self.userNameField.text isEqualToString:nil]||[self.userNameField.text length] == 0) {
                
        [self alertWithFistButton:nil SencodButton:@"确定" Message:@"账号不能为空！"];
        
        [self.userNameField becomeFirstResponder];
        
        return FALSE;
    }else if ([self.pwdField.text isEqualToString:@""]||[self.pwdField.text isEqualToString:nil]||[self.pwdField.text length] == 0) {
        
        [self alertWithFistButton:nil SencodButton:@"确定" Message:@"密码不能为空！"];
        
        [self.pwdField becomeFirstResponder];
        
        return FALSE;
    } else if (![pred evaluateWithObject:self.pwdField.text]) {
        
        [self alertWithFistButton:nil SencodButton:@"确定" Message:@"帐号或密码错误，请重新输入"];
        
        [self.pwdField becomeFirstResponder];
        
        return FALSE;
    } else {
        return TRUE;
    }
}

/**
 *  关闭键盘
 */
- (void)closeKeyBoard {
    [self.userNameField resignFirstResponder];
    [self.pwdField resignFirstResponder];
}

/**
 *  登录
 */
- (void)loginAction
{
    if ([Common connectedToNetwork]) {
        [self resigns];
        if ([self checkForm]) {
            [self hideHudView];
            hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"登录中..."];
            
            NSMutableDictionary* requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.userNameField.text,@"username",
                                               self.pwdField.text,@"password",
                                               @"0",@"type",
                                               [self getUuidString],@"uuid",
                                               [[NSUserDefaults standardUserDefaults] objectForKey:LINKEDBE_TOKEN_KEY],@"token",
                                               nil];
            LoginMessageDataManager* dlManager = [[LoginMessageDataManager alloc] init];
            dlManager.delegate = self;
            [dlManager accessLoginMessageData:requestDic requestType:LinkedBe_POST];
        }
    }else{
        [self alertWithFistButton:@"确定" SencodButton:nil Message:@"网络不给力呀，请稍后重试"];
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
 *  忘记密码
 */
- (void)forgetPwdClick{
    [MobClick event:@"login_forget_passward"];
    ForgetPasswordViewController *forgetPwdVc = [[ForgetPasswordViewController alloc]init];
    forgetPwdVc.numPhoneString = self.userNameField.text;
    [self.navigationController pushViewController:forgetPwdVc animated:YES];
    RELEASE_SAFE(forgetPwdVc);
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

//选择组织
-(void)chooseOrgination{
    [MobClick event:@"login_login"];
    ChooseOrganizationViewController *chooseOrganizationVc = [[ChooseOrganizationViewController alloc] init];
    chooseOrganizationVc.orgArr = self.orgArray;
    [self.navigationController pushViewController:chooseOrganizationVc animated:YES];
    RELEASE_SAFE(chooseOrganizationVc);
}

//进入欢迎页面
- (void)enterWelcomeViewController
{
    [MobClick event:@"login_login"];
    WelcomeViewController* welcomVc = [[WelcomeViewController alloc] init];
    welcomVc.orgDataDic = [self.orgArray objectAtIndex:0];
    [self.navigationController pushViewController:welcomVc animated:NO];
    RELEASE_SAFE(welcomVc);
}

//显示密码
-(void)clearPwdBtn:(UIGestureRecognizer *) gestureRecognizer{
    
    UIImageView *imageView = (UIImageView *)gestureRecognizer.view;
    imageView.highlighted = !imageView.highlighted;
    
    if (self.pwdField.secureTextEntry) {
        self.pwdField.secureTextEntry = NO;
    }else{
        self.pwdField.secureTextEntry = YES;
    }
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
            self.userNameField.placeholder = @"请输入手机号码";
            self.userNameField.tag = 1;
            self.userNameField.keyboardType = UIKeyboardTypeNumberPad;
            [self.userNameField becomeFirstResponder];
            [self.userNameField setClearButtonMode:UITextFieldViewModeWhileEditing];
            cell.ico_clearImageView.hidden = YES;
            if (self.mobileString) {
                self.userNameField.text = self.mobileString;
                self.userNameField.enabled = NO;
            }
            cell.textLabel.text = @"账号";
        }
            break;
        case 1:
        {
            self.pwdField = cell.loginField;
            self.pwdField.delegate = self;
            self.pwdField.placeholder = @"请输入密码";
            self.pwdField.secureTextEntry = YES;
            self.pwdField.keyboardType = UIKeyboardTypeDefault;
            self.pwdField.returnKeyType =  UIReturnKeySend;
            [self.pwdField setClearButtonMode:UITextFieldViewModeWhileEditing];
            cell.ico_clearImageView.hidden = YES;
            cell.textLabel.text = @"密码";

            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearPwdBtn:)];
            [cell.ico_clearImageView addGestureRecognizer:tap];
            [tap release];
        }
            break;
            
        default:
            break;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    [cell.textLabel setTextColor:RGBACOLOR(136,136,136,1)];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (IOS7_OR_LATER) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }

    return cell;
}

-(void)sendLoginClientId{
 
    LoginSendClientMessage* sendClientMessage = [[LoginSendClientMessage alloc] init];
    [sendClientMessage accessLoginSendClientMessageData:nil requestType:LinkedBe_POST];
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

//LoginMessageDataManagerdelete
-(void)getLoginMessageHttpCallBack:(NSArray*) arr requestCallBackDic:(NSDictionary *)dic interface:(LinkedBe_WInterface) interface{
    //过滤请求结果
    [self hideHudView];
    switch (interface) {
        case LinkedBe_USER_Login:
        {
            if(dic){
                if([[dic objectForKey:@"errcode"] integerValue] == 0){
                    //获取到当前的客户端的id和秘钥以后去请求token
                    [self sendLoginClientId];
                /*
                 * 判断当前的用户是在几个组织里面 然后分别显示不同地方
                 */
                    [self chooseOrgOrWelcome];
                }else {
                    [self alertWithFistButton:@"确定" SencodButton:nil Message:[dic objectForKey:@"errmsg"]];
                }
            }else{
                [self alertWithFistButton:@"确定" SencodButton:nil Message:@"服务异常，请稍后重试"];
            }
        }
            break;
        case LinkedBe_Token_Secert:
        {
            //保存当前的用户的userid
            
        }
        default:
            break;
    }
}

#pragma mark - UITextFieldDelegate
// 键盘return按钮监听
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.pwdField) {
        [self resigns];
        [self loginAction];
    }
    return YES;
}

//输入框开始编辑回调
- (void)textFieldDidBeginEditing:(UITextField *)textField{
 if (textField == self.pwdField) {
     LoginTableViewCell *cell = (LoginTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
     cell.ico_clearImageView.hidden = NO;
    }
}

- (void) hideHudView
{
    if (hudView) {
        [hudView hide:YES];
    }
}

@end
