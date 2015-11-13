//
//  EditViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-16.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "EditViewController.h"
#import "UIViewController+NavigationBar.h"
#import "Global.h"
#import "EditHeaderView.h"
#import "EditCell.h"
#import "WatermarkCameraViewController.h"
#import "AreaListViewController.h"
#import "IndustryViewController.h"
#import "PhoneViewController.h"
#import "BirthdayViewController.h"
#import "UserSignModifyViewController.h"
#import "UserInfoModifyViewController.h"
#import "Userinfo_model.h"
#import "SBJson.h"
#import "UserModel.h"
#import "CommonProgressHUD.h"
#import "MyselfMessageManager.h"
#import "UIImageView+WebCache.h"
#import "SnailRequestPostObject.h"
#import "SnailNetWorkManager.h"
#import "NSObject_extra.h"

#import "Circle_member_model.h"
#import "MobClick.h"

@interface EditViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,WatermarkCameraViewControllerDelegate,HttpRequestDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate> {
    UITableView *_editTableView;
    EditHeaderView *_editHeaderView;
    
     MBProgressHUD *hudView;
}

@end

@implementation EditViewController
@synthesize userInfoDic;

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
    [_editTableView release];
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self loadDBData];
    
    [self loadTableHeadData];
    [_editTableView reloadData];
    [MobClick beginLogPageView:@"EditViewPage"];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"EditViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"编辑资料";
    self.view.backgroundColor = RGBACOLOR(249,249,249,1);
    
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
    
/*
    //导航栏右按钮
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(20, 7, 40, 30);
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    [rightBtn setTitleColor:RGBACOLOR(42, 119, 195, 1) forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem release];
*/
//     [self loadDBData];
    
    [self initWithHeaderView]; //表头视图
    
    [self initWithTableView]; //初始化tableview
}

-(void)loadDBData{
    Userinfo_model *userInfoModel = [[Userinfo_model alloc]init];
    NSString *dicString = [[[userInfoModel getList] firstObject] objectForKey:@"content"];
    self.userInfoDic = [dicString JSONValue];
    [userInfoModel release];
}

- (void)initWithTableView {
    if (IOS7_OR_LATER) {
        _editTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight - 64) style:UITableViewStyleGrouped];
    } else {
        _editTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight - 44) style:UITableViewStylePlain];
    }
    _editTableView.delegate = self;
    _editTableView.dataSource = self;
    _editTableView.tableHeaderView = _editHeaderView;
    [_editTableView setBackgroundColor:RGBACOLOR(249, 249, 249, 1)];
    [self.view addSubview:_editTableView];
}

- (void)initWithHeaderView {
    _editHeaderView = [[EditHeaderView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 80)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEditHeaderView)];
    [_editHeaderView addGestureRecognizer:tap];
    [tap release];
}

-(void)loadTableHeadData{
    if ([[self.userInfoDic objectForKey:@"sex"] intValue] == 0) {
        [_editHeaderView.iconImage setImageWithURL:[NSURL URLWithString:[self.userInfoDic objectForKey:@"portrait"]] placeholderImage:[UIImage imageNamed:@"ico_default_portrait_male.png"]];
    }else{
        [_editHeaderView.iconImage setImageWithURL:[NSURL URLWithString:[self.userInfoDic objectForKey:@"portrait"]] placeholderImage:[UIImage imageNamed:@"ico_default_portrait_female.png"]];
    }
}

