//
//  SelfBusinessCardViewController.m
//  LinkeBe
//
//  Created by Dream on 14-9-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SelfBusinessCardViewController.h"
#import "Userinfo_model.h"
#import "SBJson.h"
#import "OpenCompanyUsers_model.h"
#import "Companie_LiveApp_model.h"
#import "CompanyLiveAppBrowserViewController.h"
#import "BrowserViewController.h"
#import "NSObject_extra.h"

@interface SelfBusinessCardViewController ()

@property(nonatomic,retain)NSDictionary *userinfoDic;
@property(nonatomic,retain)NSMutableArray *userinfoArray;
@property(nonatomic,retain)NSMutableArray *openCompanyUsersArray;
@property(nonatomic,retain)NSDictionary *openCompanyDic;
@property(nonatomic,retain)NSDictionary *liveAppDic;
@property (nonatomic,copy) NSString *signatureStr; //签名


@end

@implementation SelfBusinessCardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"我的名片";
    }
    return self;
}

- (void)dealloc
{
    self.liveAppDic = nil;
    self.userinfoDic = nil;
    self.userinfoArray = nil;
    self.openCompanyUsersArray = nil;
    self.openCompanyDic = nil;
    self.signatureStr = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    Companie_LiveApp_model *companyLiveModel = [[Companie_LiveApp_model alloc] init];
    self.liveAppDic = [[[[companyLiveModel getList] firstObject] objectForKey:@"content"] JSONValue];
    NSIndexSet * index=[[NSIndexSet alloc]initWithIndex:1];
    [self.businessCardTableView reloadSections:index withRowAnimation:UITableViewRowAnimationNone];
    [index release];
    RELEASE_SAFE(companyLiveModel);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self creteRightButton]; //导航栏右按钮
    
    [self readSqlData]; //数据库读取数据
    
    [self refreshInfoData]; //刷新数据
    
    [self initWithBottomButton];  //底部 访问场景商店
    
}

-(void)readSqlData{
    
    Userinfo_model *userInfoModel = [[Userinfo_model alloc]init];
    self.userinfoArray = [userInfoModel getList];
    NSString *dicString = [[self.userinfoArray firstObject] objectForKey:@"content"];
    self.userinfoDic = [dicString JSONValue];
    [userInfoModel release];
    
    OpenCompanyUsers_model *openCompanyModel = [[OpenCompanyUsers_model alloc]init];
    self.openCompanyUsersArray = [openCompanyModel getList];
    [openCompanyModel release];
    
    Companie_LiveApp_model *companyLiveModel = [[Companie_LiveApp_model alloc] init];
    self.liveAppDic = [[[[companyLiveModel getList] firstObject] objectForKey:@"content"] JSONValue];
    [companyLiveModel release];
}

- (void)refreshInfoData {
    
    //公司
    self.persionView.companyNameLable.text = [self.userinfoDic objectForKey:@"companyName"];
    //姓名
    self.persionView.personNameLable.text = [self.userinfoDic objectForKey:@"realname"];
    //职位
    self.persionView.positionLable.text = [self.userinfoDic objectForKey:@"companyRole"];
    
    //根据名字排性别的frame
    CGSize nameSize = [self.persionView.personNameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:17.0] constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
    self.persionView.sexImage.frame = CGRectMake(MIN(nameSize.width + 73, 120+73), 24, 12, 12);
    self.persionView.positionLable.frame = CGRectMake(MIN(nameSize.width + 90, 120+90), 20, 150.0, 20);
    
    if ([[self.userinfoDic objectForKey:@"sex"] intValue] == 0) {
        [self.persionView.iconImage setImageWithURL:[NSURL URLWithString:[self.userinfoDic objectForKey:@"portrait"]] placeholderImage:[UIImage imageNamed:@"ico_default_portrait_male.png"]];
        
        self.persionView.sexImage.image = [UIImage imageNamed:@"ico_me_male.png"];
    }else{
        [self.persionView.iconImage setImageWithURL:[NSURL URLWithString:[self.userinfoDic objectForKey:@"portrait"]] placeholderImage:[UIImage imageNamed:@"ico_default_portrait_female.png"]];
        
        self.persionView.sexImage.image = [UIImage imageNamed:@"ico_me_female.png"];
    }

    self.signatureStr = [self.userinfoDic objectForKey:@"signature"];
}

