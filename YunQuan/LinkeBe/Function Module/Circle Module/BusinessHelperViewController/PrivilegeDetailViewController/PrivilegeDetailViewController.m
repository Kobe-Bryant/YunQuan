//
//  PrivilegeDetailViewController.m
//  LinkeBe
//
//  Created by Dream on 14-9-15.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "PrivilegeDetailViewController.h"
#import "UIViewController+NavigationBar.h"
#import "Global.h"
#import "UIImageView+WebCache.h"
#import "MobClick.h"

@interface PrivilegeDetailViewController ()

@end

@implementation PrivilegeDetailViewController
@synthesize privilegeDetailDic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"特权详情";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"PrivilegeDetailViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"PrivilegeDetailViewPage"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = BACKGROUNDCOLOR;
    
    [self creteaBackButton]; // 返回
    
    [self initScrollVC];
    [self initHeadView];
    
}

//初始化滚动
-(void) initScrollVC{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollView];
    [self.view bringSubviewToFront:scrollView];
    [scrollView release];
    
    UIImageView* midImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 125, self.view.bounds.size.width, 200)];
    [midImgV setImageWithURL:[self.privilegeDetailDic objectForKey:@"imagePath"] placeholderImage:[UIImage imageNamed:@"img_landing_default220.png"]];
    [scrollView addSubview:midImgV];
    
    UILabel* lab = [[UILabel alloc] init];
    lab.frame = CGRectMake(10, CGRectGetMaxY(midImgV.frame), 100, 30);
    lab.font = KQLboldSystemFont(15);
    lab.textColor = [UIColor darkGrayColor];
    lab.text = @"使用说明";
    lab.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:lab];
    
    UITextView* textV = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMinX(lab.frame), CGRectGetMaxY(lab.frame), self.view.bounds.size.width - 20, 88)];
    textV.userInteractionEnabled = NO;
    textV.backgroundColor = [UIColor whiteColor];
    textV.font = KQLboldSystemFont(13);
    textV.textColor = [UIColor darkGrayColor];
    textV.text = [self.privilegeDetailDic objectForKey:@"desc"];
    [scrollView addSubview:textV];
    
    CGSize size = [textV.text sizeWithFont:textV.font constrainedToSize:CGSizeMake(self.view.bounds.size.width, 2000) lineBreakMode:NSLineBreakByWordWrapping];
    textV.frame = CGRectMake(CGRectGetMinX(lab.frame), CGRectGetMaxY(lab.frame), self.view.bounds.size.width - 20, size.height + 60);
    
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, CGRectGetMaxY(textV.frame) + 64 + 40);
    
    RELEASE_SAFE(lab);
    RELEASE_SAFE(textV);
    RELEASE_SAFE(midImgV);
    
}

//初始化头部UI
-(void) initHeadView{
    //250/2
    UIView* headV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 250/2)];
    headV.backgroundColor = [UIColor clearColor];
    [self.view addSubview:headV];
    
    UIImageView* bgImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, headV.bounds.size.width, headV.bounds.size.height)];
    bgImgV.image = [UIImage imageNamed:@"bg_tool_pd"];
    [headV addSubview:bgImgV];
    
    UIImage* tagImage = [UIImage imageNamed:@"ico_tool_discount"];
    UIImageView* tagImgV = [[UIImageView alloc] initWithFrame:CGRectMake(10, (80 - tagImage.size.height)/2, tagImage.size.width, tagImage.size.height)];
    tagImgV.image = tagImage;
    [headV addSubview:tagImgV];
    
    UILabel* titleLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tagImgV.frame) + 10, 10, self.view.bounds.size.width - (CGRectGetMaxX(tagImgV.frame) + 10), 25)];
    titleLab.text = [self.privilegeDetailDic objectForKey:@"title"];//@"云来网络";
    titleLab.textColor = [UIColor whiteColor];
    titleLab.font = [UIFont boldSystemFontOfSize:16.0];
    titleLab.backgroundColor = [UIColor clearColor];
    [headV addSubview:titleLab];
    
    long long startTime = [[self.privilegeDetailDic objectForKey:@"startTime"] longLongValue];
    long long endTime = [[self.privilegeDetailDic objectForKey:@"endTime"] longLongValue];
    
    NSString* startStr = [Common makeTime13To10:startTime withFormat:@"YYYY.MM.dd"];
    NSString* endStr = [Common makeTime13To10:endTime withFormat:@"YYYY.MM.dd"];
    
    UILabel* indateLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tagImgV.frame) + 10, CGRectGetMaxY(titleLab.frame) + 10, self.view.bounds.size.width - (CGRectGetMaxX(tagImgV.frame) + 10), 25)];
    indateLab.textColor = [UIColor whiteColor];
    indateLab.font = [UIFont boldSystemFontOfSize:13.0];
    indateLab.backgroundColor = [UIColor clearColor];
    indateLab.text = [NSString stringWithFormat:@"有效期：%@－%@",startStr,endStr];
    [headV addSubview:indateLab];
    
    UIImageView* lineImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 80, self.view.bounds.size.width, 1)];
    lineImgV.image = [UIImage imageNamed:@"img_feed_line"];
    [headV addSubview:lineImgV];
    
    UILabel* LAB = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, self.view.bounds.size.width, 45)];
    LAB.text = @"云来网络";
    LAB.backgroundColor = [UIColor clearColor];
    LAB.textAlignment = NSTextAlignmentCenter;
    LAB.textColor = [UIColor whiteColor];
    LAB.font = KQLboldSystemFont(13);
    [headV addSubview:LAB];
    
    RELEASE_SAFE(bgImgV);
    RELEASE_SAFE(headV);
    RELEASE_SAFE(tagImgV);
    RELEASE_SAFE(titleLab);
    RELEASE_SAFE(indateLab);
    RELEASE_SAFE(lineImgV);
    RELEASE_SAFE(LAB);
}

//时间转化yyyy-MM-dd格式
-(NSString*) dateIntToStr:(int) d{
    NSDateFormatter* format = [[[NSDateFormatter alloc] init] autorelease];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate* date = [[[NSDate alloc] initWithTimeIntervalSince1970:d] autorelease];
    
    return [format stringFromDate:date];
}

#pragma mark --  各种手势按钮点击事件

//返回按钮
- (void)creteaBackButton{
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
}

- (void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
