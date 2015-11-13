//
//  SetPlaceViewController.h
//  ql
//
//  Created by yunlai on 14-8-18.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetPlaceDelegate <NSObject>

@optional
-(void) setOpenTimePlace:(NSString*) str;

@end

@interface SetPlaceViewController : UIViewController<UITextFieldDelegate>

@property(nonatomic,assign) id<SetPlaceDelegate> delegate;
//设置地点文本
@property(nonatomic,copy) NSString* placeStr;

@end
