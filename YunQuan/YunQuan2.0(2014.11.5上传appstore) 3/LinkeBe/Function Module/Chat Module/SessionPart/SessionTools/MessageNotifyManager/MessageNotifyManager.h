//
//  MessageNotifyManager.h
//  ql
//
//  Created by LazySnail on 14-8-11.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageNotifyManager : NSObject

+ (MessageNotifyManager *)shareNotifyManager;

- (void)playChatMessageReciveSystemMusic;

- (void)playVibrate;

@end
