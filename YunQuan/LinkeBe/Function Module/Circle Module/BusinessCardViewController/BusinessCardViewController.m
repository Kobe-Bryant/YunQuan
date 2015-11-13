//
//  BusinessCardViewController.m
//  LinkeBe
//
//  Created by Dream on 14-9-12.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "BusinessCardViewController.h"

@interface BusinessCardViewController ()
@end

@implementation BusinessCardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"名片";
        self.bussinessType = NormalBussinessType;
    }
    return self;
}

- (void)dealloc {
    self.nameStr = nil;
    self.persionView = nil;
    self.businessCardTableView.tableHeaderView = nil;
    self.businessCardTableView = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"BusinessCardViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"BusinessCardViewPage"];
}

- (void)viewDidAppear:(BOOL)animated
{
    _businessCardTableView.contentSize = CGSizeMake(ScreenWidth, _businessCardTableView.contentSize.height + 50.0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
        
    [self creteaBackButton]; //返回按钮
    [self initWithHeadView]; //表头View
    [self initWithTableView]; //初始化tableview表视图
//    [self initWithBottomButton];  //底部 聊天按钮 访问场景商店
    
}

- (void)initWithTableView {
    UITableView *tempTable;
    if (IOS7_OR_LATER) {
        tempTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 26) style:UITableViewStyleGrouped];
    } else {
         tempTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 40) style:UITableViewStylePlain];
    }
    tempTable.delegate = self;
    tempTable.dataSource = self;
    tempTable.backgroundColor = RGBACOLOR(249, 249, 249, 1);
    tempTable.tableHeaderView = _persionView;
    self.businessCardTableView = tempTable;
    [self.view addSubview:tempTable];
    RELEASE_SAFE(tempTable);
}

- (void)initWithHeadView {
    _persionView = [[PersionInfoView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 80.0)];
    
    UITapGestureRecognizer *tapIconImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ClickIconImage)];
    [_persionView.iconImage addGestureRecognizer:tapIconImage];
    [tapIconImage release];
    
    CGSize nameSize = [_persionView.personNameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:16.0] constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
    _persionView.sexImage.frame = CGRectMake(nameSize.width + 73, 24, 12, 12);
}

- (void)initWithBottomButton {
    UIButton *bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomBtn.backgroundColor = [UIColor whiteColor];
    bottomBtn.layer.borderWidth = 0.5f;
    bottomBtn.layer.borderColor = RGBACOLOR(200, 200, 200, 1).CGColor;
    [bottomBtn setFrame:CGRectMake(0.f, ScreenHeight - 64 - 50, ScreenWidth, 50.f)];
    
//    if (self.businessCard == SELFBUSINESSCARD) {
//        [bottomBtn setImage:[UIImage imageNamed:@"ico_common_chat62.png"] forState:UIControlStateNormal];
//        [bottomBtn setTitle:@"聊聊" forState:UIControlStateNormal];
//    } else if (self.businessCard == HISBUSINESSCARD) {
//
//    }
    [bottomBtn setTitle:@"访问场景应用商店" forState:UIControlStateNormal];
    [bottomBtn setTitleColor:RGBACOLOR(0, 160, 233, 1) forState:UIControlStateNormal];
    [bottomBtn addTarget:self action:@selector(bottomBtnSend) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomBtn];
}

