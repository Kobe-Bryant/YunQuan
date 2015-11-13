//
//  MyselfViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "MyselfViewController.h"
#import "Global.h"
#import "SetViewController.h"
#import "MyselfTableHeaderView.h"
#import "SecondCell.h"
#import "FirstCell.h"
#import "ThirdCell.h"
#import "EditViewController.h"
#import "MyDynamicListViewController.h"
#import "NSObject_extra.h"
#import "RelateMeViewController.h"
#import "MBProgressHUD.h"
#import "CommonProgressHUD.h"
#import "MyselfMessageManager.h"
#import "Userinfo_model.h"
#import "OpenCompanyUsers_model.h"
#import "SBJson.h"
#import "UIImageView+WebCache.h"
#import "BrowserViewController.h"
#import "RelevantMe_model.h"
#import "UserModel.h"
#import "PublishPermissionViewController.h"
#import "Companie_LiveApp_model.h"
#import "CompanyLiveAppBrowserViewController.h"
#import "SelfBusinessCardViewController.h"
#import "UIButton+WebCache.h"
#import "TimeStamp_model.h"
#import "AppDelegate.h"
#import "DynamicListManager.h"
#import "MobClick.h"

#define redPointTag 4000

@interface MyselfViewController ()<MyselfMessageManagerDelegate,DynamicListManagerDelegate>{
    UITableView *myselfTableView;
    MBProgressHUD *hudView;
    
}

@property(nonatomic,retain)NSDictionary *userinfoDic;
@property(nonatomic,retain)NSDictionary *relevantMeInfoDic;
@property(nonatomic,retain)NSMutableArray *userinfoArray;
@property(nonatomic,retain)NSMutableArray *openCompanyUsersArray;
@property(nonatomic,retain)NSDictionary *openCompanyDic;

@property(nonatomic,retain)NSMutableArray *liveAppArray;
@property(nonatomic,retain)NSDictionary *liveAppDic;
@property (nonatomic, retain) MyselfTableHeaderView *persionView;


@end

@implementation MyselfViewController
@synthesize userinfoArray;
@synthesize openCompanyUsersArray;
@synthesize userinfoDic;
@synthesize openCompanyDic;
@synthesize relevantMeInfoDic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relateMeComment:) name:@"RelateMeComment" object:nil];
    }
    return self;
}

- (void)dealloc
{
    self.userinfoDic = nil;
    self.relevantMeInfoDic = nil;
    self.userinfoArray = nil;
    self.openCompanyUsersArray = nil;
    self.openCompanyDic = nil;
    self.liveAppArray = nil;
    self.liveAppDic = nil;
    
    self.persionView = nil;
    myselfTableView.delegate = nil;
    myselfTableView.tableHeaderView = nil;
    [myselfTableView release]; myselfTableView = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    滑动返回
    if (IOS7_OR_LATER) {
        self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    }

    self.view.backgroundColor = RGBACOLOR(249, 249, 249, 1);
    
    [self initRightSetBtn];
    
    [self initWithTableView]; //初始化tableview表视图
}

- (void)viewWillAppear:(BOOL)animated{
//    判断当前的我的资料是否有更新
//    LinkedBe_TsType myselfTsType = MYSELFINFORPROCESS;
//    long long myselfTs = [TimeStamp_model getTimeStampWithType:myselfTsType];
//    NSMutableDictionary *selfDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLongLong:myselfTs],@"ts", nil];
//    MyselfMessageManager* dlManager = [[MyselfMessageManager alloc] init];
//    [dlManager accessMyselfMessageData:selfDic];
    
    //    读取数据库中得数据
    [self readSqlData];
    [MobClick beginLogPageView:@"MySelfViewPage"];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"MySelfViewPage"];
}


-(void)readSqlData{
 
    Userinfo_model *userInfoModel = [[Userinfo_model alloc]init];
    self.userinfoArray = [userInfoModel getList];
    RELEASE_SAFE(userInfoModel);
    
    NSString *dicString = [[self.userinfoArray firstObject] objectForKey:@"content"];
    self.userinfoDic = [dicString JSONValue];
    
    OpenCompanyUsers_model *openCompanyModel = [[OpenCompanyUsers_model alloc]init];
    self.openCompanyUsersArray = [openCompanyModel getList];
    RELEASE_SAFE(openCompanyModel);
    
    RelevantMe_model *relevantMeModel = [[RelevantMe_model alloc] init];
    self.relevantMeInfoDic = [[[[relevantMeModel getList] firstObject] objectForKey:@"content"] JSONValue];
    RELEASE_SAFE(relevantMeModel);
    
    Companie_LiveApp_model *companyLiveModel = [[Companie_LiveApp_model alloc] init];
    self.liveAppDic = [[[[companyLiveModel getList] firstObject] objectForKey:@"content"] JSONValue];
    RELEASE_SAFE(companyLiveModel);
    
     [self loadTableHeadData];
    
    [myselfTableView reloadData];
}


