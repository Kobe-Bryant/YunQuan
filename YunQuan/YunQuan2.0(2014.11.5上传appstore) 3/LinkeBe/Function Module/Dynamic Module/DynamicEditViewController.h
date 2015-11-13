//
//  DynamicEditViewController.h
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DynamicCommon.h"

@protocol DynamicEditDelegate <NSObject>

-(void) publishSuccessCallBackWith:(NSDictionary*) dic;

@end

@interface DynamicEditViewController : UIViewController

@property(nonatomic,assign) id<DynamicEditDelegate> delegate;

//动态类型
@property(nonatomic) DynamicType type;

@end
