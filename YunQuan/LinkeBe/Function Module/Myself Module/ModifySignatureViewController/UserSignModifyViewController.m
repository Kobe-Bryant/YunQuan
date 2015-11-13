//
//  UserSignModifyViewController.m
//  ql
//
//  Created by yunlai on 14-5-4.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "UserSignModifyViewController.h"
#import "Global.h"
#import "UIViewController+NavigationBar.h"
#import "common.h"
#import "CommonProgressHUD.h"
#import "MyselfMessageManager.h"
#import "SBJson.h"
#import "Userinfo_model.h"
#import "NSObject_extra.h"
#import "MobClick.h"

@interface UserSignModifyViewController ()<MyselfMessageManagerDelegate>
{
//    签名文本框
    UITextView *_signTextView;
//    内容文本框
    UILabel *countLable;
//    保存按钮
    UIButton *saveButton;
    
    MBProgressHUD *hudView;
}
@end

@implementation UserSignModifyViewController
@synthesize titleCtl,content;
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
    [MobClick beginLogPageView:@"UserSignModifyViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"UserSignModifyViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBACOLOR(249, 249, 249, 1);
    
    self.title = titleCtl;
    
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
    
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    
//    加载主视图
    [self loadMainView];
    
//    初始化保存按钮
    [self saveBarButton];
}

-(void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//加载主视图
- (void)loadMainView{
    _signTextView = [[UITextView alloc]initWithFrame:CGRectMake(5.f, 10.f, ScreenWidth - 10, 90.f)];
    _signTextView.text = self.content;
    _signTextView.textAlignment = NSTextAlignmentLeft;
    _signTextView.backgroundColor = [UIColor whiteColor];
    _signTextView.font = [UIFont systemFontOfSize:16.0];
    _signTextView.delegate = self;
    [self.view addSubview:_signTextView];
    
    countLable =  [[UILabel alloc]initWithFrame:CGRectMake(270, 120, 70, 20)];
    countLable.backgroundColor = [UIColor clearColor];
    countLable.text = [NSString stringWithFormat:@"%d/25",_signTextView.text.length];
    countLable.font = [UIFont systemFontOfSize:16.0];
    [self.view addSubview:countLable];
}

// 初始化保存
- (void)saveBarButton{
    
    [_signTextView resignFirstResponder];
    saveButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    [saveButton addTarget:self action:@selector(saveClick) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setFrame:CGRectMake(0 , 5, 40.f, 30.f)];
    [saveButton setTitleColor:RGBACOLOR(26,161,230,1) forState:UIControlStateNormal];
    saveButton.enabled = NO;
    UIBarButtonItem  *rightItem = [[UIBarButtonItem  alloc]  initWithCustomView:saveButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    RELEASE_SAFE(rightItem);
}

#pragma mark - textView
//文本框检测 超过25个字 按钮不可点击
-(BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString * aString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if ([aString length] > 25) {
        return NO;
    }else if([aString length] <26){
        saveButton.enabled = YES;
        [saveButton setTitleColor:RGBACOLOR(42, 119, 195, 1) forState:UIControlStateNormal];
        countLable.textColor = [UIColor blackColor];
        countLable.text = [NSString stringWithFormat:@"%d/25",aString.length];
    }
    if ([aString length] == 0) {
        saveButton.enabled = NO;
        [saveButton setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.f] forState:UIControlStateNormal];
    }
    return YES;
}

#pragma mark - 保存
//字数检测与提示
- (void)saveClick{
    if ([Common connectedToNetwork]) {
        [_signTextView resignFirstResponder];
        if ([self whitespaceAndNewlineCharacterSet:_signTextView.text].length > 0 && [self whitespaceAndNewlineCharacterSet:_signTextView.text].length <= 25) {
            [self hideHudView];
            hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"请稍候..."];
            
            NSMutableDictionary *selfDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.fieldString,@"field",[Common placeEmoji:_signTextView.text],@"val", nil];
            
            MyselfMessageManager* dlManager = [[MyselfMessageManager alloc] init];
            dlManager.delegate = self;
            [dlManager accessUpdateUserInfoData:selfDic];
            
        }else if(_signTextView.text.length > 25){
            [self alertWithFistButton:@"确定" SencodButton:nil Message:@"字数超出限制"];
            
            [_signTextView becomeFirstResponder];
        }
//        else{
//            [self alertWithFistButton:@"确定" SencodButton:nil Message:@"你没填写内容哦~"];
//            
//            [_signTextView becomeFirstResponder];
//        }
    }else{
        [self alertWithFistButton:@"确定" SencodButton:nil Message:@"网络不给力呀，请稍后重试"];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [_signTextView resignFirstResponder];
}

- (void) hideHudView
{
    if (hudView) {
        [hudView hide:YES];
    }
}
- (void)dealloc
{
    RELEASE_SAFE(countLable);
    RELEASE_SAFE(_signTextView);
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
                [contentDic setObject:_signTextView.text forKey:self.fieldString];
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
