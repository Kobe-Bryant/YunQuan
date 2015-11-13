//
//  DynamicViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "DynamicViewController.h"

#import "CHTumblrMenuView.h"
#import "DynamicCommon.h"

#import "PublishPermissionViewController.h"

#import "DynamicListManager.h"
#import "DynamicListCell.h"
#import "PopViewCell.h"

#import "DynamicDetailViewController.h"
#import "TSPopoverController.h"

#import "MJRefresh.h"

#import "DynamicEditViewController.h"
#import "DynamicDetailViewController.h"
#import "PublishPermissionViewController.h"

#import "Dynamic_card_model.h"
#import "Dynamic_page_model.h"

#import "DynamicIMManager.h"

#import "OthersBusinessCardViewController.h"
#import "SelfBusinessCardViewController.h"

#import "MobClick.h"

@interface DynamicViewController ()<DynamicListCellDelegate,DynamicListManagerDelegate,UIAlertViewDelegate,DynamicEditDelegate,DynamicDetailViewDelegate>{
    NSArray* popArr;//弹框选项
    
    BOOL isRefresh;
    
    NSIndexPath* selectPath;
    UIButton* selectButton;
}

//发布按钮
@property(nonatomic,retain) UIButton* publishButton;
//空视图
@property(nonatomic,retain) UILabel* noneView;
//titlePop
@property(nonatomic,retain) UIView* popView;

@property(nonatomic,retain) TSPopoverController *popVC;

@end

#define POPVIEWLAB  1000
#define POPVIEWBUTTON   2000
#define POPTABLETAG     3000

@implementation DynamicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isRefresh = YES;
        cardsArr = [[NSMutableArray alloc] init];
        
        popArr = [[NSArray alloc] initWithObjects:
                  @{@"image":@"",@"title":@"全部动态"},
                  @{@"image":DynamicPic_filter_party,@"title":@"聚聚"},
                  @{@"image":DynamicPic_filter_pic,@"title":@"图文"},
                  @{@"image":DynamicPic_filter_have,@"title":@"我有"},
                  @{@"image":DynamicPic_filter_want,@"title":@"我要"},
                  nil];
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated{
    NSDictionary* permissionDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UserModel shareUser].org_id,@"orgId",
                                   [UserModel shareUser].orgUserId,@"orgUserId",
                                   nil];
    DynamicListManager* dyManager = [[DynamicListManager alloc] init];
    dyManager.delegate = self;
    [dyManager checkPublishPermissionWithParam:permissionDic];
    
    self.tabBarController.tabBar.hidden = NO;
    [MobClick beginLogPageView:@"DynamicViewPage"];

//    //有无权限，不同得图片
//    if ([UserModel shareUser].isHavePermission) {
//        [self.publishButton setImage:IMGREADFILE(DynamicPic_list_publish) forState:UIControlStateNormal];
//    }else{
//        [self.publishButton setImage:IMGREADFILE(DynamicPic_list_publish_gray) forState:UIControlStateNormal];
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"DynamicViewPage"];

}

