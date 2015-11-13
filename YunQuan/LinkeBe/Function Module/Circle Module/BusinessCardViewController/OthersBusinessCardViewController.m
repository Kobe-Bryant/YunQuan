//
//  OthersBusinessCardViewController.m
//  LinkeBe
//
//  Created by Dream on 14-9-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "OthersBusinessCardViewController.h"
#import "UserModel.h"
#import "CommonProgressHUD.h"
#import "SessionDataOperator.h"
#import "CompanyLiveAppBrowserViewController.h"
#import "BrowserViewController.h"
#import "NSObject_extra.h"

@interface OthersBusinessCardViewController ()<MajorCircleManagerDelegate>
{
    MBProgressHUD *hudView;
}
@property(nonatomic,retain)NSDictionary *cardDictionary;
@property (nonatomic,copy) NSString *signatureStr; //签名
@property (nonatomic,retain) NSDictionary *liveAppDic;

@end

@implementation OthersBusinessCardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.liveAppDic = nil;
    self.cardDictionary = nil;
    self.signatureStr = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadData];
}

- (void)loadData {
    [self hideHudView];
    
    hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"请稍候..."];
    
    MajorCircleManager *manager = [[MajorCircleManager alloc]init];
    manager.delegate = self;
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                self.orgUserId,@"orgUserId",
                                @"0",@"ts",
                                nil];
    [manager accessBusinessCard:dic];
}

