//
//  CityViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-29.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "CityViewController.h"
#import "UIViewController+NavigationBar.h"
#import "Global.h"
#import "EditViewController.h"
#import "UserModel.h"
#import "NSObject_extra.h"
#import "CommonProgressHUD.h"
#import "MyselfMessageManager.h"
#import "Userinfo_model.h"
#import "SBJson.h"
#import "Common.h"
#import "MobClick.h"

@interface CityViewController ()<UITableViewDataSource,UITableViewDelegate,MyselfMessageManagerDelegate>
{
    UITableView *cityListTableView;
    MBProgressHUD *hudView;
    
    NSString *selectStateString;
    
    NSInteger currentIndex;
}
@end

@implementation CityViewController
@synthesize cityArray;
@synthesize areraString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"CityViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"CityViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"选择城市";
    self.view.backgroundColor = RGBACOLOR(249,249,249,1);
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
    
    //    初始化保存按钮
    [self saveBarButton];
    
    [self loardTableView];
    
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

#pragma mark - 保存
//- (void)saveClick{
//    [self hideHudView];
//    hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"请稍候..."];
//    
//    NSMutableDictionary *selfDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"city",@"field",[self.cityArray objectAtIndex:currentIndex],@"val", nil];
//    MyselfMessageManager* dlManager = [[MyselfMessageManager alloc] init];
//    dlManager.delegate = self;
//    [dlManager accessUpdateUserInfoData:selfDic];
//}

-(void)loardTableView{
    cityListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, MainHeight) style:UITableViewStylePlain];
    cityListTableView.delegate = self;
    cityListTableView.dataSource = self;
    cityListTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    cityListTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [self.view addSubview:cityListTableView];
}


-(void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveClick{
    if ([Common connectedToNetwork]) {
        [self hideHudView];
        hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"请稍候..."];
        //    保存当前的省份
        NSMutableDictionary *provinceDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"province",@"field",self.areraString,@"val", nil];
        MyselfMessageManager* dlManager = [[MyselfMessageManager alloc] init];
        //    dlManager.delegate = self;
        [dlManager accessUpdateUserInfoData:provinceDic];
        
        //    保存当前的城市
        NSMutableDictionary *cityDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"city",@"field",[self.cityArray objectAtIndex:currentIndex],@"val", nil];
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
    return [self.cityArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AreaTableView"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:
                 UITableViewCellStyleSubtitle reuseIdentifier:@"AreaTableView"] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.textLabel.text = [self.cityArray objectAtIndex:indexPath.row];
    return cell;
}
#pragma mark UITableViewDelegate implementation
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row==currentIndex){
        return;
    }
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:currentIndex
                                                   inSection:0];
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    currentIndex=indexPath.row;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==currentIndex){
        return UITableViewCellAccessoryCheckmark;
    }else{
        return UITableViewCellAccessoryNone;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void) hideHudView
{
    if (hudView) {
        [hudView hide:YES];
    }
}

-(void)dealloc{
    RELEASE_SAFE(cityListTableView);
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
                
                //修改成功以后更换当前数据库里面的内容
                Userinfo_model *userInfoModel = [[Userinfo_model alloc]init];
                NSString *dicString = [[[userInfoModel getList] firstObject] objectForKey:@"content"];
                
                NSMutableDictionary *contentDic = [dicString JSONValue];
                [contentDic setObject:[self.cityArray objectAtIndex:currentIndex] forKey:@"city"];
                
                [contentDic setObject:self.areraString forKey:@"province"];
                
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
            for (UIViewController *viewController in self.navigationController.viewControllers) {
                if ([viewController isKindOfClass:[EditViewController class]]) {
                    [self.navigationController popToViewController:viewController animated:YES];
                }
            }
        }
            break;
        default:
            break;
    }
}
@end