#pragma mark -- UITableviewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    } else if (section == 1) {
        return 1;
    } else {
        return 5;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
    //************************第一个section包括电话邮箱，兴趣，签名**************************//
        case 0:{
            static NSString *identifier1 = @"FirstCell";
            FirstCell *firstCell = (FirstCell *)[tableView dequeueReusableCellWithIdentifier:identifier1];
            if (!firstCell) {
                firstCell = [[[FirstCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1]autorelease];
                firstCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            switch (indexPath.row) {
                case 0:
                    firstCell.titleLable.text = @"电话";
                    break;
                case 1:
                    firstCell.titleLable.text = @"邮箱";
                    break;
                case 2:
                    firstCell.titleLable.text = @"兴趣";
                    break;
                case 3:
                    firstCell.titleLable.text = @"签名";
                    firstCell.contentLable.text = self.test;
                    //签名自适应高度
                    CGSize titleSize = [self.test sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
                    firstCell.contentLable.frame = CGRectMake(70, 10, 240, titleSize.height + 1);
                    
                    break;
                    
                default:
                    break;
            }
            return firstCell;
        }
        break;
    //**************************第二个section包括企业介绍 liveapp**************************//
        case 1:{
            static NSString *identifier2 = @"SecondCell";
            SecondCell *secondCell = [tableView dequeueReusableCellWithIdentifier:identifier2];
            if (!secondCell) {
                secondCell = [[[SecondCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2]autorelease];
                secondCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            secondCell.companyLable.text = @"云来网络有限公司";
            secondCell.countLable.text = @"100万次浏览";
            
            
            return secondCell;
        }
            break;
    //**************************第三个section包括 开通liveapp案例**************************//
//        case 2:{
//            static NSString *identifier3 = @"ThirdCell";
//            ThirdCell *thirdCell = [tableView dequeueReusableCellWithIdentifier:identifier3];
//            if (!thirdCell) {
//                thirdCell = [[[ThirdCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3]autorelease];
//                thirdCell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//            }
//            
//            NSInteger row = indexPath.row;
//            for (NSInteger i = 0; i < 2; i++){
//                if (i==0) {
//                   thirdCell.leftView.titleNameLabel.text = @"刘文龙";
//                   thirdCell.leftView.companyLabel.text =@"云来网络";
//                   thirdCell.leftView.tag = 100+ row*2 + i;
//                    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thirdCellViewTaped:)];
//                    [thirdCell.leftView addGestureRecognizer:tapRecognizer];
//                    [tapRecognizer release];
//                } else {
//                    thirdCell.rightView.titleNameLabel.text = @"刘文龙2";
//                    thirdCell.rightView.companyLabel.text =@"云来网络2";
//                    thirdCell.rightView.tag = 100+ row*2 + i;
//                    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thirdCellViewTaped:)];
//                    [thirdCell.rightView addGestureRecognizer:tapRecognizer];
//                    [tapRecognizer release];
//                }
//            }
//            return thirdCell;
//        }
//            break;
        case 2:{
       //**************************更多资料**************************//

            static NSString *identifier1 = @"FirstCell1";
            FirstCell *firstCell = (FirstCell *)[tableView dequeueReusableCellWithIdentifier:identifier1];
            if (!firstCell) {
                firstCell = [[[FirstCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1]autorelease];
                firstCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            switch (indexPath.row) {
                case 0:
                    firstCell.titleLable.text = @"行业";
//                    firstCell.contentLable.text = @"移动软件";
                    break;
                case 1:
                    firstCell.titleLable.text = @"家乡";
//                    firstCell.contentLable.text = @"湖南 常德";
                    break;
                case 2:
                    firstCell.titleLable.text = @"学校";
//                    firstCell.contentLable.text = @"深圳大学";
                    break;
                case 3:
                    firstCell.titleLable.text = @"生日";
//                    firstCell.contentLable.text = @"1991年12月20日";
                    break;
                    
                default:
                    break;
            }
            return firstCell;
        }
            break;

        default:
            break;
    }
    return nil;
}

#pragma mark -- UITableviewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || indexPath.section == 2) {
        //签名这一层要自适应高度
        if (indexPath.section == 0) {
            if (indexPath.row == 3) {
                if (self.test == nil || self.test.length == 0 || [self.test isEqualToString:@""]) {
                    return 40.0;
                } else {
                    CGSize titleSize = [self.test sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
                    return titleSize.height + 21;
                }
                
            } else {
                return 40.0;
            }
        } else if (indexPath.section == 2) {
            return 40.0;
        }
        
    } else {
        return 64.0;
    }
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (IOS7_OR_LATER) {
        if (section == 1 || section == 2) {
            return 15.0;
        }
        //    else if(section == 2){
        //        return 3.0;
        //    }
    }
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, 80.f)];
        headView.backgroundColor = RGBACOLOR(249, 249, 249, 1);
        UILabel *lable = [[UILabel alloc]init];
        if (IOS7_OR_LATER) {
            lable.frame = CGRectMake(15, 12, 280, 20);
        } else {
            lable.frame = CGRectMake(15, 5, 280, 20);
        }
        if (self.nameStr == nil || self.nameStr.length == 0 || [self.nameStr isEqualToString:@""]) {
            lable.text = @"企业空间（免费赠送场景应用）";
        } else {
            lable.text = [NSString stringWithFormat:@"%@的企业空间（免费赠送场景应用）",self.nameStr];
        }
        
        lable.textColor = RGBACOLOR(136, 136, 136, 1);
        lable.font = [UIFont systemFontOfSize:12.0];
        lable.backgroundColor = [UIColor clearColor];
        [headView addSubview:lable];
        
        [lable release];
        return [headView autorelease];
    }
//    else if(section ==1){
//        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, 20.f)];
//        headView.backgroundColor = RGBACOLOR(249, 249, 249, 1);
//        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 2, 280, 20)];
//        lable.text = @"他们都开通了企业介绍";
//        lable.textColor = RGBACOLOR(51, 51, 51, 1);
//        lable.font = [UIFont systemFontOfSize:12.0];
//        lable.backgroundColor = [UIColor clearColor];
//        [headView addSubview:lable];
//        
//        [lable release];
//        return [headView autorelease];
//    }
    else if(section ==1) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, 80.f)];
        headView.backgroundColor = RGBACOLOR(249, 249, 249, 1);
        UILabel *lable = [[UILabel alloc]init];
        if (IOS7_OR_LATER) {
            lable.frame = CGRectMake(15, 12, 280, 20);
        } else {
            lable.frame = CGRectMake(15, 5, 280, 20);
        }
        lable.text = @"更多资料";
        lable.textColor = RGBACOLOR(136, 136, 136, 1);
        lable.font = [UIFont systemFontOfSize:12.0];
        lable.backgroundColor = [UIColor clearColor];
        [headView addSubview:lable];
        
        [lable release];
        return [headView autorelease];
    
    }
    if (IOS6_OR_LATER) {
        if (section == 2) {
            UIView *headView = [[UIView alloc] initWithFrame:CGRectZero];
            return [headView autorelease];
        }
    }
    return nil;

}

#pragma mark --  各种手势按钮点击事件

//返回按钮
- (void)creteaBackButton{
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
}

- (void)creteRightButton{
    UIButton* rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:IMGREADFILE(DynamicPic_list_publish) forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(20, 7, 30, 30);
    [rightBtn addTarget:self action:@selector(clickRightButton) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem release];
}

- (void)clickRightButton {
    EditViewController *editVC = [[EditViewController alloc]init];
    [self.navigationController pushViewController:editVC animated:YES];
    [editVC release];
}

- (void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.bussinessType == TabbarBussinessType) {
        self.tabBarController.tabBar.hidden = YES;
    }
}

//点击头像放大
- (void)ClickIconImage {

}

//开通了企业介绍
- (void)thirdCellViewTaped:(UITapGestureRecognizer *)recognizer {
    NSInteger tag = [recognizer view].tag-100;
    NSLog(@"cellviewTaped %d",tag);
}

//底部按钮点击事件
- (void)bottomBtnSend {
}

@end
