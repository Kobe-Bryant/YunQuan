//
//  SocketMessageLocalNotify.m
//  LinkeBe
//
//  Created by yunlai on 14-10-13.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SocketMessageLocalNotify.h"

#import "LocalNotifyManager.h"
#import "UserModel.h"
#import "OriginData.h"
#import "Circle_member_model.h"
#import "SBJson.h"

@implementation SocketMessageLocalNotify

//单聊消息本地提醒
+(void) singleMessageNotify:(NSDictionary*) dic{
    //本地推送
    if ([UserModel shareUser].isBackGround) {
        //用户ID
        long long speakerId = [[[dic objectForKey:@"spkinfo"] objectForKey:@"uid"] longLongValue];
        NSDictionary* speakerDic = [Circle_member_model getMemberDicWithUserID:speakerId];
//        NSDictionary* contentDic = [[speakerDic objectForKey:@"content"] JSONValue];
        
        //消息体
        NSDictionary* dataDic = [[dic objectForKey:@"msg"] objectForKey:@"data"];
        //消息类型
        int objtype = [[[dic objectForKey:@"msg"] objectForKey:@"objtyp"] intValue];
        
        //文本消息
        NSString* message = nil;
        //name
        NSString* nickName = [speakerDic objectForKey:@"realname"];
        
        NSString* msgTxt = nil;
        
        switch (objtype) {
            case DataMessageTypeText:
            {
                msgTxt = [dataDic objectForKey:@"txt"];
            }
                break;
            case DataMessageTypePicture:
            {
                msgTxt = @"发来一张图片";
            }
                break;
            case DataMessageTypeVoice:
            {
                msgTxt = @"发来一段语音";
            }
                break;
            case DataMessageTypeCustomEmotion:
            {
                msgTxt = @"发来一个表情";
            }
                break;
            default:
                break;
        }
        if (msgTxt != nil && nickName != nil && nickName.length != 0) {
            message = [NSString stringWithFormat:@"%@:%@",nickName,msgTxt];
        }
        
        [[LocalNotifyManager shareManager] showLocalNotifyMessage:message];
    }
}

//群聊消息本地提醒
+(void) circleMessageNotify:(NSDictionary*) dic{
    [SocketMessageLocalNotify singleMessageNotify:dic];
}

@end
