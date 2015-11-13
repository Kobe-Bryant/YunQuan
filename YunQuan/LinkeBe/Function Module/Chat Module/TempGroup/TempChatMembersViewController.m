//
//  TempChatMembersViewController.m
//  LinkeBe
//
//  Created by Dream on 14-10-17.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "TempChatMembersViewController.h"
#import "Global.h"
#import "UIViewController+NavigationBar.h"
#import "Circle_member_model.h"
#import "CicleListCell.h"
#import "UIImageView+WebCache.h"
#import "UserModel.h"
#import "SelfBusinessCardViewController.h"
#import "OthersBusinessCardViewController.h"
#import "SessionDataOperator.h"
#import "Common.h"
#import "PinYinSort.h"
#import "MobClick.h"

#define inviteTag  5900
#define sendTag    900

@interface TempChatMembersViewController () <UITableViewDataSource,UITableViewDelegate,MajorCircleManagerDelegate>{
    int clickButtonTag;

}

@property (nonatomic, retain) UITableView *contactMemberTableView;

@property (nonatomic, retain) NSMutableArray *membersArray;

@property (nonatomic ,assign) long long objectID;

@end

@implementation TempChatMembersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
        self.membersArray = [[[NSMutableArray alloc]init] autorelease];
    }
    return self;
}

- (void)dealloc
{
    self.membersArray = nil;
    self.membersDic = nil;
    self.contactMemberTableView.delegate = nil;
    self.contactMemberTableView = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"TempChatMembersViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"TempChatMembersViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
    
    if (self.typePush == yellowViewType){
        self.title = @"新加入成员";
    } else {
        self.title = @"成员列表";
    }
    
    [self loadBackButton];
    
    [self loadData];
    
    [self loadTableView];
    
}

- (void)loadData {
    NSArray *arr = [self.membersDic objectForKey:@"members"];
    if (self.typePush == yellowViewType) {
        if ([arr count] > 0) {
            NSMutableArray *tempArray = [NSMutableArray array];
            for (NSDictionary *Dic in arr) {
                long long userId = [[Dic objectForKey:@"userId"] longLongValue];
                NSDictionary *dic = [Circle_member_model getMemberDicWithUserID:userId];
                if (dic) {
                    [tempArray addObject:dic];
                }
            }
            NSMutableDictionary *dic = [PinYinSort accordingFirstLetterFromPinYin:tempArray];
            NSArray *keyArray = [[dic allKeys] sortedArrayUsingSelector:@selector(compare:)];
            if ([keyArray count]) {
                for (int i = 0; i < [dic allKeys].count; i ++) {
                    [self.membersArray addObjectsFromArray:[dic objectForKey:[keyArray objectAtIndex:i]]];
                }

            }
        }
    } else {
        if ([arr count] > 0) {
             NSMutableArray *tempArray = [NSMutableArray array];
            for (int i = 0; i < arr.count; i ++) {
                long long userId = [[arr objectAtIndex:i] longLongValue];
                NSDictionary *dic = [Circle_member_model getMemberDicWithUserID:userId];
                if (dic) {
                    [tempArray addObject:dic];
               }
            }
            NSMutableDictionary *dic = [PinYinSort accordingFirstLetterFromPinYin:tempArray];
            NSArray *keyArray = [[dic allKeys] sortedArrayUsingSelector:@selector(compare:)];
            if ([keyArray count]) {
                for (int i = 0; i < [dic allKeys].count; i ++) {
                    [self.membersArray addObjectsFromArray:[dic objectForKey:[keyArray objectAtIndex:i]]];
                }
              }
            }
        }
}
- (void)loadTableView {
    UITableView *tempTable = [[UITableView alloc]initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];

    self.contactMemberTableView = tempTable;
    self.contactMemberTableView.delegate = self;
    self.contactMemberTableView.dataSource = self;
    self.contactMemberTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.contactMemberTableView.backgroundColor = RGBACOLOR(249, 249, 249, 1);
    [self.view addSubview:self.contactMemberTableView];
    
    RELEASE_SAFE(tempTable);

}

