//
//  TempChatDetailViewController.m
//  LinkeBe
//
//  Created by Dream on 14-9-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "TempChatDetailViewController.h"
#import "Global.h"
#import "ChatMacro.h"
#import "UIViewController+NavigationBar.h"
#import "TempChatNameViewController.h"
#import "ContactSelectMembersViewController.h"
#import "TempChat_list_model.h"
#import "ObjectData.h"
#import "UIImageView+WebCache.h"
#import "ChatMacro.h"
#import "TempChatManager.h"
#import "TempChatMembersViewController.h"
#import "MobClick.h"

#define chatNameTag 100

@interface TempChatDetailViewController ()<UITableViewDataSource,UITableViewDelegate,TempChatNameDelegate>

@property (nonatomic, retain) UITableView *tempChatTableView;

@property (nonatomic, retain) ObjectData *nameData; //获取名字

@property (nonatomic, retain) NSMutableArray *portraitArray; //图片集

@property (nonatomic, retain) NSDictionary *tempDic; //会话详情数据字典

@property (nonatomic, assign) int membersCount; //会话人数

@end

@implementation TempChatDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.membersCount = 0;
        self.title = @"群聊详情";
        self.portraitArray = [[[NSMutableArray alloc]init] autorelease];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshDetailData) name:TempCircleMemberChanged object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(quitCircleSuccess) name:TempCircleQuitScucess object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"TempChatDetailViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"TempChatDetailViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
    
    [self loadBackButton];  //返回按钮
    
    [self loadTempChatDetailData]; //数据库取数据
    
    [self loadTableView];   //初始化tableview
}

