//
//  SnailSystemiMOperator.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-27.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailSystemiMOperator.h"
#import "SnailSocketManager.h"
#import "SnailCommandFactory.h"

@implementation SnailSystemiMOperator

- (void)loginIMServer
{
    //登陆iM 服务端
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                          [[UserModel shareUser] org_id],@"oid",
                          [NSNumber numberWithInt:1],@"clityp", nil];
    
    SnailCommandObject * loginCommand = [SnailCommandFactory commandObjectWithCommand:CMD_USER_LOGIN andBodyDic:dic andReceiverID:0];
    loginCommand.receiverID = 0;
    [SnailSocketManager sendCommandObject:loginCommand];
}

- (void)loginIMServerOut
{
    if ([SnailSocketManager isConnected]) {
        SnailCommandObject * loginOutCommand = [SnailCommandFactory commandObjectWithCommand:CMD_USER_LOGOUT andBodyDic:[NSDictionary dictionary] andReceiverID:0];
        [SnailSocketManager sendCommandObject:loginOutCommand];
    }
}

@end
