//
//  CicleMemberViewController.m
//  LinkeBe
//
//  Created by Dream on 14-9-15.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "CicleMemberViewController.h"
#import "UIViewController+NavigationBar.h"
#import "Global.h"
#import "CicleListCell.h"
#import "Circle_member_model.h"
#import "UIImageView+WebCache.h"
#import "SBJson.h"
#import "PinYinForObjc.h"
#import "SelfBusinessCardViewController.h"
#import "OthersBusinessCardViewController.h"
#import "Common.h"
#import "SessionDataOperator.h"
#import "PinYinSort.h"
#import "Cicle_member_list_model.h"
#import "MobClick.h"

#define inviteTag  2500
#define sendTag    500

@interface CicleMemberViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UISearchDisplayDelegate,MajorCircleManagerDelegate> {

    UITableView *_oneLayerTableView;
    int clickButtonTag;
}

@property (nonatomic, assign)long long objectID;

//组织成员的数据
@property (nonatomic, retain) NSMutableArray *membersArray;
//搜索最终数据
@property (nonatomic, retain) NSMutableArray *searchResults;
//搜索栏
@property (nonatomic, retain) UISearchBar *searchBar;
//搜索控制器
@property (nonatomic, retain) UISearchDisplayController *searchControl;

@property (nonatomic, retain) NSArray *keyArray;

@property (nonatomic, retain) NSMutableDictionary *sortDic;

@property (nonatomic,retain) NSMutableArray *tempArray;

@end

@implementation CicleMemberViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.searchResults = [[[NSMutableArray alloc]init] autorelease];
        self.membersArray = [[[NSMutableArray alloc]init]autorelease];
    }
    return self;
}

- (void)dealloc
{
    self.sortDic = nil;
    self.tempArray = nil;
    self.keyArray = nil;
    self.searchBar = nil;
    self.searchResults = nil;
    self.searchControl = nil;
    self.orgName = nil;
    self.membersArray = nil;
    [_oneLayerTableView release]; _oneLayerTableView = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"CicleMembersViewPage"];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"CicleMembersViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.orgName;
    self.view.backgroundColor = BACKGROUNDCOLOR;
    
    [self loadDbData]; //数据库数据
    
    [self creteaBackButton]; //返回按钮
    
    [self initWithTableView]; //初始化tableview
    
    [self initWithSearchBar]; //searchBar
    
    if (![self.membersArray count]) {
        UILabel *lable = [[UILabel alloc]init];
        lable.textColor = RGBACOLOR(51, 51, 51, 1);
        lable.text = [NSString stringWithFormat:@"“%@”暂无成员",self.orgName];
        CGSize lableSize = [lable.text sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:CGSizeMake(MAXFLOAT,30)];
        lable.frame = CGRectMake((ScreenWidth - lableSize.width)/2, self.view.frame.size.height/2 - 50, lableSize.width + 5, 30);
        lable.backgroundColor = [UIColor clearColor];
        [self.view addSubview:lable];
        [lable release];
    }
}

