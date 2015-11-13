//
//  LoginViewController.h
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,retain)NSString *mobileString;//在A组织已注册登录的用户，收到B组织的邀请码，再次走注册流程，然后手机号码是已经获取到了
@end