-(void) viewDidAppear:(BOOL)animated{
    if (tableview) {
        if ([[DynamicIMManager shareManager] isNew] && [[DynamicIMManager shareManager] tabbarSelectIndexWhenHaveNew] != 2) {
            [tableview headerBeginRefreshing];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = YES;
    }
    
    self.view.backgroundColor = BACKGROUNDCOLOR;
    
    [self publishBtn];
    
    [self getDynamicListData];
    
    [self initTable];
    
    [self midPopView];
    
    //如果数据库中没有缓存数据、或者有新数据提醒，发送http请求
    if (cardsArr.count == 0) {
        tableview.footerHidden = YES;
        [tableview headerBeginRefreshing];
    }
    
    //注册动态删除block
    [[DynamicIMManager shareManager] setDdeleteNotifyBlock:^{
        NSArray* arr = [Dynamic_card_model getAllDynamicCardsWithType:type];
        [cardsArr removeAllObjects];
        [cardsArr addObjectsFromArray:arr];
        [tableview reloadData];
    }];
    
    // Do any additional setup after loading the view.
}

//获取数据库缓存数据
-(void) getDynamicListData{
    NSArray* arr = [Dynamic_card_model getAllDynamicCards];
    [cardsArr addObjectsFromArray:arr];
}

//中间视图
-(void) midPopView{
    UIView* popV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    popV.backgroundColor = [UIColor clearColor];
    
    UIButton* popLab = [UIButton buttonWithType:UIButtonTypeCustom];
    popLab.frame = CGRectMake(10, 0, 180, 30);
    popLab.backgroundColor = [UIColor clearColor];
    [popLab setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [popLab setTitle:@"全部动态" forState:UIControlStateNormal];
    popLab.tag = POPVIEWLAB;
    [popLab addTarget:self action:@selector(showPopover:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    [popV addSubview:popLab];
    
    UIButton* pBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pBtn setImage:IMGREADFILE(DynamicPic_filter_down) forState:UIControlStateNormal];
    [pBtn setImage:IMGREADFILE(DynamicPic_filter_up) forState:UIControlStateSelected];
    pBtn.frame = CGRectMake(140, 10, 10, 10);
    pBtn.tag = POPVIEWBUTTON;
    [pBtn addTarget:self action:@selector(showPopover:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    [popV addSubview:pBtn];
    
    self.popView = popV;
    self.navigationItem.titleView = popV;
    
    [popV release];
}

//显示弹框
-(void)showPopover:(id)sender forEvent:(UIEvent*)event{
    UIButton* btn = (UIButton*)[self.popView viewWithTag:POPVIEWBUTTON];
    btn.selected = YES;
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.view.frame = CGRectMake(0,0, 100, popArr.count*40 - 5);
    tableViewController.tableView.delegate = self;
    tableViewController.tableView.dataSource = self;
    tableViewController.tableView.scrollEnabled = NO;
    tableViewController.tableView.tag = POPTABLETAG;
    tableViewController.tableView.backgroundColor = BALCKCOLOR;
    
    tableViewController.tableView.separatorColor = DynamicCardTextColor;
    if (IOS7_OR_LATER) {
        [tableViewController.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    TSPopoverController *popoverController = [[TSPopoverController alloc] initWithContentViewController:tableViewController];
    [tableViewController release];
    
    popoverController.cornerRadius = 2;
    popoverController.popoverBaseColor = BALCKCOLOR;
    popoverController.popoverGradient= NO;
//    [popoverController showPopoverWithTouch:event];
    [popoverController showPopoverWithPoint:CGPointMake(200, 46)];
    
    popoverController.finishDismiss = ^{
        UIButton* btn = (UIButton*)[self.popView viewWithTag:POPVIEWBUTTON];
        btn.selected = NO;
    };
    
    self.popVC = popoverController;
    [popoverController release];
}

//初始化列表
-(void) initTable{
    tableview = [[UITableView alloc] init];
    tableview.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64 - 49);
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tableview];
    
    //集成刷新控件
    [tableview addHeaderWithTarget:self action:@selector(headerRefresh)];
    
    [tableview addFooterWithTarget:self action:@selector(footerRefresh)];
}

//发布动态入口
-(void) publishBtn{
    UIButton* pBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    //有无权限，不同得图片
    if ([UserModel shareUser].isHavePermission) {
        [pBtn setImage:IMGREADFILE(DynamicPic_list_publish) forState:UIControlStateNormal];
    }else{
        [pBtn setImage:IMGREADFILE(DynamicPic_list_publish_gray) forState:UIControlStateNormal];
    }
    
    pBtn.frame = CGRectMake(20, 7, 30, 30);
    [pBtn addTarget:self action:@selector(publishClick) forControlEvents:UIControlEventTouchUpInside];
    self.publishButton = pBtn;
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:pBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem release];
    
    //有无权限，不同得图片
    if ([UserModel shareUser].isHavePermission) {
        [self.publishButton setImage:IMGREADFILE(DynamicPic_list_publish) forState:UIControlStateNormal];
    }else{
        [self.publishButton setImage:IMGREADFILE(DynamicPic_list_publish_gray) forState:UIControlStateNormal];
    }
}

#pragma mark - publish
-(void) publishClick{
    [MobClick event:@"feed_add_btn_click"];
    
    if ([UserModel shareUser].isHavePermission) {
        [self showPublishList];
    }else{
        [self tureToPermissionView];
    }
}

-(void) showPublishList{
    CHTumblrMenuView* menuView = [[CHTumblrMenuView alloc] init];
    [menuView addMenuItemWithTitle:@"聚聚" andIcon:IMGREADFILE(DynamicPic_list_together) andSelectedBlock:^{
        [MobClick event:@"feed_publish_type_party"];
        
        DynamicEditViewController* editVC = [[DynamicEditViewController alloc] init];
        editVC.type = DynamicTypeTogether;
        editVC.delegate = self;
        editVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:editVC animated:YES];
        [editVC release];
    }];
    [menuView addMenuItemWithTitle:@"图文" andIcon:IMGREADFILE(DynamicPic_list_camera) andSelectedBlock:^{
        [MobClick event:@"feed_publish_type_image_text"];
        
        DynamicEditViewController* editVC = [[DynamicEditViewController alloc] init];
        editVC.type = DynamicTypePic;
        editVC.delegate = self;
        editVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:editVC animated:YES];
        [editVC release];
    }];
    [menuView addMenuItemWithTitle:@"我有" andIcon:IMGREADFILE(DynamicPic_list_have) andSelectedBlock:^{
        [MobClick event:@"feed_publish_type_have"];
        
        DynamicEditViewController* editVC = [[DynamicEditViewController alloc] init];
        editVC.type = DynamicTypeHave;
        editVC.delegate = self;
        editVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:editVC animated:YES];
        [editVC release];
    }];
    [menuView addMenuItemWithTitle:@"我要" andIcon:IMGREADFILE(DynamicPic_list_want) andSelectedBlock:^{
        [MobClick event:@"feed_publish_type_want"];
        
        DynamicEditViewController* editVC = [[DynamicEditViewController alloc] init];
        editVC.type = DynamicTypeWant;
        editVC.delegate = self;
        editVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:editVC animated:YES];
        [editVC release];
    }];
    [menuView show];
    [menuView release];
}

