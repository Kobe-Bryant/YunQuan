//
//  SetViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-16.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SetViewController.h"
#import "UIViewController+NavigationBar.h"
#import "Global.h"
#import "upgrade_model.h"
#import "AboutUsViewController.h"
#import "ServiceViewController.h"
#import "CommonProgressHUD.h"
#import "MyselfMessageManager.h"
#import "SnailSystemiMOperator.h"
#import "AppDelegate.h"
#import "SessionDataOperator.h"
#import "SecretarySingleton.h"
#import "NSObject_extra.h"

#import "message_push_model.h"
#import "MobClick.h"

@interface SetViewController ()<UITableViewDelegate,UITableViewDataSource,MyselfMessageManagerDelegate>{

    UITableView * _setTableView;
    MBProgressHUD *hudView;
    
    //消息设置状态
    NSDictionary* pushStatusDic;
    
    //状态key
    NSString* statusKey;
    //状态值
    int statusValue;
}

@end

@implementation SetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    RELEASE_SAFE(_setTableView);
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"SetViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"SetViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置";
    self.view.backgroundColor = RGBACOLOR(249, 249, 249, 1);
    
//    if (IOS7_OR_LATER) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
    
    [self getMessagePushStatus];
    
    [self initWithTableView]; //初始化视图
    
}

- (void)initWithTableView {
    if (IOS7_OR_LATER) {
        _setTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
    } else {
        _setTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight - 44) style:UITableViewStylePlain];
    }
    if (IOS7_OR_LATER) {
        _setTableView.separatorInset = UIEdgeInsetsZero;
    }
    _setTableView.delegate = self;
    _setTableView.dataSource = self;
    _setTableView.tableFooterView = [self initWithFootView];
    [_setTableView setBackgroundColor:RGBACOLOR(249, 249, 249, 1)];
    [self.view addSubview:_setTableView];
}

- (UIView *)initWithFootView {
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 200)];
    sectionView.backgroundColor = RGBACOLOR(249, 249, 249, 1);
    
    UIButton *quitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [quitBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [quitBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    quitBtn.layer.borderWidth = 0.5;
    quitBtn.layer.borderColor = [UIColor redColor].CGColor;
    quitBtn.layer.cornerRadius = 4.0;
    quitBtn.layer.masksToBounds = YES;
    quitBtn.frame = CGRectMake(20, 40, ScreenWidth - 40, 44);
    [quitBtn addTarget:self action:@selector(quitButton) forControlEvents:UIControlEventTouchUpInside];
    [sectionView addSubview:quitBtn];
    
    UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(quitBtn.frame) + 50, CGRectGetMaxY(quitBtn.frame) +20, 250, 30)];
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.text = @"创新商人工作和生活方式";
    titleLable.font = [UIFont systemFontOfSize:15.0];
    titleLable.textColor = RGBACOLOR(136, 136, 136, 1);
    [sectionView addSubview:titleLable];
    [titleLable release];
    
    return [sectionView autorelease];
}

//退出im的服务器
-(void)logoutSend{
    SnailSystemiMOperator *systemOut = [[SnailSystemiMOperator alloc] init];
    [systemOut loginIMServerOut];
    [systemOut release];
}

//获取消息设置状态
-(void) getMessagePushStatus{
    NSDictionary* dic = [message_push_model getMessagePushInfoWithUserId:[[UserModel shareUser].user_id intValue]];
    if (dic == nil) {
        //默认打开并记录状态
        pushStatusDic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [UserModel shareUser].user_id,@"userId",
                         [NSNumber numberWithInt:1],@"chatStatus",
                         [NSNumber numberWithInt:1],@"updateStatus",
                         [NSNumber numberWithInt:1],@"replayStatus",
                         nil];
        [message_push_model updateOrInsertPushStatus:pushStatusDic];
    }else{
        pushStatusDic = [dic copy];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (IOS6_OR_LATER) {
        if (scrollView == _setTableView){
            CGFloat sectionHeaderHeight = 30;
            if (scrollView.contentOffset.y<=sectionHeaderHeight && scrollView.contentOffset.y>=0) {
                scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
            } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
                scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
            }
        }
    }
}