- (void)initWithTableView {
    if (IOS7_OR_LATER) {
        myselfTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
    } else {
        myselfTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
    }
    myselfTableView.delegate = self;
    myselfTableView.dataSource = self;
    myselfTableView.backgroundColor = RGBACOLOR(249, 249, 249, 1);
//    myselfTableView.tableHeaderView = [self initWithHeadView];
    [self.view addSubview:myselfTableView];
    
    [self initWithHeadView];
}

- (void)initWithHeadView {
    MyselfTableHeaderView *persionV = [[MyselfTableHeaderView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 74.0)];
    self.persionView = persionV;
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 74.0)];
    myselfTableView.tableHeaderView = headerView;
    [myselfTableView.tableHeaderView addSubview:persionV];
    RELEASE_SAFE(headerView);
    RELEASE_SAFE(persionV);
}

-(void)loadTableHeadData{
    self.persionView.personNameLable.text = [self.userinfoDic objectForKey:@"realname"];
    if ([self.userinfoDic objectForKey:@"infoPercent"]) {
        self.persionView.dataImproveLable.text = [NSString stringWithFormat:@"资料完善程度%@%@",[self.userinfoDic objectForKey:@"infoPercent"],@"%"];//@"资料完善程度80%";
    }else{
        self.persionView.dataImproveLable.text = @"";//@"资料完善程度80%";
    }
    [self.persionView.editBtn addTarget:self action:@selector(editBtn) forControlEvents:UIControlEventTouchUpInside];
    
    CGSize nameSize = [self.persionView.personNameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:16.0] constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
    self.persionView.sexImage.frame = CGRectMake(nameSize.width + 75, 20, 12, 12);
    
    if ([[self.userinfoDic objectForKey:@"sex"] intValue] == 0) {
        [self.persionView.iconImageBtn setImageWithURL:[NSURL URLWithString:[self.userinfoDic objectForKey:@"portrait"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ico_default_portrait_male.png"]];
        
        self.persionView.sexImage.image = [UIImage imageNamed:@"ico_me_male.png"];
    }else{
        [self.persionView.iconImageBtn setImageWithURL:[NSURL URLWithString:[self.userinfoDic objectForKey:@"portrait"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ico_default_portrait_female.png"]];
        
        self.persionView.sexImage.image = [UIImage imageNamed:@"ico_me_female.png"];
    }
    
    [self.persionView.iconImageBtn addTarget:self action:@selector(iconImageBtnAction) forControlEvents:UIControlEventTouchUpInside];
}

/*
 *点击我的头像跳转
 */
-(void)iconImageBtnAction{
    SelfBusinessCardViewController *selfBusinessVC = [[SelfBusinessCardViewController alloc]init];
    selfBusinessVC.hidesBottomBarWhenPushed = YES;
    selfBusinessVC.bussinessType = NormalBussinessType;
    [self.navigationController pushViewController:selfBusinessVC animated:YES];
    [selfBusinessVC release];
}

//编辑资料
-(void)editBtn{
    [MobClick event:@"me_self_info_edit"];
    EditViewController *editVc = [[EditViewController alloc] init];
    editVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editVc animated:YES];
    [editVc release];
}

//设置
-(void)initRightSetBtn{
    UIButton* setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [setBtn setImage:IMGREADFILE(LinkeBe_Set_Image) forState:UIControlStateNormal];
    setBtn.frame = CGRectMake(20, 7, 30, 30);
    [setBtn addTarget:self action:@selector(setBtn) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:setBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem release];
}

-(void)setBtn{
    [MobClick event:@"setting_start"];
    SetViewController *setVc = [[SetViewController alloc] init];
    setVc.hidesBottomBarWhenPushed  = YES;
    [self.navigationController pushViewController:setVc animated:YES];
    [setVc release];
}

-(void) tureToPermissionView{
    PublishPermissionViewController* ppVC = [[PublishPermissionViewController alloc] init];
    ppVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ppVC animated:YES];
    [ppVC release];
}

//邀请开通公司轻APP
- (void)dredgeCompanyLightApp{
    //开通公司轻APP
    CompanyLiveAppBrowserViewController* browserVC = [[CompanyLiveAppBrowserViewController alloc] init];
    browserVC.url = [NSString stringWithFormat:@"%@?org_id=%@&user_id=%@",LIGHTAPPURL,[UserModel shareUser].org_id,[UserModel shareUser].user_id];
    browserVC.webTitle = @"开通企业场景应用";
    browserVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:browserVC animated:YES];
    [browserVC release];
}

#pragma mark -- UITableviewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:{
            static NSString *identifier1 = @"FirstCell";
            UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier1];
            if (!cell) {
                cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier1]autorelease];
                UIImage *image2 = [UIImage imageNamed:@"ico_group_arrow1.png"];
                UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(290,(50 - image2.size.height)/2 , image2.size.width, image2.size.height)];
                arrowImage.image = image2;
                [cell addSubview:arrowImage];
                [arrowImage release];
                
                cell.contentView.backgroundColor = [UIColor whiteColor];
                cell.imageView.layer.cornerRadius = 3.0;
                cell.imageView.layer.masksToBounds = YES;
                cell.textLabel.font = [UIFont systemFontOfSize:15.0];
                cell.textLabel.backgroundColor = [UIColor clearColor];
                cell.textLabel.textColor = RGBACOLOR(51, 51, 51, 1);
                cell.detailTextLabel.textColor = RGBACOLOR(136, 136, 136, 1);
                cell.detailTextLabel.backgroundColor = [UIColor clearColor];
                
                //访客红点提示
                if (indexPath.row == 1) {
                    UILabel *redPoint = [[UILabel alloc]initWithFrame:CGRectMake(260, (50-20)/2, 20, 20)];
                    redPoint.text = @"●";
                    redPoint.hidden = YES;
                    redPoint.textColor = [UIColor redColor];
                    redPoint.tag = redPointTag;
                    redPoint.font = KQLSystemFont(25);
                    redPoint.backgroundColor = [UIColor clearColor];
                    [cell addSubview:redPoint];
                    RELEASE_SAFE(redPoint);
                }
            }
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            switch (indexPath.row) {
                case 0:
                {
                    cell.imageView.image = IMGREADFILE(LinkeBe_Myself_MydynamicImage);
                    cell.textLabel.text = @"我的动态";
                }
                    break;
                case 1:
                {
//                    通过时间戳进行判断
                    cell.imageView.image = IMGREADFILE(LinkeBe_Myself_LinkMeImage);
                    cell.textLabel.text = @"与我相关";
//                    if ([self.relevantMeInfoDic objectForKey:@"realname"]) {
//                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@给我发了一条消息",[self.relevantMeInfoDic objectForKey:@"realname"]];
//                    }else{
//                        cell.detailTextLabel.text = @"";
//                    }
                    cell.detailTextLabel.backgroundColor =[UIColor clearColor];
                }
                    break;
                default:
                    break;
            }
            return cell;
        }
            break;
            //第二个section包括企业介绍 liveapp
        case 1:{
            static NSString *identifier2 = @"SecondCell";
            SecondCell *secondCell = [tableView dequeueReusableCellWithIdentifier:identifier2];
            if (!secondCell) {
                secondCell = [[[SecondCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2]autorelease];
                secondCell.contentView.backgroundColor = [UIColor whiteColor];

            }
            if ([self.liveAppDic count]>0&&[self.liveAppDic objectForKey:@"companyName"]) {
                [secondCell openCompanyLightApp];
                secondCell.companyLable.text = [self.liveAppDic objectForKey:@"companyName"];
                if ([self.liveAppDic objectForKey:@"pv"]) {
                    secondCell.countLable.text = [NSString stringWithFormat:@"%@次浏览",[self.liveAppDic objectForKey:@"pv"]];
                } else {
                    secondCell.countLable.text = [NSString stringWithFormat:@"%@次浏览",@"0"];
                }
               
                [secondCell.headImage setImageWithURL:[NSURL URLWithString:[self.liveAppDic objectForKey:@"logoUrl"]] placeholderImage:[UIImage imageNamed:@"icon_liveApp_default.png"]];
            }else{
                [secondCell noDredgeCompanyLightApp];
                [secondCell.dredgeBtn addTarget:self action:@selector(dredgeCompanyLightApp) forControlEvents:UIControlEventTouchUpInside];
            }
            return secondCell;
        }
            break;
            //第三个section包括 开通liveapp案例
        case 2:{
            static NSString *identifier3 = @"ThirdCell";
            ThirdCell *thirdCell = [tableView dequeueReusableCellWithIdentifier:identifier3];
            if (!thirdCell) {
                thirdCell = [[[ThirdCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3]autorelease];
                thirdCell.contentView.backgroundColor = [UIColor whiteColor];
            }
            thirdCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSInteger row = indexPath.row;
            for (NSInteger i = 0; i < 2; i++){
                //奇数
                if (row*2+i>self.openCompanyUsersArray.count-1)
                {
                    break;
                }
                if ([self.openCompanyUsersArray count] > 0) {
                    self.openCompanyDic = [[[self.openCompanyUsersArray objectAtIndex:row*2 + i] objectForKey:@"content"] JSONValue];
                }
                
                if (i==0) {
                    thirdCell.leftView.titleNameLabel.text = [self.openCompanyDic objectForKey:@"realname"];
                    thirdCell.leftView.companyLabel.text = [self.openCompanyDic objectForKey:@"companyName"];
                    [thirdCell.leftView.iconImageView setImageWithURL:[NSURL URLWithString:[self.openCompanyDic objectForKey:@"portrait"]] placeholderImage:[UIImage imageNamed:@"ico_default_portrait_male.png"]];
                    thirdCell.leftView.tag = 100+ row*2 + i;
                    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thirdCellViewTaped:)];
                    [thirdCell.leftView addGestureRecognizer:tapRecognizer];
                    [tapRecognizer release];
                } else {
                    thirdCell.rightView.titleNameLabel.text = [self.openCompanyDic objectForKey:@"realname"];
                    thirdCell.rightView.companyLabel.text = [self.openCompanyDic objectForKey:@"companyName"];
                    [thirdCell.rightView.iconImageView setImageWithURL:[NSURL URLWithString:[self.openCompanyDic objectForKey:@"portrait"]] placeholderImage:[UIImage imageNamed:@"ico_default_portrait_male.png"]];
                    thirdCell.rightView.tag = 100+ row*2 + i;
                    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thirdCellViewTaped:)];
                    [thirdCell.rightView addGestureRecognizer:tapRecognizer];
                    [tapRecognizer release];
                    
                }
            }
            
            return thirdCell;
        }
            break;
            
