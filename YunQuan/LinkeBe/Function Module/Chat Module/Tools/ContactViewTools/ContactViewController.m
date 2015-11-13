//
//  ContactViewController.m
//  LinkeBe
//
//  Created by Dream on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "ContactViewController.h"
#import "MobClick.h"

#define ContectViewTag 888

@interface ContactViewController ()

@property (nonatomic, retain) NSMutableArray *membersArray; //表中激活成员数据

@property (nonatomic, retain) NSMutableArray *passArray;  //用来传递 搜索和tableview的数据

@property (nonatomic, retain) NSArray *keyArray;

@property (nonatomic, retain) NSDictionary * sortDic;

@end

@implementation ContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"添加成员";
        self.membersArray = [[[NSMutableArray alloc]init]autorelease];
        self.searchResults = [[[NSMutableArray alloc]init] autorelease];
        self.modelArray = [[[NSMutableArray alloc]initWithCapacity:0] autorelease];
        self.modelSearchArray = [[[NSMutableArray alloc]init]autorelease];
        self.selectedArray = [[[NSMutableArray alloc]init]autorelease];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
    
    [self loadSearchBar];  //初始化searchBar
    
    [self loadTableView];  //初始化tableView
    
    [self loadButtomView]; //初始化底部滑动条
    
    [self loadBackButton]; //返回按钮
    
    [self loadData];       //添加数据源
}

- (void)loadData {
    //按首字母排序
    NSMutableArray *arr = [Circle_member_model getActiveMembers]; //有效成员
    NSMutableDictionary *sortDic= [PinYinSort accordingFirstLetterFromPinYin:arr];
    self.sortDic = sortDic;
    
    self.keyArray = [[sortDic allKeys] sortedArrayUsingSelector:@selector(compare:)];
    if ([self.keyArray count]) {
        for (int i = 0; i < [sortDic allKeys].count; i ++) {
            [self.membersArray addObjectsFromArray:[sortDic objectForKey:[self.keyArray objectAtIndex:i]]];
        }
    }
    
    NSDictionary *dic = nil;
    if ([self.membersArray count]) {
        for (int i = 0; i< [self.membersArray count]; i ++) {
            dic = [self.membersArray objectAtIndex:i];
            ContactModel *model = [[ContactModel alloc]init];
            model.iconStr = [dic objectForKey:@"portrait"];
            model.nameStr = [dic objectForKey:@"realname"];
            model.positionStr = [dic objectForKey:@"companyRole"];
            model.companyStr = [dic objectForKey:@"companyName"];
            model.userId = [[dic objectForKey:@"userId"] longLongValue];
            model.sexString = [dic objectForKey:@"sex"];
            //单聊 把他填入数组
            if (self.listData.ObjectID == model.userId) {
                [self.selectedArray addObject:model];
            }
            [self.modelArray addObject:model];
            [model release];
        }
    }
    [self freshButtomView];
}

- (void)loadSearchBar{
    UISearchBar * tempSearch = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.f, ScreenWidth, 44.0f)];
    self.searchBar = tempSearch;
    RELEASE_SAFE(tempSearch);
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.translucent= YES;
	self.searchBar.placeholder=@"搜索";
	self.searchBar.delegate = self;
    //设置为聊天列表头
    
    //搜索控制器
    UISearchDisplayController *searchController = [[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
    searchController.searchResultsTableView.allowsMultipleSelection = YES;
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
    searchController.delegate = self;
    self.searchControl = searchController;
    RELEASE_SAFE(searchController);
    
}

- (void)loadTableView {
    UITableView *tempTable;
    if (IOS7_OR_LATER) {
        tempTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 26) style:UITableViewStyleGrouped];
    } else {
       tempTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 26) style:UITableViewStylePlain];
    }
    self.mainTableView = tempTable;
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.allowsMultipleSelection = YES;
    
    UIView * tableHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, 44.0f)];
    self.mainTableView.tableHeaderView = tableHeadView;
    RELEASE_SAFE(tableHeadView);
    [self.mainTableView.tableHeaderView addSubview:self.searchBar];
    if (IOS7_OR_LATER) {
        self.mainTableView.sectionIndexBackgroundColor = [UIColor clearColor];// 索引字体颜色
        self.mainTableView.sectionIndexColor = [UIColor grayColor];
    }
   
    [self.view addSubview:self.mainTableView];
    RELEASE_SAFE(tempTable);

}

