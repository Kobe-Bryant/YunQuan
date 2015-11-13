//
//  RelateMeViewController.m
//  LinkeBe
//
//  Created by Dream on 14-9-17.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "RelateMeViewController.h"
#import "UIViewController+NavigationBar.h"
#import "Global.h"
#import "RelateCell.h"
#import "CommonProgressHUD.h"
#import "MyselfMessageManager.h"
#import "NSObject_extra.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "Common.h"
#import "MJRefresh.h"
#import "YLNullViewReminder.h"
#import "DynamicDetailViewController.h"
#import "DynamicListManager.h"
#import "MobClick.h"

@interface RelateMeViewController ()<UITableViewDataSource,UITableViewDelegate,MyselfMessageManagerDelegate>{
//    MBProgressHUD *hudView;
    UITableView *_relateTableView;
    
    //    空视图页面
    YLNullViewReminder *_nullViewReminder;
    BOOL isRefresh;
    int pageNumber;
    
}
@property(nonatomic,assign)long long timeTs;
@property(nonatomic,retain) NSMutableArray *relateMeArray;
@property(nonatomic,assign)int pageNumber;
@end

@implementation RelateMeViewController
@synthesize relateMeArray;
@synthesize timeTs;
@synthesize pageNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"与我相关";
        isRefresh = YES;
        self.relateMeArray = [[[NSMutableArray alloc] init] autorelease];
    }
    return self;
}

- (void)dealloc
{
    [_relateTableView release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"RelateMeViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"RelateMeViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = RGBACOLOR(249, 249, 249, 1);
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
    
    [self initWithTableView]; //初始化tableview
}


-(void)requestRelevantMe{
    NSMutableDictionary *selfDic ;
    if (isRefresh) {
        selfDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0",@"ts",@"20",@"pageSize", nil];
    }else{
        selfDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithInt:self.pageNumber+1],@"pageNumber",@"20",@"pageSize",nil];
    }
    MyselfMessageManager* dlManager = [[MyselfMessageManager alloc] init];
    dlManager.delegate = self;
    [dlManager accessRelevantMeData:selfDic];
}

- (void)initWithTableView {
    _relateTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
    _relateTableView.delegate = self;
    _relateTableView.dataSource = self;
    _relateTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [_relateTableView setBackgroundColor:RGBACOLOR(249, 249, 249, 1)];
    [self.view addSubview:_relateTableView];
    
    //集成刷新控件
    [_relateTableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    [_relateTableView headerBeginRefreshing];
    
   [_relateTableView addFooterWithTarget:self action:@selector(footerRefresh)];
}

-(void) footerRefresh{
    isRefresh = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //1.请求数据
        [self requestRelevantMe];
    });
    [_relateTableView footerEndRefreshing];
}

-(void) headerRefresh{
    isRefresh = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //1.请求数据
        [self requestRelevantMe];
    });
    [_relateTableView headerEndRefreshing];
}

//
-(void)signNoDataView{
    NSString *sign = @"余亦能高咏，斯人不可闻";
    _relateTableView.hidden = YES;
    
    _nullViewReminder = [[YLNullViewReminder alloc]initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight) reminderImage:[UIImage imageNamed:@"pic_me_default1.png"] reminderTitle:sign];
    [self.view addSubview:_nullViewReminder];
}