//        case 3:{
//            static NSString *identifier1 = @"FourCell";
//            UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier1];
//            if (!cell) {
//                cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1]autorelease];
//                cell.textLabel.font = [UIFont systemFontOfSize:15.0];
//                cell.textLabel.textColor = [UIColor blueColor];
//            }
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            cell.imageView.image = [UIImage imageNamed:@"group_logo1.png"];
//            cell.textLabel.text = @"+添加组织";
//            
//            return cell;
//        }
//            break;
            
        default:
            break;
    }
    
    return nil;
    
}

#pragma mark -- UITableviewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 50.0;
    } else {
        return 64.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (IOS7_OR_LATER) {
        if (section == 1) {
            return 13.0;
        }else if(section == 2){
            return 3.0;
        }
//        else if(section == 3){
//            return 13.0;
//        }
    }
    return 0.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //与我相关
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                [MobClick event:@"me_my_feeds"];
                NSDictionary* permissionDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UserModel shareUser].org_id,@"orgId",
                                               [UserModel shareUser].orgUserId,@"orgUserId",
                                               nil];
                DynamicListManager* dyManager = [[DynamicListManager alloc] init];
                dyManager.delegate = self;
                [dyManager checkPublishPermissionWithParam:permissionDic];

            }
                break;
            case 1:
            {
                [MobClick event:@"me_relate_me"];
                UILabel *lable = (UILabel *)[self.view viewWithTag:redPointTag];
                if (lable.hidden == NO) {
                    lable.hidden = YES;
                }
                AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                appDelegate.newMySelfCommentLabel.hidden = YES;
                
                RelateMeViewController *relateMeVC = [[RelateMeViewController alloc]init];
                relateMeVC.hidesBottomBarWhenPushed  = YES;
                [self.navigationController pushViewController:relateMeVC animated:YES];
                [relateMeVC release];
            }
                break;
            default:
                break;
        }
    }else if (indexPath.section == 1){
        [MobClick event:@"me_liveapp"];
        if ([[self.liveAppDic objectForKey:@"liveappList"] length]!=0) {
            //开通公司轻APP
            CompanyLiveAppBrowserViewController* browserVC = [[CompanyLiveAppBrowserViewController alloc] init];
            browserVC.hidesBottomBarWhenPushed = YES;
            browserVC.url = [self.liveAppDic objectForKey:@"liveappList"];
            browserVC.webTitle = @"开通企业场景应用";
            [self.navigationController pushViewController:browserVC animated:YES];
            [browserVC release];
        }else{
            [self dredgeCompanyLightApp];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, 80.f)];
        headView.backgroundColor = [UIColor clearColor];
        UILabel *lable = [[UILabel alloc]init];
        if (IOS7_OR_LATER) {
            lable.frame = CGRectMake(15, 12, 280, 20);
        } else {
            lable.frame = CGRectMake(15, 2, 280, 20);
        }
        lable.text = @"企业空间(免费赠送场景应用)";
        lable.textColor = RGBACOLOR(136, 136, 136, 1);
        lable.font = [UIFont systemFontOfSize:12.0];
        lable.backgroundColor = [UIColor clearColor];
        [headView addSubview:lable];
        
        [lable release];
        return [headView autorelease];
    }else if(section ==1){
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, 20.f)];
        headView.backgroundColor = [UIColor clearColor];
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 2, 280, 20)];
        lable.text = @"企业空间经典案例";
        lable.textColor = RGBACOLOR(136, 136, 136, 1);
        lable.font = [UIFont systemFontOfSize:12.0];
        lable.backgroundColor = [UIColor clearColor];
        [headView addSubview:lable];
        
        [lable release];
        return [headView autorelease];
    }
    if (IOS6_OR_LATER) {
        if (section == 2) {
            UIView *headView = [[UIView alloc] initWithFrame:CGRectZero];
            return [headView autorelease];
        }

    }
