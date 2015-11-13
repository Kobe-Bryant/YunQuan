//
//  SnailCommandObject.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnailCommandObject : NSObject

@property (nonatomic, assign) int command;

@property (nonatomic, assign) long long senderID;

@property (nonatomic, assign) long long receiverID;

@property (nonatomic, assign) int serialNumber;

@property (nonatomic, assign) NSDictionary * bodyDic;

- (instancetype)initWithData:(NSData *)data;

- (NSData *)data;

//- (void)handleCommandData;

@end
