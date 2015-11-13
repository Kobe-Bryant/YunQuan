//
//  ContactSelectOrgViewController.m
//  LinkeBe
//
//  Created by Dream on 14-9-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "ContactSelectOrgViewController.h"
#import "CicleListHeaderView.h"
#import "CicleViewController.h"
#import "ContactModel.h"
#import "SessionDataOperator.h"
#import "UserModel.h"
#import "Cicle_org_model.h"
#import "DetailSelectOrgViewController.h"
#import "MobClick.h"

@interface ContactSelectOrgViewController () <DetailSelectOrgViewControllerDelegate>

@end

@implementation ContactSelectOrgViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"发起新聊天";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"ContactSelectOrgViewPage"];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"ContactSelectOrgViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - UITableView Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (tableView == self.searchControl.searchResultsTableView) {
        return nil;
    } else {
        if ([Cicle_org_model isOnlyFirstRankOrganization]) {
            return nil;
        }
        
        CicleListHeaderView *headView = [[CicleListHeaderView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 60)];
        headView.backgroundColor = [UIColor whiteColor];
        headView.nameLable.text = @"选择组织";
        
        //直线
        UIImage *line = [UIImage imageNamed:@"img_group_underline.png"];
        UIImageView *lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 60, ScreenWidth, 0.5)];
        lineImage.image = line;
        [headView addSubview:lineImage];
        [lineImage release];
        
        //箭头
        UIImage *arrowImg = [UIImage imageNamed:@"ico_group_arrow1.png"];
        UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(285,(60 - arrowImg.size.height)/2 , arrowImg.size.width, arrowImg.size.height)];
        arrowImage.image = arrowImg;
        [headView addSubview:arrowImage];
        [arrowImage release];
        
        UITapGestureRecognizer *selectOrgTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectOrgTap)];
        [headView addGestureRecognizer:selectOrgTap];
        [selectOrgTap release];
        
        return [headView autorelease];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchControl.searchResultsTableView) {
        return 0.0;
    } else {
        if ([Cicle_org_model isOnlyFirstRankOrganization]) {
            return 0;
        } else {
            return 60;
        }
    }
}

- (void)selectOrgTap {
//    SelectOrgViewController *selectOrgViewControl = [[SelectOrgViewController alloc]init];
//    selectOrgViewControl.delegate = self;
//    [self.navigationController pushViewController:selectOrgViewControl animated:YES];
//    
//    RELEASE_SAFE(selectOrgViewControl);
    [MobClick event:@"chat_select_orgs"];
    
    DetailSelectOrgViewController *selectOrgViewControl = [[DetailSelectOrgViewController alloc]init];
    selectOrgViewControl.delegate = self;
    [self.navigationController pushViewController:selectOrgViewControl animated:YES];
    RELEASE_SAFE(selectOrgViewControl);
    
}

- (void)ClickSureButton {
    [self BeginNewChatViewController:self.selectedArray];
}

- (void)BeginNewChatViewController:(NSMutableArray *)array {
    if (array.count == 1) {
        ContactModel * contact = [array firstObject];
        [SessionDataOperator otherSystemTurnToSessionWithSender:self andObjectID:contact.userId andSessionType:SessionTypePerson isPopToRootViewController:YES isShowRightButton:YES];
    } else if (array.count > 1){
        self.hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"准备群聊中..."];
        [[TempChatManager shareManager]createTempChatWithContactArr:array];
        [TempChatManager shareManager].delegate = self;
    }
}

- (void)delayAction {
    
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - SelectOrgViewControllerDelegate

- (void)CallBackSureSelect:(NSMutableArray *)array {

    NSMutableArray *membersArr = [NSMutableArray array];
    if (array.count > 0) {
        for (NSDictionary *dic in array) {
            ContactModel *model = [[ContactModel alloc]init];
            model.iconStr = [dic objectForKey:@"portrait"];
            model.nameStr = [dic objectForKey:@"realname"];
            model.positionStr = [dic objectForKey:@"companyRole"];
            model.companyStr = [dic objectForKey:@"companyName"];
            model.userId = [[dic objectForKey:@"userId"] longLongValue];
            model.sexString = [dic objectForKey:@"sex"];
            //自己的话就不用添加进来了
            if (model.userId != [[UserModel shareUser].user_id intValue]) {
                 [membersArr addObject:model];
            }
            [model release];
        }
    }
   [self BeginNewChatViewController:membersArr];
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

- (void)backTo{
   [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -Dealloc

- (void)dealloc
{
    if ([TempChatManager shareManager].delegate != nil &&[[TempChatManager shareManager].delegate isEqual:self]) {
        [TempChatManager shareManager].delegate = nil;
    }
    self.hudView = nil;
    [super dealloc];
}

@end
