//
//  CompanyLiveAppBrowserViewController.h
//  LinkeBe
//
//  Created by yunlai on 14-10-8.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface CompanyLiveAppBrowserViewController : UIViewController <UIWebViewDelegate,UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    
    UIActivityIndicatorView *spinner;
    UIWebView *_myWebView;
}

@property (nonatomic, retain) MBProgressHUD *mbProgressHUD;
@property (nonatomic, retain) NSString *webTitle;
@property (nonatomic, retain) NSString *url;


@end
