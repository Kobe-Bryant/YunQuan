//
//  SnailLoginOutCommandObject.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-27.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandLoginOut.h"
#import "SnailSocketManager.h"
#import "AppDelegate.h"

@implementation SnailCommandLoginOut

- (void)handleCommandData
{
    //清楚用户缓存
    UserModel *user = [UserModel shareUser];
    [user clearUserInfo];
    
    [SnailSocketManager breakConnect];
    
    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appdelegate initGuidePageVc];
}

@end
