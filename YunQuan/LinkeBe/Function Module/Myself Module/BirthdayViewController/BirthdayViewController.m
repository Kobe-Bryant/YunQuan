//
//  BirthdayViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-29.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "BirthdayViewController.h"
#import "UIViewController+NavigationBar.h"
#import "Global.h"
#import "Common.h"
#import "MBProgressHUD.h"
#import "CommonProgressHUD.h"
#import "NSObject_extra.h"
#import "Userinfo_model.h"
#import "SBJson.h"
#import "Common.h"
#import "MyselfMessageManager.h"
#import "MobClick.h"

@interface BirthdayViewController ()<UITableViewDataSource,UITableViewDelegate,MyselfMessageManagerDelegate>{
    UITableView *birthdayTableView;
    UIDatePicker *datePicker;
    
    UILabel *_openOrCloseLabel;
    
    MBProgressHUD *hudView;
    
    NSString *telShield;
}
@end

@implementation BirthdayViewController
@synthesize dateString;
@synthesize secretString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"BirthdayViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"BirthdayViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"编辑生日";
    self.view.backgroundColor = RGBACOLOR(249,249,249,1);
    
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
    
//    保存按钮
    [self rightBtn];
    
    [self loardTableView];
    
    [self initDatePicker];
}

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

-(void) initDatePicker{
    // 初始化UIDatePicker
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, ScreenHeight-250, 320, 250)];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文显示
    datePicker.locale = locale;
    RELEASE_SAFE(locale);
    // 设置时区
    [datePicker setTimeZone:[NSTimeZone systemTimeZone]];
    // 设置显示最大时间（此处为当前时间）
    [datePicker setMaximumDate:[NSDate date]];
    // 设置UIDatePicker的显示模式
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    // 当值发生改变的时候调用的方法
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];

    // 设置当前显示时间
    NSDateFormatter *formatter_minDate = [[NSDateFormatter alloc] init];
    [formatter_minDate setDateFormat:@"YYYY-MM-dd"];
    
    if (![self.dateString isEqualToString:@"(null)"]) {
        [datePicker setDate:[formatter_minDate dateFromString:self.dateString] animated:YES];
    }else{
        [datePicker setDate:[formatter_minDate dateFromString:@"1970-01-01"] animated:YES];
    }

    //    默认的时间
//    NSString* dateStr = [Common makeTime:[datePicker.date timeIntervalSince1970] withFormat:@"YYYY-MM-dd"];
//    self.dateString = dateStr;
    
    [self.view addSubview:datePicker];
}

- (void)datePickerValueChanged:(UIDatePicker *) sender {
    // 设置当前显示时间
    NSString* dateStr = [Common makeTime:[datePicker.date timeIntervalSince1970] withFormat:@"YYYY-MM-dd"];
    self.dateString = dateStr;
    [birthdayTableView reloadData];
}
-(void)rightBtn{
     //导航栏右按钮
     UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
     rightBtn.frame = CGRectMake(20, 7, 40, 30);
     rightBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
     [rightBtn setTitle:@"保存" forState:UIControlStateNormal];
     [rightBtn setTitleColor:RGBACOLOR(42, 119, 195, 1) forState:UIControlStateNormal];
     [rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
     
     UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
     self.navigationItem.rightBarButtonItem = rightItem;
     [rightItem release];
}

-(void)loardTableView{
    birthdayTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 30, ScreenWidth, 50) style:UITableViewStylePlain];
    birthdayTableView.delegate = self;
    birthdayTableView.dataSource = self;
    birthdayTableView.scrollEnabled = NO;
    birthdayTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [self.view addSubview:birthdayTableView];
}

-(void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//右导航栏点击按钮
- (void)rightBtnClick {
    if ([Common connectedToNetwork]) {
        [self hideHudView];
        hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"请稍候..."];
        if ([_openOrCloseLabel.text isEqualToString:@"公开"]) {
            telShield = @"0";
        }else{
            telShield = @"1";
        }
        //   保存当前的状态(保密或者公开，0：未屏蔽 1：屏蔽)
        NSMutableDictionary *provinceDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"birthdayShield",@"field",telShield,@"val", nil];
        MyselfMessageManager* dlManager = [[MyselfMessageManager alloc] init];
        [dlManager accessUpdateUserInfoData:provinceDic];
        
        //   保存当前的类型
        NSMutableDictionary *cityDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"birthday",@"field",self.dateString,@"val", nil];
        MyselfMessageManager* cityManager = [[MyselfMessageManager alloc] init];
        cityManager.delegate = self;
        [cityManager accessUpdateUserInfoData:cityDic];
    }else{
        [self alertWithFistButton:@"确定" SencodButton:nil Message:@"网络不给力呀，请稍后重试"];

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
        
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(232, 15, 40, 20)];
        lable.tag = 11112;
        lable.textColor = [UIColor grayColor];
        lable.font = [UIFont systemFontOfSize:13.0];
        lable.backgroundColor = [UIColor clearColor];
        [cell addSubview:lable];
        [lable release];
    }
    _openOrCloseLabel = (UILabel *)[cell viewWithTag:11112];
    if (![self.dateString isEqualToString:@"(null)"]) {
        cell.textLabel.text = self.dateString;
    }else{
        // 设置当前显示时间
        NSDateFormatter *formatter_minDate = [[NSDateFormatter alloc] init];
        [formatter_minDate setDateFormat:@"YYYY-MM-dd"];

        cell.textLabel.text = [Common makeTime:[[formatter_minDate dateFromString:@"1970-01-01"] timeIntervalSince1970] withFormat:@"YYYY-MM-dd"];
    }
    
    UISwitch *switchView = [[UISwitch alloc]initWithFrame:CGRectMake(260, 5, 70, 30)];
    if (!IOS7_OR_LATER) {
        _openOrCloseLabel.frame = CGRectMake(212, 15, 40, 20);
        switchView.frame = CGRectMake(240, 10, 70, 30);
    }
    if ([self.secretString integerValue] == 0) {
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

- (void) hideHudView
{
    if (hudView) {
        [hudView hide:YES];
    }
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
                [contentDic setObject:self.dateString forKey:@"birthday"];
                [contentDic setObject:telShield forKey:@"birthdayShield"];
                
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
-(void)dealloc{
    RELEASE_SAFE(datePicker);
    [super dealloc];
}
@end
