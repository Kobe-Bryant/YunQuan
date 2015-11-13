//
//  InvitationCodeMessageData.h
//  LinkeBe
//
//  Created by yunlai on 14-9-25.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"
#import "HttpRequest.h"

@protocol InvitationCodeMessageDataDelegate <NSObject>

-(void)getInvitationCodeMessageDataHttpCallBack:(NSArray*) arr requestCallBackDic:(NSDictionary *)dic interface:(LinkedBe_WInterface) interface;

@end

@interface InvitationCodeMessageData : NSObject<HttpRequestDelegate>

@property(nonatomic,assign) id<InvitationCodeMessageDataDelegate> delegate;

-(void) accessInvitationCodeMessageData:(NSMutableDictionary*) requestDic;
@end
