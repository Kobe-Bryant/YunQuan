//
//  AppDelegate.m
//  LinkeBe
//
//  Created by yunlai on 14-9-1.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "AppDelegate.h"
#import "CicleViewController.h"
#import "MessageListViewController.h"
#import "DynamicViewController.h"
#import "MyselfViewController.h"
#import "Global.h"
#import "GuidePageViewController.h"
#import "FileManager.h"
#import "DBOperate.h"
#import "NSObject_extra.h"
#import "LinkedBeHttpRequest.h"
#import "upgrade_model.h"
#import "secret_message_model.h"
#import "SystemApnsLoginMessageData.h"
#import "Common.h"
#import "LoginSendClientMessage.h"
#import "UserModel.h"
#import "SnailSystemiMOperator.h"
#import "SnailSocketManager.h"

#import "DynamicListManager.h"
#import "MessageListDataOperator.h"
#import "Reachability.h"
#import "UIImage+extra.h"

#import "MyselfMessageManager.h"
#import "MobClick.h"

@interface AppDelegate ()
{
}

@property (nonatomic) Reachability * internetReachability;

@end

@implementation AppDelegate
@synthesize tabBarController = _tabBarController;
@synthesize myDeviceToken;
//@synthesize newDynamicLabel;
//@synthesize newMySelfCommentLabel;
//@synthesize newCicleLable;
@synthesize unreadLabel;

@synthesize province,city,area,isLoction;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Get Reachabilitys
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    //Start NetWorkChange Nofity
    [self.internetReachability startNotifier];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//修改状态栏颜色
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNetStatusChangeNotification:) name:kReachabilityChangedNotification2 object:nil];
    
    //  友盟的方法本身是异步执行，所以不需要再异步调用
    [self umengTrack];
    
    //定位信息
    [self getLocation];
    
    [self locationSelf];
    
    // 推送通知注册 及 开启定位
	[self applicationRegisterAndLocation];
    
    // 创建数据库
	[self operateDB];
    
//    引导页面
    [self initGuidePageVc];
    
    //获取设备令牌接口
    [self accessSystemAPNS];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)umengTrack {
    //    [MobClick setCrashReportEnabled:NO]; // 如果不需要捕捉异常，注释掉此行
//    [MobClick setLogEnabled:YES];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    //   reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //   channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
    
    //      [MobClick checkUpdate];   //自动更新检查, 如果需要自定义更新请使用下面的方法,需要接收一个(NSDictionary *)appInfo的参数
    //    [MobClick checkUpdateWithDelegate:self selector:@selector(updateMethod:)];
    
    [MobClick updateOnlineConfig];  //在线参数配置
    
    //    1.6.8之前的初始化方法
    //    [MobClick setDelegate:self reportPolicy:REALTIME];  //建议使用新方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    
    
//    Class cls = NSClassFromString(@"UMANUtil");
//    SEL deviceIDSelector = @selector(openUDIDString);
//    NSString *deviceID = nil;
//    if(cls && [cls respondsToSelector:deviceIDSelector]){
//        deviceID = [cls performSelector:deviceIDSelector];
//    }
//    NSLog(@"{\"oid\": \"%@\"}", deviceID);
    
    
}

- (void)onlineConfigCallBack:(NSNotification *)note {
    
    NSLog(@"online config has fininshed and note = %@", note.userInfo);
}

//获取用户设置信息
-(void) getUserSetInfo{
    MyselfMessageManager* manager = [[MyselfMessageManager alloc] init];
    manager.delegate = nil;
    [manager accessUserSetInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:[UserModel shareUser].user_id,@"userId", nil]];
}

- (void)receiveNetStatusChangeNotification:(NSNotification *)noti
{
    Reachability * reachability = [noti object];
    if ([reachability isEqual:self.internetReachability]) {
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        if (netStatus == ReachableViaWWAN || netStatus == ReachableViaWiFi) {
            [self loginIM];
        }
    }
}