-(void) tureToPermissionView{
    PublishPermissionViewController* ppVC = [[PublishPermissionViewController alloc] init];
    ppVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ppVC animated:YES];
    [ppVC release];
}

#pragma mark - tableview
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == POPTABLETAG) {
        return popArr.count;
    }
    if (cardsArr.count) {
        return cardsArr.count;
    }
    return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == POPTABLETAG) {
        return 40.0;
    }
    
    if (cardsArr.count) {
        return [DynamicListCell getDynamicListCellHeightWith:[cardsArr objectAtIndex:indexPath.row]];
    }
    return ScreenHeight - 64;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == POPTABLETAG) {
        static NSString* popCell = @"popcell";
        PopViewCell* cell = [tableview dequeueReusableCellWithIdentifier:popCell];
        if (cell == nil) {
            cell = [[[PopViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:popCell] autorelease];
            
        }
        
        NSDictionary* dic = [popArr objectAtIndex:indexPath.row];
        [cell initWithData:dic];
        
        if (indexPath.row == 0) {
            cell.titleLab.frame = CGRectMake(20, 0, 60, 40);
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else{
        if (cardsArr.count) {
            static NSString* listCell = @"dynamicListCell";
            DynamicListCell* cell = [tableView dequeueReusableCellWithIdentifier:listCell];
            if (cell == nil) {
                cell = [[[DynamicListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:listCell] autorelease];
            }
            
            cell.delegate = self;
            cell.indexPath = indexPath;
            
            [cell writeDataInCell:[cardsArr objectAtIndex:indexPath.row]];
            
            return cell;
            
        }else{
            static NSString* noneCell = @"noneCell";
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:noneCell];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noneCell] autorelease];
                
                //空页面
                UILabel* noneLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64)];
                noneLab.text = @"加载中...";
                noneLab.textColor = DynamicCardTextColor;
                noneLab.textAlignment = NSTextAlignmentCenter;
                noneLab.font = [UIFont systemFontOfSize:16];
                noneLab.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:noneLab];
                
                self.noneView = noneLab;
                
                switch (type) {
                    case DynamicTypePic:
                        self.noneView.text = @"暂时还没有新动态";
                        break;
                    case DynamicTypeHave:
                        self.noneView.text = @"暂时还没有我有";
                        break;
                    case DynamicTypeWant:
                        self.noneView.text = @"暂时还没有我要";
                        break;
                    case DynamicTypeTogether:
                        self.noneView.text = @"暂时还没有聚聚";
                        break;
                    default:
                        self.noneView.text = @"暂时还没有新动态";
                        break;
                }
                
                [noneLab release];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
    }
    
    return nil;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == POPTABLETAG) {
        [MobClick event:@"feed_query_by_type"];
        
        //隐藏选项框
        [self.popVC dismissPopoverAnimatd:YES];
        
        DynamicType cardType;
        switch (indexPath.row) {
            case 0:
                cardType = 0;
                break;
            case 1:
                cardType = DynamicTypeTogether;
                break;
            case 2:
                cardType = DynamicTypePic;
                break;
            case 3:
                cardType = DynamicTypeHave;
                break;
            case 4:
                cardType = DynamicTypeWant;
                break;
            default:
                break;
        }
        
        UIButton* btn = (UIButton*)[self.popView viewWithTag:POPVIEWLAB];
        [btn setTitle:[[popArr objectAtIndex:indexPath.row] objectForKey:@"title"] forState:UIControlStateNormal];
        
        [self itemClickCallBackWith:cardType];
    }else{
        [MobClick event:@"feed_list_item_click"];
        
        NSDictionary* dic = [cardsArr objectAtIndex:indexPath.row];
        
        if ([[dic objectForKey:@"delete"] intValue] == 1) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"这条动态已被删除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            return;
        }
        
        selectPath = [indexPath copy];
        
        DynamicDetailViewController* ddVC = [[DynamicDetailViewController alloc] init];
        ddVC.publishId = [[dic objectForKey:@"id"] intValue];
        ddVC.isShowKeyBoard = NO;
        ddVC.detailDic = dic;
        ddVC.delegate = self;
        ddVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:ddVC animated:YES];
    }
}

