//
//  WelcomeViewController.h
//  LinkeBe
//
//  Created by yunlai on 14-9-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface WelcomeViewController : UIViewController{
    UIProgressView *proView;
    double proValue;
    MBProgressHUD *HUD;
    NSTimer *timer;
}
@property(nonatomic,retain) NSDictionary* orgDataDic;
@end