- (void)loadDbData {
    NSArray *arr = [Cicle_member_list_model getMembersWithOrgId:self.orgId];

    NSMutableDictionary *dic = [PinYinSort accordingFirstLetterFromPinYin:arr];
    self.sortDic = dic;
    self.keyArray = [[dic allKeys] sortedArrayUsingSelector:@selector(compare:)];
    if ([self.keyArray count]) {
        for (int i = 0; i < [dic allKeys].count; i ++) {
            [self.membersArray addObjectsFromArray:[dic objectForKey:[self.keyArray objectAtIndex:i]]];
        }
    }
}
- (void)initWithSearchBar {
    UISearchBar * tempSearch = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar = tempSearch;
    RELEASE_SAFE(tempSearch);
    self.searchBar.frame = CGRectMake(0.0f, 0.f, ScreenWidth, 44.0f);
	self.searchBar.placeholder=@"查找朋友";
	self.searchBar.delegate = self;
    
    //设置为聊天列表头
    UIView * tableHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, 44.0f)];
    _oneLayerTableView.tableHeaderView = tableHeadView;
    RELEASE_SAFE(tableHeadView);
    [_oneLayerTableView.tableHeaderView addSubview:self.searchBar];
    
    //搜索控制器
    UISearchDisplayController *searchController = [[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
    self.searchControl = searchController;
    RELEASE_SAFE(searchController);
    self.searchControl.searchResultsDataSource = self;
    self.searchControl.searchResultsDelegate = self;
    self.searchControl.delegate = self;

}

- (void)initWithTableView {
    _oneLayerTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
    _oneLayerTableView.delegate = self;
    _oneLayerTableView.dataSource = self;
    [_oneLayerTableView setBackgroundColor:BACKGROUNDCOLOR];
    if (IOS7_OR_LATER) {
        _oneLayerTableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _oneLayerTableView.sectionIndexColor = [UIColor grayColor];
    }
    [self.view addSubview:_oneLayerTableView];
}

#pragma mark -- 一级组织和搜索功能协议方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchControl.searchResultsTableView) {
        return [_searchResults count];
        
    } else if (tableView == _oneLayerTableView) {
        return [self.membersArray count];
        
    }
    return section;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _oneLayerTableView) {
        static NSString *identifier2 = @"CicleListCell";
        
        CicleListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
        
        if (!cell) {
            cell = [[[CicleListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSDictionary* dic = nil;
        if ([self.membersArray count]) {
            dic = [self.membersArray objectAtIndex:indexPath.row];
        }
        self.tempArray = self.membersArray;
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
        cell.positionLable.frame = CGRectMake(MIN(60 + listNameWidth.width + 10, 180), 2.0, 80, 30.f); //职位
        
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
    } else if (tableView == self.searchControl.searchResultsTableView){
        
        static NSString *searchCell = @"CicleListCell";
        CicleListCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCell];
        if (nil == cell) {
            cell = [[[CicleListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCell]autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        NSDictionary *dic = nil;
        if ([_searchResults count]) {
           dic = [_searchResults objectAtIndex:indexPath.row];
        }
        self.tempArray = _searchResults;
        cell.nameLable.text = [dic objectForKey:@"realname"];
        cell.companyLable.text = [dic objectForKey:@"companyName"];
        //根据名字排版职位的UI排布
        CGSize listNameWidth = [cell.nameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:16.0] constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
        cell.positionLable.frame = CGRectMake(MIN(60 + listNameWidth.width + 10, 180), 2.0, 80, 30.f); //职位
        
        cell.positionLable.text = [dic objectForKey:@"companyRole"];  //职位
        
        //    姓名字体的变化 add vincent
        if ([[dic objectForKey:@"realname"] rangeOfString:_searchBar.text].location != NSNotFound) {
            if ([dic objectForKey:@"realname"]) {
                NSRange rang1 = [[dic objectForKey:@"realname"] rangeOfString:_searchBar.text];
                NSMutableAttributedString  *numStr = [[NSMutableAttributedString alloc] initWithString:[dic objectForKey:@"realname"]];
                [numStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:rang1];
                cell.nameLable.attributedText = numStr;
                [numStr release];
            }
        }
        //    公司名字的字体的颜色的变化 add vincent
        if ([[dic objectForKey:@"companyName"] rangeOfString:_searchBar.text].location != NSNotFound) {
            if ([dic objectForKey:@"companyName"]) {
                NSRange rang1 = [[dic objectForKey:@"companyName"] rangeOfString:_searchBar.text];
                NSMutableAttributedString  *numStr = [[NSMutableAttributedString alloc] initWithString:[dic objectForKey:@"companyName"]];
                [numStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:rang1];
                cell.companyLable.attributedText = numStr;
                [numStr release];
            }
        }
        
        NSURL* urlStr = [NSURL URLWithString:[dic objectForKey:@"portrait"]];
        if ([[dic objectForKey:@"sex"] intValue] == 0) {
            [cell.listNameImage setImageWithURL:urlStr placeholderImage:[UIImage imageNamed:@"ico_default_portrait_male.png"]];
        } else {
            [cell.listNameImage setImageWithURL:urlStr placeholderImage:[UIImage imageNamed:@"ico_default_portrait_female.png"]];
        }
        
        //点击变已邀请
        cell.inviteLable.hidden = YES;
        cell.inviteLable.tag = inviteTag + indexPath.row;
        
        /* 0未邀请 1已邀请 2已激活(正常使用状态)
         *  3禁用 4删除 ，大于2从本地数据库删除
         */
        //这里单独拿出来原因是。。。
        NSDictionary *stateDic = nil;
        if ([_searchResults count]) {
            stateDic = [_searchResults objectAtIndex:indexPath.row];
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
    return nil;
}

#pragma mark -- UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [MobClick event:@"cicle_members_business"];
    if (tableView == _oneLayerTableView) {
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

    } else if (tableView == self.searchControl.searchResultsTableView){
        NSDictionary *dic = [_searchResults objectAtIndex:indexPath.row];
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
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.searchControl.searchResultsTableView) {
        return nil;
    }else{
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
        [arr addObjectsFromArray:self.keyArray];
        if ([arr count] > 0) {
            [arr insertObject:@"#" atIndex:self.keyArray.count];
        }
        return arr;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSString *key = nil;
    if (index < self.keyArray.count) {
        key = [self.keyArray objectAtIndex:index];
        NSArray * sourceArr =[self.sortDic objectForKey:key];
        if (sourceArr.count > 0) {
            NSDictionary * firstSourceDic = [sourceArr firstObject];
            NSInteger index = [self.membersArray indexOfObject:firstSourceDic];
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    return index;
}

#pragma mark -- UISearchBarDelegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    self.searchBar.showsCancelButton = YES;
    for (UIView *view in [self.searchBar.subviews[0] subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton* cancelbutton = (UIButton* )view;
            [cancelbutton setTitle:@"取消" forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_searchResults removeAllObjects];
    
    //获取本组织联系人数据
    Circle_member_model *contactMod = [[Circle_member_model alloc]init];
    contactMod.where = [NSString stringWithFormat:@"orgId = %d and state < 3",self.orgId];
    NSArray *allContactsArr = [contactMod getList];
    RELEASE_SAFE(contactMod);

    NSMutableArray* allContactAndCompanyArr = [NSMutableArray arrayWithCapacity:0];
    
    if ([allContactsArr count]) {
        for (NSDictionary *Dic in allContactsArr) {
            NSString* str = [NSString stringWithFormat:@"%@-%@-%@",[Dic objectForKey:@"realname"],[Dic objectForKey:@"companyName"],[Dic objectForKey:@"companyRole"]];
            [allContactAndCompanyArr addObject:str];
        }
    }
    //不包含中文的搜索
    if (self.searchBar.text.length > 0 && ![Common isIncludeChineseInString:self.searchBar.text]) {
        for (int i=0; i<allContactAndCompanyArr.count; i++) {
            if ([Common isIncludeChineseInString:allContactAndCompanyArr[i]]) {
                
                // 转换为拼音
                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:allContactAndCompanyArr[i]];
                
                // 搜索是否在转换后拼音中
                NSRange titleResult=[tempPinYinStr rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
                
                if (titleResult.length>0) {
                    
                    [_searchResults addObject:allContactsArr[i]];
                    
                }else{
                    // 转换为拼音的首字母
                    NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:allContactAndCompanyArr[i]];
                    
                    // 搜索是否在范围中
                    NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
                    
                    if (titleHeadResult.length>0) {
                        [_searchResults addObject:allContactsArr[i]];
                    }
                }
            }
            else {
                
                NSRange titleResult=[allContactAndCompanyArr[i] rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
                
                if (titleResult.length>0) {
                    [_searchResults addObject:allContactsArr[i]];
                }
            }
        }
        // 搜索中文
    } else if (self.searchBar.text.length>0 && [Common isIncludeChineseInString:self.searchBar.text]) {
        
        for (int i=0; i<allContactAndCompanyArr.count; i++) {
            NSString *tempStr = allContactAndCompanyArr[i];
            
            NSRange titleResult=[tempStr rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
            
            if (titleResult.length>0) {
                [_searchResults addObject:[allContactsArr objectAtIndex:i]];
            }
        }
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if ([_searchResults count] == 0) {
        UITableView *tableView1 = self.searchControl.searchResultsTableView;
        for( UIView *subview in tableView1.subviews ) {
            if([subview isKindOfClass:[UILabel class]]) {
                UILabel *lbl = (UILabel*)subview; // sv changed to subview.
                lbl.text = [NSString stringWithFormat:@"没有找到\"%@\"相关的联系人",self.searchBar.text];
            }
        }
    }else {
        NSMutableDictionary *sortDic= [PinYinSort accordingFirstLetterFromPinYin:_searchResults];
        [_searchResults removeAllObjects];
        NSArray *keyArray = [[sortDic allKeys] sortedArrayUsingSelector:@selector(compare:)];
        if (keyArray.count > 0) {
            for (int i = 0; i < [sortDic allKeys].count; i ++) {
                [_searchResults addObjectsFromArray:[sortDic objectForKey:[keyArray objectAtIndex:i]]];
            }
        }
    }

    return YES;
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

//一级成员邀请 聊聊点击按钮
- (void)send:(UIButton *)sender{
    UIButton *button = (UIButton *)sender;
    clickButtonTag = button.tag;
    
    NSDictionary *Dic = [self.tempArray objectAtIndex:sender.tag - sendTag];
    self.objectID = [[Dic objectForKey:@"userId"] longLongValue];
    if ([button.titleLabel.text isEqualToString:@"邀请"]) {
    
        [MobClick event:@"cicle_member_invitate"];
        MajorCircleManager *manager = [[MajorCircleManager alloc]init];
        manager.delegate = self;
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [UserModel shareUser].user_id,@"userId",
                                    [Dic objectForKey:@"userId"],@"inviteeId",
                                    [Dic objectForKey:@"orgId"],@"orgId",
                                    nil];
        [manager accessUserInvite:dic];
        
    } else {
        [MobClick event:@"cicle_members_chat"];
        [SessionDataOperator otherSystemTurnToSessionWithSender:self andObjectID:self.objectID andSessionType:SessionTypePerson isPopToRootViewController:NO isShowRightButton:YES];
    }
}

#pragma mark -- 聊天回调
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