// 创建数据库
- (void)operateDB{
    int soft_ver = [[NSUserDefaults standardUserDefaults] integerForKey:APP_SOFTWARE_VER_KEY];
	if(soft_ver != CURRENT_APP_VERSION)
	{
        [FileManager removeFileDB:AppDataBaseName];
        
        [[NSUserDefaults standardUserDefaults] setInteger:CURRENT_APP_VERSION forKey:APP_SOFTWARE_VER_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
	}
    
    //创建应用数据表
    [DBOperate createApplicationDB];
}

// 推送通知注册 及 开启定位
- (void)applicationRegisterAndLocation{
    //推送通知注册
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:LINKEDBE_TOKEN_KEY];
    if (token != nil) {
		self.myDeviceToken = token;

        NSLog(@"myDeviceToken==%@",self.myDeviceToken);

	} else {
        //注册消息通知 获取token号
        if (IOS8_OR_LATER) {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                                 settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                                                 categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }else{
            [[UIApplication sharedApplication]registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
        }
        
    }
}

- (void)loginIM
{
    //iM服务端登录 连接即是登陆
    [SnailSocketManager connectToServer];
}

-(void)initGuidePageVc{
    [self configLikeBeNac];
    
    LoginSendClientMessage *loginSendClient = [[LoginSendClientMessage alloc] init];
    if ([loginSendClient authorizationReturn]) {
        
        [self getUserSetInfo];
        
        [self loginIM];
        
        [self initViewController];
        
        [self refreshChatItemUnreadNumber];
    }else{
        GuidePageViewController *guidePageVc = [[GuidePageViewController alloc] init];
        UINavigationController *guidePageVcNav = [[UINavigationController alloc] initWithRootViewController:guidePageVc];
        [guidePageVc release];
        [self.window addSubview:guidePageVcNav.view];
    }
}

- (void)refreshChatItemUnreadNumber
{
    NSInteger unreadNum = [MessageListDataOperator getAllUnreadMessageCount];
    if (unreadNum > 0) {
        self.unreadLabel.hidden = NO;
    }else {
        self.unreadLabel.hidden = YES;
    }
}

//初始化
-(void)initViewController{
//    圈子
    CicleViewController *cicleViewController = [[CicleViewController alloc] init];
    UITabBarItem *cicleBatItem = [[UITabBarItem alloc] init];
    cicleBatItem.title =  @"圈子";
    cicleViewController.title = cicleBatItem.title;
    cicleViewController.tabBarItem = cicleBatItem;
    [cicleBatItem release];
    [cicleViewController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ico_group_set.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"ico_group.png"]];
    UINavigationController *cicleNavigationController = [[UINavigationController alloc] initWithRootViewController:cicleViewController];
    [cicleViewController release];
    
    //    聊天
    MessageListViewController *messageViewController = [[MessageListViewController alloc] init];
    UITabBarItem *chatBatItem = [[UITabBarItem alloc] init];
    chatBatItem.title =  @"聊天";
    messageViewController.title = chatBatItem.title;
    messageViewController.tabBarItem = chatBatItem;
    [chatBatItem release];
    [messageViewController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ico_chat_set.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"ico_chat.png"]];
    UINavigationController *chatNavigationController = [[UINavigationController alloc] initWithRootViewController:messageViewController];
    [messageViewController release];
    
    //   动态
    DynamicViewController *dynamicViewController = [[DynamicViewController alloc] init];
    UITabBarItem *dynamicBatItem = [[UITabBarItem alloc] init];
    dynamicBatItem.title =  @"动态";
    dynamicViewController.title = dynamicBatItem.title;
    dynamicViewController.tabBarItem = dynamicBatItem;
    [dynamicBatItem release];
    [dynamicViewController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ico_feed_set.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"ico_feed.png"]];
    UINavigationController *dynamicNavigationController = [[UINavigationController alloc] initWithRootViewController:dynamicViewController];
    [dynamicViewController release];
    
    //  我的
    MyselfViewController *myselfViewController = [[MyselfViewController alloc] init];
    UITabBarItem *myselfBatItem = [[UITabBarItem alloc] init];
    myselfBatItem.title =  @"我";
    myselfViewController.title = myselfBatItem.title;
    myselfViewController.tabBarItem = myselfBatItem;
    [myselfBatItem release];
    [myselfViewController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ico_me.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"ico_me_selected.png"]];
    
    UINavigationController *myselfNavigationController = [[UINavigationController alloc] initWithRootViewController:myselfViewController];
    [myselfViewController release];
    
    //    tabbar
    _tabBarController = [[UITabBarController alloc] init];
    _tabBarController.delegate = self;
    [_tabBarController setViewControllers:[NSArray arrayWithObjects:cicleNavigationController,
                                           chatNavigationController,
                                           dynamicNavigationController,
                                           myselfNavigationController, nil]];
    
    CGRect cicleLabelRect = CGRectMake(ScreenWidth*1/4 - 30, 6, 10, 10);
    UILabel * cicleLabel = [[UILabel alloc]initWithFrame:cicleLabelRect];
    cicleLabel.layer.cornerRadius = 7;
    cicleLabel.clipsToBounds = YES;
    cicleLabel.hidden = YES;
    cicleLabel.backgroundColor = [UIColor redColor];
    self.newCicleLable = cicleLabel;
    [_tabBarController.tabBar addSubview:cicleLabel];
    RELEASE_SAFE(cicleLabel);
    
    CGRect chatNotifyLabelRect = CGRectMake(ScreenWidth*2/4 - 30, 6, 10, 10);
    UILabel * chatNotifyLabel = [[UILabel alloc]initWithFrame:chatNotifyLabelRect];
    chatNotifyLabel.layer.cornerRadius = 5;
    chatNotifyLabel.clipsToBounds = YES;
    chatNotifyLabel.textAlignment = NSTextAlignmentCenter;
    chatNotifyLabel.hidden = YES;
    chatNotifyLabel.backgroundColor = [UIColor redColor];
    chatNotifyLabel.font = KQLSystemFont(9);
    self.unreadLabel = chatNotifyLabel;
    [_tabBarController.tabBar addSubview:chatNotifyLabel];
    RELEASE_SAFE(chatNotifyLabel);
    
    CGRect DynamicNotifyLabelRect = CGRectMake(ScreenWidth*3/4 - 30, 6, 10, 10);
    UILabel * DynamicNotifyLabel = [[UILabel alloc]initWithFrame:DynamicNotifyLabelRect];
    DynamicNotifyLabel.layer.cornerRadius = 7;
    DynamicNotifyLabel.clipsToBounds = YES;
    DynamicNotifyLabel.hidden = YES;
    DynamicNotifyLabel.backgroundColor = [UIColor redColor];
    self.newDynamicLabel = DynamicNotifyLabel;
    [_tabBarController.tabBar addSubview:DynamicNotifyLabel];
    RELEASE_SAFE(DynamicNotifyLabel);
    
    CGRect MySelfNotifyLabelRect = CGRectMake(ScreenWidth - 30, 6, 10, 10);
    UILabel * MySelfNotifyLabel = [[UILabel alloc]initWithFrame:MySelfNotifyLabelRect];
    MySelfNotifyLabel.layer.cornerRadius = 7;
    MySelfNotifyLabel.clipsToBounds = YES;
    MySelfNotifyLabel.hidden = YES;
    MySelfNotifyLabel.backgroundColor = [UIColor redColor];
    self.newMySelfCommentLabel = MySelfNotifyLabel;
    [_tabBarController.tabBar addSubview:MySelfNotifyLabel];
    RELEASE_SAFE(MySelfNotifyLabel);
    
    [cicleNavigationController release];
    [chatNavigationController release];
    [dynamicNavigationController release];
    [myselfNavigationController release];
    
    self.window.rootViewController = _tabBarController;
    [_tabBarController release];//add vincent 内存释放
}

