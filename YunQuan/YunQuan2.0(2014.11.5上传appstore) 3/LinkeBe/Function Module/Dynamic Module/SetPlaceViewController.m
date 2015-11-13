//
//  SetPlaceViewController.m
//  ql
//
//  Created by yunlai on 14-8-18.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "SetPlaceViewController.h"
#import "CusTextField.h"

#import "Global.h"
#import "Common.h"
#import "MobClick.h"

@interface SetPlaceViewController ()

//地址输入框
@property(nonatomic,retain) CusTextField* placeField;
@property(nonatomic,retain) UIView* stateView;
@property(nonatomic,retain) UILabel* stateLab;

@end

@implementation SetPlaceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [MobClick beginLogPageView:@"SetPlaceViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"SetPlaceViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"设置地点";
    
    if (IOS7_OR_LATER) {
        self.navigationController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = BACKGROUNDCOLOR;
    
    [self initNavBar];
    
    [self initMainView];
    
	// Do any additional setup after loading the view.
}

//导航栏初始化
-(void) initNavBar{
    UIButton* leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.backgroundColor = [UIColor clearColor];
    [leftBtn addTarget:self action:@selector(leftButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    leftBtn.frame = CGRectMake(0, 30, 50, 30);
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    
    UIBarButtonItem* leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    RELEASE_SAFE(leftItem);
    
    UIButton* rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.backgroundColor = [UIColor clearColor];
    [rightBtn addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(0, 30, 50, 30);
    [rightBtn setTitleColor:BLUECOLOR forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    RELEASE_SAFE(rightItem);
}

#pragma mark - back
-(void) leftButtonClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) rightButtonClick{
    //必须要输入,限制字数
    NSString* placeStr = self.placeField.text;
    if ([placeStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [Common checkProgressHUDShowInAppKeyWindow:@"请输入聚会地点" andImage:nil];
        return;
    }
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(setOpenTimePlace:)]) {
        [_delegate setOpenTimePlace:placeStr];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

#pragma mark - textField
-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //拦截换行和空格
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    
    return YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

//主视图初始化
-(void) initMainView{
    //ios6适配
    CGFloat fixHeight;
    if (IOS7_OR_LATER) {
        fixHeight = 64.0;
    }else{
        fixHeight = 0;
    }
    
    //输入框
    CusTextField* textField = [[CusTextField alloc] init];
    textField.delegate = self;
    textField.frame = CGRectMake(0, 20 + fixHeight, self.view.bounds.size.width, 45);
    textField.placeholder = @"请输入地点";
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.backgroundColor = [UIColor whiteColor];
    if (!IOS7_OR_LATER) {
         textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    textField.font = KQLboldSystemFont(15);
    self.placeField = textField;
    [self.view addSubview:textField];
    
    if (_placeStr) {
        textField.text = _placeStr;
    }
    
    //定位
    UIView* staView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(textField.frame) + 20, self.view.bounds.size.width, 45)];
    staView.backgroundColor = [UIColor whiteColor];
    staView.userInteractionEnabled = YES;
    [self.view addSubview:staView];
    self.stateView = staView;
    
    UIImageView* dtImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 30, 30)];
    dtImgV.image = IMGREADFILE(@"ico_feed_position.png");
    [staView addSubview:dtImgV];
    
    UILabel* staLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(dtImgV.frame) + 10, CGRectGetMinY(dtImgV.frame), 200, 30)];
    staLab.textColor = [UIColor darkGrayColor];
    staLab.font = [UIFont systemFontOfSize:14];
    staLab.backgroundColor = [UIColor clearColor];
    staLab.text = @"未开启定位";
    [staView addSubview:staLab];
    self.stateLab = staLab;
    
    [textField release];
    [staView release];
    [dtImgV release];
    [staLab release];
    
    self.stateView.hidden = YES;
}

//取消键盘
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_placeField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc{
    _delegate = nil;
    
    [_placeStr release];
    [_placeField release];
    [_stateLab release];
    [_stateView release];
    
    [super dealloc];
}

@end
