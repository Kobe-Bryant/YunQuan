//
//  SnailCommandReceiveMessage.h
//  LinkeBe
//
//  Created by LazySnail on 14-1-26.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandObject.h"
#import "MessageData.h"

@interface SnailCommandReceiveMessage : SnailCommandObject

- (void)storeMessageAndSendItToOtherComponentWithMessageDic:(NSDictionary *)dic andMessageType:(SessionType)type;

@end
