//
//  AppDelegate.h
//  LinkeBe
//
//  Created by yunlai on 14-9-1.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SystemApnsLoginMessageData.h"
#import "DynamicIMManager.h"

//友盟统计key 5452e434fd98c52d0b001bd2 自己测试号
#define UMENG_APPKEY       @"544fab5bfd98c5a68b00a37c"

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate,SystemApnsLoginMessageDelegate,UITabBarControllerDelegate>{
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UITabBarController *tabBarController;//add vincent
@property (retain, nonatomic) NSString *myDeviceToken;

@property (nonatomic, retain) NSString *province;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *area;
@property (nonatomic, assign) BOOL isLoction;

@property (nonatomic, strong) UILabel *newCicleLable;
@property (nonatomic, strong) UILabel *unreadLabel;
@property (nonatomic, strong) UILabel *newDynamicLabel;
@property (nonatomic, strong) UILabel *newMySelfCommentLabel;

-(void)initViewController;

-(void)initGuidePageVc;

- (void)refreshChatItemUnreadNumber;
@end
