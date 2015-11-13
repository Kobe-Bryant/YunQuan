//
//  BrowserViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-29.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "BrowserViewController.h"
#import "Global.h"
#import "UIViewController+NavigationBar.h"

@interface BrowserViewController ()

@end

@implementation BrowserViewController
@synthesize webvieUrl;
@synthesize webTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pushType = MyselfPush;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = webTitle;
    
    self.view.backgroundColor = RGBACOLOR(249, 249, 249, 1);
    
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
    
	myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width , ScreenHeight - 64)];
	myWebView.delegate = self;
	myWebView.scalesPageToFit = YES;
	[self.view addSubview:myWebView];
    
	if ([self.webvieUrl length] > 1)
	{
		//开始请求连接
		NSURL *webUrl =[NSURL URLWithString:self.webvieUrl];
		NSURLRequest *request =[NSURLRequest requestWithURL:webUrl];
		[myWebView loadRequest:request];
	}

}

-(void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.pushType == BussinessCardPush) {
        self.tabBarController.tabBar.hidden = YES;
    }
}

//当网页视图已经开始加载一个请求后，得到通知。
-(void)webViewDidStartLoad:(UIWebView*)webView
{
	//添加loading图标
    if (spinner == nil)
    {
        spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        [spinner setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2.0)];
    }
	
    [self.view addSubview:spinner];
	[spinner startAnimating];
}

//当网页视图结束加载一个请求之后，得到通知。
-(void)webViewDidFinishLoad:(UIWebView*)webView
{
    [spinner stopAnimating];
	[spinner removeFromSuperview];

}

//当在请求加载中发生错误时，得到通知。会提供一个NSSError对象，以标识所发生错误类型。
-(void)webView:(UIWebView*)webView  DidFailLoadWithError:(NSError*)error
{
	NSLog(@"浏览器浏览发生错误...");
}

- (void)dealloc {
	[myWebView release];
    myWebView.delegate = nil;
    [spinner release];
    [webTitle release];
    [super dealloc];
}

@end