- (void)loadButtomView {
    ContactView * tempContectView = [[ContactView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 55 - 64, ScreenWidth, 55)];
    tempContectView.tag = ContectViewTag;
    tempContectView.backgroundColor = RGBACOLOR(68, 68, 68, 0.95);
    tempContectView.opaque = 0.95;
    [tempContectView.surreButton addTarget:self action:@selector(ClickSureButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tempContectView];
    
    self.contectView = tempContectView;
    RELEASE_SAFE(tempContectView);
}

- (void)freshButtomView {
    //进来之前删除老数据
    for (UIView *subView in self.contectView.scrollView.subviews) {
        [subView removeFromSuperview];
    }
    UIImageView *defaultImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 44, 44)];
    defaultImage.image = [UIImage imageNamed:@"btn_chat_dotted.png"];
    [self.contectView.scrollView addSubview:defaultImage];
    RELEASE_SAFE(defaultImage);
    
    //再添加新数据
    for (int i = [self.selectedArray count] - 1; i >= 0; i --) {
        ContactModel *model = [self.selectedArray objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10*([self.selectedArray count] - i)+44*([self.selectedArray count] - i - 1)+54, 0, 44, 44)];
        imageView.layer.cornerRadius = 3.0;
        imageView.layer.masksToBounds = YES;
        NSURL* urlStr = [NSURL URLWithString:model.iconStr];
        if ([model.sexString intValue] == 0) {
            [imageView setImageWithURL:urlStr placeholderImage:[UIImage imageNamed:DEFAULT_MALE_PORTRAIT]];
        }else{
            [imageView setImageWithURL:urlStr placeholderImage:[UIImage imageNamed:DEFAULT_FEMALE_PORTRAIT]];
        }
        [self.contectView.scrollView addSubview:imageView];
        self.contectView.scrollView.contentSize = CGSizeMake([self.selectedArray count]*54 + 64, 44);
        [imageView release];
    }
    //小红点数字
    if ([self.selectedArray count] > 0) {
        self.contectView.redLable.hidden = NO;
        self.contectView.redLable.text = [NSString stringWithFormat:@"%d",[self.selectedArray count]];
    } else {
        self.contectView.redLable.hidden = YES;
    }
}

//返回按钮
- (void)loadBackButton{
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (IOS6_OR_LATER) {
        if (scrollView == self.mainTableView){
            CGFloat sectionHeaderHeight = 55;
            if (scrollView.contentOffset.y<=sectionHeaderHeight && scrollView.contentOffset.y>=0) {
                scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
            } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
                scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
            }
        }
    }
}

