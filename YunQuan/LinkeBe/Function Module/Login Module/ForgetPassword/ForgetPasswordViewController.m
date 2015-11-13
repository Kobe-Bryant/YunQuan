//
//  ForgetPasswordViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-22.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import "Global.h"
#import "UIViewController+NavigationBar.h"
#import "ForgetPwdTableViewCell.h"
#import "ResetPasswordViewController.h"
#import "LoginMessageDataManager.h"
#import "MBProgressHUD.h"
#import "CommonProgressHUD.h"
#import "NSObject_extra.h"
#import "MobClick.h"

@interface ForgetPasswordViewController ()<UITableViewDataSource,UITableViewDelegate,LoginMessageDataManagerDelegate,UITextFieldDelegate>{
    UITableView *_tableView;
    
    UIButton *_nextBtn;
    
    MBProgressHUD *hudView;
    
    int num;
}
@property (nonatomic,retain) UITextField *userNameField;
@property (nonatomic,retain) UITextField *pwdField;
@end

@implementation ForgetPasswordViewController
@synthesize userNameField,pwdField;
@synthesize numPhoneString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"ForgetPasswordViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"ForgetPasswordViewPage"];
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
    
    // 登录按钮
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextBtn.frame = CGRectMake(15, CGRectGetMaxY(_tableView.frame) + 50, ScreenWidth - 15 *2, 40.f);
    [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    _nextBtn.layer.cornerRadius = 3;
    [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_nextBtn setBackgroundColor:RGBACOLOR(26,161,230,1)];
    [_nextBtn addTarget:self action:@selector(nextBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextBtn];
}

/*
*   获取验证码
*/
-(void)getAuthCodeAction{
    if (![Common connectedToNetwork]) {
        // 网络繁忙，请重新再试
        [self alertWithFistButton:@"确定" SencodButton:nil Message:@"网络不给力呀，请稍后重试"];
    } else {
        if ([self.userNameField.text isEqualToString:@""]||[self.userNameField.text isEqualToString:nil]||[self.userNameField.text length] == 0) {
            
            [self alertWithFistButton:nil SencodButton:@"确定" Message:@"账号不能为空！"];
            
            [self.userNameField becomeFirstResponder];
            
            return;
        }else if (![self isMobileNumber:self.userNameField.text] || [self.userNameField.text length]!=11) {
            
            [self alertWithFistButton:nil SencodButton:@"确定" Message:@"手机号码格式不正确，请重新输入"];
            
            [self.userNameField becomeFirstResponder];
            
            return;
        }else{
//            检测当前的手机号码是否已经在组织方后台注册过了
            [self checkMobileInBack];
        }
    }
}

//检测手机号码是否已经在组织方后台注册过了
-(void)checkMobileInBack{
    NSMutableDictionary* requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.userNameField.text,@"mobile",
                                    nil];
    LoginMessageDataManager* dlManager = [[LoginMessageDataManager alloc] init];
    dlManager.delegate = self;
    [dlManager accessValidatemobile:requestDic];
}

//发送邀请码网络请求
-(void)accessAuthCodeService{    
    NSMutableDictionary* requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.userNameField.text,@"mobile",
                                       @"2",@"type",                                       nil];
    LoginMessageDataManager* dlManager = [[LoginMessageDataManager alloc] init];
    dlManager.delegate = self;
    [dlManager accessSendAuthCodeService:requestDic];
}

/**
 *  重发验证码点击
 */
- (void)updateAuthCode{
    ForgetPwdTableViewCell *cell = (ForgetPwdTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    NSString *titles=[NSString stringWithFormat:@"获取中(%d)",num];
    self.userNameField.enabled = NO;
    [cell.getAuthCode setTitle:titles forState:UIControlStateNormal];
    if (num==0) {
        [cell.getAuthCode setUserInteractionEnabled:YES];
        [cell.getAuthCode setBackgroundColor:RGBACOLOR(26,161,230,1)];
        
        if (_timer) {
            [_timer invalidate];
            _timer=nil;
        }
        self.userNameField.enabled = NO;
        [cell.getAuthCode setBackgroundColor:RGBACOLOR(26,161,230,1)];
        [cell.getAuthCode  setTitle:@"重新获取" forState:UIControlStateNormal];
    }
    --num;
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
        
        [self alertWithFistButton:nil SencodButton:@"确定" Message:@"验证码不能为空！"];
        
        [self.pwdField becomeFirstResponder];
        
        return FALSE;
    }else{
        return TRUE;
    }
}

