//
//  VoiceMessageCell.h
//  ql
//
//  Created by LazySnail on 14-6-26.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "MessageCell.h"
#import "VoiceData.h"

@interface VoiceMessageCell : MessageCell

@property (nonatomic, retain) VoiceData * voiceObject;

- (void)playCurrentVoice;

@end