#pragma mark - 删除动态回调
-(void) deleteDynamicCallBack:(int)publishId{
//    [cardsArr removeObjectAtIndex:selectPath.row];
    [Dynamic_card_model deleteDynamicCardWithPublishId:publishId];
    
//    if (cardsArr.count) {
//        [tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:selectPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }else{
//        [tableview reloadData];
//    }
    
    [self itemClickCallBackWith:type];
    
}

#pragma mark - 发布完成回调
-(void) publishSuccessCallBackWith:(NSDictionary *)dic{
    UIButton* btn = (UIButton*)[self.popView viewWithTag:POPVIEWLAB];
    [btn setTitle:[[popArr objectAtIndex:0] objectForKey:@"title"] forState:UIControlStateNormal];
    
    [tableview headerBeginRefreshing];
}

#pragma mark - dynamiclistCell
-(void) commentClickCallBackWith:(NSIndexPath*)iPath{
    [MobClick event:@"feed_list_add_comment"];
    
    NSDictionary* dic = [cardsArr objectAtIndex:iPath.row];
    
    if ([[dic objectForKey:@"delete"] intValue] == 1) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"这条动态已被删除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return;
    }
    
    selectPath = [iPath copy];
    
    DynamicDetailViewController* ddVC = [[DynamicDetailViewController alloc] init];
    ddVC.isShowKeyBoard = YES;
    ddVC.publishId = [[dic objectForKey:@"id"] intValue];
    ddVC.detailDic = dic;
    ddVC.delegate = self;
    ddVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ddVC animated:YES];
    [ddVC release];
}

