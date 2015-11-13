//
//  LocalNotifyManager.m
//  ql
//
//  Created by yunlai on 14-9-1.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "LocalNotifyManager.h"

@implementation LocalNotifyManager

+(id) shareManager{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(id) init{
    if (self = [super init]) {
        _localNotify = [[UILocalNotification alloc] init];
    }
    
    return self;
}

-(void) showLocalNotifyMessage:(NSString *)message{
    //设置提醒时间1s
    _localNotify.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
    // 设置时区
    _localNotify.timeZone = [NSTimeZone defaultTimeZone];
    // 设置重复间隔，不重复
    _localNotify.repeatInterval = 0;
    // 推送声音
    _localNotify.soundName = UILocalNotificationDefaultSoundName;
    // 推送内容
    _localNotify.alertBody = message;
    //显示在icon上的红色圈中的数子
    _localNotify.applicationIconBadgeNumber += 1;
    //设置userinfo 方便在之后需要撤销的时候使用
    NSDictionary *info = [NSDictionary dictionaryWithObject:@"name"forKey:@"key"];
    _localNotify.userInfo = info;
    //添加推送到UIApplication
    UIApplication *app = [UIApplication sharedApplication];
    [app scheduleLocalNotification:_localNotify];
}

-(void) cancelLocalNotify{
    _localNotify.applicationIconBadgeNumber = 0;
    UIApplication *app = [UIApplication sharedApplication];
    [app cancelLocalNotification:_localNotify];
}

@end
