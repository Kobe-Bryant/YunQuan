//
//  XHAudioPlayerHelper.m
//  MessageDisplayKit
//
//  Created by Aevitx on 14-1-22.
//  Copyright (c) 2014年 Aevitx. All rights reserved.
//

#import "XHAudioPlayerHelper.h"
#import "XHVoiceCommonHelper.h"

@implementation XHAudioPlayerHelper

#pragma mark - Public Methed

- (void)managerAudioWithFileName:(NSString*)amrName toPlay:(BOOL)toPlay {
    if (toPlay) {
        [self playAudioWithFileName:amrName];
    } else {
        [self pausePlayingAudio];
    }
}

- (void)managerAudioWithData:(NSData *)data toPlay:(BOOL)toPlay
{
    if(toPlay) {
        [self playAudioWithData:data];
    } else {
        [self pausePlayingAudio];
    }
}

//暂停
- (void)pausePlayingAudio {
    if (_player) {
        [_player pause];
        if ([self.delegate respondsToSelector:@selector(didAudioPlayerPausePlay:)]) {
            [self.delegate didAudioPlayerPausePlay:_player];
        }
    }
}

- (void)stopAudio {
    [self setPlayingFileName:@""];
    [self setPlayingIndexPathInFeedList:nil];
    if (_player && _player.isPlaying) {
        [_player stop];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    if ([self.delegate respondsToSelector:@selector(didAudioPlayerStopPlay:)]) {
        [self.delegate didAudioPlayerStopPlay:_player];
    }
}

#pragma mark - action

//用已有的二进制文件进行播放
- (void)playAudioWithData:(NSData *)data
{
    if (data != nil) {
        //不随着静音键和屏幕关闭而静音。code by Aevit
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if ([data isEqualToData:self.playingData]) {
            if (_player) {
                //重置 播放时间 code by snail
                _player.currentTime = 0;
                [_player play];
                [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
                if ([self.delegate respondsToSelector:@selector(didAudioPlayerBeginPlay:)]) {
                    [self.delegate didAudioPlayerBeginPlay:_player];
                }
            }
        } else {
            if (_player) {
                [_player stop];
                self.player = nil;
            }
            NSError * error;
            
            AVAudioPlayer *dataPlayer = [[AVAudioPlayer alloc]initWithData:data error:&error];
            if (error != nil) {
                NSLog(@"用二进制数据初始化声音播放器失败 ,%@",error);
            } else {
                dataPlayer.delegate = self;
                [dataPlayer play];
                self.player = dataPlayer;
                [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
                if ([self.delegate respondsToSelector:@selector(didAudioPlayerBeginPlay:)]) {
                    [self.delegate didAudioPlayerBeginPlay:_player];
                }
            }
        }
        self.playingData = data;
    }
}

//播放转换后wav
- (void)playAudioWithFileName:(NSString*)fileName {
    if (fileName.length > 0) {
        
        //不随着静音键和屏幕关闭而静音。code by Aevit
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        if (_playingFileName && [fileName isEqualToString:_playingFileName]) {//上次播放的录音
            if (_player) {
                [_player play];
                [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
                if ([self.delegate respondsToSelector:@selector(didAudioPlayerBeginPlay:)]) {
                    [self.delegate didAudioPlayerBeginPlay:_player];
                }
            }
        } else {//不是上次播放的录音
            if (_player) {
                [_player stop];
                self.player = nil;
            }
            /*
             [self convertAmrToWav:amrName];
             NSString *wavName = [amrName stringByReplacingOccurrencesOfString:@"wavToAmr" withString:@"amrToWav"];
             AVAudioPlayer *pl = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[XHVoiceCommonHelper getPathByFileName:fileName ofType:@"wav"]] error:nil];
             */
            AVAudioPlayer *pl = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:fileName] error:nil];
            pl.delegate = self;
            [pl play];
            self.player = pl;
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
            if ([self.delegate respondsToSelector:@selector(didAudioPlayerBeginPlay:)]) {
                [self.delegate didAudioPlayerBeginPlay:_player];
            }
        }
        self.playingFileName = fileName;
    }
}

/*
#pragma mark - amr转wav

- (void)convertAmrToWav:(NSString*)amrName {
    if (amrName.length > 0){
        NSString *wavName = [amrName stringByReplacingOccurrencesOfString:@"wavToAmr" withString:@"amrToWav"];// [amrName stringByAppendingString:@"amrToWav"];
        
        //转格式
        [VoiceConverter amrToWav:[SCAudioRecordManager getPathByFileName:amrName ofType:@"amr"] wavSavePath:[SCAudioRecordManager getPathByFileName:wavName ofType:@"wav"]];
        
    }
}
*/

#pragma mark - Getter

- (AVAudioPlayer*)player {
    return _player;
}

- (BOOL)isPlaying {
    if (!_player) {
        return NO;
    }
    return _player.isPlaying;
}

#pragma mark - Setter 

- (void)setDelegate:(id<XHAudioPlayerHelperDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
        
        if (_delegate == nil) {
            [self stopAudio];
        }
    }
}

#pragma mark - Life Cycle

+ (id)shareInstance {
    static XHAudioPlayerHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XHAudioPlayerHelper alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self changeProximityMonitorEnableState:YES];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
    return self;
}

- (void)dealloc {
    [self changeProximityMonitorEnableState:NO];
}

#pragma mark - audio delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self stopAudio];
    if ([self.delegate respondsToSelector:@selector(didAudioPlayerStopPlay:)]) {
//        [self.delegate didAudioPlayerStopPlay:_player];
    }
}

#pragma mark - 近距离传感器

- (void)changeProximityMonitorEnableState:(BOOL)enable {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        if (enable) {
            
            //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
            
        } else {
            
            //删除近距离事件监听
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}

- (void)sensorStateChange:(NSNotificationCenter *)notification {
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
    if ([[UIDevice currentDevice] proximityState] == YES) {
        //黑屏
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    } else {
        //没黑屏幕
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (!_player || !_player.isPlaying) {
            //没有播放了，也没有在黑屏状态下，就可以把距离传感器关了
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}

@end