#define mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    } else if (section == 3) {
        return 5;
    } else {
        return 1;
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
                    firstCell.titleLable.text = @"组织";
                    firstCell.contentLable.text = [self.userinfoDic objectForKey:@"orgName"];
                    break;
                case 1:
                    firstCell.titleLable.text = @"电话";
                    
                    if ([[self.userinfoDic objectForKey:@"telShield"] integerValue]==0) {
                        if ([[self.userinfoDic objectForKey:@"mobile"] length]!=0) {
                            firstCell.contentLable.text = [self phoneNumTypeTurnWith:[self.userinfoDic objectForKey:@"mobile"] withString:@" "];
                        }else {
                            firstCell.contentLable.text = @"";
                        }
                    }else{
                        if ([[self.userinfoDic objectForKey:@"mobile"] length]!=0) {
                            firstCell.contentLable.text = [[[self phoneNumTypeTurnWith:[self.userinfoDic objectForKey:@"mobile"] withString:@" "] substringToIndex:9] stringByAppendingString:@"****"]
                            ;
                        }else {
                            firstCell.contentLable.text = @"";
                        }
                    }
                    break;
                case 2:
                    firstCell.titleLable.text = @"邮箱";
                    firstCell.contentLable.text = [self.userinfoDic objectForKey:@"email"];
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
                secondCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            if ([self.liveAppDic count]>0&&[self.liveAppDic objectForKey:@"companyName"]) {
                [secondCell openCompanyLightApp];
                secondCell.companyLable.text = [self.liveAppDic objectForKey:@"companyName"];
                
                if ([self.liveAppDic objectForKey:@"pv"]) {
                    secondCell.countLable.text = [NSString stringWithFormat:@"%@次浏览",[self.liveAppDic objectForKey:@"pv"]];
                } else {
                    secondCell.countLable.text = @"";
                }

                [secondCell.headImage setImageWithURL:[NSURL URLWithString:[self.liveAppDic objectForKey:@"logoUrl"]] placeholderImage:[UIImage imageNamed:@"icon_liveApp_default.png"]];
            }else{
                [secondCell noDredgeCompanyLightApp];
                [secondCell.dredgeBtn addTarget:self action:@selector(dredgeCompanyLightApp) forControlEvents:UIControlEventTouchUpInside];
            }
            
            return secondCell;
        }
            break;
   //**************************第三个section包括 开通liveapp案例**************************//
        case 2:{
            static NSString *identifier3 = @"ThirdCell";
            ThirdCell *thirdCell = [tableView dequeueReusableCellWithIdentifier:identifier3];
            if (!thirdCell) {
                thirdCell = [[[ThirdCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3]autorelease];
                thirdCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
            
            NSInteger row = indexPath.row;
            for (NSInteger i = 0; i < 2; i++){
                
                //奇数
                if (row*2+i>self.openCompanyUsersArray.count-1)
                {
                    break;
                }
                if ([self.openCompanyUsersArray count] > 0) {
                    self.openCompanyDic = [[[self.openCompanyUsersArray objectAtIndex:row*2 + i] objectForKey:@"content"] JSONValue];
                }
                if (i==0) {
                    thirdCell.leftView.titleNameLabel.text = [self.openCompanyDic objectForKey:@"realname"];
                    thirdCell.leftView.companyLabel.text = [self.openCompanyDic objectForKey:@"companyName"];
                    [thirdCell.leftView.iconImageView setImageWithURL:[NSURL URLWithString:[self.openCompanyDic objectForKey:@"portrait"]] placeholderImage:[UIImage imageNamed:@"ico_default_portrait_male.png"]];
                    thirdCell.leftView.tag = 100+ row*2 + i;
                    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thirdCellViewTaped:)];
                    [thirdCell.leftView addGestureRecognizer:tapRecognizer];
                    [tapRecognizer release];
                } else {
                    thirdCell.rightView.titleNameLabel.text = [self.openCompanyDic objectForKey:@"realname"];
                    thirdCell.rightView.companyLabel.text = [self.openCompanyDic objectForKey:@"companyName"];
                    [thirdCell.rightView.iconImageView setImageWithURL:[NSURL URLWithString:[self.openCompanyDic objectForKey:@"portrait"]] placeholderImage:[UIImage imageNamed:@"ico_default_portrait_male.png"]];
                    thirdCell.rightView.tag = 100+ row*2 + i;
                    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thirdCellViewTaped:)];
                    [thirdCell.rightView addGestureRecognizer:tapRecognizer];
                    [tapRecognizer release];
                    
                }
            }
            return thirdCell;
        }
            break;

        case 3:{
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
                    firstCell.contentLable.text = [self.userinfoDic objectForKey:@"industry"];
                    break;
                case 1:
                    firstCell.titleLable.text = @"兴趣";
                    firstCell.contentLable.text = [self.userinfoDic objectForKey:@"interests"];
                    break;
                case 2:
                    firstCell.titleLable.text = @"家乡";
                    if ([self.userinfoDic objectForKey:@"province"] != nil || [self.userinfoDic objectForKey:@"city"]!= nil) {
                        firstCell.contentLable.text = [NSString stringWithFormat:@"%@%@",[self.userinfoDic objectForKey:@"province"],[self.userinfoDic objectForKey:@"city"]];
                    }
                    break;
                case 3:
                    firstCell.titleLable.text = @"学校";
                    firstCell.contentLable.text = [self.userinfoDic objectForKey:@"school"];
                    break;
                case 4:
                {
                    firstCell.titleLable.text = @"生日";
                    
                    if ([[self.userinfoDic objectForKey:@"birthdayShield"] integerValue]==0) {
                        if ([[self.userinfoDic objectForKey:@"birthday"] isEqualToString:nil]||[[self.userinfoDic objectForKey:@"birthday"] length]==0) {
                            firstCell.contentLable.text = @"";
                        }else{
                            firstCell.contentLable.text = [NSString stringWithFormat:@"%@",[self.userinfoDic objectForKey:@"birthday"]];
                        }
                    }else{
                        firstCell.contentLable.text = @"保密";
                    }
//                    firstCell.contentLable.text = [NSString stringWithFormat:@"%@",[self.userinfoDic objectForKey:@"birthday"]==nil?@"":[self.userinfoDic objectForKey:@"birthday"]];
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

#pragma mark -- UITableviewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        BrowserViewController* browserVC = [[BrowserViewController alloc] init];
        browserVC.hidesBottomBarWhenPushed = YES;
        browserVC.webvieUrl = [self.liveAppDic objectForKey:@"liveappUrl"];
        browserVC.webTitle = [self.liveAppDic objectForKey:@"companyName"];
        browserVC.pushType = BussinessCardPush;
        [self.navigationController pushViewController:browserVC animated:YES];
        [browserVC release];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || indexPath.section == 3) {
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
        } else if (indexPath.section == 3) {
            return 40.0;
        }
        
    } else {
        return 64.0;
    }
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1 || section == 3) {
        return 15.0;
    }else if(section == 2){
        return 3.0;
    }
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, 80.f)];
        headView.backgroundColor = RGBACOLOR(249, 249, 249, 1);
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 12, 280, 20)];
        lable.text = @"我的企业空间(免费赠送场景应用)";
        lable.textColor = RGBACOLOR(136, 136, 136, 1);
        lable.font = [UIFont systemFontOfSize:12.0];
        lable.backgroundColor = [UIColor clearColor];
        [headView addSubview:lable];
        
        [lable release];
        return [headView autorelease];
    }else if(section ==1){
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, 20.f)];
        headView.backgroundColor = RGBACOLOR(249, 249, 249, 1);
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 2, 280, 20)];
        lable.text = @"企业空间经典案例";
        lable.textColor = RGBACOLOR(136, 136, 136, 1);
        lable.font = [UIFont systemFontOfSize:12.0];
        lable.backgroundColor = [UIColor clearColor];
        [headView addSubview:lable];
        
        [lable release];
        return [headView autorelease];
    }else if(section ==2) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, 80.f)];
        headView.backgroundColor = RGBACOLOR(249, 249, 249, 1);
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 12, 280, 20)];
        lable.text = @"更多资料";
        lable.textColor = RGBACOLOR(136, 136, 136, 1);
        lable.font = [UIFont systemFontOfSize:12.0];
        lable.backgroundColor = [UIColor clearColor];
        [headView addSubview:lable];
        
        [lable release];
        return [headView autorelease];
        
    }
    return nil;
    
}

