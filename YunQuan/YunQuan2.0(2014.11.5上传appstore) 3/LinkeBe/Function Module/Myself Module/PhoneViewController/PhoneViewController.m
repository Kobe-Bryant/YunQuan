//
//  PhoneViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-29.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "PhoneViewController.h"
#import "UIViewController+NavigationBar.h"
#import "Global.h"
#import "MyselfMessageManager.h"
#import "MBProgressHUD.h"
#import "CommonProgressHUD.h"
#import "NSObject_extra.h"
#import "Userinfo_model.h"
#import "SBJson.h"
#import "Common.h"
#import "MobClick.h"

@interface PhoneViewController ()<UITableViewDataSource,UITableViewDelegate,MyselfMessageManagerDelegate>{
    UITableView *phoneTableView;
    
    UITextField *_inputField;
    UILabel *_openOrCloseLabel;
    
    MBProgressHUD *hudView;
    
    NSString *telShield ;
}

@end

@implementation PhoneViewController
@synthesize fieldString;
@synthesize content = _content;
@synthesize secketString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"PhoneViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"PhoneViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"编辑电话";
    self.view.backgroundColor = RGBACOLOR(249,249,249,1);
    
    //    初始化保存按钮
    [self saveBarButton];
    
    [self loardTableView];
    
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
}

-(void)loardTableView{
    phoneTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 30, ScreenWidth, 50) style:UITableViewStylePlain];
    phoneTableView.delegate = self;
    phoneTableView.dataSource = self;
    phoneTableView.scrollEnabled = NO;
    phoneTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    phoneTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [self.view addSubview:phoneTableView];
}

// 初始化保存
- (void)saveBarButton{
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
    if ([[self whitespaceAndNewlineCharacterSet:_inputField.text] isEqualToString:@""]||[[self whitespaceAndNewlineCharacterSet:_inputField.text] isEqualToString:nil]||[[self whitespaceAndNewlineCharacterSet:_inputField.text] length] == 0) {
        
        [self alertWithFistButton:nil SencodButton:@"确定" Message:[NSString stringWithFormat:@"%@不能为空！",@"电话号码不能为空"]];
        
        [_inputField becomeFirstResponder];
        
        return FALSE;
    }else{
        return TRUE;
    }
}

- (void) hideHudView
{
    if (hudView) {
        [hudView hide:YES];
    }
}

#pragma mark - 保存
- (void)saveClick{
    if ([Common connectedToNetwork]) {
        [_inputField resignFirstResponder];
//        if ([self checkForm]) {
        [self hideHudView];
        hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"请稍候..."];
        if ([_openOrCloseLabel.text isEqualToString:@"公开"]) {
            telShield = @"0";
        }else{
            telShield = @"1";
        }
        //   保存当前的状态(保密或者公开，0：未屏蔽 1：屏蔽)
        NSMutableDictionary *provinceDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"telShield",@"field",telShield,@"val", nil];
        MyselfMessageManager* dlManager = [[MyselfMessageManager alloc] init];
        [dlManager accessUpdateUserInfoData:provinceDic];
        
        //   保存当前的类型
        NSMutableDictionary *cityDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"mobile",@"field",[self whitespaceAndNewlineCharacterSet:_inputField.text],@"val", nil];
        MyselfMessageManager* cityManager = [[MyselfMessageManager alloc] init];
        cityManager.delegate = self;
        [cityManager accessUpdateUserInfoData:cityDic];
//        }

    }else{
        [self alertWithFistButton:@"确定" SencodButton:nil Message:@"网络不给力呀，请稍后重试"];
    }
}


-(void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (void)switchView:(UISwitch *)sender{
    if (sender.tag == 800) {
        NSLog(@"100");
        if (sender.isOn) {
            _openOrCloseLabel.text = @"公开";
        }else{
            _openOrCloseLabel.text = @"保密";
        }
    }
}

#pragma UITableViewDelegate
#pragma mark UITableViewDataSource implementation
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AreaTableView"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:
                 UITableViewCellStyleSubtitle reuseIdentifier:@"AreaTableView"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UITextField *loginField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, 220, 50)];
        loginField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;//字体垂直居中对齐
        loginField.font = [UIFont systemFontOfSize:16];
        loginField.tag = 11111;
        loginField.backgroundColor =[UIColor clearColor];
        [loginField setKeyboardType:UIKeyboardTypeNumberPad];
        [cell addSubview:loginField];
        [loginField release];
        
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(232, 15, 40, 20)];
        lable.tag = 11112;
        lable.textColor = [UIColor grayColor];
        lable.font = [UIFont systemFontOfSize:13.0];
        lable.backgroundColor = [UIColor clearColor];
        [cell addSubview:lable];
        [lable release];
    }
    _inputField = (UITextField *)[cell viewWithTag:11111];
    _inputField.text = [self phoneNumTypeTurnWith:self.content withString:@" "];
    [_inputField becomeFirstResponder];
    
    _openOrCloseLabel = (UILabel *)[cell viewWithTag:11112];

    UISwitch *switchView = [[UISwitch alloc]initWithFrame:CGRectMake(260, 8, 70, 30)];
    if (!IOS7_OR_LATER) {
        _openOrCloseLabel.frame = CGRectMake(212, 15, 40, 20);
        switchView.frame = CGRectMake(240, 10, 70, 30);
    }
    if ([self.secketString integerValue] == 0) {
        _openOrCloseLabel.text = @"公开";
        switchView.on = YES;
    }else{
        _openOrCloseLabel.text = @"保密";
        switchView.on = NO;
    }
    
    switchView.tag = 800 +indexPath.row;
    [switchView addTarget:self action:@selector(switchView:) forControlEvents:UIControlEventValueChanged];
    [cell addSubview:switchView];
    [switchView release];
    return cell;
}
#pragma mark UITableViewDelegate implementation
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //    for (UIViewController *viewController in self.navigationController.viewControllers) {
    //        if ([viewController isKindOfClass:[EditViewController class]]) {
    //            [self.navigationController popToViewController:viewController animated:YES];
    //        }
    //    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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
                
                //修改成功以后更换当前数据库里面的内容
                Userinfo_model *userInfoModel = [[Userinfo_model alloc]init];
                NSString *dicString = [[[userInfoModel getList] firstObject] objectForKey:@"content"];
                
                NSMutableDictionary *contentDic = [dicString JSONValue];
                [contentDic setObject:_inputField.text forKey:@"mobile"];
                [contentDic setObject:telShield forKey:@"telShield"];
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