/*
 *   下一步
 */
-(void)nextBtnAction{
    if ([Common connectedToNetwork]) {
        [self resigns];
        if ([self checkForm]) {
            [self hideHudView];
            hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"请稍候..."];
            
            NSMutableDictionary* requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.userNameField.text,@"mobile",
                                               self.pwdField.text,@"code",
                                               @"2",@"type",
                                               nil];
            LoginMessageDataManager* dlManager = [[LoginMessageDataManager alloc] init];
            dlManager.delegate = self;
            [dlManager acessIdentifycode:requestDic];
        }
    }else{
        // 网络繁忙，请重新再试
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
    ForgetPwdTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ForgetPwdTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.contentView.backgroundColor =  [UIColor whiteColor];
        
    }
    switch (indexPath.row) {
        case 0:
        {
            self.userNameField = cell.loginField;
            self.userNameField.placeholder = @"请输入手机号码";
            self.userNameField.tag = 1;
            self.userNameField.text = self.numPhoneString;
            self.userNameField.keyboardType = UIKeyboardTypeNumberPad;
            [self.userNameField becomeFirstResponder];
            cell.getAuthCode.hidden = YES;
            cell.textLabel.text = @"账号";
        }
            break;
            
        case 1:
        {
            self.pwdField = cell.loginField;
            self.pwdField.frame = CGRectMake(80, 0, 180, 50);
            //            self.pwdField.delegate=self;
            self.pwdField.placeholder = @"请输入验证码";
            self.pwdField.tag = 2;
            self.pwdField.delegate = self;
            self.pwdField.keyboardType = UIKeyboardTypeNumberPad;
            self.pwdField.backgroundColor = [UIColor clearColor];
            cell.textLabel.text = @"验证码";
            
            [cell.getAuthCode addTarget:self action:@selector(getAuthCodeAction) forControlEvents:UIControlEventTouchUpInside];

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

//LoginMessageDataManagerdelete
-(void)getLoginMessageHttpCallBack:(NSArray*) arr requestCallBackDic:(NSDictionary *)dic interface:(LinkedBe_WInterface) interface{
    //过滤请求结果
    [self hideHudView];
    switch (interface) {
        case LinkedBe_Identifycode:
        {
            if(dic){
                if ([[dic objectForKey:@"errcode"] integerValue]==0) {
                    ResetPasswordViewController *resetPwdVc = [[ResetPasswordViewController alloc] init];
                    resetPwdVc.mobileString = self.userNameField.text;
                    [self.navigationController pushViewController:resetPwdVc animated:YES];
                    RELEASE_SAFE(resetPwdVc);
                }else{
                    [self alertWithFistButton:@"确定" SencodButton:nil Message:[dic objectForKey:@"errmsg"]];
                }
            }else{
                [self alertWithFistButton:@"确定" SencodButton:nil Message:@"网络不给力呀，请稍后重试"];
            }
        }
            break;
        case LinkedBe_SendAuthcode:
        {
            if ([[dic objectForKey:@"errcode"] integerValue]!=0) {
                [self alertWithFistButton:@"确定" SencodButton:nil Message:[dic objectForKey:@"errmsg"]];
            }
        }
            break;
        case LinkedBe_Validatemobile:
        {
            if(dic){
                if ([dic objectForKey:@"isExists"]) {
                    if ([[dic objectForKey:@"isExists"] integerValue]==1) {
                        ForgetPwdTableViewCell *cell = (ForgetPwdTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        [cell.getAuthCode setUserInteractionEnabled:NO];
                        [cell.getAuthCode setBackgroundColor:RGBACOLOR(187,187,187,1)];
                        
                        //发送验证码网络请求
                        [self accessAuthCodeService];
                        
                        num = 60;
                        _timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateAuthCode) userInfo:nil repeats:YES];
                        
                    }else if([[dic objectForKey:@"isExists"] integerValue]==0){
                        [self alertWithFistButton:@"确定" SencodButton:nil Message:@"手机号码无效"];
                    }
                }else{
                    [self alertWithFistButton:@"确定" SencodButton:nil Message:[dic objectForKey:@"errmsg"]];
                }
            }else{
                [self alertWithFistButton:@"确定" SencodButton:nil Message:@"服务异常，请稍后重试"];
            }
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

#pragma mark - UITextFiledDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (range.location > 5) {
        return NO;
    }else{
        return YES;
    }
}
@end
