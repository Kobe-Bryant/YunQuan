//
//  RegisterSetPwdViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-13.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "RegisterSetPwdViewController.h"
#import "LoginTableViewCell.h"
#import "Global.h"
#import "UIViewController+NavigationBar.h"
#import "ChooseOrganizationViewController.h"
#import "LinkedBeHttpRequest.h"
#import "NSObject_extra.h"
#import "UserModel.h"
#import "Common.h"
#import "LoginMessageDataManager.h"
#import "LoginSendClientMessage.h"
#import "CommonProgressHUD.h"
#import "chooseOrg_model.h"
#import "WelcomeViewController.h"
#import "MobClick.h"

@interface RegisterSetPwdViewController ()<LoginMessageDataManagerDelegate>
{
    UITableView *_tableView;
    
    UIButton *_loginBtn;
    LinkedBeHttpRequest *_request;
    BOOL flag;
    
    MBProgressHUD *hudView;
}
@property (nonatomic,retain) UITextField *userNameField;
@property (nonatomic,retain) UITextField *pwdField;
@property(nonatomic,retain)NSArray *orgArray;

@end

@implementation RegisterSetPwdViewController
@synthesize registerSetDic;
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
    [MobClick beginLogPageView:@"RegisterSetPwdViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"RegisterSetPwdViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBACOLOR(249,249,249,1);
    self.title = @"设置密码";
    
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
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0.f,30.f, ScreenWidth, 100.f)style:UITableViewStylePlain];
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
//    6-20位数字字母组合区分大小写
    UILabel* warningLabel = [[UILabel alloc] init];
    warningLabel.frame = CGRectMake(18, CGRectGetMaxY(_tableView.frame) + 15, 200, 15);
    warningLabel.backgroundColor = [UIColor clearColor];
    warningLabel.textColor = [UIColor grayColor];
    warningLabel.text = @"6-20位数字字母组合区分大小写";
    warningLabel.textAlignment = NSTextAlignmentLeft;
    warningLabel.font = KQLboldSystemFont(14);
    [self.view addSubview:warningLabel];
    [warningLabel release];

    // 登录按钮
    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginBtn.frame = CGRectMake(15, CGRectGetMaxY(_tableView.frame) + 55, ScreenWidth - 15 *2, 40.f);
    [_loginBtn setTitle:@"登  录" forState:UIControlStateNormal];
    _loginBtn.layer.cornerRadius = 3;
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginBtn setBackgroundColor:RGBACOLOR(26,161,230,1)];
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
    [self closeKeyBoard];
    if ([self checkForm]) {
        [self hideHudView];
        hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"请稍候..."];
        
        if (!_request) {
            _request = [LinkedBeHttpRequest shareInstance];
        }
        NSString *systemToken;
        if (![[NSUserDefaults standardUserDefaults] objectForKey:LINKEDBE_TOKEN_KEY]) {
            systemToken = @"";
        }else{
            systemToken = [[NSUserDefaults standardUserDefaults] objectForKey:LINKEDBE_TOKEN_KEY];
        }
        NSMutableDictionary *parameterDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             self.userNameField.text,@"username",
                                             self.pwdField.text,@"password",
                                             [self getUuidString],@"uuid",
                                             [UserModel shareUser].org_id,@"orgId",
                                             systemToken,@"token",
                                             nil];
        [_request requsetSetPassword:self parameterDictionary:parameterDic parameterArray:nil requestType:LinkedBe_POST];
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
 *   点击变明文
 */
- (void)clearImageTap {
    flag = !flag;
    if (flag) {
        self.pwdField.secureTextEntry = NO;
    } else {
        self.pwdField.secureTextEntry = YES;
    }
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

/**
 *  密码设置成功以后去登录
 */
- (void)loginOrgAction
{
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

-(void)sendLoginClientId{
    
    LoginSendClientMessage* sendClientMessage = [[LoginSendClientMessage alloc] init];
    [sendClientMessage accessLoginSendClientMessageData:nil requestType:LinkedBe_POST];
}


- (void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
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
            //            self.userNameField.delegate=self;.
            self.userNameField.text = [self.registerSetDic objectForKey:@"mobile"];
//            self.userNameField.placeholder = @"请输入手机号码";
            self.userNameField.tag = 1;
            self.userNameField.enabled = NO;
            self.userNameField.keyboardType = UIKeyboardTypeNumberPad;
            cell.ico_clearImageView.hidden = YES;
            cell.textLabel.text = @"账号";
        }
            break;
            
        case 1:
        {
            self.pwdField = cell.loginField;
            //            self.pwdField.delegate=self;
            self.pwdField.placeholder = @"请输入密码";
            self.pwdField.tag = 2;
            [self.pwdField becomeFirstResponder];
            self.pwdField.secureTextEntry = YES;
            self.pwdField.keyboardType = UIKeyboardTypeDefault;
            cell.ico_clearImageView.hidden = YES;
            UITapGestureRecognizer *clearImageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clearImageTap)];
            [cell.ico_clearImageView addGestureRecognizer:clearImageTap];
            [clearImageTap release];
            cell.textLabel.text = @"密码";
            
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

#pragma mark - httpback
-(void)didFinishCommand:(NSDictionary *)jsonDic cmd:(int)commandid withVersion:(int)ver{
    switch (commandid) {
        case LinkedBe_Set_Password:
        {
            if ([[jsonDic objectForKey:@"errcode"] intValue] == 0) {
                [UserModel shareUser].userInfo = [jsonDic objectForKey:@"userinfo"];
//            成功以后走登陆的逻辑
                [self loginOrgAction];
            
            }else{
                [self alertWithFistButton:@"确定" SencodButton:nil Message:[jsonDic objectForKey:@"errmsg"]];
            }
        }
            break;
        default:
            break;
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
    [self hideHudView];
    if (arr.count) {
        switch (interface) {
            case LinkedBe_USER_Login:
            {
                //获取到当前的客户端的id和秘钥以后去请求token
                [self sendLoginClientId];
                
                /*
                 *  判断当前的用户是在几个组织里面 然后分别显示不同地方
                 */
                [self chooseOrgOrWelcome];
                
//                //  选择组织
//                ChooseOrganizationViewController *chooseOrganizationVc = [[ChooseOrganizationViewController alloc] init];
//                [self.navigationController pushViewController:chooseOrganizationVc animated:YES];
//                RELEASE_SAFE(chooseOrganizationVc);

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
}

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

- (void) hideHudView
{
    if (hudView) {
        [hudView hide:YES];
    }
}
@end
