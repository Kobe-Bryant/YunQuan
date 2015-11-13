//
//  SnailiMDataManager.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailiMDataManager.h"
#import "MessageDataManager.h"
#import "SnailSocketManager.h"
#import "SnailCommandFactory.h"
#import "SecretarySingleton.h"
#import "OrgSingleton.h"
#import <AudioToolbox/AudioToolbox.h>

@interface SnailiMDataManager () {
    
}

@property (nonatomic, retain) NSMutableArray * sendFaildedMessageArr;

@end

@implementation SnailiMDataManager

static id m_iMDataManager = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sendFaildedMessageArr = [[[NSMutableArray alloc]initWithCapacity:10]autorelease];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resendFaildMessage) name:IMLoginSuccess object:nil];
    }
    return self;
}

+ (SnailiMDataManager *)shareiMDataManager
{
    if (m_iMDataManager == nil) {
        m_iMDataManager = [[SnailiMDataManager alloc]init];
    }
    return m_iMDataManager;
}

- (void)sendMessageData:(MessageData *)data
{
    BOOL isConnected = [SnailSocketManager isConnected];
    
    int command = 0;
    if (data.objectID == [[SecretarySingleton shareSecretary]secretaryID] || data.objectID == [[OrgSingleton shareOrg]orgID ]) {
        command = CMD_ORG_MSGSEND;
    } else {
        switch (data.sessionType) {
            case SessionTypePerson:
                command = CMD_PERSONAL_MSGSEND;
                break;
            case SessionTypeTempCircle:
                command = CMD_TEMP_CIRCLE_MSGSEND;
                break;
            default:
                break;
        }
    }
    
    if (isConnected) {
        SnailCommandObject * object = [SnailCommandFactory commandObjectWithCommand:command andBodyDic:[data getiMSendDic] andReceiverID:data.objectID];
        [SnailSocketManager sendCommandObject:object];
    } else {
        [SnailSocketManager connectToServer];
        [self.sendFaildedMessageArr addObject:data];
    }
}

- (void)resendFaildMessage
{
    for (MessageData * failedData in self.sendFaildedMessageArr) {
        [self sendMessageData:failedData];
    }
    [self.sendFaildedMessageArr removeAllObjects];
}

- (void)playVibrate
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

- (void)dealloc
{
    self.sendFaildedMessageArr = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IMLoginSuccess object:nil];
    [super dealloc];
}

@end