#pragma mark -- UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.mainTableView) {
        return [self.modelArray count];
    } else if(tableView == self.searchControl.searchResultsTableView){
        return [_searchResults count];
    }
    return section;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.mainTableView) {
        static NSString *identifier = @"ContactViewCell";
        ContactViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[ContactViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]autorelease];
            
            UIView *clearView = [[UIView alloc]initWithFrame:cell.bounds];
            clearView.backgroundColor = [UIColor clearColor];
            cell.selectedBackgroundView = clearView;
            [clearView release];
            
            //直线
            UIImage *line = [UIImage imageNamed:@"img_group_underline.png"];
            UIImageView *lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 54.5, ScreenWidth, 0.5)];
            lineImage.image = line;
            [cell addSubview:lineImage];
            [lineImage release];
            
        }
        ContactModel *model = [self.modelArray objectAtIndex:indexPath.row];
        //这里是搜索选中返回列表也需要被选中
        if ([self.selectedArray count] > 0) {
            for (ContactModel *selectModel in self.selectedArray) {
                if (model.userId == selectModel.userId) {
                    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
        }
    
        //自己默认 和单聊的人被选中
        switch (self.listData.latestMessage.sessionType) {
            case SessionTypePerson:
            {
                if ([[UserModel shareUser].user_id longLongValue] == model.userId || self.listData.ObjectID == model.userId) {
                    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
                break;
            case SessionTypeTempCircle:
            {
                for (int i = 0; i < [self.tempChatMemberArray count]; i++) {
                    ObjectData *portraitData = [ObjectData objectFromMemberListWithID:[[self.tempChatMemberArray objectAtIndex:i] longLongValue]];
                    if (portraitData.objectID == model.userId) {
                        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
            default:
                break;
        }
        NSURL* urlStr = [NSURL URLWithString:model.iconStr];
        if ([model.sexString intValue] == 0) {
            [cell.listNameImage setImageWithURL:urlStr placeholderImage:[UIImage imageNamed:DEFAULT_MALE_PORTRAIT]];
        }else{
            [cell.listNameImage setImageWithURL:urlStr placeholderImage:[UIImage imageNamed:DEFAULT_FEMALE_PORTRAIT]];
        }
        
        cell.nameLable.text = model.nameStr;
        
        //根据名字排版职位的UI排布
        CGSize listNameWidth = [cell.nameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:16.0] constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
        cell.positionLable.frame = CGRectMake(MIN(CGRectGetMaxX(cell.listNameImage.frame) + 10 + listNameWidth.width + 5, 250), 2.0, 80.0, 30.f); //职位
        
        cell.positionLable.text = model.positionStr;  //职位
        
        cell.companyLable.text = model.companyStr; //公司名称
        
        return cell;
        
    } else if (tableView == self.searchControl.searchResultsTableView){
        static NSString *searchCell = @"ContactViewCell";
        ContactViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCell];
        if (!cell) {
            cell = [[[ContactViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCell]autorelease];
            UIView *clearView = [[UIView alloc]initWithFrame:cell.bounds];
            clearView.backgroundColor = [UIColor clearColor];
            cell.selectedBackgroundView = clearView;
            [clearView release];
            
            //直线
            UIImage *line = [UIImage imageNamed:@"img_group_underline.png"];
            UIImageView *lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 54.5, ScreenWidth, 0.5)];
            lineImage.image = line;
            [cell addSubview:lineImage];
            [lineImage release];
            
        }
        
        NSDictionary *dic = nil;
        if ([_searchResults count]) {
            dic = [_searchResults objectAtIndex:indexPath.row];
        }
         //这里是搜索选中返回列表也需要被选中
        ContactModel *model = [self.modelSearchArray objectAtIndex:indexPath.row];
        if ([self.selectedArray count] > 0) {
            for (ContactModel *selectModel in self.selectedArray) {
                if (model.userId == selectModel.userId) {
                    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
        }
        
        //自己默认 和单聊的人被选中
        switch (self.listData.latestMessage.sessionType) {
            case SessionTypePerson:
            {
                if ([[UserModel shareUser].user_id longLongValue] == model.userId || self.listData.ObjectID == model.userId) {
                    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
                break;
            case SessionTypeTempCircle:
            {
                for (int i = 0; i < [self.tempChatMemberArray count]; i++) {
                    ObjectData *portraitData = [ObjectData objectFromMemberListWithID:[[self.tempChatMemberArray objectAtIndex:i] longLongValue]];
                    if (portraitData.objectID == model.userId) {
                        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
            default:
                break;
        }
        cell.nameLable.text = [dic objectForKey:@"realname"];
        cell.companyLable.text = [dic objectForKey:@"companyName"];
        //根据名字排版职位的UI排布
        CGSize listNameWidth = [cell.nameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:16.0] constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
        cell.positionLable.frame = CGRectMake(MIN(CGRectGetMaxX(cell.listNameImage.frame) + 10 + listNameWidth.width + 10, 250), 2.0, 80.0, 30.f); //职位
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
            [cell.listNameImage setImageWithURL:urlStr placeholderImage:[UIImage imageNamed:DEFAULT_MALE_PORTRAIT]];
        } else {
            [cell.listNameImage setImageWithURL:urlStr placeholderImage:[UIImage imageNamed:DEFAULT_FEMALE_PORTRAIT]];
        }
        
        return cell;
    }
    return nil;
}

#pragma mark -- UITableView DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [MobClick event:@"chat_select_member"];
    
    ContactModel *model = nil;
    if (tableView == self.mainTableView) {
        model = [self.modelArray objectAtIndex:indexPath.row];
    } else if (tableView == self.searchControl.searchResultsTableView) {
        model = [self.modelSearchArray objectAtIndex:indexPath.row];
    }
    //单聊和群聊已经存在的不能再选中
    switch (self.listData.latestMessage.sessionType) {
        case SessionTypePerson:
        {
            if (model.userId == [[UserModel shareUser].user_id longLongValue] || self.listData.ObjectID == model.userId) {
                return;
            } else {
                if (model) {
                    [self.selectedArray addObject:model];
                }
            }
        }
            break;
        case SessionTypeTempCircle:
        {
            for (int i = 0; i < [self.tempChatMemberArray count]; i++) {
                ObjectData *portraitData = [ObjectData objectFromMemberListWithID:[[self.tempChatMemberArray objectAtIndex:i] longLongValue]];
                if (portraitData.objectID == model.userId) {
                    return;
                }
            }
            if (model) {
                 [self.selectedArray addObject:model];
            }
        }
        default:
            break;
    }

    [self freshButtomView]; //刷新底部滑动栏
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactModel *model = nil;
    if (tableView == self.mainTableView) {
        model = [self.modelArray objectAtIndex:indexPath.row];
    } else if (tableView == self.searchControl.searchResultsTableView) {
        model = [self.modelSearchArray objectAtIndex:indexPath.row];
    }
    
    switch (self.listData.latestMessage.sessionType) {
        case SessionTypePerson:
        {
            if (model.userId == [[UserModel shareUser].user_id longLongValue] || self.listData.ObjectID == model.userId) {
                return nil;
            }
        }
            break;
        case SessionTypeTempCircle:
        {
            for (int i = 0; i < [self.tempChatMemberArray count]; i++) {
                ObjectData *portraitData = [ObjectData objectFromMemberListWithID:[[self.tempChatMemberArray objectAtIndex:i] longLongValue]];
                if (portraitData.objectID == model.userId) {
                    return nil;
                }
            }
        }
        default:
            break;
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactModel *model = nil;
    if (tableView == self.mainTableView) {
        model = [self.modelArray objectAtIndex:indexPath.row];
        if (self.passArray.count > 0) {
            for (ContactModel *passModel in self.passArray) {
                if (passModel.userId == model.userId) {
                    model = passModel;
                }
            }
        }
    } else if (tableView == self.searchControl.searchResultsTableView) {
        model = [self.modelSearchArray objectAtIndex:indexPath.row];
        if (self.passArray.count > 0) {
            for (ContactModel *passModel in self.passArray) {
                if (passModel.userId == model.userId) {
                    model = passModel;
                }
            }
        }
    }
    [self.selectedArray removeObject:model];

    [self freshButtomView]; //刷新底部滑动栏
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
    [MobClick event:@"chat_selected_contact_searchbar"];
    self.searchBar.showsCancelButton = YES;
    
    //改变底部view的高度
    UIView *view = [self.view viewWithTag:ContectViewTag];
    view.frame = CGRectMake(0, ScreenHeight - 55 - 20, ScreenWidth, 55);
    
    self.passArray = self.selectedArray;
    
    for (UIView *view in [self.searchBar.subviews[0] subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton* cancelbutton = (UIButton* )view;
            [cancelbutton setTitle:@"取消" forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    UIView *view = [self.view viewWithTag:ContectViewTag];
    view.frame = CGRectMake(0, ScreenHeight - 55 - 64, ScreenWidth, 55);
    self.passArray = self.selectedArray;
    [self.mainTableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchControl.searchResultsTableView) {
        if (indexPath.row == self.searchResults.count-1) {
        self.searchControl.searchResultsTableView.contentSize = CGSizeMake(ScreenWidth, self.searchResults.count*55.0 + 55.0);
        }
    } else {
        if (indexPath.row == 1) {
            self.mainTableView.contentSize = CGSizeMake(ScreenWidth, self.membersArray.count*55 +142 + 55.0);
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_searchResults removeAllObjects];
    
    //获取所有联系人数据
    NSArray *allContactsArr = [Circle_member_model getActiveMembers];
    
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
    
    [controller.searchContentsController.view addSubview:[self.view viewWithTag:ContectViewTag]];
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
    [self loadSearchData];
    return YES;
}

- (void)loadSearchData {
    [self.modelSearchArray removeAllObjects];
    if ([_searchResults count]) {
      for (int i = 0; i< [_searchResults count]; i ++) {
        NSDictionary *dic = [_searchResults objectAtIndex:i];
        ContactModel *model = [[ContactModel alloc]init];
        model.iconStr = [dic objectForKey:@"portrait"];
        model.nameStr = [dic objectForKey:@"realname"];
        model.positionStr = [dic objectForKey:@"companyRole"];
        model.companyStr = [dic objectForKey:@"companyName"];
        model.userId = [[dic objectForKey:@"userId"] longLongValue];
        model.sexString = [dic objectForKey:@"sex"];
        //单聊 把（和我聊天的人)填入数组
        if (self.listData.ObjectID == model.userId) {
            [self.selectedArray addObject:model];
        }
        [self.modelSearchArray addObject:model];
          [model release];
      }
    }
}

//底部确定button按钮点击事件
- (void)ClickSureButton {
  
}

//返回上一级
- (void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hideHudView
{
    if (self.hudView) {
        [self.hudView hide:YES];
    }
}

- (void)dealloc
{
    self.keyArray = nil;
    self.hudView = nil;
    self.passArray = nil;
    self.selectedArray = nil;
    self.contectView = nil;
    self.membersArray = nil;
    self.modelArray = nil;
    self.searchBar = nil;
    self.sortDic = nil;
    // add by snail 7.0 系统下headView
    self.mainTableView.delegate = nil;
    self.mainTableView.tableHeaderView = nil;
    self.mainTableView = nil;
    self.searchResults = nil;
    self.searchControl = nil;
    self.tempChatMemberArray = nil;
    self.modelSearchArray = nil;
    [super dealloc];
}

@end
