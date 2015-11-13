//
//  SnailCommandDynamicDeleteNotify.m
//  LinkeBe
//
//  Created by yunlai on 14-10-20.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandDynamicDeleteNotify.h"

#import "DynamicIMManager.h"

@implementation SnailCommandDynamicDeleteNotify

//动态删除通知
-(void) handleCommandData{
    [[DynamicIMManager shareManager] receiveDynamicDeleteNotify:self.bodyDic];
}

@end
