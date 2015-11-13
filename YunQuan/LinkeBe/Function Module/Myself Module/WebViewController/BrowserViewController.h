//
//  BrowserViewController.h
//  LinkeBe
//
//  Created by yunlai on 14-9-29.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,PushType ) {
    BussinessCardPush,
    MyselfPush
};

@interface BrowserViewController : UIViewController<UIWebViewDelegate,UIGestureRecognizerDelegate,UINavigationControllerDelegate>

{
    UIWebView *myWebView;
    UIActivityIndicatorView *spinner;
}
@property(nonatomic,retain)NSString *webvieUrl;
@property(nonatomic,retain)NSString *webTitle;

@property (nonatomic, assign)PushType pushType;
@end
