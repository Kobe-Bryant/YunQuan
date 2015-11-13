//
//  InvitationCodeViewController.m
//  ql
//
//  Created by yunlai on 14-2-22.
//  Copyright (c) 2014年 ChenFeng. All rights reserved.
//

#import "InvitationCodeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Global.h"
#import "UIViewController+NavigationBar.h"
#import "LoginTableViewCell.h"
#import "VerifyViewController.h"
#import "LinkedBeHttpRequest.h"
#import "NSObject_extra.h"
#import "ServiceViewController.h"
#import "InvitationCodeMessageData.h"
#import "CommonProgressHUD.h"
#import "UserModel.h"
#import "MobClick.h"

@interface InvitationCodeViewController()<InvitationCodeMessageDataDelegate>
{
    UIButton *_nextButton;
    LinkedBeHttpRequest *_request;
    BOOL flag;
    
     MBProgressHUD *hudView;
}

@property (nonatomic,retain) UITextField *userNameField;
@property (nonatomic,retain) UITextField *pwdField;

@end

#define kMargin 15.f

@implementation InvitationCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [MobClick beginLogPageView:@"invitationCodeViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"invitationCodeViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = RGBACOLOR(249,249,249,1);
    self.title = @"输入邀请码";
    
    [self creteaRightButton];
    [self mainView];
    
    //点击退出键盘
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeKeyBoard)];
    [self.view addGestureRecognizer:closeTap];
    [closeTap release];
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

/**
 *  主界面布局
 */
- (void)mainView{
    
    UITableView *inportTable = [[UITableView alloc]initWithFrame:CGRectMake(0.f,30.f, ScreenWidth, 100.f) style:UITableViewStylePlain];
    inportTable.delegate = self;
    inportTable.dataSource = self;
    inportTable.backgroundColor = [UIColor clearColor];
    inportTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    inportTable.scrollEnabled = NO;
    [self.view addSubview:inportTable];
    [inportTable release];
    
    // 忘记密码
    UIButton *_noCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _noCodeBtn.frame = CGRectMake(9, inportTable.frame.size.height+inportTable.frame.origin.y+8, 80, 25);
    [_noCodeBtn setTitle:@"没有邀请码" forState:UIControlStateNormal];
    [_noCodeBtn setBackgroundColor:[UIColor clearColor]];
    _noCodeBtn.titleLabel.font = KQLSystemFont(12);
    [_noCodeBtn setTitleColor:RGBACOLOR(26,161,230,1) forState:UIControlStateNormal];
    [_noCodeBtn addTarget:self action:@selector(_noCodeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_noCodeBtn];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, _noCodeBtn.frame.size.height+_noCodeBtn.frame.origin.y-6, 62, 1)];
    lineLabel.backgroundColor = RGBACOLOR(26,161,230,1);
    [self.view addSubview:lineLabel];
    [lineLabel release];
    
   // 下一步
    _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nextButton setFrame:CGRectMake(15, CGRectGetMaxY(inportTable.frame) + 55, ScreenWidth - 15 *2, 44.f)];
    [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [_nextButton setBackgroundColor:RGBACOLOR(26,161,230,1)];
    [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_nextButton addTarget:self action:@selector(nextTo) forControlEvents:UIControlEventTouchUpInside];
    _nextButton.layer.cornerRadius = 6;
    [self.view addSubview:_nextButton];
    
    UILabel *tip = [[UILabel alloc]initWithFrame:CGRectMake(20,CGRectGetMaxY(_nextButton.frame) + 10.f, 150.f, 30.f)];
    tip.text = @"点击下一步即同意";
    tip.font = KQLSystemFont(13);
    tip.textColor = [UIColor grayColor];
    tip.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tip];
    [tip release];
    
    //
    UIButton *_errorMoblie = [UIButton buttonWithType:UIButtonTypeCustom];
    _errorMoblie.frame = CGRectMake(110,CGRectGetMaxY(_nextButton.frame) + 10.f, 150.f, 30.f);
    [_errorMoblie setTitle:@"《云圈用户服务协议》" forState:UIControlStateNormal];
    [_errorMoblie setTitleColor:RGBACOLOR(26,161,230,1) forState:UIControlStateNormal];
    [_errorMoblie setBackgroundColor:[UIColor clearColor]];
    [_errorMoblie addTarget:self action:@selector(notCodeClick) forControlEvents:UIControlEventTouchUpInside];
    _errorMoblie.titleLabel.font = KQLSystemFont(13);
    [self.view addSubview:_errorMoblie];
}

