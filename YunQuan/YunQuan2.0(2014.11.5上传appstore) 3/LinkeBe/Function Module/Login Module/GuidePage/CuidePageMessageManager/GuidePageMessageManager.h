//
//  GuidePageMessageManager.h
//  LinkeBe
//
//  Created by yunlai on 14-9-25.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpRequest.h"
#import "Global.h"

@protocol GuidePageMessageManagerDelegate <NSObject>

-(void)getGuidePageMessageHttpCallBack:(NSArray*) arr guideDic:(NSDictionary *)guideDic interface:(LinkedBe_WInterface) interface;

@end


@interface GuidePageMessageManager : NSObject<HttpRequestDelegate>

@property(nonatomic,assign) id<GuidePageMessageManagerDelegate> delegate;

-(void) accessGuidePageMessageData:(NSMutableDictionary*) loginDic requestType:(LinkedBe_RequestType)requestType;

@end