- (void)initWithBottomButton {
    UIButton *bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomBtn.backgroundColor = [UIColor whiteColor];
    bottomBtn.layer.borderWidth = 0.5f;
    bottomBtn.layer.borderColor = RGBACOLOR(200, 200, 200, 1).CGColor;
    [bottomBtn setFrame:CGRectMake(0.f, ScreenHeight - 64 - 50, ScreenWidth, 50.f)];
    [bottomBtn setTitle:@"访问场景应用商店" forState:UIControlStateNormal];
    [bottomBtn setTitleColor:RGBACOLOR(0, 160, 233, 1) forState:UIControlStateNormal];
    [bottomBtn addTarget:self action:@selector(bottomBtnSend) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomBtn];
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

//liveApp跳转
- (void)dredgeCompanyLightApp {
    //开通公司轻APP
    CompanyLiveAppBrowserViewController* browserVC = [[CompanyLiveAppBrowserViewController alloc] init];
    browserVC.url = [NSString stringWithFormat:@"%@?org_id=%@&user_id=%@",LIGHTAPPURL,[UserModel shareUser].org_id,[UserModel shareUser].user_id];
    browserVC.webTitle = @"开通企业场景应用";
    [self.navigationController pushViewController:browserVC animated:YES];
    [browserVC release];
}

//开通了企业介绍
- (void)thirdCellViewTaped:(UITapGestureRecognizer *)recognizer {
    NSInteger tag = [recognizer view].tag-100;
    //开通公司轻APP
    BrowserViewController* browserVC = [[BrowserViewController alloc] init];
    browserVC.hidesBottomBarWhenPushed = YES;
    browserVC.pushType = MyselfPush;
    browserVC.webvieUrl = [[[[self.openCompanyUsersArray objectAtIndex:tag] objectForKey:@"content"] JSONValue] objectForKey:@"lightapp"];
    browserVC.webTitle = [[[[self.openCompanyUsersArray objectAtIndex:tag] objectForKey:@"content"] JSONValue] objectForKey:@"realname"];
    [self.navigationController pushViewController:browserVC animated:YES];
    [browserVC release];
}

//底部按钮点击事件
- (void)bottomBtnSend {
    BrowserViewController* browserVC = [[BrowserViewController alloc] init];
    browserVC.webvieUrl = @"http://lightapp.cn";
    browserVC.webTitle = @"场景应用";
    [self.navigationController pushViewController:browserVC animated:YES];
    [browserVC release];
}

-(void)ClickIconImage{
    [MobClick event:@"card_user_portrait"];
    if ([self.userinfoDic objectForKey:@"portrait"]) {
        NSArray* pics = [[NSArray alloc] initWithObjects:[self.userinfoDic objectForKey:@"portrait"], nil];
        
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
