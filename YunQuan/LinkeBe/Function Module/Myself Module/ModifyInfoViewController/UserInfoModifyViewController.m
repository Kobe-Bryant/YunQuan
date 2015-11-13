//
//  UserInfoModifyViewController.m
//  ql
//
//  Created by yunlai on 14-4-22.
//  Copyright (c) 2014年 ChenFeng. All rights reserved.
//

#import "UserInfoModifyViewController.h"
#import "Global.h"
#import "UIViewController+NavigationBar.h"
#import "NSObject_extra.h"
#import "CommonProgressHUD.h"
#import "MyselfMessageManager.h"
#import "Userinfo_model.h"
#import "SBJson.h"
#import "Common.h"
#import "MobClick.h"

@interface UserInfoModifyViewController ()<MyselfMessageManagerDelegate>
{
    UITextField *_inputField;
    
    MBProgressHUD *hudView;
}

@end

@implementation UserInfoModifyViewController
@synthesize titleCtl = _titleCtl;
@synthesize content = _content;
@synthesize fieldString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"UserInfoModifyViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"UserInfoModifyViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = RGBACOLOR(249,249,249,1);
    
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = YES;
    }
    
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];

    self.title = self.titleCtl;
//    初始化保存按钮
    [self saveBarButton];
//    加载主视图
    [self mainLoadView];
}

-(void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

//加载主视图
- (void)mainLoadView{
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0.f, 20.f, ScreenWidth, 40.f)];
    bgView.backgroundColor = [UIColor whiteColor];
    _inputField = [[UITextField alloc]initWithFrame:CGRectMake(10.f, 0.f, ScreenWidth-10, 40.f)];
    _inputField.backgroundColor = [UIColor whiteColor];
    _inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _inputField.delegate = self;
    [_inputField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    _inputField.placeholder = [NSString stringWithFormat:@"输入%@",self.titleCtl];
    _inputField.text = self.content;
    [bgView addSubview:_inputField];
    
    [self.view addSubview:bgView];
    RELEASE_SAFE(bgView);
}

// 初始化保存
- (void)saveBarButton{
    [_inputField resignFirstResponder];
    
    UIButton *saveButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    
    [saveButton addTarget:self action:@selector(saveClick) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setFrame:CGRectMake(0 , 5, 40.f, 30.f)];
    [saveButton setTitleColor:RGBACOLOR(26,161,230,1) forState:UIControlStateNormal];
    UIBarButtonItem  *rightItem = [[UIBarButtonItem  alloc]  initWithCustomView:saveButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    RELEASE_SAFE(rightItem);
    
}

/*
 *表单验证
 */

- (BOOL)checkForm {
//    if ([[self whitespaceAndNewlineCharacterSet:_inputField.text] isEqualToString:@""]||[[self whitespaceAndNewlineCharacterSet:_inputField.text] isEqualToString:nil]||[[self whitespaceAndNewlineCharacterSet:_inputField.text] length] == 0) {
//        
//        [self alertWithFistButton:nil SencodButton:@"确定" Message:[NSString stringWithFormat:@"%@不能为空！",self.titleCtl]];
//        
//        [_inputField becomeFirstResponder];
//        
//        return FALSE;
//    }else
    if([self.titleCtl isEqualToString:@"公司"]){
        if ([_inputField.text length]>15) {
            
            [self alertWithFistButton:nil SencodButton:@"确定" Message:@"公司名称长度不得超过15个字"];
            [_inputField becomeFirstResponder];
            
            return FALSE;
        }else{
            return TRUE;
        }
    }else if([self.titleCtl isEqualToString:@"邮箱"]){
        //邮箱格式检测
        if ([Common validateEmail:_inputField.text]) {
            return TRUE;
        }else{
            [self alertWithFistButton:nil SencodButton:@"确定" Message:@"请输入正确的邮箱格式！"];
            [_inputField becomeFirstResponder];
            
            return FALSE;
        }
    }else{
        return TRUE;
    }
}
#pragma mark - 保存
- (void)saveClick{
    if ([Common connectedToNetwork]) {
        [_inputField resignFirstResponder];
        if ([self checkForm]) {
            [self hideHudView];
            hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"请稍候..."];
            
            NSMutableDictionary *selfDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.fieldString,@"field",_inputField.text,@"val", nil];
            
            MyselfMessageManager* dlManager = [[MyselfMessageManager alloc] init];
            dlManager.delegate = self;
            [dlManager accessUpdateUserInfoData:selfDic];
        }
    }else{
        [self alertWithFistButton:@"确定" SencodButton:nil Message:@"网络不给力呀，请稍后重试"];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [_inputField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//限制输入框手机号码11位数
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    if (textField == _inputField && textField.text.length!=0 &&self.modifyType == 5) {
//        if (range.location >= 11){
//            
//            [Common checkProgressHUD:@"请输入11位的手机号码" andImage:nil showInView:self.view];
//            return NO;
//        }
//    }
//    return YES;
//}
- (void) hideHudView
{
    if (hudView) {
        [hudView hide:YES];
    }
}

-(void) dealloc{
    [_inputField release];
    [super dealloc];
}

-(void)getMyselfMessageManagerHttpCallBack:(NSArray*) arr requestCallBackDic:(NSDictionary *)dic interface:(LinkedBe_WInterface) interface{
    [self hideHudView];
    switch (interface) {
        case LinkedBe_MYSELF_UPDATEUSER:
        {
            if (dic) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"修改成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alertView.tag = 100;
                [alertView show];
                [alertView release];
                
//               修改成功以后更换当前数据库里面的内容
                Userinfo_model *userInfoModel = [[Userinfo_model alloc]init];
                NSString *dicString = [[[userInfoModel getList] firstObject] objectForKey:@"content"];
                
                NSMutableDictionary *contentDic = [dicString JSONValue];
                [contentDic setObject:_inputField.text forKey:self.fieldString];
                [contentDic setObject:[dic objectForKey:@"infoPercent"] forKey:@"infoPercent"];

                 userInfoModel.where = [NSString stringWithFormat:@"orgUserId = %d",[[[dicString JSONValue] objectForKey:@"orgUserId"] intValue]];
                
                // 个人信息
                NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [[dicString JSONValue] objectForKey:@"orgUserId"],@"orgUserId",
                                         [contentDic JSONRepresentation],@"content",
                                         nil];
                NSArray *userArray = [userInfoModel getList];
                if ([userArray count] > 0) {
                    [userInfoModel updateDB:userDic];
                } else {
                    [userInfoModel insertDB:userDic];
                }
            }else{
                [self alertWithFistButton:@"确定" SencodButton:nil Message:@"修改错误"];
            }

        }
            break;
        default:
            break;
    }
}

#pragma mark - UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 100:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
}
@end