#pragma mark -- UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        static NSString *identifier = @"Cell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]autorelease];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.textLabel.textColor = RGBACOLOR(51, 51, 51, 1);
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UISwitch *switchView = [[UISwitch alloc]init];
            if (IOS7_OR_LATER) {
                switchView.frame = CGRectMake(260, 5, 70, 30);
            } else {
                switchView.frame = CGRectMake(240, 5, 70, 30);
            }
            int status;
            switch (indexPath.row) {
                case 0:
                    status = [[pushStatusDic objectForKey:@"chatStatus"] intValue];
                    break;
                case 1:
                    status = [[pushStatusDic objectForKey:@"replayStatus"] intValue];
                    break;
                case 2:
                    status = [[pushStatusDic objectForKey:@"updateStatus"] intValue];
                    break;
                default:
                    break;
            }
            switchView.on = status==0?NO:YES;
            switchView.tag = 800 +indexPath.row;
            [switchView addTarget:self action:@selector(switchView:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:switchView];
            [switchView release];
        }
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"聊天消息提醒";
                break;
            case 1:
                cell.textLabel.text = @"动态回复提醒";
                break;
            case 2:
                cell.textLabel.text = @"动态更新提醒";
                break;
                
            default:
                break;
        }
        return cell;
        
    } else if (indexPath.section == 1) {
        
        static NSString *identifier = @"Cell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]autorelease];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.textLabel.textColor = RGBACOLOR(51, 51, 51, 1);
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            //箭头
            UIImage *image = [UIImage imageNamed:@"ico_group_arrow1.png"];
            UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(290,(40 - image.size.height)/2 , image.size.width, image.size.height)];
            arrowImage.image = image;
            [cell addSubview:arrowImage];
            [arrowImage release];
        }
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"提建议";
                break;
            case 1:
                cell.textLabel.text = @"检测新版本";
                break;
            case 2:
                cell.textLabel.text = @"评分支持下";
                break;
            case 3:
                cell.textLabel.text = @"关于云圈";
                break;
            case 4:
                cell.textLabel.text = @"服务协议";
                break;
            default:
                break;
        }
        return cell;
    }
    
    
    return nil;
}

#pragma mark -- UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    sectionView.backgroundColor = RGBACOLOR(249, 249, 249, 1);
        
    UILabel *titleLable = [[UILabel alloc]init];
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.font = [UIFont systemFontOfSize:13.0];
    titleLable.textColor = RGBACOLOR(90, 90, 90, 1);
    [sectionView addSubview:titleLable];
    [titleLable release];
    
    if (section == 0) {
        if (IOS7_OR_LATER) {
            titleLable.frame = CGRectMake(15, 12, ScreenWidth, 20);
        } else {
            titleLable.frame = CGRectMake(15, 6, ScreenWidth, 20);
        }
        
        titleLable.text = @"消息提醒设置";
    } else if (section == 1) {
        if (IOS7_OR_LATER) {
            titleLable.frame = CGRectMake(15, -5, ScreenWidth, 20);
        } else {
            titleLable.frame = CGRectMake(15, 7, ScreenWidth, 20);
        }
        titleLable.text = @"其它";
    }
        
    return [sectionView autorelease];
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!IOS6_OR_LATER) {
        if (section == 0) {
            return 32.0;
        } else {
            return 15.0;
        }
    } else {
        return 25;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
            {
                [MobClick event:@"setting_advice"];
//                提意见
                [SessionDataOperator otherSystemTurnToSessionWithSender:self andObjectID:[SecretarySingleton shareSecretary].secretaryID andSessionType:SessionTypePerson isPopToRootViewController:NO isShowRightButton:NO];
            }
                break;
            case 1:
            {
                [MobClick event:@"setting_new_version"];
                upgrade_model* upgradeMod = [[upgrade_model alloc] init];
                NSArray* arr = [upgradeMod getList];
                [upgradeMod release];
                
                int upgradeVer = [[[arr firstObject] objectForKey:@"ver"] intValue];
//                检测新版本
                if (upgradeVer > CURRENT_APP_VERSION) {
                    [self checkUpdateApp];
                }else{
                    [Common checkProgressHUD:@"当前已是最新版本" andImage:nil showInView:self.view];
                }
            }
                break;
            case 2:
            {
                [MobClick event:@"setting_grade"];
                upgrade_model* upgradeMod = [[upgrade_model alloc] init];
                NSArray* arr = [upgradeMod getList];
                [upgradeMod release];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[arr firstObject] objectForKey:@"score_url"]]]];
            }
                break;
            case 3:
            {
//                关于云圈
                [MobClick event:@"settting_about"];
                AboutUsViewController *aboutUsVc = [[AboutUsViewController alloc] init];
                [self.navigationController pushViewController:aboutUsVc animated:YES];
                RELEASE_SAFE(aboutUsVc);
            }
                break;
            case 4:
            {
//                服务协议
                ServiceViewController *serviceVC = [[ServiceViewController alloc]init];
                [self.navigationController pushViewController:serviceVC animated:YES];
                RELEASE_SAFE(serviceVC);
            }
                break;
            default:
                break;
        }
    }
}