#pragma mark - ==============NetworkAccess============

//获取设备令牌
-(void) accessSystemAPNS{
    NSString *systemToken;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:LINKEDBE_TOKEN_KEY]) {
        systemToken = @"";
    }else{
        systemToken = [[NSUserDefaults standardUserDefaults] objectForKey:LINKEDBE_TOKEN_KEY];
    }
    NSMutableDictionary* requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"1",@"platform",
                                       systemToken,@"token",
                                       [self getUuidString],@"uuid",
                                       [NSString stringWithFormat:@"%d",CURRENT_APP_VERSION],@"curVer", nil];
    SystemApnsLoginMessageData* apnsManager = [[SystemApnsLoginMessageData alloc] init];
    apnsManager.delegate = self;
    [apnsManager accessSystemApnsMessageData:requestDic];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //程序进入后台，记住状态
    [UserModel shareUser].isBackGround = YES;
    int num = [MessageListDataOperator getAllUnreadMessageCount];
    [UIApplication sharedApplication].applicationIconBadgeNumber = num>99?99:num;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //程序进入后台，记住状态
    [UserModel shareUser].isBackGround = YES;
    //进入后台icon数字展示未读消息数目
    int num = [MessageListDataOperator getAllUnreadMessageCount];
    [UIApplication sharedApplication].applicationIconBadgeNumber = num>99?99:num;
    
    UIApplication* app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //程序进入前台，记住状态
    [UserModel shareUser].isBackGround = NO;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
