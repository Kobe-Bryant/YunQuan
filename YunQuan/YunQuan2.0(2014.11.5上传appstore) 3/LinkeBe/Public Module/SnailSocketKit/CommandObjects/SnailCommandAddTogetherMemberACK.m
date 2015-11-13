//
//  SnailCommandAddTogetherMemberACK.m
//  LinkeBe
//
//  Created by yunlai on 14-10-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandAddTogetherMemberACK.h"

#import "DynamicIMManager.h"
#import "TempChatManager.h"

@implementation SnailCommandAddTogetherMemberACK

- (void)handleCommandData {
    NSLog(@"创建临时会话");
    int recode = [[self.bodyDic objectForKey:@"rcode"]intValue];
    switch (recode) {
        case 0:
        {
            [[DynamicIMManager shareManager] receiveAddToTempContact:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [self.bodyDic objectForKey:@"rcode"],@"rcode",
                                                                      [self.bodyDic objectForKey:@"gid"],@"circleId",
                                                                      nil]];
            
            //获取临时会话详情
            [[TempChatManager shareManager]createOrAddMemberAckWithDic:self.bodyDic andDataLocalID:self.serialNumber];
            
        }
            break;
        case 1:
        {
            
        }
            break;
        default:
            break;
    }
    
}

@end
