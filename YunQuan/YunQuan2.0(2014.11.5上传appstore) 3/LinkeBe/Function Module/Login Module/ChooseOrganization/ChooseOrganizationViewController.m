//
//  ChooseOrganizationViewController.m
//  ql
//
//  Created by yunlai on 14-5-22.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "ChooseOrganizationViewController.h"
#import "chooseOrg_model.h"
#import "UIImageView+WebCache.h"
#import "WelcomeViewController.h"
#import "DBOperate.h"
#import "UserModel.h"
#import "Global.h"
#import "UIViewController+NavigationBar.h"
#import "AppDelegate.h"
#import "LinkedBeHttpRequest.h"
#import "SnailSystemiMOperator.h"
#import "MajorCircleManager.h"
#import "DynamicListManager.h"
#import "TimeStamp_model.h"
#import "MobClick.h"

@interface ChooseOrganizationViewController ()
{
    UITableView *_orgTableView;
    
    int selectIndex;

}

@end

@implementation ChooseOrganizationViewController
@synthesize orgArr = _orgArr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _orgArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"ChooseOrganizationViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"ChooseOrganizationViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self creteaRightButton];
    
    self.title = @"选择组织";
    
    self.view.backgroundColor = RGBACOLOR(249,249,249,1);

    //获取组织数据
//    [self getOrgArrayData];
    
    [self loadMainView];

}

//-(void) getOrgArrayData{
//    chooseOrg_model *orgMod = [[chooseOrg_model alloc]init];
//    orgMod.where = nil;
//    NSArray* arr = [orgMod getList];
//    self.orgArr = arr;
//    RELEASE_SAFE(orgMod);
//}

/**
 *  导航栏右边按钮
 */
- (void)creteaRightButton{
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    backButton.hidden = YES;
    [self setBackBarButtonItem:backButton];
}

-(void) backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadMainView{
    _orgTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight+20) style:UITableViewStylePlain];
    _orgTableView.delegate = self;
    _orgTableView.dataSource = self;
    _orgTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (IOS7_OR_LATER) {
        _orgTableView.separatorInset = UIEdgeInsetsZero;
    }
    [self.view addSubview:_orgTableView];
    
}

//进入欢迎页面
- (void)enterWelcomeViewController
{
    if ([[[self.orgArr objectAtIndex:selectIndex] objectForKey:@"isDisabled"] integerValue]==0) {
        WelcomeViewController* welcomVc = [[WelcomeViewController alloc] init];
        welcomVc.orgDataDic = [self.orgArr objectAtIndex:selectIndex];
        [self.navigationController pushViewController:welcomVc animated:NO];
        RELEASE_SAFE(welcomVc);
    }else{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"账号被禁用，请联系所在组织。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        RELEASE_SAFE(alertView);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.orgArr.count!=0) {
        return self.orgArr.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 135;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    selectIndex = indexPath.row;
    
    [self enterWelcomeViewController];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"orgCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
//        UIImageView* lineImgV = [[UIImageView alloc] init];
//        lineImgV.frame = CGRectMake(0, 134, self.view.bounds.size.width, 1);
//        lineImgV.image = IMGREADFILE(@"img_feed_line_gray.png");
//        [cell.contentView addSubview:lineImgV];
//        RELEASE_SAFE(lineImgV);
    }
//    cell.contentView.backgroundColor = [[ThemeManager shareInstance] getColorWithName:@"COLOR_AUXILIARY"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *orgImge =  [[UIImageView alloc]init];
    orgImge.frame = CGRectMake(20.f, 15.f, 280.f, 105);
    orgImge.backgroundColor = [UIColor clearColor];
    NSURL *urlImg = [NSURL URLWithString:[[self.orgArr objectAtIndex:indexPath.row] objectForKey:@"catPic"]];
    [orgImge setImageWithURL:urlImg placeholderImage:IMGREADFILE(@"img_landing_default220.png")];
    [cell.contentView addSubview:orgImge];
    
    /////--------飞入动画--------//////
    CGFloat rotationAngleDegrees = 0;
    CGFloat rotationAngleRadians = rotationAngleDegrees * (M_PI/180);
    
    CGPoint offsetPositioning;
    if (indexPath.row %2 == 0) {
        offsetPositioning = CGPointMake(-400, -20);
    }else{
        offsetPositioning = CGPointMake(400, -20);
    }
    
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DRotate(transform, rotationAngleRadians, 0.0, 0.0, 1.0);
    transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y, 0.0);
    
    
    UIView *card = [cell contentView];
    card.layer.transform = transform;
    card.layer.opacity = 0.8;
    
    
    [UIView animateWithDuration:1.f animations:^{
        card.layer.transform = CATransform3DIdentity;
        card.layer.opacity = 1;
    }];
    /////--------飞入动画--------//////
    
    return cell;
}


-(void) dealloc{
    RELEASE_SAFE(proView);
    RELEASE_SAFE(HUD);
    RELEASE_SAFE(timer);
    RELEASE_SAFE(_orgArr);
    
    [super dealloc];
}

@end
