//
//  AssignCircleViewController.h
//  LinkeBe
//
//  Created by yunlai on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AssignCircleDelegate <NSObject>

-(void) sureCallBack:(NSArray*) arr;

@end

@interface AssignCircleViewController : UIViewController

@property(nonatomic,assign) id<AssignCircleDelegate> delegate;

@property(nonatomic,retain) NSArray* selectArr;//选中的圈子

@end