//    BOOL isConnected = [SnailSocketManager isConnected];
//    if (!isConnected) {
//        LoginSendClientMessage *loginSendClient = [[LoginSendClientMessage alloc] init];
//        if ([loginSendClient authorizationReturn]) {
//            //iM服务端登录
//            SnailSystemiMOperator * loginManager = [[SnailSystemiMOperator alloc]init];
//            [loginManager loginIMServer];
//            RELEASE_SAFE(loginManager);
//        }
//    }
//    else{
//        SnailCommandObject * loginCommand = [SnailCommandFactory commandObjectWithCommand:CMD_USER_LOGIN andBodyDic:dic];
//        loginCommand.receiverID = 0;
//        [SnailSocketManager sendCommandObject:loginCommand];
//    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //程序进入前台，记住状态
    [UserModel shareUser].isBackGround = NO;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


////////////////------------推送-------------////////////////
#pragma mark -  ===========Application lifecycle===========
- (void)showString:(NSDictionary*)userInfo
{
    //接收到消息推送后处理函数 apns支持自定义字段
    NSLog(@"userInfo====%@",userInfo);
    int badge = [[userInfo objectForKey:@"badge"] intValue];
    [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
}

- (void)launchNotification:(NSNotification*)notification
{
	[self showString:[[notification userInfo]objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"]];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	[self showString:userInfo];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Error in registration. Error: %@", error);
}

// 获取token号回调
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	NSString *mydevicetoken = [[[NSMutableString stringWithFormat:@"%@",deviceToken]stringByReplacingOccurrencesOfString:@"<" withString:@""]stringByReplacingOccurrencesOfString:@">" withString:@""];
	self.myDeviceToken = mydevicetoken;
    
    // 保存token号
    [[NSUserDefaults standardUserDefaults] setObject:self.myDeviceToken forKey:LINKEDBE_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
////////////////------------推送-------------////////////////

//配置导航和下面的tabbar
-(void)configLikeBeNac{
    if (!IOS7_OR_LATER) {
        UIColor *navigationBarColor = RGBACOLOR(54, 54, 54,0.90);
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:navigationBarColor size:CGSizeMake(320, 44)]
                                           forBarMetrics:UIBarMetricsDefault];
        
        [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage alloc] init]];
        [[UITabBar appearance] setBackgroundColor:RGBACOLOR(54, 54, 54,0.90)];
        [[UITabBar appearance] setTintColor:RGBACOLOR(54, 54, 54,0.90)];
    }else{
        [[UITabBar appearance] setBarTintColor:RGBACOLOR(54, 54, 54,0.90)];
        [[UINavigationBar appearance] setBarTintColor:RGBACOLOR(54,54,54,0.90)];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,
        [UIColor whiteColor], UITextAttributeTextShadowColor,[NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
    [UIFont systemFontOfSize:17], UITextAttributeFont,nil]];

    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:RGBACOLOR(187,187,187,1),UITextAttributeTextColor,[UIFont systemFontOfSize:12],UITextAttributeFont,nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:RGBACOLOR(2,161,233,1), UITextAttributeTextColor,[UIFont systemFontOfSize:12],UITextAttributeFont,nil] forState:UIControlStateSelected];
}

