//
//  SnailMessageVoiceFactory.h
//  ql
//
//  Created by LazySnail on 14-6-26.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnailMessageVoiceFactory : NSObject

// 通过发送消息人类型来判断动画图片的方向 0 为自己发送 1 为别人发送
+ (UIImageView *)messageVoiceAnimationImageViewWithBubbleMessageType:(NSInteger)type;

@end
