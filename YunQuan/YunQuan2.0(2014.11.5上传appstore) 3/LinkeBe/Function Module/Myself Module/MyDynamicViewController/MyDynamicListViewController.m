
//
//  MyDynamicListViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-30.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "MyDynamicListViewController.h"
#import "Global.h"
#import "UIViewController+NavigationBar.h"

#import "DynamicCommon.h"
#import "CHTumblrMenuView.h"
#import "DynamicListCell.h"
#import "DynamicDetailViewController.h"
#import "DynamicEditViewController.h"
#import "SelfBusinessCardViewController.h"
#import "OthersBusinessCardViewController.h"

#import "MJRefresh.h"
#import "MobClick.h"

@interface MyDynamicListViewController ()<DynamicListCellDelegate,DynamicListManagerDelegate,DynamicEditDelegate,DynamicDetailViewDelegate>{
    NSIndexPath* selectPath;
    UIButton* selectButton;
    
    BOOL isRefresh;
}

//空视图
@property(nonatomic,retain) UILabel* noneView;

@end

#define POPVIEWLAB  1000
#define POPVIEWBUTTON   2000
#define POPTABLETAG     3000

@implementation MyDynamicListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isRefresh = YES;
        cardsArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"MyDynamicListViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"MyDynamicListViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBACOLOR(249,249,249,1);
    self.title = @"我的动态";
    
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
    
    [self initTable];
    
    [self sendDynamicListRequest];
}

//初始化列表
-(void) initTable{
    tableview = [[UITableView alloc] init];
    tableview.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64);
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tableview];
    
    //集成刷新控件
//    [tableview addHeaderWithTarget:self action:@selector(headerRefresh)];
//
//    [tableview addFooterWithTarget:self action:@selector(footerRefresh)];
}