- (void)loadTableView {
    UITableView *tempTableView;
    if (IOS7_OR_LATER) {
        tempTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStyleGrouped];
    } else {
      tempTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 44) style:UITableViewStylePlain];
    }
    tempTableView.delegate = self;
    tempTableView.dataSource =self;
    tempTableView.scrollEnabled = NO;
    self.tempChatTableView = tempTableView;
    [self.view addSubview:tempTableView];
    RELEASE_SAFE(tempTableView);
    
    UIButton *quitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [quitBtn setTitle:@"退出并删除" forState:UIControlStateNormal];
    [quitBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    quitBtn.layer.borderWidth = 0.5;
    quitBtn.layer.borderColor = [UIColor redColor].CGColor;
    quitBtn.layer.cornerRadius = 4.0;
    quitBtn.layer.masksToBounds = YES;
    quitBtn.frame = CGRectMake(20, ScreenHeight - 200, ScreenWidth - 40, 44);
    [quitBtn addTarget:self action:@selector(quitButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:quitBtn];
}

- (void)loadTempChatDetailData {
    //会话信息
    self.tempDic = [TempChat_list_model getTempChatContentDataWith:self.listData.ObjectID];
    
    //会话人数
    NSArray *membersArray = [self.tempDic objectForKey:@"members"];
    if (membersArray.count > 0) {
        self.membersCount = [membersArray count];
    }
    
    //获取名字
    self.nameData = [ObjectData objectFromMemberListWithID:[[self.tempDic objectForKey:@"userId"] longLongValue]];
    
    //获取头像
    [self.portraitArray removeAllObjects];
    for (int i = 0; i < [membersArray count]; i++) {
        ObjectData *portraitData = [ObjectData objectFromMemberListWithID:[[membersArray objectAtIndex:i] longLongValue]];
        [self.portraitArray addObject:portraitData];
    }
}

- (void)refreshDetailData {
    [self loadTempChatDetailData];
    [self.tempChatTableView reloadData];
}


#pragma mark - UITableVew DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        //-----------------------会话名称，创建人-------------------------
        static NSString *identifier = @"Cell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]autorelease];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = RGBACOLOR(136, 136, 136, 1);
            
            UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(95, (44 - 20)/2, ScreenWidth - 150, 20)];
            lable.backgroundColor = [UIColor clearColor];
            lable.tag = chatNameTag;
            lable.font = [UIFont systemFontOfSize:15.0];
            lable.textColor = RGBACOLOR(51, 51, 51, 1);
            [cell addSubview:lable];
            [lable release];
            
            //箭头
            UIImage *arrowImg = [UIImage imageNamed:@"ico_group_arrow1.png"];
            UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(290,(44 - arrowImg.size.height)/2 , arrowImg.size.width, arrowImg.size.height)];
            arrowImage.tag = 1000;
            arrowImage.hidden = YES;
            arrowImage.image = arrowImg;
            [cell addSubview:arrowImage];
            RELEASE_SAFE(arrowImage);
        }
        if (indexPath.row == 0) {
            cell.textLabel.text = @"群聊名称";
            UILabel *subLable = (UILabel *)[cell viewWithTag:chatNameTag];
            //判断超过20个字的情况
            NSString *title = [self.tempDic objectForKey:@"name"];
            NSString *subTitle = nil;
            if (title.length > 20) {
                subTitle = [title substringToIndex:20];
            } else {
                subTitle = title;
            }
            subLable.text = subTitle;
            
            UIImageView *image = (UIImageView *)[cell viewWithTag:1000];
            image.hidden = NO;
        } else {
            cell.textLabel.text = @"创建人";
            UILabel *subLable = (UILabel *)[cell viewWithTag:chatNameTag];
            
            subLable.text = self.nameData.objectName;
        }
        return cell;
        
    } else if (indexPath.section == 1) {
        //---------------------头像，选择组织 -------------------------
        static NSString *identifier = @"Cell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]autorelease];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(60, (44 - 20)/2, ScreenWidth - 150, 20)];
            lable.backgroundColor = [UIColor clearColor];
            lable.tag = 200;
            lable.font = [UIFont systemFontOfSize:15.0];
            lable.textColor = RGBACOLOR(51, 51, 51, 1);
            [cell addSubview:lable];
            [lable release];
            
            //箭头
            UIImage *arrowImg = [UIImage imageNamed:@"ico_group_arrow1.png"];
            UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(290,(44 - arrowImg.size.height)/2 , arrowImg.size.width, arrowImg.size.height)];
            arrowImage.image = arrowImg;
            [cell addSubview:arrowImage];
            RELEASE_SAFE(arrowImage);
        }
        
        if (indexPath.row == 0) {
            //再添加新数据
            NSMutableArray *imageArray = [NSMutableArray array];
            if ([self.portraitArray count] > 6) {
                for (int i = 0; i < 6; i ++) {
                    [imageArray addObject:[self.portraitArray objectAtIndex:i]];
                }
                
                for (int i = 0; i < [imageArray count]; i ++) {
                    ObjectData *portraitData = [imageArray objectAtIndex:i];
                    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15*(i+1)+28*i, (44- 30)/2, 30, 30)];
                    imageView.layer.cornerRadius = 2.0;
                    imageView.layer.masksToBounds = YES;
                    NSURL* urlStr = [NSURL URLWithString:portraitData.objectPortrait];
                    [imageView setImageWithURL:urlStr placeholderImage:[portraitData getDefaultProtraitImg]];
                    [cell addSubview:imageView];
                    [imageView release];
                }

            } else {
                for (int i = 0; i < [self.portraitArray count]; i ++) {
                    ObjectData *portraitData = [self.portraitArray objectAtIndex:i];
                    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15*(i+1)+30*i, (44- 30)/2, 30, 30)];
                    imageView.layer.cornerRadius = 2.0;
                    imageView.layer.masksToBounds = YES;
                    NSURL* urlStr = [NSURL URLWithString:portraitData.objectPortrait];
                    [imageView setImageWithURL:urlStr placeholderImage:[portraitData getDefaultProtraitImg]];
                    [cell addSubview:imageView];
                    [imageView release];
                }
            }

        } else {
            
            cell.imageView.image = [UIImage imageNamed:@"ico_chat_add_blue.png"];
            UILabel *subLable = (UILabel *)[cell viewWithTag:200];
            subLable.text = @"添加成员";
        }
        return cell;
    
    }
    return nil;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{ //会话名称
                
                [MobClick event:@"chat_modify_tempCircleName"];
                UITableViewCell *cell = (UITableViewCell *)[self.tempChatTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                UILabel *lable = (UILabel *)[cell viewWithTag:chatNameTag];
                TempChatNameViewController *chatNameVC = [[TempChatNameViewController alloc]init];
                chatNameVC.delegate =self;
                chatNameVC.circleId = self.listData.ObjectID;
                
                if (lable.text == nil) {
                    chatNameVC.title = @"";
                } else {
                    chatNameVC.title = lable.text;
                }
                
                [self.navigationController pushViewController:chatNameVC animated:YES];
                [chatNameVC release];
            }
               
                break;
            case 1:
                NSLog(@"1");
                break;
                
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0:{
                TempChatMembersViewController *TempChatMembersVC = [[TempChatMembersViewController alloc]init];
                TempChatMembersVC.membersDic = self.tempDic;
                TempChatMembersVC.typePush = tempChatDetailType;
                [self.navigationController pushViewController:TempChatMembersVC animated:YES];
                RELEASE_SAFE(TempChatMembersVC);
                
            }
                break;
            case 1:{ //选择成员
                ContactSelectMembersViewController *contactSelectMembersVC = [[ContactSelectMembersViewController alloc]init];
                contactSelectMembersVC.tempChatMemberArray = [self.tempDic objectForKey:@"members"];
                contactSelectMembersVC.listData = self.listData;
                [self.navigationController pushViewController:contactSelectMembersVC animated:YES];
                RELEASE_SAFE(contactSelectMembersVC);
            }
                break;
            default:
                break;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
        UILabel *titleLable = [[UILabel alloc]init];
        if (IOS7_OR_LATER) {
            titleLable.frame = CGRectMake(15, 17, ScreenWidth, 20);
        } else {
            sectionView.backgroundColor = BACKGROUNDCOLOR;
            titleLable.frame = CGRectMake(15, 5, ScreenWidth, 20);
        }
        titleLable.font = [UIFont systemFontOfSize:13.0];
        titleLable.backgroundColor = [UIColor clearColor];
        titleLable.textColor = RGBACOLOR(53,53, 53, 1);
        [sectionView addSubview:titleLable];
        [titleLable release];
        
        titleLable.text = [NSString stringWithFormat:@"群聊人数(%d/%d)",self.membersCount,TempChatMembersMaxNumber];
        
        return [sectionView autorelease];
    }
    if (IOS6_OR_LATER) {
        if (section == 1) {
            UIView *sectionView = [[[UIView alloc]initWithFrame:CGRectZero] autorelease];
            return sectionView;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (IOS7_OR_LATER) {
        return 20.0f;
    } else {
        return 0.0;
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

//回调过来改变名字
- (void)callBackChatName:(NSString *)string {
    UITableViewCell *cell = (UITableViewCell *)[self.tempChatTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UILabel *lable = (UILabel *)[cell viewWithTag:100];
    lable.text = string;
}

//退出按钮
- (void)quitButton {
    [MobClick event:@"chat_click_quitTempCircleButton"];
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"退出并删除后，将无法再接收此群聊信息" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    [alertView release];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
       [[TempChatManager shareManager] quitTempCircleWithCircleID:self.listData.ObjectID];
    }
}

- (void)quitCircleSuccess
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TempCircleMemberChanged object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TempCircleQuitScucess object:nil];
    
    self.tempChatTableView = nil;
    self.tempDic = nil;
    self.nameData = nil;
    self.portraitArray = nil;
    [super dealloc];
}

@end
