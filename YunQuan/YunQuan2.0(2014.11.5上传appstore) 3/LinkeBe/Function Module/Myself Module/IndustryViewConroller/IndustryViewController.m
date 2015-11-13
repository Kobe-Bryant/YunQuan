//
//  IndustryViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-29.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "IndustryViewController.h"
#import "UIViewController+NavigationBar.h"
#import "Global.h"
#import "EditViewController.h"
#import "MBProgressHUD.h"
#import "CommonProgressHUD.h"
#import "MyselfMessageManager.h"
#import "Userinfo_model.h"
#import "SBJson.h"
#import "NSObject_extra.h"
#import "Common.h"
#import "MobClick.h"

@interface IndustryViewController ()<UITableViewDataSource,UITableViewDelegate,MyselfMessageManagerDelegate>
{
    UITableView *tradeListTableView;
    NSArray *industryArray;
    
    NSInteger currentIndex;
    
     MBProgressHUD *hudView;
}
@end

@implementation IndustryViewController
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
    [MobClick beginLogPageView:@"IndustryViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"IndustryViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择行业";
    self.view.backgroundColor = RGBACOLOR(249,249,249,1);
    
    [self initRightSetBtn];
    
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
    
    industryArray = [[NSArray alloc] initWithObjects:@"金融",@"房产",@"制造",@"政府",@"汽车",@"通信",@"教育",@"医疗",@"法律",@"互联网",@"贸易",@"运输",@"酒店/旅游",@"餐饮",@"快消",@"传媒"@"文化/娱乐",@"电子",@"生物",@"能源",@"印刷",@"工艺",@"学生",@"其它", nil];
    
    [self loardTableView];
}

-(void)loardTableView{
    tradeListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, MainHeight) style:UITableViewStylePlain];
    tradeListTableView.delegate = self;
    tradeListTableView.dataSource = self;
    tradeListTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tradeListTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [self.view addSubview:tradeListTableView];
}

-(void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//设置
-(void)initRightSetBtn{
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

//右导航栏点击按钮
- (void)rightBtnClick {
    if ([Common connectedToNetwork]) {
        [self hideHudView];
        hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"请稍候..."];
        
        NSMutableDictionary *selfDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.fieldString,@"field",[industryArray objectAtIndex:currentIndex],@"val", nil];
        
        MyselfMessageManager* dlManager = [[MyselfMessageManager alloc] init];
        dlManager.delegate = self;
        [dlManager accessUpdateUserInfoData:selfDic];
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
    return [industryArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AreaTableView"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:
                 UITableViewCellStyleSubtitle reuseIdentifier:@"AreaTableView"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
   
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.textLabel.text = [industryArray objectAtIndex:indexPath.row];
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
                [contentDic setObject:[industryArray objectAtIndex:currentIndex] forKey:self.fieldString];
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
                [self alertWithFistButton:@"确定" SencodButton:nil Message:@"修改失败"];
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
