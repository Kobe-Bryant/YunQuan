//
//  SnailMessageVoiceFactory.m
//  ql
//
//  Created by LazySnail on 14-6-26.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "SnailMessageVoiceFactory.h"

@implementation SnailMessageVoiceFactory

// 通过发送消息人类型来判断动画图片的方向 0 为自己发送 1 为别人发送
+ (UIImageView *)messageVoiceAnimationImageViewWithBubbleMessageType:(NSInteger)type
{
    UIImageView *messageVoiceAniamtionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    NSString *imageSepatorName = nil;

    switch (type) {
        case 0:
            imageSepatorName = @"ico_common_right_voice";
            break;
        case 1:
            imageSepatorName = @"ico_common_left_voice";
            break;
        default:
            break;
    }
    
    NSMutableArray * images = [NSMutableArray arrayWithCapacity:3];
    for (NSInteger i = 0; i < 4; i++) {
        UIImage *img = [UIImage imageCwNamed:[imageSepatorName stringByAppendingFormat:@"%d.png",i]];
        if (img) {
            [images addObject:img];
        }
    }
    
    messageVoiceAniamtionImageView.image = [UIImage imageNamed:imageSepatorName];
    messageVoiceAniamtionImageView.animationImages = images;
    messageVoiceAniamtionImageView.animationDuration = 1.0;
    [messageVoiceAniamtionImageView stopAnimating];
    
    return messageVoiceAniamtionImageView;
}


@end