- (void)initWithBottomButton {
    UIButton *bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomBtn.layer.borderWidth = 0.5f;
    bottomBtn.layer.borderColor = RGBACOLOR(200, 200, 200, 1).CGColor;
    [bottomBtn setFrame:CGRectMake(0.f, ScreenHeight - 64 - 50, ScreenWidth, 50.f)];
    [bottomBtn setBackgroundImage:[UIImage imageNamed:@"btn_group_vip_bg.png"] forState:UIControlStateNormal];
    [bottomBtn setImage:[UIImage imageNamed:@"ico_common_chat62.png"] forState:UIControlStateNormal];
    [bottomBtn setTitle:@"聊 聊" forState:UIControlStateNormal];
    [bottomBtn setTitleColor:RGBACOLOR(0, 160, 233, 1) forState:UIControlStateNormal];
    [bottomBtn addTarget:self action:@selector(bottomBtnSend) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomBtn];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = nil;
    if (self.cardDictionary) {
         dic = [self.cardDictionary objectForKey:@"userinfo"];
    }
   
    switch (indexPath.section) {
    //************************第一个section包括电话邮箱，兴趣，签名**************************//
        case 0:{
            static NSString *identifier1 = @"FirstCell";
            FirstCell *firstCell = (FirstCell *)[tableView dequeueReusableCellWithIdentifier:identifier1];
            if (!firstCell) {
                firstCell = [[[FirstCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1]autorelease];
                firstCell.contentView.backgroundColor = [UIColor whiteColor];
                firstCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            switch (indexPath.row) {
                case 0:
                    firstCell.titleLable.text = @"组织";
                    firstCell.contentLable.text = [dic objectForKey:@"orgName"];;
                    break;
                case 1:
                    firstCell.titleLable.text = @"电话";
                    if ([[dic objectForKey:@"telShield"] integerValue]==0) {
                        if ([[dic objectForKey:@"mobile"] length]!=0) {
                            firstCell.contentLable.text = [self phoneNumTypeTurnWith:[dic objectForKey:@"mobile"] withString:@" "];
                        }else {
                            firstCell.contentLable.text = @"";
                        }
                    }else{
                        if ([[dic objectForKey:@"mobile"] length]!=0) {
                            firstCell.contentLable.text = [[[self phoneNumTypeTurnWith:[dic objectForKey:@"mobile"] withString:@" "] substringToIndex:9] stringByAppendingString:@"****"];
                        }else {
                            firstCell.contentLable.text = @"";
                        }
                    }
                    break;
                case 2:
                    firstCell.titleLable.text = @"邮箱";
                    firstCell.contentLable.text = [dic objectForKey:@"email"];
                    break;
                case 3:
                    firstCell.titleLable.text = @"签名";
                    firstCell.contentLable.text = self.signatureStr;
                    //签名自适应高度
                    CGSize titleSize = [self.signatureStr sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
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
                secondCell.contentView.backgroundColor = [UIColor whiteColor];
                secondCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            if ([self.liveAppDic count]>0&&[self.liveAppDic objectForKey:@"companyName"]) {
                [secondCell openCompanyLightApp];
                secondCell.companyLable.text = [self.liveAppDic objectForKey:@"companyName"];
                secondCell.countLable.text = [NSString stringWithFormat:@"%@次浏览",[self.liveAppDic objectForKey:@"pv"]];
                [secondCell.headImage setImageWithURL:[NSURL URLWithString:[self.liveAppDic objectForKey:@"logoUrl"]] placeholderImage:[UIImage imageNamed:@"icon_liveApp_default.png"]];
            }else{
                [secondCell noDredgeCompanyLightApp];
                secondCell.dredgeBtn.hidden = YES;
//                [secondCell.dredgeBtn setTitle:@"未开通" forState:UIControlStateNormal];
//                [secondCell.dredgeBtn addTarget:self action:@selector(dredgeCompanyLightApp) forControlEvents:UIControlEventTouchUpInside];
            }

            return secondCell;
        }
            break;
        case 2:{
            //**************************更多资料**************************//
            
            static NSString *identifier1 = @"FirstCell1";
            FirstCell *firstCell = (FirstCell *)[tableView dequeueReusableCellWithIdentifier:identifier1];
            if (!firstCell) {
                firstCell = [[[FirstCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1]autorelease];
                firstCell.contentView.backgroundColor = [UIColor whiteColor];
                firstCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            switch (indexPath.row) {
                case 0:
                    firstCell.titleLable.text = @"行业";
                    firstCell.contentLable.text = [dic objectForKey:@"industry"];
                    break;
                case 1:
                    firstCell.titleLable.text = @"兴趣";
                    firstCell.contentLable.text = [dic objectForKey:@"interests"];
                    break;
                 
                case 2:
                    firstCell.titleLable.text = @"家乡";
                    if ([dic objectForKey:@"province"] != nil || [dic objectForKey:@"city"]!= nil) {
                      firstCell.contentLable.text = [NSString stringWithFormat:@"%@%@",[dic objectForKey:@"province"],[dic objectForKey:@"city"]];
                    }
                    
                    break;
                case 3:
                    firstCell.titleLable.text = @"学校";
                    firstCell.contentLable.text = [dic objectForKey:@"school"];
                    break;
                case 4:
                {
                    firstCell.titleLable.text = @"生日";
                    
                    if ([[dic objectForKey:@"birthdayShield"] integerValue]==0) {
                        if ([[dic objectForKey:@"birthday"] isEqualToString:nil]||[[dic objectForKey:@"birthday"] length]==0) {
                            firstCell.contentLable.text = @"";
                        }else{
                            firstCell.contentLable.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"birthday"]];
                        }
                    }else{
                        firstCell.contentLable.text = @"保密";
                    }
                }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || indexPath.section == 2) {
        //签名这一层要自适应高度
        if (indexPath.section == 0) {
            if (indexPath.row == 3) {
                if (self.signatureStr == nil || self.signatureStr.length == 0 || [self.signatureStr isEqualToString:@""]) {
                    return 40.0;
                } else {
                    CGSize titleSize = [self.signatureStr sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
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

#pragma mark -- UITableviewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if ([self.liveAppDic objectForKey:@"liveappUrl"]) {
            BrowserViewController* browserVC = [[BrowserViewController alloc] init];
            browserVC.hidesBottomBarWhenPushed = YES;
            browserVC.webvieUrl = [self.liveAppDic objectForKey:@"liveappUrl"];
            browserVC.webTitle = [self.liveAppDic objectForKey:@"companyName"];
            browserVC.pushType = BussinessCardPush;
            [self.navigationController pushViewController:browserVC animated:YES];
            [browserVC release];
        }
    }
}
- (void)dredgeCompanyLightApp {
//    NSDictionary *dic = nil;
//    if (self.cardDictionary) {
//        dic = [self.cardDictionary objectForKey:@"userinfo"];
//    }
//    //开通公司轻APP
//    CompanyLiveAppBrowserViewController* browserVC = [[CompanyLiveAppBrowserViewController alloc] init];
//    browserVC.url = [NSString stringWithFormat:@"%@?org_id=%@&user_id=%@",LIGHTAPPURL,[UserModel shareUser].org_id,[dic objectForKey:@"userId"]];
//    browserVC.webTitle = @"开通企业场景应用";
//    browserVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:browserVC animated:YES];
//    [browserVC release];
}

//底部按钮点击事件
- (void)bottomBtnSend {
    [MobClick event:@"card_chat"];
    NSDictionary *dic = nil;
    if (self.cardDictionary) {
        dic = [self.cardDictionary objectForKey:@"userinfo"];
    }
    long long objectID = [[dic objectForKey:@"userId"] longLongValue];
    [SessionDataOperator otherSystemTurnToSessionWithSender:self andObjectID:objectID andSessionType:SessionTypePerson isPopToRootViewController:NO isShowRightButton:YES];
}

- (void) hideHudView
{
    if (hudView) {
        [hudView hide:YES];
    }
}

- (void)getCircleViewHttpCallBack:(NSArray *)arr interface:(LinkedBe_WInterface)interface{
    [self hideHudView];
    switch (interface) {
        case LinkeBe_BusinessCard:
        {
            if ([arr count]) {
                self.cardDictionary = [arr objectAtIndex:0];
                NSDictionary *dic = [self.cardDictionary objectForKey:@"userinfo"];
                
                //姓名
                self.persionView.personNameLable.text = [dic objectForKey:@"realname"];
                //公司
                
                self.persionView.companyNameLable.text = [dic objectForKey:@"companyName"];
                //职位
                self.persionView.positionLable.text = [dic objectForKey:@"companyRole"];
                
                //根据名字排性别的frame
                CGSize nameSize = [self.persionView.personNameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:17.0] constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
                self.persionView.sexImage.frame = CGRectMake(MIN(nameSize.width + 73, 120+73), 24, 12, 12);
                self.persionView.positionLable.frame = CGRectMake(MIN(nameSize.width + 90, 120+90), 20, 150.0, 20);
                
                if ([[dic objectForKey:@"sex"] intValue] == 0) {
                    [self.persionView.iconImage setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"portrait"]] placeholderImage:[UIImage imageNamed:@"ico_default_portrait_male.png"]];
                    
                    self.persionView.sexImage.image = [UIImage imageNamed:@"ico_me_male.png"];
                }else{
                    [self.persionView.iconImage setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"portrait"]] placeholderImage:[UIImage imageNamed:@"ico_default_portrait_female.png"]];
                    
                    self.persionView.sexImage.image = [UIImage imageNamed:@"ico_me_female.png"];
                }
                
                if ([dic objectForKey:@"realname"]) {
                    self.title = [NSString stringWithFormat:@"%@的名片",[dic objectForKey:@"realname"]];
                } else {
                    self.title = @"名片";
                }
                
                if ([[dic objectForKey:@"state"] intValue] == 2) {
                    [self initWithBottomButton];  //底部 聊天
                }
                
                self.signatureStr = [dic objectForKey:@"signature"]; //签名
                
                self.nameStr = [dic objectForKey:@"realname"]; //谁的企业空间
                
                self.liveAppDic = [[self.cardDictionary objectForKey:@"companies"] firstObject];
                
                [self.businessCardTableView reloadData];

            }
           
        }
            break;
            
        default:
            break;
    }
}

//点击头像放大
- (void)ClickIconImage {
    [MobClick event:@"card_user_portrait"];
    if ([[self.cardDictionary objectForKey:@"userinfo"] objectForKey:@"portrait"]) {
        NSArray* pics = [[NSArray alloc] initWithObjects:[[self.cardDictionary objectForKey:@"userinfo"] objectForKey:@"portrait"], nil];
        
        // 1.封装图片数据
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity:[pics count]];
        for (int i = 0; i < [pics count]; i++) {
            NSString * getImageStrUrl = [NSString stringWithFormat:@"%@", [pics objectAtIndex:i]];
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [NSURL URLWithString: getImageStrUrl]; // 图片路径
            
            photo.srcImageView = self.persionView.iconImage;;
            [photos addObject:photo];
            [photo release];
        }
        // 2.显示相册
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.photos = photos; // 设置所有的图片
        [browser show];
        [browser release];
        [pics release];
    }
}

@end
