//
//  ServiceViewController.m
//  ql
//
//  Created by Dream on 14-9-9.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "ServiceViewController.h"
#import "Global.h"
#import "UIViewController+NavigationBar.h"
#import "NSObject_extra.h"
#import "MobClick.h"

@interface ServiceViewController ()<UIWebViewDelegate> {

    UIWebView *_webView;
    UIActivityIndicatorView *_indicatorView;
}

@end

@implementation ServiceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    _webView.delegate = nil;
    [_webView release];
    [_indicatorView release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"ServiceViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"ServiceViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"服务协议";
    self.view.backgroundColor =  RGBACOLOR(249,249,249,1);
    
    [self creteaRightButton];
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0 ,self.view.bounds.size.width, self.view.bounds.size.height - 64)];
    if (!IOS7_OR_LATER) {
        _webView.frame = CGRectMake(0, 0 ,self.view.bounds.size.width, self.view.bounds.size.height - 44);
    }
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    NSURL *url = [NSURL URLWithString:SERVICEDELEGATE];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_indicatorView setCenter:self.view.center];
    [self.view addSubview:_indicatorView];
}


#pragma mark - UIWebViewDelegate Methods
- (void)webViewDidStartLoad:(UIWebView *)aWebView{
	[_indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView{
	[_indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error{
    [_indicatorView stopAnimating];
    NSLog(@"error %d",[error code]);
    if ([error code]==-1009) {
        [self alertWithFistButton:@"确定" SencodButton:nil Message:@"网络不给力呀，请稍后重试"];
    }

}

/**
 *  返回按钮
 */
/**
 *  导航栏右边按钮
 */
- (void)creteaRightButton{
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
}

- (void)backTo {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