-(void) optionClickCallBackWith:(NSIndexPath*)iPath type:(int) btype{
    NSDictionary* dic = [cardsArr objectAtIndex:iPath.row];
    NSMutableDictionary* newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    if (btype == 1) {
        //hehe
        [newDic setObject:[NSNumber numberWithBool:YES] forKey:@"hehe"];
        [newDic setObject:[NSNumber numberWithInt:[[dic objectForKey:@"heheSum"] intValue] + 1] forKey:@"heheSum"];
    }else if (btype == 2) {
        //zan
        [newDic setObject:[NSNumber numberWithBool:YES] forKey:@"zan"];
        [newDic setObject:[NSNumber numberWithInt:[[dic objectForKey:@"zanSum"] intValue] + 1] forKey:@"zanSum"];
    }
    [cardsArr replaceObjectAtIndex:iPath.row withObject:newDic];
    [Dynamic_card_model insertOrUpdateDynamicCardWithDic:newDic];
}

-(void) detailClickCallBackWith:(NSIndexPath*)iPath{
    [MobClick event:@"feed_list_detail"];
    
    NSDictionary* dic = [cardsArr objectAtIndex:iPath.row];
    
    if ([[dic objectForKey:@"delete"] intValue] == 1) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"这条动态已被删除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return;
    }
    
    selectPath = [iPath copy];
    
    DynamicDetailViewController* ddVC = [[DynamicDetailViewController alloc] init];
    ddVC.isShowKeyBoard = NO;
    ddVC.publishId = [[dic objectForKey:@"id"] intValue];
    ddVC.detailDic = dic;
    ddVC.delegate = self;
    ddVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ddVC animated:YES];
    [ddVC release];
}

-(void) headClickCallBackWith:(NSIndexPath*)iPath{
    [MobClick event:@"feed_user_portrait"];
    
    //名片页
    NSDictionary* dic = [cardsArr objectAtIndex:iPath.row];
    
    //点击跳转名片页
    if ([[dic objectForKey:@"userId"] intValue] == [[UserModel shareUser].user_id intValue]) {
        SelfBusinessCardViewController *selfBusinessVC = [[SelfBusinessCardViewController alloc]init];
        selfBusinessVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:selfBusinessVC animated:YES];
        [selfBusinessVC release];
    } else {
        OthersBusinessCardViewController *otherBusinessVC = [[OthersBusinessCardViewController alloc]init];
        otherBusinessVC.orgUserId = [dic objectForKey:@"orgUserId"];
        otherBusinessVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:otherBusinessVC animated:YES];
        [otherBusinessVC release];
    }
}

-(void) itemClickCallBackWith:(DynamicType)dyType{
    type = dyType;
    
    UIButton* btn = (UIButton*)[self.popView viewWithTag:POPVIEWLAB];
    [btn setTitle:[[popArr objectAtIndex:dyType] objectForKey:@"title"] forState:UIControlStateNormal];
    
    NSArray* arr = [Dynamic_card_model getAllDynamicCardsWithType:dyType];
    [cardsArr removeAllObjects];
    [cardsArr addObjectsFromArray:arr];
    [tableview reloadData];
    
}