//    else if (section == 2) {
//        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, 20.f)];
//        headView.backgroundColor = [UIColor clearColor];
//        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 2, 280, 20)];
//        lable.text = @"组织切换";
//        lable.textColor = RGBACOLOR(51, 51, 51, 1);
//        lable.font = [UIFont systemFontOfSize:12.0];
//        lable.backgroundColor = [UIColor clearColor];
//        [headView addSubview:lable];
//        
//        [lable release];
//        return [headView autorelease];
//    }
    return nil;
    
}

#pragma mark --  各种手势按钮点击事件

//开通了企业介绍
- (void)thirdCellViewTaped:(UITapGestureRecognizer *)recognizer {
    [MobClick event:@"liveapp_case_right"];
    [MobClick event:@"liveapp_case_left"];
    NSInteger tag = [recognizer view].tag-100;
    //开通公司轻APP
    BrowserViewController* browserVC = [[BrowserViewController alloc] init];
    browserVC.hidesBottomBarWhenPushed = YES;
    browserVC.pushType = MyselfPush;
    browserVC.webvieUrl = [[[[self.openCompanyUsersArray objectAtIndex:tag] objectForKey:@"content"] JSONValue] objectForKey:@"lightapp"];
    browserVC.webTitle = [[[[self.openCompanyUsersArray objectAtIndex:tag] objectForKey:@"content"] JSONValue] objectForKey:@"realname"];
    [self.navigationController pushViewController:browserVC animated:YES];
    [browserVC release];
}