//云圈服务协议
- (void)notCodeClick {
    ServiceViewController *serviceVC = [[ServiceViewController alloc]init];
    [self.navigationController pushViewController:serviceVC animated:YES];
    RELEASE_SAFE(serviceVC);
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
        
        [self alertWithFistButton:nil SencodButton:@"确定" Message:@"邀请码不能为空！"];
        
        [self.pwdField becomeFirstResponder];
        
        return FALSE;
    }else{
        return TRUE;
    }
}


/**
 *  下一步点击事件
 */
- (void)nextTo{
    [MobClick event:@"Invitation_nextButton"];
    [self closeKeyBoard];
    if ([self checkForm]) {
        [self hideHudView];
        hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"请稍候..."];
        
        [self accessInviteCodeService]; //网络请求数据
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
- (void)clearImageTap:(UIGestureRecognizer *)gestureRecognizer {
    
    UIImageView *imageView = (UIImageView *)gestureRecognizer.view;
    imageView.highlighted = !imageView.highlighted;
    
    flag = !flag;
    if (flag) {
        self.pwdField.secureTextEntry = NO;
    } else {
        self.pwdField.secureTextEntry = YES;
    }
}

/**
 *  没有邀请码点击事件
 */
- (void)_noCodeBtnClick
{
    [MobClick event:@"Invitation_noInvitate"];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"您好，云圈只限于内部成员交流，如果您是组织会员，请联系组织负责人获取邀请码，或拨打0755-86329205咨询" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
}

#pragma mark - UITableViewDelegate
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
            self.userNameField.placeholder = @"请输入手机号码";
            self.userNameField.tag = 1;
            [self.userNameField setClearButtonMode:UITextFieldViewModeWhileEditing];
            self.userNameField.keyboardType = UIKeyboardTypeNumberPad;
            [self.userNameField becomeFirstResponder];
            cell.ico_clearImageView.hidden = YES;
            cell.textLabel.text = @"账号";
        }
            break;
            
        case 1:
        {
            self.pwdField = cell.loginField;
            //            self.pwdField.delegate=self;
            self.pwdField.placeholder = @"请输入邀请码";
            self.pwdField.tag = 2;
            self.pwdField.delegate = self;
            [self.pwdField setClearButtonMode:UITextFieldViewModeWhileEditing];
            self.pwdField.keyboardType = UIKeyboardTypeNumberPad;
            cell.ico_clearImageView.hidden = YES;
            UITapGestureRecognizer *clearImageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clearImageTap:)];
            [cell.ico_clearImageView addGestureRecognizer:clearImageTap];
            [clearImageTap release];
            cell.textLabel.text = @"邀请码";
            
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

#pragma mark - accessService

- (void)accessInviteCodeService{
    if ([Common connectedToNetwork]) {
        NSMutableDictionary* requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.userNameField.text,@"mobile",
                                           self.pwdField.text,@"code",
                                           nil];
        
        InvitationCodeMessageData *invitationCode = [[InvitationCodeMessageData alloc] init];
        invitationCode.delegate = self;
        [invitationCode accessInvitationCodeMessageData:requestDic];
    }else{
        [self alertWithFistButton:@"确定" SencodButton:nil Message:@"网络异常，请稍后重试"];
    }
}


- (void)dealloc
{
//    RELEASE_SAFE(_inportTable);
//    RELEASE_SAFE(_notCodeBtn);
    [super dealloc];
}

- (void) hideHudView
{
    if (hudView) {
        [hudView hide:YES];
    }
}

-(void)getInvitationCodeMessageDataHttpCallBack:(NSArray*) arr requestCallBackDic:(NSDictionary *)dic interface:(LinkedBe_WInterface) interface{
    [self hideHudView];
    switch (interface) {
        case LinkedBe_User_Invitationcode:
        {
            if(dic){
                if ([[dic objectForKey:@"errcode"] intValue] != 0) {
                    [self alertWithFistButton:@"确定" SencodButton:nil Message:[dic objectForKey:@"errmsg"]];
                }else{
                    VerifyViewController *verifyVC = [[VerifyViewController alloc]init];
                    verifyVC.inviteeDic = dic;
                    [self.navigationController pushViewController:verifyVC animated:YES];
                    RELEASE_SAFE(verifyVC);
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

#pragma mark - UITextFiledDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (range.location > 5) {
        return NO;
    }else{
        return YES;
    }
}
@end