//参与／我有我要点击
-(void) roundButtonClickCallBackWithType:(DynamicType) dyType indexPath:(NSIndexPath*) iPath sender:(UIButton *)sender{
    int tag = 0;
    NSString* msg = nil;
    
    //保存选中ipath
    selectPath = [iPath copy];
    selectButton = sender;
    
    //name
    NSDictionary* dic = [cardsArr objectAtIndex:iPath.row];
    
    if (dyType == DynamicTypeTogether) {
        //判断是不是过时
        long long endTime = [[dic objectForKey:@"endTime"] longLongValue];
        long long nowTime = [[NSDate date] timeIntervalSince1970];
        if (endTime/1000 < nowTime) {
            UIAlertView* outAlert = [[UIAlertView alloc] initWithTitle:nil message:@"该聚聚已过时" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [outAlert show];
            [outAlert release];
            
            return;
        }
    }
    
    NSString* name = [dic objectForKey:@"realname"];
    //IM接口
    switch (dyType) {
        case DynamicTypeTogether:
        {
            tag = 1;
            msg = [NSString stringWithFormat:@"回应%@，参加这个聚聚",name];
        }
            break;
        case DynamicTypeHave:
        {
            tag = 3;
            msg = [NSString stringWithFormat:@"回应%@发布的我有",name];
        }
            break;
        case DynamicTypeWant:
        {
            tag = 2;
            msg = [NSString stringWithFormat:@"回应%@发布的我要",name];
        }
            break;
        default:
            break;
    }
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = tag;
    [alert show];
    [alert release];
}

-(void) removeOptionBoxWith:(NSIndexPath *)iPath{
    NSArray* arr = [tableview visibleCells];
    for (DynamicListCell* cell in arr) {
        if (cell.indexPath != iPath) {
            UIView* v = [cell.cardView viewWithTag:10000];
            if (v) {
                [v removeFromSuperview];
            }
        }
    }
}

#pragma mark - alertview
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSDictionary* dic = [cardsArr objectAtIndex:selectPath.row];
    
    if (buttonIndex != alertView.cancelButtonIndex) {
        switch (alertView.tag) {
            case 1:
            {
                //IM聚聚
                long long circleId = [[dic objectForKey:@"groupId"] longLongValue];
                NSArray* userIdArr = [NSArray arrayWithObject:[UserModel shareUser].user_id];
                //加入临时会话的数据
                NSDictionary* addDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithLongLong:circleId],@"circleId",
                                        userIdArr,@"uid",
                                        nil];
                //向临时会话发送的消息数据
                int publishId = [[dic objectForKey:@"id"] intValue];
                
                //聚聚描述
                NSString* msgdesc = nil;
                long long startTime = [[dic objectForKey:@"startTime"] longLongValue];
                long long endTime = [[dic objectForKey:@"endTime"] longLongValue];
                
                NSString* startStr = [Common makeTime13To10:startTime withFormat:@"YYYY年MM月dd日 HH:mm"];
                NSString* endStr = [Common makeTime13To10:endTime withFormat:@"YYYY年MM月dd日 HH:mm"];
                
                NSString* location = [dic objectForKey:@"location"];
                if (location == nil) {
                    location = @"";
                }
                NSString* city = [dic objectForKey:@"city"];
                if (city == nil) {
                    city = @"";
                }
                
//                NSString* titleStr = [dic objectForKey:@"title"];
                NSString* titleStr = [dic objectForKey:@"content"];
                
                msgdesc = [NSString stringWithFormat:@"%@ -- %@ ,%@  %@ ,%@",startStr,endStr,city,location,titleStr];
                
                NSMutableDictionary* msgDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithLongLong:circleId],@"circleId",
                                               [NSNumber numberWithInt:publishId],@"msgId",
                                               TOGETHERMESSAGETEXT,@"txt",
                                               msgdesc,@"msgdesc",
                                               nil];
                
                [[DynamicIMManager shareManager] addToTempContact:addDic msgDic:msgDic block:^{
                    selectButton.enabled = NO;
                    //更新列表数据和缓存数据
                    NSMutableDictionary* newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [newDic setObject:[NSNumber numberWithBool:YES] forKey:@"joined"];
                    [cardsArr replaceObjectAtIndex:selectPath.row withObject:newDic];
                    
                    [Dynamic_card_model insertOrUpdateDynamicCardWithDic:newDic];
                    
                }];
            }
                break;
            case 2:
            {
                //IM我有
                
                long long circleId = [[dic objectForKey:@"groupId"] longLongValue];
                int publishId = [[dic objectForKey:@"id"] intValue];
//                NSString* msgdesc = [dic objectForKey:@"title"];
                NSString* msgdesc = [dic objectForKey:@"content"];
                NSNumber* receiveId = [dic objectForKey:@"userId"];
                NSDictionary* haveDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithLongLong:circleId],@"circleId",
                                         receiveId,@"receiverId",
                                         [NSNumber numberWithInt:publishId],@"msgId",
                                         HAVEMESSAGETEXT,@"txt",
                                         msgdesc,@"msgdesc",
                                         nil];
                [[DynamicIMManager shareManager] sendHaveMessage:haveDic  block:^{
                    selectButton.enabled = NO;
                    
                    //更新列表数据和缓存数据
                    NSMutableDictionary* newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [newDic setObject:[NSNumber numberWithBool:YES] forKey:@"joined"];
                    [cardsArr replaceObjectAtIndex:selectPath.row withObject:newDic];
                    
                    [Dynamic_card_model insertOrUpdateDynamicCardWithDic:newDic];
                }];
                
            }
                break;
            case 3:
            {
                //IM我要
                
                long long circleId = [[dic objectForKey:@"groupId"] longLongValue];
                int publishId = [[dic objectForKey:@"id"] intValue];
//                NSString* msgdesc = [dic objectForKey:@"title"];
                NSString* msgdesc = [dic objectForKey:@"content"];
                NSNumber* receiveId = [dic objectForKey:@"userId"];
                NSDictionary* haveDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithLongLong:circleId],@"circleId",
                                         receiveId,@"receiverId",
                                         [NSNumber numberWithInt:publishId],@"msgId",
                                         WANTMESSAGETEXT,@"txt",
                                         msgdesc,@"msgdesc",
                                         nil];
                [[DynamicIMManager shareManager] sendWantMessage:haveDic  block:^{
                    selectButton.enabled = NO;
                    
                    //更新列表数据和缓存数据
                    NSMutableDictionary* newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [newDic setObject:[NSNumber numberWithBool:YES] forKey:@"joined"];
                    [cardsArr replaceObjectAtIndex:selectPath.row withObject:newDic];
                    
                    [Dynamic_card_model insertOrUpdateDynamicCardWithDic:newDic];
                    
                }];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - refreshHandler