//与我相关 红点提示
- (void)relateMeComment:(NSNotification *)notification {
    NSDictionary *dic = notification.object;
    
    UILabel *lable = (UILabel *)[self.view viewWithTag:redPointTag];
    lable.hidden = NO;
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.newMySelfCommentLabel.hidden = NO;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *cell = [myselfTableView cellForRowAtIndexPath:indexPath];
    if ([dic objectForKey:@"msg"]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"msg"]];
    }else{
        cell.detailTextLabel.text = @"";
    }
}

//底部按钮点击事件
- (void)bottomBtnSend {
    NSLog(@"--");
}

- (void) hideHudView
{
    if (hudView) {
        [hudView hide:YES];
    }
}

//当前我的个人资料的返回值
-(void)getMyselfMessageManagerHttpCallBack:(NSArray*) arr requestCallBackDic:(NSDictionary *)dic interface:(LinkedBe_WInterface) interface{
    [self hideHudView];
    switch (interface) {
        case LinkedBe_Myself_PersonalData:
        {
            if ([[dic objectForKey:@"errcode"] integerValue]!=0) {
                [self alertWithFistButton:@"确定" SencodButton:nil Message:[dic objectForKey:@"errmsg"]];
            }
        }
            break;
        default:
            break;
    }
}

-(void) getDynamicListHttpCallBack:(NSArray *)arr interface:(LinkedBe_WInterface)interface{
    //过滤请求结果
    if (arr.count) {
        switch (interface) {
            case LinkedBe_PermissionList:
            {
                if ([UserModel shareUser].isHavePermission) {
                    MyDynamicListViewController *myDynamicList = [[MyDynamicListViewController alloc] init];
                    myDynamicList.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:myDynamicList animated:YES];
                    RELEASE_SAFE(myDynamicList);
                }else{
                    [self tureToPermissionView];
                }
            }
                break;
            default:
                break;
        }
    }
}
@end