#pragma mark -- UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.relateMeArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"RelateCell";
    RelateCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[RelateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]autorelease];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    NSDictionary *relateDic = [self.relateMeArray objectAtIndex:indexPath.row];
    
    cell.nameLable.text = [relateDic objectForKey:@"realname"];
    
    if ([[relateDic objectForKey:@"sex"] intValue] == 0) {
        [cell.iconImage setImageWithURL:[NSURL URLWithString:[relateDic objectForKey:@"portrait"]] placeholderImage:[UIImage imageNamed:@"ico_default_portrait_male.png"]];
    }else{
        [cell.iconImage setImageWithURL:[NSURL URLWithString:[relateDic objectForKey:@"portrait"]] placeholderImage:[UIImage imageNamed:@"ico_default_portrait_female.png"]];
    }
    /*
     评论类型0普通评论1赞2呵呵3回复评论
    */
    cell.loveBtn.hidden = YES;
    cell.commentLable.text = nil;
    
    switch ([[relateDic objectForKey:@"type"] integerValue]) {
        case 0:
        {
            cell.commentLable.text = [relateDic objectForKey:@"content"];
            CGFloat commentSize = [TQRichTextView getRechTextViewHeightWithText:cell.commentLable.text viewWidth:180 font:[UIFont systemFontOfSize:13] lineSpacing:1.2];

            //根据字数确定commentLable的高度
            cell.commentLable.frame = CGRectMake(CGRectGetMaxX(cell.iconImage.frame) + 5, CGRectGetMinY(cell.nameLable.frame) + 20, 180, commentSize + 1);
            
            //根据字数确定time的高度
            cell.timeLable.text = [Common makeFriendTime:[[relateDic objectForKey:@"updatedTime"] intValue]];
            cell.timeLable.frame = CGRectMake(CGRectGetMaxX(cell.iconImage.frame) + 5, commentSize + 27, 180, 20);
        }
            break;
        case 1:
        {
            cell.loveBtn.hidden = NO;
            
            UIImage *loveImage = [UIImage imageNamed:@"ico_feed_comment_top.png"];
            [cell.loveBtn setImage:loveImage forState:UIControlStateNormal];
            [cell.loveBtn setTitle:@"  不错，赞一个!" forState:UIControlStateNormal];
            cell.loveBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 0);
            cell.loveBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
            
            //根据字数确定time的高度
            cell.timeLable.text = [Common makeFriendTime:[[relateDic objectForKey:@"updatedTime"] intValue]];
            cell.timeLable.frame = CGRectMake(CGRectGetMaxX(cell.iconImage.frame) + 5, CGRectGetMinY(cell.loveBtn.frame) + 20, 180, 20);
        }
            break;
        case 2:
        {
            cell.loveBtn.hidden = NO;
            
            UIImage *loveImage = [UIImage imageNamed:@"ico_feed_comment_hehe.png"];
            [cell.loveBtn setImage:loveImage forState:UIControlStateNormal];
            [cell.loveBtn setTitle:@"  呵呵!" forState:UIControlStateNormal];
            cell.loveBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 44);
            cell.loveBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 53);
            
            //根据字数确定time的高度
            cell.timeLable.text = [Common makeFriendTime:[[relateDic objectForKey:@"updatedTime"] intValue]];
            cell.timeLable.frame = CGRectMake(CGRectGetMaxX(cell.iconImage.frame) + 5, CGRectGetMinY(cell.loveBtn.frame) + 20, 180, 20);
        }
            break;
        case 3:
        {
            if(![relateDic objectForKey:@"toName"]||![relateDic objectForKey:@"fromName"]){
                 cell.commentLable.text = [relateDic objectForKey:@"content"];
            }else{
                 cell.commentLable.text = [NSString stringWithFormat:@"%@回复%@:%@",[relateDic objectForKey:@"fromName"],[relateDic objectForKey:@"toName"],[relateDic objectForKey:@"content"]];
            }
            
            CGFloat commentSize = [TQRichTextView getRechTextViewHeightWithText:cell.commentLable.text viewWidth:180 font:[UIFont systemFontOfSize:13] lineSpacing:1.2];
            
            //根据字数确定commentLable的高度
            cell.commentLable.frame = CGRectMake(CGRectGetMaxX(cell.iconImage.frame) + 5, CGRectGetMinY(cell.nameLable.frame) + 20, 180, commentSize + 1);
            
            //根据字数确定time的高度
            cell.timeLable.text = [Common makeFriendTime:[[relateDic objectForKey:@"updatedTime"] intValue]];
            cell.timeLable.frame = CGRectMake(CGRectGetMaxX(cell.iconImage.frame) + 5, commentSize + 27, 180, 20);
        }
            break;
        default:
            break;
    }
    
    cell.contentLable.hidden = YES;
    cell.contentImage.hidden = YES;
    if ([[relateDic objectForKey:@"picUrl"] length]!=0) {
        [cell.contentImage setImageWithURL:[NSURL URLWithString:[relateDic objectForKey:@"picUrl"]] placeholderImage:[UIImage imageNamed:@"img_landing_default220.png"]];
        cell.contentImage.hidden = NO;
    }else{
        [cell.contentLable setText:[relateDic objectForKey:@"publishContent"]];
        cell.contentLable.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *relateDic = [self.relateMeArray objectAtIndex:indexPath.row];
    
    DynamicDetailViewController* ddVC = [[DynamicDetailViewController alloc] init];
    ddVC.publishId = [[relateDic objectForKey:@"publishId"] intValue];
    
    [self.navigationController pushViewController:ddVC animated:YES];
    [ddVC release];
}