////////////////------------定位-------------////////////////
#pragma mark - =============LocationManager============
// 定位获取位置
- (void)getLocation
{
    if ([Common isLoctionOpen]) {
        CLLocationManager *manger = [[CLLocationManager alloc] init];
        manger.desiredAccuracy = kCLLocationAccuracyBest;
        manger.delegate = self;
        if ([manger respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [manger requestWhenInUseAuthorization];
        }
        [manger startUpdatingLocation];
//        [manger release];
    } else {
        [self locationSelf];
    }
}

// 得到定位地址
- (NSString *)getAddress:(NSString *)address
{
    NSRange rang = [address rangeOfString:@"省"];
    if (rang.length == 0) {
        rang = [address rangeOfString:@"区"];
        if (rang.length == 0) {
            return address;
        } else {
            return [address substringFromIndex:rang.length + rang.location];
        }
    } else {
        return [address substringFromIndex:rang.length + rang.location];
    }
}

// 定位城市赋值
- (void)locationSelf
{
#if TARGET_IPHONE_SIMULATOR
    self.city = @"深圳市";
    self.province = @"广东省";
    self.area = @"南山区";
#elif TARGET_OS_IPHONE
#endif
//    self.city = @"深圳市";
    NSString* cahceCity = [[NSUserDefaults standardUserDefaults] objectForKey:@"locationCity"];
    if (cahceCity) {
        self.city = cahceCity;
    }
    
}

//定位成功
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation......wait.....");
    
    self.isLoction = YES;
    
    [manager stopUpdatingLocation];
    
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude - 0.00311111 longitude:newLocation.coordinate.longitude + 0.00511111]; // 0.002899
    
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark *placemark in placemarks) {
            
            self.province = [placemark.addressDictionary objectForKey:@"State"];
            
            self.city = [placemark.addressDictionary objectForKey:@"City"];
            if (self.city) {
                [[NSUserDefaults standardUserDefaults] setObject:self.city forKey:@"locationCity"];
            }
            
            self.area = [placemark.addressDictionary objectForKey:@"SubLocality"];
        }
        
        // 定位城市赋值
//        [self locationSelf];
    }];
    [loc release];
    [geocoder release];
}

// 定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError......");
    
    [manager stopUpdatingLocation];
    
    //    查看是否授权 add vincent
    if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized){
        // your code
        self.isLoction = NO;
    }
    
    // 定位城市赋值
    [self locationSelf];
}
////////////////------------定位-------------////////////////

// 新版本更新
- (void)checkUpdateApp
{
    BOOL is_show_update_alert = [[NSUserDefaults standardUserDefaults] boolForKey:IS_SHOW_UPDATE_ALERT];
    if (!is_show_update_alert)
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
    
}


//
-(void)getSystemApnsLoginMessageHttpCallBack:(NSArray*) arr interface:(LinkedBe_WInterface) interface{
    if (arr.count>0) {
        if ([[[arr lastObject] objectForKey:@"ver"] intValue] > CURRENT_APP_VERSION) {
            [self checkUpdateApp];
        }
    }
}

#pragma mark - UIAlertViewDelegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {
        //设备令牌
        upgrade_model* upgradeMod = [[upgrade_model alloc] init];
        NSArray* arr = [upgradeMod getList];
        [upgradeMod release];
        
        switch (alertView.tag) {
            case 100:
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[arr firstObject] objectForKey:@"url"]]];
            }
                break;
                default:
                break;
        }
    }
}

#pragma mark - tabbardelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    if (tabBarController.selectedIndex == 0) {
        [MobClick event:@"cloud_cicleCount"];
    } else if (tabBarController.selectedIndex == 1) {
        [MobClick event:@"cloud_chatCount"];
    } else if (tabBarController.selectedIndex == 2) {
        [MobClick event:@"cloud_dynamicCount"];
    } else {
        [MobClick event:@"cloud_mySelfCount"];
    }
    
    if (tabBarController.selectedIndex != 2) {
        [[DynamicIMManager shareManager] setTabbarSelectIndexWhenHaveNew:tabBarController.selectedIndex];
    }
}

@end