-(void) showPublishList{
    CHTumblrMenuView* menuView = [[CHTumblrMenuView alloc] init];
    [menuView addMenuItemWithTitle:@"聚聚" andIcon:IMGREADFILE(DynamicPic_list_together) andSelectedBlock:^{
        DynamicEditViewController* editVC = [[DynamicEditViewController alloc] init];
        editVC.type = DynamicTypeTogether;
        editVC.delegate = self;
        editVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:editVC animated:YES];
        [editVC release];
    }];
    [menuView addMenuItemWithTitle:@"图文" andIcon:IMGREADFILE(DynamicPic_list_camera) andSelectedBlock:^{
        DynamicEditViewController* editVC = [[DynamicEditViewController alloc] init];
        editVC.type = DynamicTypePic;
        editVC.delegate = self;
        editVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:editVC animated:YES];
        [editVC release];
    }];
    [menuView addMenuItemWithTitle:@"我有" andIcon:IMGREADFILE(DynamicPic_list_have) andSelectedBlock:^{
        DynamicEditViewController* editVC = [[DynamicEditViewController alloc] init];
        editVC.type = DynamicTypeHave;
        editVC.delegate = self;
        editVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:editVC animated:YES];
        [editVC release];
    }];
    [menuView addMenuItemWithTitle:@"我要" andIcon:IMGREADFILE(DynamicPic_list_want) andSelectedBlock:^{
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

#pragma mark - 返回
-(void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - table
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (cardsArr.count) {
        return cardsArr.count;
    }
    return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (cardsArr.count) {
        return [DynamicListCell getDynamicListCellHeightWith:[cardsArr objectAtIndex:indexPath.row]];
    }
    return ScreenHeight - 64;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
            UILabel* noneLab = [[UILabel alloc] init];
            noneLab.frame = CGRectMake(0, 12, self.view.bounds.size.width, self.view.bounds.size.height);
            noneLab.textAlignment = NSTextAlignmentCenter;
            noneLab.numberOfLines = 2;
            noneLab.textColor = [UIColor darkGrayColor];
            noneLab.backgroundColor = [UIColor whiteColor];
            noneLab.font = KQLboldSystemFont(15);
            
            UIButton *publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [publishBtn setFrame:CGRectMake(20.f, 60.f, 280.f, 140.f)];
            [publishBtn addTarget:self action:@selector(showPublishList) forControlEvents:UIControlEventTouchUpInside];
            
            [publishBtn setBackgroundImage:IMGREADFILE(@"img_member_default3.png") forState:UIControlStateNormal];
            
            [cell.contentView addSubview:noneLab];
            [cell.contentView addSubview:publishBtn];
            
            noneLab.text = @"写点什么吧...";
            
            [noneLab release];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    return nil;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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

#pragma mark - dynamiclistCell
-(void) commentClickCallBackWith:(NSIndexPath*)iPath{
    NSDictionary* dic = [cardsArr objectAtIndex:iPath.row];
    
    if ([[dic objectForKey:@"delete"] intValue] == 1) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"这条动态已被删除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
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
    }else if (btype == 2) {
        //zan
        [newDic setObject:[NSNumber numberWithBool:YES] forKey:@"zan"];
    }
    [cardsArr replaceObjectAtIndex:iPath.row withObject:newDic];
}

-(void) detailClickCallBackWith:(NSIndexPath*)iPath{
    NSDictionary* dic = [cardsArr objectAtIndex:iPath.row];
    
    if ([[dic objectForKey:@"delete"] intValue] == 1) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"这条动态已被删除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
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

#pragma mark - 删除动态回调
-(void) deleteDynamicCallBack:(int)publishId{
    [cardsArr removeObjectAtIndex:selectPath.row];
    if (cardsArr.count) {
        [tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:selectPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        [tableview reloadData];
    }
    
}

#pragma mark - 发布完成回调
-(void) publishSuccessCallBackWith:(NSDictionary *)dic{
//    [tableview headerBeginRefreshing];
    [self sendDynamicListRequest];
}

#pragma mark - hehezan
-(void) heheZanCallBack{
    [self sendDynamicListRequest];
}

#pragma mark - refreshHandler
-(void) headerRefresh{
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
    NSMutableDictionary* param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [UserModel shareUser].orgUserId,@"orgUserId",
                                  [UserModel shareUser].user_id,@"userId",
                                  nil];
    if (!isRefresh) {
        [param setObject:[NSNumber numberWithInt:[pageNumber intValue] + 1] forKey:@"pageNumber"];
    }
    
    DynamicListManager* dlManager = [[DynamicListManager alloc] init];
    dlManager.delegate = self;
    [dlManager accessMyDynamic:param];
}

-(void) getDynamicListHttpCallBack:(NSArray *)arr interface:(LinkedBe_WInterface)interface{
    
    if (isRefresh) {
        [tableview headerEndRefreshing];
    }else{
        [tableview footerEndRefreshing];
    }
    
    //过滤请求结果
    if (arr.count) {
        
        switch (interface) {
            case LinkedBe_Comment_dynamic:
            {
                
            }
                break;
            case LinkedBe_My_Dynamic:
            {
                NSDictionary* dic = [arr firstObject];
//                ts = [dic objectForKey:@"ts"];
                pageNumber = [dic objectForKey:@"pageNumber"];
                
                NSArray* publishArr = [[dic objectForKey:@"myPublishPages"] objectForKey:@"result"];
                
                [cardsArr removeAllObjects];
//                [cardsArr addObjectsFromArray:publishArr];
                
                //移除掉delete为1的数据
                for (NSDictionary* tmpDic in publishArr) {
                    if ([[tmpDic objectForKey:@"delete"] intValue] == 0) {
                        [cardsArr addObject:tmpDic];
                    }
                }
                
                [tableview reloadData];
            }
                break;
            default:
                break;
        }
        
    }else{
        
    }
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
    [cardsArr release];
    [tableview release];
    
    [super dealloc];
}

@end
