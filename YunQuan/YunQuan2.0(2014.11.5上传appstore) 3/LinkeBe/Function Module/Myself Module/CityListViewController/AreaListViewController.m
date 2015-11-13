//
//  CityListViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-29.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "AreaListViewController.h"
#import "UIViewController+NavigationBar.h"
#import "Global.h"
#import "CityViewController.h"
#import "UserModel.h"
#import "NSObject_extra.h"
#import "CommonProgressHUD.h"
#import "MyselfMessageManager.h"
#import "Userinfo_model.h"
#import "SBJson.h"
#import "Common.h"
#import "MobClick.h"

@interface AreaListViewController ()<UITableViewDataSource,UITableViewDelegate,MyselfMessageManagerDelegate>
{
    UITableView *areaListTableView;
    NSArray *tableHeaderArary;
    MBProgressHUD *hudView;
    
    NSInteger currentIndex;
    
    NSString *selectStateString;
}
@end

@implementation AreaListViewController
@synthesize provincesArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"AreaListViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"AreaListViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择地区";
    self.view.backgroundColor = RGBACOLOR(249,249,249,1);
    
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
    
    //    初始化保存按钮
//    [self saveBarButton];
    
    tableHeaderArary = [[NSArray alloc]initWithObjects:@"按省份选择城市", nil];
    
    [self loardTableView];
    
    [self loardProvincesData];
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
- (void)saveClick{
    [self hideHudView];
    hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"请稍候..."];
    
    NSMutableDictionary *selfDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"province",@"field",selectStateString,@"val", nil];
    MyselfMessageManager* dlManager = [[MyselfMessageManager alloc] init];
    dlManager.delegate = self;
    [dlManager accessUpdateUserInfoData:selfDic];
}

-(void)loardProvincesData{
    self.provincesArray = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"city.plist" ofType:nil]];
    [areaListTableView reloadData];
}

-(void)loardTableView{
    areaListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, MainHeight) style:UITableViewStylePlain];
    areaListTableView.delegate = self;
    areaListTableView.dataSource = self;
    areaListTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    areaListTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [self.view addSubview:areaListTableView];
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
#pragma UITableViewDelegate
#pragma mark UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.provincesArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AreaTableView"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:
                 UITableViewCellStyleSubtitle reuseIdentifier:@"AreaTableView"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
//    if (indexPath.section == 0) {
//        cell.textLabel.text = @"深圳";
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }else{
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [[self.provincesArray objectAtIndex:indexPath.row] objectForKey:@"state"];
//    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, 20.f)];
    headView.backgroundColor = [UIColor whiteColor];
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 2, 280, 20)];
    lable.text = [tableHeaderArary objectAtIndex:section];
    lable.textColor = RGBACOLOR(136, 136, 136, 1);
    lable.font = [UIFont systemFontOfSize:12.0];
    lable.backgroundColor = [UIColor clearColor];
    [headView addSubview:lable];
    [lable release];
    return [headView autorelease];
}


#pragma mark UITableViewDelegate implementation
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (indexPath.section == 0) {
//        if(indexPath.row==currentIndex){
//            return;
//        }
//    }else if (indexPath.section == 1) {
        CityViewController *cityList = [[CityViewController alloc] init];
        cityList.cityArray = [[self.provincesArray objectAtIndex:indexPath.row] objectForKey:@"cities"];
        cityList.areraString = [[self.provincesArray objectAtIndex:indexPath.row] objectForKey:@"state"];
        [self.navigationController pushViewController:cityList animated:YES];
        RELEASE_SAFE(cityList);
//    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
//    if(indexPath.section==0){
//        return UITableViewCellAccessoryCheckmark;
//    }else{
        return UITableViewCellAccessoryDisclosureIndicator;
//    }
}

-(void)dealloc{
    RELEASE_SAFE(areaListTableView);
    [super dealloc];
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
            if (dic == nil) {
                //               修改成功以后更换当前数据库里面的内容
                Userinfo_model *userInfoModel = [[Userinfo_model alloc]init];
                NSString *dicString = [[[userInfoModel getList] firstObject] objectForKey:@"content"];
                
                NSMutableDictionary *dic = [dicString JSONValue];
                [dic setObject:selectStateString forKey:@"province"];
                
                userInfoModel.where = [NSString stringWithFormat:@"orgUserId = %d",[[[dicString JSONValue] objectForKey:@"orgUserId"] intValue]];
                
                // 个人信息
                NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [[dicString JSONValue] objectForKey:@"orgUserId"],@"orgUserId",
                                         [dic JSONRepresentation],@"content",
                                         nil];
                NSArray *userArray = [userInfoModel getList];
                if ([userArray count] > 0) {
                    [userInfoModel updateDB:userDic];
                } else {
                    [userInfoModel insertDB:userDic];
                }
            }else{
                [self alertWithFistButton:@"确定" SencodButton:nil Message:[dic objectForKey:@"errmsg"]];
            }
            
        }
            break;
        default:
            break;
    }
}
@end