#pragma mark -- UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.membersArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier2 = @"CicleListCell";
    
    CicleListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
    
    if (!cell) {
        cell = [[[CicleListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2] autorelease];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //直线
        UIImage *line = [UIImage imageNamed:@"img_group_underline.png"];
        UIImageView *lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 53.5, ScreenWidth, 0.5)];
        lineImage.image = line;
        [cell addSubview:lineImage];
        [lineImage release];
    }
    NSDictionary* dic = nil;
    if ([self.membersArray count]) {
        dic = [self.membersArray objectAtIndex:indexPath.row];
    }
    cell.nameLable.text = [dic objectForKey:@"realname"];  //成员名称
    NSURL* urlStr = [NSURL URLWithString:[dic objectForKey:@"portrait"]];
    cell.userID = [[dic objectForKey:@"id"]longLongValue];
    
    if ([[dic objectForKey:@"sex"] intValue] == 0) {
        [cell.listNameImage setImageWithURL:urlStr placeholderImage:[UIImage imageNamed:@"ico_default_portrait_male.png"]]; //成员头像
    }else{
        [cell.listNameImage setImageWithURL:urlStr placeholderImage:[UIImage imageNamed:@"ico_default_portrait_female.png"]]; //成员头像
    }
    //根据名字排版职位的UI排布
    CGSize listNameWidth = [cell.nameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:16.0] constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
    cell.positionLable.frame = CGRectMake(MIN(60 + listNameWidth.width + 10, 180), 2.0, 250.f, 30.f); //职位
    
    cell.positionLable.text = [dic objectForKey:@"companyRole"];  //职位
    
    cell.companyLable.text = [dic objectForKey:@"companyName"]; //公司名称
    
    //点击变已邀请
    cell.inviteLable.hidden = YES;
    cell.inviteLable.tag = inviteTag + indexPath.row;
    
    /* 0未邀请 1已邀请 2已激活(正常使用状态)
     *  3禁用 4删除 ，大于2从本地数据库删除
     */
    //这里单独拿出来原因是。。。
    NSDictionary *stateDic = nil;
    if ([self.membersArray count]) {
        stateDic = [self.membersArray objectAtIndex:indexPath.row];
    }
    cell.sendBtn.hidden = YES;
    if ([[stateDic objectForKey:@"state"] intValue] == 0) {
        cell.sendBtn.hidden = NO;
        [cell.sendBtn setTitle:@"邀请" forState:UIControlStateNormal];
        
    } else if([[stateDic objectForKey:@"state"] intValue] == 1) {
        cell.inviteLable.hidden = NO;
        
    } else if([[stateDic objectForKey:@"state"] intValue] == 2) {
        cell.sendBtn.hidden = NO;
        [cell.sendBtn setTitle:@"聊聊" forState:UIControlStateNormal];
        
    }
    if ([[dic objectForKey:@"userId"] intValue] == [[UserModel shareUser].user_id intValue]) {
        cell.sendBtn.hidden = YES;
        cell.inviteLable.hidden = YES;
    }
    cell.sendBtn.tag = sendTag + indexPath.row;
    [cell.sendBtn addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
   }

#pragma mark -- UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [self.membersArray objectAtIndex:indexPath.row];
    //跳转名片
    if ([[dic objectForKey:@"userId"] intValue] == [[UserModel shareUser].user_id intValue]) {
        SelfBusinessCardViewController *selfBusinessVC = [[SelfBusinessCardViewController alloc]init];
        [self.navigationController pushViewController:selfBusinessVC animated:YES];
        [selfBusinessVC release];
    } else {
        OthersBusinessCardViewController *otherBusinessVC = [[OthersBusinessCardViewController alloc]init];
        otherBusinessVC.orgUserId = [dic objectForKey:@"orgUserId"];
        [self.navigationController pushViewController:otherBusinessVC animated:YES];
        [otherBusinessVC release];
    }
        
}

//返回按钮
- (void)loadBackButton{
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
}
//返回上一级按钮
- (void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

//一级成员邀请 聊聊点击按钮
- (void)send:(UIButton *)sender{
    UIButton *button = (UIButton *)sender;
    clickButtonTag = button.tag;
    
    NSDictionary *Dic = [self.membersArray objectAtIndex:sender.tag - sendTag];
    self.objectID = [[Dic objectForKey:@"userId"] longLongValue];

    if ([button.titleLabel.text isEqualToString:@"邀请"]) {
        MajorCircleManager *manager = [[MajorCircleManager alloc]init];
        manager.delegate = self;
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [UserModel shareUser].user_id,@"userId",
                                    [Dic objectForKey:@"userId"],@"inviteeId",
                                    [Dic objectForKey:@"orgId"],@"orgId",
                                    nil];
        [manager accessUserInvite:dic];
        
    } else {
        [SessionDataOperator otherSystemTurnToSessionWithSender:self andObjectID:self.objectID andSessionType:SessionTypePerson isPopToRootViewController:NO isShowRightButton:YES];
    }
}

#pragma mark --  各种手势按钮点击事件
- (void)getCircleViewHttpCallBack:(NSArray *)arr interface:(LinkedBe_WInterface)interface{
    if (interface == LinkedBe_USER_INVITE) {
        NSDictionary *dic = nil;
        if ([arr count] > 0) {
            dic = [arr objectAtIndex:0];
        }
        if ([dic objectForKey:@"errcode"]) {
            if ([[dic objectForKey:@"errcode"] intValue] ==0) {
                UIButton *button =(UIButton *) [self.view viewWithTag:clickButtonTag];
                button.hidden = YES;
                UILabel *lable = (UILabel *)[self.view viewWithTag:clickButtonTag + (inviteTag - sendTag)];
                lable.hidden = NO;
                [Common checkProgressHUDShowInAppKeyWindow:@"发送邀请成功" andImage: [UIImage imageNamed:@"ico_group_right.png"]];
                
                Circle_member_model *model = [[Circle_member_model alloc]init];
                model.where = [NSString stringWithFormat:@"userId = %lld",self.objectID];
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithLongLong:self.objectID],@"userId",
                                     [NSNumber numberWithInteger:1],@"state",
                                     nil];
                [model updateDB:dic];
                RELEASE_SAFE(model);
                
            }else if([[dic objectForKey:@"errcode"] intValue] ==4006 || [[dic objectForKey:@"errcode"] intValue] ==-1){
                [Common checkProgressHUDShowInAppKeyWindow:[dic objectForKey:@"errmsg"] andImage: [UIImage imageNamed:@"ico_group_wrong.png"]];
            }
            
        } else {
            [Common checkProgressHUDShowInAppKeyWindow:@"网络连接失败，请重试" andImage:[UIImage imageNamed:@"ico_group_wrong.png"]];
        }
        
    }
}


@end
