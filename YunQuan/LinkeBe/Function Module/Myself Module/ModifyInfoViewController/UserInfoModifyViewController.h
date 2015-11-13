//
//  UserInfoModifyViewController.h
//  ql
//
//  Created by yunlai on 14-4-22.
//  Copyright (c) 2014年 ChenFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpRequest.h"

@interface UserInfoModifyViewController : UIViewController<UITextFieldDelegate>

//title
@property (nonatomic ,retain) NSString *titleCtl;
//内容
@property (nonatomic ,retain) NSString *content;

@property (nonatomic,retain) NSString *fieldString;
@end
