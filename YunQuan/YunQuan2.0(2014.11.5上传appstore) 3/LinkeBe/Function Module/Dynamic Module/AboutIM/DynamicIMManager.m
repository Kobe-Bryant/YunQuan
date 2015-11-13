//
//  DynamicIMManager.m
//  LinkeBe
//
//  Created by yunlai on 14-9-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "DynamicIMManager.h"
#import "ContactModel.h"
#import "LinkedBeHttpRequest.h"

#import "AppDelegate.h"
#import "Dynamic_card_model.h"

@implementation DynamicIMManager

@synthesize isNew;
@synthesize tabbarSelectIndexWhenHaveNew;

+(id) shareManager{
    static DynamicIMManager* DImanager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DImanager = [[self alloc] init];
    });
    return DImanager;
}

//加入临时会话
-(void) addToTempContact:(NSDictionary*) dic msgDic:(NSDictionary *)msgdic block:(ReceiveCallBackBlock)block{
    self.circleId = [[dic objectForKey:@"circleId"] longLongValue];
    self.msgDic = msgdic;
    self.callBackBlock = block;
    
    long long circleId = [[dic objectForKey:@"circleId"] longLongValue];
    NSArray* userIdArr = [dic objectForKey:@"uid"];
    
    NSMutableArray * contactArr = [NSMutableArray arrayWithCapacity:userIdArr.count];
    for (NSNumber * userID in userIdArr) {
        //临时会话创建逻辑调整 add By snail
        ContactModel * contact = [[ContactModel alloc]init];
        contact.userId = userID.longLongValue;
        [contactArr addObject:contact];
        RELEASE_SAFE(contact);
    }
    
//    [[TempChatManager shareManager]addMembersToTempChat:circleId andMemberArr:contactArr];
    [[TempChatManager shareManager]addMembersToTogether:circleId andMemberArr:contactArr];
}

//发送聚聚消息
-(void) sendTogetherMessage:(NSDictionary*) dic{
    self.circleId = [[dic objectForKey:@"circleId"] longLongValue];
    
    self.msgDic = dic;
    
    long long circleId = [[dic objectForKey:@"circleId"] longLongValue];
    int msgId = [[dic objectForKey:@"msgId"] intValue];
    NSString* msgTxt = [dic objectForKey:@"txt"];
    NSString* msgdesc = [dic objectForKey:@"msgdesc"];
    
    [[SessionDataOperator shareOperator] sendGetheringMessageWithTempCircleID:circleId andMessageID:msgId andMsgTxt:msgTxt andMsgDesc:msgdesc];
}

//发送我有消息
-(void) sendHaveMessage:(NSDictionary*) dic block:(ReceiveCallBackBlock)block{
    self.callBackBlock = block;
    
    self.msgDic = dic;
    
    long long receiverId = [[dic objectForKey:@"receiverId"] longLongValue];
    int publishId = [[dic objectForKey:@"msgId"] intValue];
    NSString* tbdesc = @"";
    NSString* tbUrl = @"";
    NSString* txt = [dic objectForKey:@"txt"];
    NSString* msgdesc = [dic objectForKey:@"msgdesc"];
    [[SessionDataOperator shareOperator] sendiWantMessageWithWantID:publishId andReceiverID:receiverId andtbDesc:tbdesc andtBurl:tbUrl andTxt:txt andMsgDesc:msgdesc];
}

//发送我要消息
-(void) sendWantMessage:(NSDictionary*) dic block:(ReceiveCallBackBlock)block{
    self.callBackBlock = block;
    
    self.msgDic = dic;
    
    long long receiverId = [[dic objectForKey:@"receiverId"] longLongValue];
    int publishId = [[dic objectForKey:@"msgId"] intValue];
    NSString* tbdesc = @"";
    NSString* tbUrl = @"";
    NSString* txt = [dic objectForKey:@"txt"];
    NSString* msgdesc = [dic objectForKey:@"msgdesc"];
    
    [[SessionDataOperator shareOperator] sendiHaveMessageWitHaveID:publishId andReceiverID:receiverId andtbDesc:tbdesc andtBurl:tbUrl andTxt:txt andMsgDesc:msgdesc];
}

