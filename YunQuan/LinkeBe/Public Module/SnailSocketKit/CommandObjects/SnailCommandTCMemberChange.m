//
//  SnailCommandTCMemberChange.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-27.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandTCMemberChange.h"
#import "TempChatManager.h"
#import "SnailCommandFactory.h"
#import "SnailSocketManager.h"

@implementation SnailCommandTCMemberChange

- (void)handleCommandData
{
    [[TempChatManager shareManager]receiveMemberChangeWithCircleID:self.senderID];
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:0],@"rcode",
                          [[UserModel shareUser] org_id],@"oid",
                          [self.bodyDic objectForKey:@"mid"],@"mid", nil];
    
    SnailCommandObject * receiveCommand = [SnailCommandFactory commandObjectWithCommand:CMD_TEMP_CIRCLEMEMBER_CHG_NTF_ACK andBodyDic:dic andReceiverID:self.senderID];
    [SnailSocketManager sendCommandObject:receiveCommand];
}

@end
