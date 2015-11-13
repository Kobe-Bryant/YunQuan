//
//  VerifyViewController.h
//  ql
//
//  Created by yunlai on 14-2-22.
//  Copyright (c) 2014年 ChenFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface VerifyViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic ,retain)NSDictionary *inviteeDic;

@end