-(void) headerRefresh{
    [MobClick event:@"feed_list_down_refresh"];
    
    isRefresh = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //1.请求数据
        [self sendDynamicListRequest];
        
    });
}

-(void) footerRefresh{
    isRefresh = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //1.请求数据
        [self sendDynamicListRequest];
    });
}

#pragma mark - dynamiclistManager
-(void) sendDynamicListRequest{
    //参数
    
    //页码时间错
    NSDictionary* dic = [Dynamic_page_model getPageDataWithType:DynamicPageTypeList];
    int pageNumber = [[dic objectForKey:@"pageNumber"] intValue];
    
    NSMutableDictionary* param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [UserModel shareUser].orgUserId,@"orgUserId",
                                  [UserModel shareUser].user_id,@"userId",
                                  [UserModel shareUser].org_id,@"orgId",
                                  [NSNumber numberWithInt:1],@"pageNumber",    //n
                                  @"20",@"pageSize",      //n
                                  [dic objectForKey:@"ts"],@"ts",
                                  nil];
    if (!isRefresh) {
        [param setObject:[NSNumber numberWithInt:pageNumber + 1] forKey:@"pageNumber"];
        [param removeObjectForKey:@"ts"];
        
        //类型参数
        int paraType = 0;
        switch (type) {
            case 0:
                paraType = 0;
                break;
            case DynamicTypeHave:
                paraType = 3;
                break;
            case DynamicTypeWant:
                paraType = 4;
                break;
            case DynamicTypePic:
                paraType = 1;
                break;
            case DynamicTypeTogether:
                paraType = 8;
                break;
            default:
                break;
        }
        if (paraType != 0) {
            [param setObject:[NSNumber numberWithInt:paraType] forKey:@"type"];
        }
    }
    
    DynamicListManager* dlManager = [[DynamicListManager alloc] init];
    dlManager.delegate = self;
    [dlManager accessDynamicList:param];
}