#pragma mark -- UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *relateDic = [self.relateMeArray objectAtIndex:indexPath.row];
    if (![relateDic objectForKey:@"content"]) {
        return 74.0;
    }else {
        NSDictionary *relateDic = [self.relateMeArray objectAtIndex:indexPath.row];
       CGFloat commentSize = [TQRichTextView getRechTextViewHeightWithText:[relateDic objectForKey:@"content"] viewWidth:180 font:[UIFont systemFontOfSize:13] lineSpacing:1.2];
        return commentSize + 55;
    }
}


-(void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getMyselfMessageManagerHttpCallBack:(NSArray*) arr requestCallBackDic:(NSDictionary *)dic interface:(LinkedBe_WInterface) interface{
    switch (interface) {
        case LinkedBe_Relevantme:
        {
            if (dic) {
                if (![dic objectForKey:@"errcode"]) {
                    if (isRefresh) {
//                        self.timeTs = [[dic objectForKey:@"ts"] longLongValue];
                        self.pageNumber = [[[dic objectForKey:@"list"] objectForKey:@"pageNumber"] integerValue];
                        
                        [self.relateMeArray removeAllObjects];
                        
                        NSArray *tempArray = [[dic objectForKey:@"list"] objectForKey:@"result"];
                        if (tempArray) {
                            NSMutableArray *headerArray = [[NSMutableArray alloc] init];
                            
                            for(int i = 0;i<[tempArray count];i++){
                                if([[[tempArray objectAtIndex:i] objectForKey:@"state"] integerValue]==0){
                                    [headerArray addObject:[tempArray objectAtIndex:i]];
                                }
                            }
//                            if (self.relateMeArray) {
//                                [self.relateMeArray insertObject:headerArray atIndex:0];
//                            }else{
                            [self.relateMeArray addObjectsFromArray:headerArray];
//                            }
                        }

                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.relateMeArray.count ==0) {
                                [self signNoDataView];
                            }else{
                                [_relateTableView reloadData];
                            }
                        });
                    }else{
                        //加载更多
                        self.pageNumber = [[[dic objectForKey:@"list"] objectForKey:@"pageNumber"] integerValue];

                        NSArray *tempArray = [[dic objectForKey:@"list"] objectForKey:@"result"];
                        NSMutableArray *footerArray = [[NSMutableArray alloc] init];
                        for(int i = 0;i<[tempArray count];i++){
                            if([[[tempArray objectAtIndex:i] objectForKey:@"state"] integerValue]==0){
                                [footerArray addObject:[tempArray objectAtIndex:i]];
                            }
                        }
                        [self.relateMeArray addObjectsFromArray:footerArray];
                        [footerArray release];
                        [_relateTableView reloadData];
                    }
                   
                }else{
                    [self signNoDataView];
                }
            }else{
                [self signNoDataView];
            }
        }
            break;
        default:
            break;
    }
    
}
@end
