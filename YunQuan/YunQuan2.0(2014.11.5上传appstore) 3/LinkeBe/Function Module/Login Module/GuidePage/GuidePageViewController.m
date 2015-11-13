//
//  GuidePageViewController.m
//  ql
//
//  Created by yunlai on 14-2-24.
//  Copyright (c) 2014年 ChenFeng. All rights reserved.
//

#import "GuidePageViewController.h"
#import "LoginViewController.h"
#import "JCTopic.h"
#import "Global.h"
#import "GuidePageMessageManager.h"
#import "InvitationCodeViewController.h"
#import "MobClick.h"

@interface GuidePageViewController ()//<GuidePageMessageManagerDelegate>
{
    CGSize pageSize;//add vincent
    
    UIImageView *placeHolderImgV; //当前图片的view
}
@property (nonatomic ,retain) NSDictionary *dataDic; //当前请求的数据的字典
@property (nonatomic ,retain) JCTopic *topic; //add vincent
@property (nonatomic ,retain) UIPageControl *pageControl; //add vincent

@property (nonatomic, retain) NSMutableArray *imageArray;

@end

@implementation GuidePageViewController
@synthesize dataDic,topic;
@synthesize pageControl = _pageControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if(isIPhone4){
            self.imageArray = [[NSMutableArray alloc] initWithObjects:@"i4_first.png",@"i4_second.png",@"i4_third.png",@"i4_four.png",@"i4_five.png", nil];
        }else{
            self.imageArray = [[NSMutableArray alloc] initWithObjects:@"i5_first.png",@"i5_second.png",@"i5_third.png",@"i5_four.png",@"i5_five.png", nil];
        }
    }
    return self;
}

- (id)initNibView:(NSDictionary *)dic{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [MobClick beginLogPageView:@"GuideViewPage"];
    //add vinvent
    [topic setupTimer];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"GuideViewPage"];
    //停止自己滚动的timer
    [topic releaseTimer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = RGBACOLOR(38, 41, 45, 1);
    
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self addPlaceHolderPic];
    
//    [self accessGuidePageService];
    
    [self loadAdsScrollView]; //广告视图 add vincent

    [self initLoginAndCodeBtn]; //初始化邀请码，和登陆按钮
    
    [self refreshAds];
    
//    add vincent
    _pageControl = [[UIPageControl alloc] init];
    if (IOS7_OR_LATER) {
        _pageControl.frame = CGRectMake((ScreenWidth - pageSize.width)/2,ScreenHeight - 30.f, pageSize.width,20.f);
    }else{
        _pageControl.frame = CGRectMake((ScreenWidth - pageSize.width)/2,ScreenHeight - 50.f, pageSize.width,20.f);
    }
    _pageControl.pageIndicatorTintColor = RGBACOLOR(255, 255, 255, 1);//其他点的颜色
    _pageControl.currentPageIndicatorTintColor = RGBACOLOR(26,161,230,1);//当前点的颜色
    [_pageControl setCurrentPage:0];
    _pageControl.numberOfPages = 5;
    [self.view addSubview:_pageControl];
    [_pageControl release];
}

//初始化当前的邀请码和登陆的按钮的界面
-(void)initLoginAndCodeBtn{
    UIButton *codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [codeBtn setFrame:CGRectMake(35.f, ScreenHeight-30-33-44-15-44, ScreenWidth - 70.0, 44)];
    [codeBtn setTitle:@"验证邀请码" forState:UIControlStateNormal];
    [codeBtn addTarget:self action:@selector(codeAction) forControlEvents:UIControlEventTouchUpInside];
    codeBtn.layer.cornerRadius = 5;
    [codeBtn setBackgroundColor:RGBACOLOR(255, 255, 255, 0.95)];
    [codeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    codeBtn.titleLabel.font = KQLSystemFont(18);
    [self.view addSubview:codeBtn];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setFrame:CGRectMake(35.f,CGRectGetMaxY(codeBtn.frame) + 15.f, ScreenWidth - 70.0, 44)];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn setBackgroundColor:RGBACOLOR(26,161,230,0.95)];
    [loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.layer.cornerRadius = 5;
    loginBtn.titleLabel.font = KQLSystemFont((18));
    [self.view addSubview:loginBtn];

}

-(void) addPlaceHolderPic{
    placeHolderImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight)];
    placeHolderImgV.contentMode = UIViewContentModeScaleAspectFill;
    placeHolderImgV.image = [UIImage imageNamed:@"default_Guide.jpeg"];
    [self.view addSubview:placeHolderImgV];
}

// 邀请码事件
- (void)codeAction{
    [MobClick event:@"welcome_inviteButton"];
    InvitationCodeViewController *invitationVC = [[InvitationCodeViewController alloc] init];
    [self.navigationController pushViewController:invitationVC animated:YES];
    RELEASE_SAFE(invitationVC);
}

// 登录
- (void)loginAction{
    [MobClick event:@"welcome_loginButton"];
    [MobClick event:@"login_start_login"];
    LoginViewController *loginVC = [[LoginViewController alloc]init];
    [self.navigationController pushViewController:loginVC animated:YES];
    RELEASE_SAFE(loginVC);
}

/**
 *  广告视图
 */
-(void)loadAdsScrollView{
    topic = [[JCTopic alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    topic.JCdelegate = self;
    [self.view addSubview:topic];
    [topic release];
}

/**
 *  刷新广告
 */
- (void)refreshAds{
    //移除站位图 booky
    [placeHolderImgV removeFromSuperview];
    
//    if (self.dataDic) {
//        NSArray *array = [self.dataDic objectForKey:@"pics"];
//        if ([array count] == 0) {
//            UIImage * image = [UIImage imageNamed:@"default_Guide.jpeg"];
//            [self.imageArray addObject:[NSDictionary dictionaryWithObjects:@[image ,@YES] forKeys:@[@"pic",@"isLoc"]]];
//        } else {
//    for () {
//        [self.imageArray addObject:[NSDictionary dictionaryWithObjects:@[[dic objectForKey:@"imagePath"],@NO] forKeys:@[@"pic",@"isLoc"]]];
//    }
//        }
//    } else {
//        if ([self.imageArray count] == 0) {
//            UIImage * image = [UIImage imageNamed:@"default_Guide.jpeg"];
//            [self.imageArray addObject:[NSDictionary dictionaryWithObjects:@[image ,@YES] forKeys:@[@"pic",@"isLoc"]]];
//        }
//    }
   topic.pics = self.imageArray;
    [topic upDate];
}

- (void)dealloc
{
    self.imageArray = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - accessService
//- (void)accessGuidePageService{
//    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0",@"ts",nil];
//    GuidePageMessageManager *guidePageMessage = [[GuidePageMessageManager alloc] init];
//    guidePageMessage.delegate = self;
//    [guidePageMessage accessGuidePageMessageData:jsontestDic requestType:LinkedBe_GET];
//}

//-(void)getGuidePageMessageHttpCallBack:(NSArray*)resultArray guideDic:(NSDictionary *)guideDic interface:(LinkedBe_WInterface)interface{
//    switch (interface) {
//        case LinkedBe_System_Index:
//        {
//            self.dataDic = guideDic;//[guideDic objectForKey:@"pics"];
//            [self refreshAds];
//        }
//            break;
//            default:
//            break;
//    }
//}

#pragma mark - JCTopicDelegate
-(void)currentPage:(int)page total:(NSUInteger)total{
    _pageControl.numberOfPages = total;
    _pageControl.currentPage = page;
    pageSize = [_pageControl sizeForNumberOfPages:total];
}

-(void)didClick:(int)index{
    
}
@end
