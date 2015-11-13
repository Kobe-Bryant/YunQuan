//
//  SnailRequestObject.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-25.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnailRequestObject : NSObject

//请求类型
@property (nonatomic, readonly) LinkedBe_RequestType requestType;
//接口命令标识
@property (nonatomic, assign) LinkedBe_WInterface command;

//接口地址
@property (nonatomic, retain) NSString * requestInterface;
//请求参数
@property (nonatomic, retain) NSMutableDictionary * requestParam;
//附带参数
@property (nonatomic, retain) id plusParameter;

@end
