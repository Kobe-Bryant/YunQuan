//
//  TempChatNameViewController.m
//  LinkeBe
//
//  Created by Dream on 14-9-25.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "TempChatNameViewController.h"
#import "Global.h"
#import "UIViewController+NavigationBar.h"
#import "TempChatManager.h"
#import "CommonProgressHUD.h"
#import "Common.h"
#import "MobClick.h"

#define sureBtnTag  200

@interface TempChatNameViewController ()<UITextViewDelegate,TempChatManagerDelegate>
{
    UILabel *_countLable;
    UIImageView *_clearImage;

}

@property (nonatomic, retain) UITextView *nameTextView;
@property (nonatomic, retain) UIButton *tempBtn;


@end

@implementation TempChatNameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"会话名称";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"TempChatNameViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"TempChatNameViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
    [self loadBackButton]; //返回按钮
    
    [self loadRightButton]; //导航栏右按钮
    
    [self loadTextView];   //textView
}

- (void)loadTextView {
    
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, ScreenWidth, 60)];
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.borderWidth = 0.5;
    backView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    UITextView *textView = [[UITextView alloc]init];
    [textView becomeFirstResponder];
    textView.font = [UIFont systemFontOfSize:17.0];
    textView.textColor = RGBACOLOR(136, 136, 136, 1);
    textView.frame = CGRectMake(0, 0, ScreenWidth - 50, 60);
    textView.delegate = self;
    textView.text = self.title;
    self.nameTextView = textView;
    [backView addSubview:textView];
    [self.view addSubview:backView];
    
    UIImage *clear = [UIImage imageNamed:@"ico_search_delete.png"];
    _clearImage = [[UIImageView alloc]initWithImage:clear];
    _clearImage.hidden = YES;
    if (textView.text.length > 0) {
        _clearImage.hidden = NO;
    }
    _clearImage.userInteractionEnabled = YES;
    _clearImage.frame = CGRectMake(285, 30, clear.size.height, clear.size.width);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clearText)];
    [_clearImage addGestureRecognizer:tap];
    [tap release];
    
    [self.view addSubview:_clearImage];
    
    _countLable =  [[UILabel alloc]initWithFrame:CGRectMake(275, CGRectGetMidY(_clearImage.frame) + 20, 70, 20)];
    _countLable.backgroundColor = [UIColor clearColor];
    _countLable.textColor = RGBACOLOR(136, 136, 136, 1);
    _countLable.text = [NSString stringWithFormat:@"%d/20",[self.nameTextView.text length]];
    _countLable.font = [UIFont systemFontOfSize:16.0];
    [self.view addSubview:_countLable];

    RELEASE_SAFE(textView);
    RELEASE_SAFE(backView);
}

#pragma mark - textView Delegate

//文本框检测 超过20个字 按钮不可点击
-(BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    self.navigationItem.rightBarButtonItem.enabled = YES;
//    [self.tempBtn setTitleColor:BLUECOLOR forState:UIControlStateNormal];
    
//    NSString * textString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    
    if ([textView.text length] > 20) {
        return NO;
    }else if([textView.text length] <21){
        _countLable.text = [NSString stringWithFormat:@"%d/20",textView.text.length];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString * newStr = textView.text;
    if ([newStr length] > 0) {
        _clearImage.hidden = NO;
    } else {
        _clearImage.hidden = YES;
    }
    
    if ([newStr isEqualToString:self.title]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self.tempBtn setTitleColor:RGBACOLOR(20,109,190,1) forState:UIControlStateNormal];
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.tempBtn setTitleColor:BLUECOLOR forState:UIControlStateNormal];
    }
}

//返回按钮
- (void)loadBackButton{
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
}

- (void)loadRightButton {
    //确认
    UIButton* moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(0, 0, 40, 30);
    [moreBtn setTitle:@"保存" forState:UIControlStateNormal];
    [moreBtn setTitleColor:RGBACOLOR(20,109,190,1) forState:UIControlStateNormal];
    moreBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [moreBtn addTarget:self action:@selector(sureClick) forControlEvents:UIControlEventTouchUpInside];
    self.tempBtn = moreBtn;
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    rightItem.enabled = NO;
    
    [rightItem release];
}

- (void)backTo{
    [self.nameTextView resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
    self.nameTextView.text = nil;
}


//保存
- (void)sureClick {
    if (self.nameTextView.text.length > 0 && self.nameTextView.text != nil) {
        [[TempChatManager shareManager] modifyTempContactName:self.circleId circleName:self.nameTextView.text];
        [TempChatManager shareManager].delegate = self;
        
        if ([_delegate respondsToSelector:@selector(callBackChatName:)]) {
            [_delegate callBackChatName:self.nameTextView.text];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"群聊名称不能为空" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        [alertView release];
    }
}
//清除
- (void)clearText {
    self.nameTextView.text = nil;
    _countLable.text = [NSString stringWithFormat:@"%d/20",[self.nameTextView.text length]];
    _clearImage.hidden = YES;
}

//修改名称回调
- (void)modifyTempChatNameSuccess:(NSDictionary *)dic {
    [self.nameTextView resignFirstResponder];
    if ([[dic objectForKey:@"errcode"] intValue] == 0) {
        [CommonProgressHUD showMBProgressHudHint:self SuperView:self.view Msg:@"修改成功" ShowTime:1];
        [self performSelector:@selector(delayAction) withObject:self afterDelay:1.0];
    } else {
     [CommonProgressHUD showMBProgressHudHint:self SuperView:self.view Msg:@"请输入20个以内汉字"ShowTime:1];
    }
}

- (void)delayAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    if ([TempChatManager shareManager].delegate != nil &&[[TempChatManager shareManager].delegate isEqual:self]) {
        [TempChatManager shareManager].delegate = nil;
    }
    self.nameTextView = nil;
    self.title = nil;
    self.tempBtn = nil;
    [_countLable release]; _countLable = nil;
    [_clearImage release]; _clearImage = nil;
    [super dealloc];
}



@end