#pragma mark -- UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    } else if (section == 1) {
        return 2;
    } else {
        return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"EditCell";
    EditCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[EditCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]autorelease];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    //箭头
    if (!(indexPath.section == 0 &&(indexPath.row == 0 ||indexPath.row == 1))) {
        UIImage *image2 = [UIImage imageNamed:@"ico_group_arrow1.png"];
        UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(290,(40 - image2.size.height)/2 , image2.size.width, image2.size.height)];
        arrowImage.image = image2;
        [cell addSubview:arrowImage];
        [arrowImage release];
    }
    
    switch (indexPath.section) {
        case 0: //基本信息
            switch (indexPath.row) {
                case 0:
                    cell.titleLable.text = @"姓名";
                    cell.contentLable.text = [self.userInfoDic objectForKey:@"realname"];;
                    break;
                case 1:
                    cell.titleLable.text = @"性别";
                    if ([[self.userInfoDic objectForKey:@"sex"] intValue] == 0) {
                        cell.contentLable.text = @"男士";
                    }else{
                        cell.contentLable.text = @"女士";
                    }
                    break;
                case 2:
                    cell.titleLable.text = @"公司";
                    cell.contentLable.text = [self.userInfoDic objectForKey:@"companyName"];
                    break;
                case 3:
                    cell.titleLable.text = @"职务";
                    cell.contentLable.text = [self.userInfoDic objectForKey:@"companyRole"];
                    break;
                case 4:
                    cell.titleLable.text = @"签名";
                    
                    cell.contentLable.text = [self.userInfoDic objectForKey:@"signature"];
                    //签名自适应高度
                    CGSize titleSize = [cell.contentLable.text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(220, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
                    cell.contentLable.frame = CGRectMake(70, 10, 220, titleSize.height + 1);
                    break;
                    
                default:
                    break;
            }
            break;
        case 1: //联系方式
            if (indexPath.row == 0) {
                cell.titleLable.text = @"电话";
                if ([[self.userInfoDic objectForKey:@"telShield"] integerValue]==0) {
                    if ([[self.userInfoDic objectForKey:@"mobile"] length]!=0) {
                        cell.contentLable.text = [self phoneNumTypeTurnWith:[self.userInfoDic objectForKey:@"mobile"] withString:@" "];
                    }else{
                        cell.contentLable.text = @"";
                    }
                }else{
                    if ([[self.userInfoDic objectForKey:@"mobile"] length]!=0) {
                        cell.contentLable.text = [[[self phoneNumTypeTurnWith:[self.userInfoDic objectForKey:@"mobile"] withString:@" "] substringToIndex:9] stringByAppendingString:@"****"];
                    }else {
                        cell.contentLable.text = @"";
                    }
                }
            }else {
                cell.titleLable.text = @"邮箱";
                cell.contentLable.text = [self.userInfoDic objectForKey:@"email"];
            }
            break;
        case 2: //详细信息
            switch (indexPath.row) {
                case 0:
                {
                    cell.titleLable.text = @"兴趣";
                    cell.contentLable.text = [self.userInfoDic objectForKey:@"interests"];
                }
                    break;
                case 1:
                {
                    cell.titleLable.text = @"行业";
                 
                    cell.contentLable.text = [self.userInfoDic objectForKey:@"industry"];
                }
                    break;
                case 2:
                {
                    cell.titleLable.text = @"家乡";
                    if ([[self.userInfoDic objectForKey:@"province"] isEqualToString:nil]||[[self.userInfoDic objectForKey:@"province"] length]==0||[[self.userInfoDic objectForKey:@"city"] isEqualToString:nil]||[[self.userInfoDic objectForKey:@"city"] length]==0) {
                        cell.contentLable.text = @"";
                    }else{
                        cell.contentLable.text = [NSString stringWithFormat:@"%@%@",[self.userInfoDic objectForKey:@"province"],[self.userInfoDic objectForKey:@"city"]];
                    }
                }
                    break;
                case 3:
                {
                    cell.titleLable.text = @"学校";
                    cell.contentLable.text = [self.userInfoDic objectForKey:@"school"];
                }
                    break;
                case 4:
                {
                    cell.titleLable.text = @"生日";
                    if ([[self.userInfoDic objectForKey:@"birthdayShield"] integerValue]==0) {
                        if ([[self.userInfoDic objectForKey:@"birthday"] isEqualToString:nil]||[[self.userInfoDic objectForKey:@"birthday"] length]==0) {
                            cell.contentLable.text = @"";
                        }else{
                            cell.contentLable.text = [NSString stringWithFormat:@"%@",[self.userInfoDic objectForKey:@"birthday"]];
                        }
                    }else{
                        cell.contentLable.text = @"保密";
                    }
                }
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark -- UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //  签名自适应
    if (indexPath.section == 0 && indexPath.row == 4) {
        if ([self.userInfoDic objectForKey:@"signature"]) {
            CGSize titleSize = [[self.userInfoDic objectForKey:@"signature"] sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(220, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            return titleSize.height + 21;
        }else{
            return 40.0;
        }
    } else {
        return 40.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: //基本信息
            switch (indexPath.row) {
                case 2:
                {
                    //公司
                    UserInfoModifyViewController *userInfoModify = [[UserInfoModifyViewController alloc] init];
                    userInfoModify.titleCtl = @"公司";
                    userInfoModify.content = [self.userInfoDic objectForKey:@"companyName"];
                    userInfoModify.fieldString = @"companyName";
                    [self.navigationController pushViewController:userInfoModify animated:YES];
                    RELEASE_SAFE(userInfoModify);
                }
                    break;
                case 3:
                {
                    //   职务
                    UserInfoModifyViewController *userInfoModify = [[UserInfoModifyViewController alloc] init];
                    userInfoModify.titleCtl = @"职务";
                    userInfoModify.content = [self.userInfoDic objectForKey:@"companyRole"];
                    userInfoModify.fieldString = @"companyRole";
                    [self.navigationController pushViewController:userInfoModify animated:YES];
                    RELEASE_SAFE(userInfoModify);

                }
                    break;
                case 4:
                {
                    //签名
                    UserSignModifyViewController *userSignModefyVc = [[UserSignModifyViewController alloc] init];
                    userSignModefyVc.titleCtl = @"签名";
                    userSignModefyVc.content = [self.userInfoDic objectForKey:@"signature"];
                    userSignModefyVc.fieldString = @"signature";
                    [self.navigationController pushViewController:userSignModefyVc animated:YES];
                    RELEASE_SAFE(userSignModefyVc);
                }
                    break;
                default:
                    break;
            }
            break;
        case 1: //联系方式
            if (indexPath.row == 0) {
                //电话
                PhoneViewController *phoneVc = [[PhoneViewController alloc] init];
                phoneVc.fieldString = @"mobile";
                phoneVc.secketString = [self.userInfoDic objectForKey:@"telShield"];
                phoneVc.content = [self.userInfoDic objectForKey:@"mobile"];
                [self.navigationController pushViewController:phoneVc animated:YES];
                RELEASE_SAFE(phoneVc);
            }else {
                //邮箱
                UserInfoModifyViewController *userInfoModify = [[UserInfoModifyViewController alloc] init];
                userInfoModify.titleCtl = @"邮箱";
                userInfoModify.fieldString = @"email";
                userInfoModify.content = [self.userInfoDic objectForKey:@"email"];
                [self.navigationController pushViewController:userInfoModify animated:YES];
                RELEASE_SAFE(userInfoModify);
            }
            break;
        case 2: //详细信息
            switch (indexPath.row) {
                case 0:
                {
                    //兴趣
                    UserInfoModifyViewController *userInfoModify = [[UserInfoModifyViewController alloc] init];
                    userInfoModify.titleCtl = @"兴趣";
                    userInfoModify.fieldString = @"interests";
                    userInfoModify.content = [self.userInfoDic objectForKey:@"interests"];
                    [self.navigationController pushViewController:userInfoModify animated:YES];
                    RELEASE_SAFE(userInfoModify);
                }
                    break;
                case 1:
                {
                    //行业
                    IndustryViewController *industyVc = [[IndustryViewController alloc] init];
                    industyVc.fieldString = @"industry";//@"level";
                    [self.navigationController pushViewController:industyVc animated:YES];
                    RELEASE_SAFE(industyVc);
                   
                }
                    break;
                case 2:
                {
                    //家乡
                    AreaListViewController *areaList = [[AreaListViewController alloc] init];
                    [self.navigationController pushViewController:areaList animated:YES];
                    RELEASE_SAFE(areaList);
                }
                    break;
                case 3:
                {
                    //学校
                    UserInfoModifyViewController *userInfoModify = [[UserInfoModifyViewController alloc] init];
                    userInfoModify.titleCtl = @"学校";
                    userInfoModify.content = [self.userInfoDic objectForKey:@"school"];
                    userInfoModify.fieldString = @"school";
                    [self.navigationController pushViewController:userInfoModify animated:YES];
                    RELEASE_SAFE(userInfoModify);
                }
                    break;
                case 4:
                {
                    //生日
                    BirthdayViewController *birthDayVc = [[BirthdayViewController alloc] init];
                    birthDayVc.secretString = [self.userInfoDic objectForKey:@"birthdayShield"];
                    birthDayVc.dateString = [NSString stringWithFormat:@"%@",[self.userInfoDic objectForKey:@"birthday"]];
                    [self.navigationController pushViewController:birthDayVc animated:YES];
                    RELEASE_SAFE(birthDayVc);
                }
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;

    }}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (IOS7_OR_LATER) {
        return 1.0;
    } else {
        return 20.0;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    sectionView.backgroundColor = RGBACOLOR(249, 249, 249, 1);
    
    UILabel *titleLable = [[UILabel alloc]init];
    if (IOS7_OR_LATER) {
        titleLable.frame = CGRectMake(15, 5, ScreenWidth, 15);
    } else {
        titleLable.frame = CGRectMake(15, 6, ScreenWidth, 15);
    }
    titleLable.font = [UIFont systemFontOfSize:12.0];
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.textColor = RGBACOLOR(136, 136, 136, 1);
    [sectionView addSubview:titleLable];
    [titleLable release];
    
    if (section == 0) {
        titleLable.text = @"联系方式";
    } else if (section == 1) {
        titleLable.text = @"详细信息";
    }
    
    return [sectionView autorelease];
}

#pragma mark --  UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:{
            NSLog(@"相机");
            [self showWaterCamera];
        }
            break;
        case 1:{
            UIImagePickerController *pickController = [[UIImagePickerController alloc]init];
            pickController.allowsEditing = YES;
            pickController.delegate = self;
            pickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:pickController animated:YES completion:^{}];
            [pickController release];
        }
            break;
        
        default:
            break;
    }
}

//水印相机
-(void) showWaterCamera{
    BOOL canUseCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    if (canUseCamera) {
        UIImagePickerController * imageCamera = [[UIImagePickerController alloc]init];
        imageCamera.allowsEditing = YES;
        imageCamera.delegate = self;
        imageCamera.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imageCamera animated:YES completion:nil];
        [imageCamera release];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"设备未被允许使用相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - waterCameraDelegate
-(void) didSelectImages:(NSArray *)images{
    if (images.count) {
        [self upLoadImage:UIImageJPEGRepresentation(images[0], 0.05)];
    }
}

#pragma mark --UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{

    [self upLoadImage:UIImageJPEGRepresentation(image, 0.05)];
//    [self upLoadImage:image];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    _editHeaderView.iconImage.image = image;
    
    [self upLoadImage:UIImageJPEGRepresentation(image, 0.05)];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- 各种点击事件
//照相上传
-(void) upLoadImage:(NSData *)imageData {
    [self hideHudView];
    hudView = [CommonProgressHUD showMBProgressHud:self SuperView:self.view Msg:@"请稍候..."];
    
    SnailRequestPostObject * postObject = [[SnailRequestPostObject alloc]init];
    postObject.postData = imageData;
    postObject.requestInterface = [MYSELF_UPLOAD_USERICON stringByReplacingOccurrencesOfString:@"{orgUserId}" withString:[NSString stringWithFormat:@"%@",[UserModel shareUser].orgUserId]];
    postObject.command = LinkedBe_MYSELF_UPLOAD_USERICON;
    [[SnailNetWorkManager shareManager] sendHttpRequest:postObject fromDelegate:self andParam:nil];
    RELEASE_SAFE(postObject);
}

-(void)tapEditHeaderView {
    UIActionSheet *sheetView = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消"destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册选择", nil];
    [sheetView showInView:[UIApplication sharedApplication].keyWindow];
    [sheetView release];
}

//右导航栏点击按钮
//- (void)rightBtnClick {
//    NSLog(@"保存");
//}

//返回按钮
-(void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) hideHudView
{
    if (hudView) {
        [hudView hide:YES];
    }
}
#pragma mark - HttpRequestDelegate
- (void)didFinishCommand:(NSDictionary *)jsonDic cmd:(LinkedBe_WInterface)commandid withVersion:(int)ver andParam:(NSMutableDictionary *)param{
    [self hideHudView];
    if (jsonDic) {
        if (commandid == LinkedBe_MYSELF_UPLOAD_USERICON) {
        
            [_editHeaderView.iconImage setImageWithURL:[NSURL URLWithString:[jsonDic objectForKey:@"portrait"]]];

            // 修改成功以后更换当前数据库里面的内容
            Userinfo_model *userInfoModel = [[Userinfo_model alloc]init];
            NSString *dicString = [[[userInfoModel getList] firstObject] objectForKey:@"content"];
            
            NSMutableDictionary *dic = [dicString JSONValue];
            [dic setObject:[jsonDic objectForKey:@"portrait"] forKey:@"portrait"];
            
            userInfoModel.where = [NSString stringWithFormat:@"orgUserId = %d",[[[dicString JSONValue] objectForKey:@"orgUserId"] intValue]];
            
            //booky更改用户头像数据
            NSDictionary* porDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [[dicString JSONValue] objectForKey:@"userId"],@"userId",
                                    [jsonDic objectForKey:@"portrait"],@"portrait",
                                    nil];
            
            [Circle_member_model updatePortraitWithDic:porDic];
            
            // 个人信息
            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [[dicString JSONValue] objectForKey:@"orgUserId"],@"orgUserId",
                                     [dic JSONRepresentation],@"content",
                                     nil];
            NSArray *userArray = [userInfoModel getList];
            if ([userArray count] > 0) {
                [userInfoModel updateDB:userDic];
            } else {
                [userInfoModel insertDB:userDic];
            }
            [userInfoModel release];
        }
    }
}

@end
