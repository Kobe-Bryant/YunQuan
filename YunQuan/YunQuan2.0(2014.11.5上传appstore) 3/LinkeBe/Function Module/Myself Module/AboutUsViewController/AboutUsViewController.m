//
//  AboutUsViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-29.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "AboutUsViewController.h"
#import "UIViewController+NavigationBar.h"
#import "MobClick.h"

@interface AboutUsViewController ()

@property(nonatomic,retain) UIImageView* aboutUsImgV;//关于我们图片
@end

@implementation AboutUsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"AboutUsViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"AboutUsViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"关于云圈";

    self.view.backgroundColor = RGBACOLOR(249, 249, 249, 1);
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
    
    [self initMainImageView];
}

//初始化有图片时关于我们UI
-(void) initMainImageView{
    _aboutUsImgV = [[UIImageView alloc] init];
    _aboutUsImgV.frame = self.view.bounds;
    if (isIPhone4) {
        [_aboutUsImgV setImage:[UIImage imageNamed:@"bg_aboutUs_iphone4.png"]];
    }else{
        [_aboutUsImgV setImage:[UIImage imageNamed:@"bg_aboutUs_iphone5.png"]];
    }
    _aboutUsImgV.frame = CGRectMake(0, 0, _aboutUsImgV.image.size.width, _aboutUsImgV.image.size.height);
    _aboutUsImgV.userInteractionEnabled = YES;
    [self.view addSubview:_aboutUsImgV];
    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.textColor = [UIColor blackColor];
    versionLabel.font = [UIFont boldSystemFontOfSize:15];
    if (isIPhone4) {
        versionLabel.frame = CGRectMake(0, 105, 320, 60);
    }else{
        versionLabel.frame = CGRectMake(0, 180, 320, 60);
    }
    versionLabel.backgroundColor = [UIColor clearColor];
    versionLabel.text = [NSString stringWithFormat:@"云圈 V%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
    [_aboutUsImgV addSubview:versionLabel];
    [versionLabel release];
    
    
    UIView *tapView = [[UIView alloc] init];
    if (isIPhone5) {
        tapView.frame = CGRectMake(30, self.view.frame.size.height - 210, 260, 45);
    }else{
        tapView.frame = CGRectMake(30, self.view.frame.size.height - 210, 260, 45);
    }
    tapView.backgroundColor = [UIColor clearColor];
    [_aboutUsImgV addSubview:tapView];
    [tapView release];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhone)];
    [tapView addGestureRecognizer:tap];
    RELEASE_SAFE(tap);
}

#pragma mark - 点击打电话
//使用webview加载的方式 有弹框效果
-(void)tapPhone{
    UIWebView*callWebview =[[UIWebView alloc] init];
    NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",@"0755-86329205"]];
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    
    [self.view addSubview:callWebview];
    [callWebview release];
}

-(void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void) dealloc{
    [_aboutUsImgV removeFromSuperview];
    [super dealloc];
}
@end
