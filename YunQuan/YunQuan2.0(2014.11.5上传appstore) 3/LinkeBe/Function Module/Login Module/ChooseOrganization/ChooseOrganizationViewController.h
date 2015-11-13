//
//  ChooseOrganizationViewController.h
//  ql
//
//  Created by yunlai on 14-5-22.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface ChooseOrganizationViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UIProgressView *proView;
    double proValue;
    MBProgressHUD *HUD;
    NSTimer *timer;
}

@property (nonatomic,retain) NSArray *orgArr;

@end