- (void)switchView:(UISwitch *)sender{
    statusValue = sender.on;
    int type = 0;
    
    if (sender.tag == 800) {
        [MobClick event:@"setting_chat_off"];
        type = 1;
        statusKey = @"chatStatus";
    } else if (sender.tag == 801){
        [MobClick event:@"setting_feed_reply_off"];
        type = 3;
        statusKey = @"replayStatus";
    } else if (sender.tag == 802) {
        [MobClick event:@"setting_feed_upgrade_off"];
        type = 2;
        statusKey = @"updateStatus";
    }
    [self messagePushSet:type status:statusValue];
    
//    NSDictionary* pushDic = [NSDictionary dictionaryWithObjectsAndKeys:
//                            [UserModel shareUser].user_id,@"userId",
//                            [NSNumber numberWithInt:status],statusKey,
//                            nil];
//    
//    [message_push_model updateOrInsertPushStatus:pushDic];
}

- (void)quitButton {
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"退出云圈将无法接收到朋友们的消息哦，您确定要退出吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 1000;
    [alert show];
    RELEASE_SAFE(alert);//add vincent
}

-(void)confirmQuit{
    [MobClick event:@"setting_exit"];
    if ([Common connectedToNetwork]) {
        [self hideHudView];
        hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"正在退出"];
        NSMutableDictionary *loginOutDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1",@"type",[UserModel shareUser].user_id,@"userId",nil];
        
        MyselfMessageManager* dlManager = [[MyselfMessageManager alloc] init];
        dlManager.delegate = self;
        [dlManager accessLoginOutMessageData:loginOutDic];
    }else{
        [self alertWithFistButton:@"确定" SencodButton:nil Message:@"网络不给力呀，请稍后重试"];
    }
}

-(void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

// 新版本更新
- (void)checkUpdateApp
{
    upgrade_model *nAVMod =[[upgrade_model alloc] init];
    NSMutableArray *upgradeArray = [nAVMod getList];
    [nAVMod release];
    
    if ([upgradeArray count] > 0)
    {
        NSDictionary *upgradeDic = [upgradeArray objectAtIndex:0];
        NSString *url = [upgradeDic objectForKey:@"url"];
        NSString *remark = [upgradeDic objectForKey:@"remark"];
        
        if (url.length > 0)
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_SHOW_UPDATE_ALERT];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"发现新版本！有好多新变化呢，快去体验一下吧~" message:remark delegate:self cancelButtonTitle:@"暂不体验" otherButtonTitles:@"马上更新", nil];
            alertView.tag = 100;
            [alertView show];
            [alertView release];
            
        }
    }
}

//消息提醒设置请求
-(void) messagePushSet:(int) type status:(int) status{
    NSMutableDictionary* paramDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [UserModel shareUser].user_id,@"userId",
                                     [UserModel shareUser].org_id,@"orgId",
                                     [NSNumber numberWithInt:type],@"type",
                                     [NSNumber numberWithInt:status],@"enabled",
                                     nil];
    MyselfMessageManager* manager = [[MyselfMessageManager alloc] init];
    manager.delegate = self;
    [manager accessSystemPush:paramDic];
}

//当前我的个人资料的返回值
-(void)getMyselfMessageManagerHttpCallBack:(NSArray*) arr requestCallBackDic:(NSDictionary *)dic interface:(LinkedBe_WInterface) interface{
    [self hideHudView];
    switch (interface) {
        case LinkedBe_Member_LoginOut:
        {
//            if ([[dic objectForKey:@"errcode"] integerValue]==0) {
////                [self logoutSend]; //退出im服务器
//            }else{
//                [Common checkProgressHUDShowInAppKeyWindow:@"退出登录失败" andImage:[UIImage imageNamed:@"ico_me_wrong.png"]];
//            }
        }
            break;
        case LinkedBe_System_push:
        {
            //链接失败
            if (dic) {
                if ([[dic objectForKey:@"errcode"] intValue] == -2) {
                    return;
                }
            }
            NSDictionary* pushDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UserModel shareUser].user_id,@"userId",
                                     [NSNumber numberWithInt:statusValue],statusKey,
                                     nil];
            
            [message_push_model updateOrInsertPushStatus:pushDic];
        }
            break;
        default:
            break;
    }
    
}

- (void) hideHudView
{
    if (hudView) {
        [hudView hide:YES];
    }
}

#pragma mark - AlterViewDelegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1000) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self confirmQuit];
        }
    }
}
@end