-(void) getDynamicListHttpCallBack:(NSArray *)arr interface:(LinkedBe_WInterface)interface{
    if (interface != LinkedBe_PermissionList) {
        if (isRefresh) {
            [tableview headerEndRefreshing];
            
            //取消新动态提醒，并改变状态
            [[DynamicIMManager shareManager] setIsNew:NO];
            [[DynamicIMManager shareManager] cancelNewDynamicNotify];
            
            if (arr.count == 0) {
                [Common checkProgressHUDShowInAppKeyWindow:@"还没有新动态" andImage:nil];
            }
        }else{
            [tableview footerEndRefreshing];
            
            if (arr.count == 0) {
                [Common checkProgressHUDShowInAppKeyWindow:@"没有更多了" andImage:nil];
            }
        }
    }
    
    //过滤请求结果
    if (arr.count) {
        
        switch (interface) {
            case LinkedBe_Comment_dynamic:
            {
                
            }
                break;
            case Linkedbe_DynamicList:
            {
                //加载数据成功
                if (isRefresh) {
                    //刷新时，显示全部
                    type = 0;
                    UIButton* btn = (UIButton*)[self.popView viewWithTag:POPVIEWLAB];
                    [btn setTitle:[[popArr objectAtIndex:0] objectForKey:@"title"] forState:UIControlStateNormal];
                    
                    //刷新
                    [cardsArr removeAllObjects];
                    [cardsArr addObjectsFromArray:[Dynamic_card_model getAllDynamicCards]];
                    
                    [tableview reloadData];
                }else{
                    //加载更多
                    [cardsArr addObjectsFromArray:arr];
                    
                    [tableview reloadData];
                }
            }
                break;
            case LinkedBe_PermissionList:
            {
                //有无权限，不同得图片
                if ([UserModel shareUser].isHavePermission) {
                    [self.publishButton setImage:IMGREADFILE(DynamicPic_list_publish) forState:UIControlStateNormal];
                }else{
                    [self.publishButton setImage:IMGREADFILE(DynamicPic_list_publish_gray) forState:UIControlStateNormal];
                }
            }
                break;
            default:
                break;
        }
        
    }else{
        switch (interface) {
            case LinkedBe_Comment_dynamic:
            {
                
            }
                break;
            case Linkedbe_DynamicList:
            {
                //改变加载文本
//                self.noneView.text = @"暂时还没有新动态";
                
            }
                break;
            default:
                break;
        }
    }
    
    if (cardsArr.count) {
        tableview.footerHidden = NO;
    }else{
        tableview.footerHidden = YES;
    }
}

#pragma mark - 评论数字交互
-(void) heheZanCallBack{
    [self itemClickCallBackWith:type];
}

#pragma mark - scrollview
-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    if (cardsArr.count) {
        NSArray* arr = [tableview visibleCells];
        for (DynamicListCell* cell in arr) {
            UIView* v = [cell.cardView viewWithTag:10000];
            if (v) {
                [v removeFromSuperview];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc{
    [_publishButton release];
    [cardsArr release];
    [tableview release];
    
    [super dealloc];
}

@end
