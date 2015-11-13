//
//  ContactSelectMembersViewController.m
//  LinkeBe
//
//  Created by Dream on 14-9-25.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SessionViewController.h"
#import "ContactSelectMembersViewController.h"
#import "SessionDataOperator.h"
#import "MobClick.h"

@interface ContactSelectMembersViewController ()

@end

@implementation ContactSelectMembersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"ContactSelectMembersViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"ContactSelectMembersViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}
#pragma mark - ContactViewDelegate

- (void)ClickSureButton {
    //添加成员
    switch (self.listData.latestMessage.sessionType) {
        case SessionTypePerson:
        {
            [[TempChatManager shareManager]createTempChatWithContactArr:self.selectedArray];
            [TempChatManager shareManager].delegate = self;
        }
            break;
        case SessionTypeTempCircle:
        {
            if ((self.tempChatMemberArray.count + self.selectedArray.count) > 100) {
                UIAlertView * maxMemberLimite = [[UIAlertView alloc]initWithTitle:@"人数已满" message:@"圈子人员数已达上限100人" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [maxMemberLimite show];
                RELEASE_SAFE(maxMemberLimite);
            } else {
                if (self.selectedArray.count > 0) {
                    [MobClick event:@"chat_detail_add_member"];
                    self.hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"正在添加中..."];
                    [[TempChatManager shareManager]addMembersToTempChat:self.listData.ObjectID andMemberArr:self.selectedArray];
                    [TempChatManager shareManager].delegate = self;
                }
            }
        }
        default:
            break;
    }
}

#pragma mark - TempChatManagerDelegate
- (void)addMemberSuccessWithCircleID:(long long)tempCircleID
{
    [self.hudView hide:YES];
    [Common checkProgressHUDShowInAppKeyWindow:@"添加成功" andImage:nil];
    NSArray * viewControllers = self.navigationController.viewControllers;
    UIViewController * popToViewController = nil;
    for (UIViewController * currentController in viewControllers) {
        if ([currentController isKindOfClass:[SessionViewController class]]) {
            popToViewController = currentController;
        }
    }
    
    if (popToViewController != nil) {
        [self.navigationController popToViewController:popToViewController animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -TempCirlceManagerDelegate

- (void)createTempChatSuccessWithCircleID:(long long)tempCircleID
{
    [self.hudView hide:YES];
    [Common checkProgressHUDShowInAppKeyWindow:@"创建成功" andImage:nil];
    if (tempCircleID > 0) {
        [SessionDataOperator otherSystemTurnToSessionWithSender:self andObjectID:tempCircleID andSessionType:SessionTypeTempCircle isPopToRootViewController:YES isShowRightButton:YES];
    }
}

#pragma mark -Dealloc

- (void)dealloc
{
    if ([[TempChatManager shareManager].delegate isEqual:self]) {
        [TempChatManager shareManager].delegate = nil;
    }
    self.hudView = nil;
    [super dealloc];
}

@end
