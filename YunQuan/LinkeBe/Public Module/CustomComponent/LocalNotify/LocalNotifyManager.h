//
//  LocalNotifyManager.h
//  ql
//
//  Created by yunlai on 14-9-1.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalNotifyManager : NSObject{
    UILocalNotification* _localNotify;
}

+(id) shareManager;

//展示本地推送文本
-(void) showLocalNotifyMessage:(NSString*) message;

//注销本地推送
-(void) cancelLocalNotify;

@end
