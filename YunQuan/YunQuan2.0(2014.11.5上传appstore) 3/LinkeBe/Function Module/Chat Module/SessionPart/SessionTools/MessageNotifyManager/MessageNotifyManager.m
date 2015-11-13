//
//  MessageNotifyManager.m
//  ql
//
//  Created by LazySnail on 14-8-11.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "MessageNotifyManager.h"
#import <AudioToolbox/AudioToolbox.h>

@interface MessageNotifyManager ()
{
    SystemSoundID _soundID;
}

@end

@implementation MessageNotifyManager

static id _messageNotifyManager;

+ (MessageNotifyManager *)shareNotifyManager
{
    if (_messageNotifyManager == nil) {
        _messageNotifyManager = [MessageNotifyManager new];
    }
    return _messageNotifyManager;
}

- (void)playChatMessageReciveSystemMusic
{
    
//    NSString *path = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"]pathForResource:@"Tock" ofType:@"aiff"];
//    
//    OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &_soundID);
//    if (error != kAudioServicesNoError) {
//        NSLog(@"Get voice id error %d",(int)error);
//    } else {
//    }
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

}

- (void)playVibrate
{
    //进入后台，有本地通知，不需要震动 booky 9.5
//    if (![Global sharedGlobal].isBackGround) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//    }
}



@end