//发送聚聚消息回调
-(void) receiveTogetherMessage:(NSDictionary*) dic{
    //判断是不是这个会话的回调
    if ([[dic objectForKey:@"rcode"] intValue] == 0) {
        [Common checkProgressHUDShowInAppKeyWindow:@"回应成功" andImage:nil];
        
        _callBackBlock();
        
        //通知java端参加了聚聚
        [self sendSyncRequestWithType:8];
    }
}

//发送我有消息回调
-(void) receiveHaveCallBack:(NSDictionary*) dic{
    //判断是不是这个会话的回调
    if ([[dic objectForKey:@"rcode"] intValue] == 0) {
        [Common checkProgressHUDShowInAppKeyWindow:@"回应成功" andImage:nil];
        
        _callBackBlock();
        
        [self sendSyncRequestWithType:3];
    }
}

//发送我要消息回调
-(void) receiveWantCallBack:(NSDictionary*) dic{
    //判断是不是这个会话的回调
    if ([[dic objectForKey:@"rcode"] intValue] == 0) {
        [Common checkProgressHUDShowInAppKeyWindow:@"回应成功" andImage:nil];
        
        _callBackBlock();
        
        [self sendSyncRequestWithType:4];
    }
}

//加入临时会话回调
-(void) receiveAddToTempContact:(NSDictionary*) dic{
    //判断是不是这个会话的回调
    long long circleId = [[dic objectForKey:@"circleId"] longLongValue];
    if (self.circleId == circleId) {
        if ([[dic objectForKey:@"rcode"] intValue] == 0) {
            [self sendTogetherMessage:_msgDic];
        }
    }
}

//发送java请求，同步聚聚、我有、我要状态
-(void) sendSyncRequestWithType:(int) type{
    NSDictionary* paraDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [UserModel shareUser].user_id,@"userId",
                             [_msgDic objectForKey:@"msgId"],@"publishId",
                             [NSNumber numberWithInt:type],@"type",
                             nil];
    [[LinkedBeHttpRequest shareInstance] requestJoinTogetherWithDelegate:nil
                                                     parameterDictionary:paraDic];
}

//新动态提醒
-(void) receiveNewDynamicNotify:(NSDictionary*) dic{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    NSArray* viewControllers = appDelegate.tabBarController.viewControllers;
//    UIViewController* dycontrollers = [viewControllers objectAtIndex:2];
//    dycontrollers.tabBarItem.badgeValue = @"";
    
    appDelegate.newDynamicLabel.hidden = NO;
    
    //标记进入动态即刷新
    self.isNew = YES;
    self.tabbarSelectIndexWhenHaveNew = appDelegate.tabBarController.selectedIndex;
}

//取消新动态红点
-(void) cancelNewDynamicNotify{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    NSArray* viewControllers = appDelegate.tabBarController.viewControllers;
//    UIViewController* dycontrollers = [viewControllers objectAtIndex:2];
//    dycontrollers.tabBarItem.badgeValue = nil;
    
    appDelegate.newDynamicLabel.hidden = YES;
 
    //标记无新动态
    self.isNew = NO;
    self.tabbarSelectIndexWhenHaveNew = 0;
}

//删除动态消息处理
-(void) receiveDynamicDeleteNotify:(NSDictionary*) dic{
    if (dic) {
        //删除数据库数据
        [Dynamic_card_model deleteDynamicCardWithPublishId:[[dic objectForKey:@"fid"] intValue]];
        
        if (self.ddeleteNotifyBlock) {
            _ddeleteNotifyBlock();
        }
        
        if (_DimDelegate && [_DimDelegate respondsToSelector:@selector(receiveDynamicDeleteWithDic:)]) {
            [_DimDelegate receiveDynamicDeleteWithDic:dic];
        }
    }
}

@end
