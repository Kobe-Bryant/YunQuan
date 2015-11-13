//
//  SystemApnsLoginMessageData.h
//  LinkeBe
//
//  Created by yunlai on 14-9-26.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpRequest.h"

@protocol SystemApnsLoginMessageDelegate <NSObject>

-(void)getSystemApnsLoginMessageHttpCallBack:(NSArray*) arr interface:(LinkedBe_WInterface) interface;

@end

@interface SystemApnsLoginMessageData : NSObject<HttpRequestDelegate>{
    
}
@property(nonatomic,assign) id<SystemApnsLoginMessageDelegate> delegate;


//apns 设配令牌
-(void) accessSystemApnsMessageData:(NSMutableDictionary*) apnsMessageDic;
@end
