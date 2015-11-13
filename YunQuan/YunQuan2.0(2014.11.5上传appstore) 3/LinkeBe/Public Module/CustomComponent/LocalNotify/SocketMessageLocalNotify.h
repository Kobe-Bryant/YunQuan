//
//  SocketMessageLocalNotify.h
//  LinkeBe
//
//  Created by yunlai on 14-10-13.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketMessageLocalNotify : NSObject

//单聊消息本地提醒
+(void) singleMessageNotify:(NSDictionary*) dic;

//群聊消息本地提醒
+(void) circleMessageNotify:(NSDictionary*) dic;

@end
