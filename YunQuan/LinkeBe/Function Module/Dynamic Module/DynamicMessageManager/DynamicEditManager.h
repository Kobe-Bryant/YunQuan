//
//  DynamicEditManager.h
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DynamicCommon.h"

@protocol DynamicEditDelegate <NSObject>

-(void) getDynamicEditHttpCallBack:(NSArray*) arr interface:(LinkedBe_WInterface) interface;

@end

@interface DynamicEditManager : NSObject

@property(nonatomic,assign) id<DynamicEditDelegate> delegate;

//发布动态请求
-(void) accessDynamicEditPublish:(NSMutableDictionary*) dic dataList:(NSArray*) dataArr;

@end
