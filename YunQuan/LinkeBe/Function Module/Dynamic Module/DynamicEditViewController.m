//
//  DynamicEditViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "DynamicEditViewController.h"
#import "QBImagePickerController.h"

#import "UIViewController+NavigationBar.h"

#import "PreviewImageViewController.h"
#import "WatermarkCameraViewController.h"

#import "SetPlaceViewController.h"
#import "AssignCircleViewController.h"

#import "DynamicEditManager.h"

#import "SDImageCache.h"
#import "MBProgressHUD.h"

#import "upLoadPicManager.h"

#import "Cicle_org_model.h"
#import "AppDelegate.h"

#import "UIImage+FixOrientation.h"
#import "NSString+emoji.h"
#import "MobClick.h"

#define MAXIMGCOUNT 6//图片最大数目
#define IMGMARGIN   2.0//图片间隔

#define IMAGEHEIGHT 70.0//图片高度
#define TEXTHEIGHT  80.0//文本框高度
#define SPACE   10.0//间隔
#define CELLHEIGHT  40.0//cell高度
#define STATEANDTIMEHEIGHT  45.0//时间地点选择框高度
#define PICSPACE    7.0//图片间隔

#define TOGETHERTEXT    @"发起聚聚..."
#define PICTEXT     @"快乐源于分享..."
#define WANTTEXT    @"发布我要..."
#define HAVETEXT    @"发布我有..."

#define PLACEHOLDERBTNTAG   1000
#define IMGFIRSTTAG     2000
#define TOGETHERTAG     3000

@interface DynamicEditViewController ()<UITextViewDelegate,QBImagePickerControllerDelegate,UIScrollViewDelegate,UIActionSheetDelegate,previewImageViewControllerDelegate,WatermarkCameraViewControllerDelegate,DynamicEditDelegate,SetPlaceDelegate,AssignCircleDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    //文本框默认文本
    NSString* placeHolderText;
    //地点
    NSString* placeStr;
    //开始时间
    NSString* startTimeStr;
    //结束时间
    NSString* endTimeStr;
    
    UIDatePicker* datePicker;
    
    UIToolbar* contraitV;
    
    MBProgressHUD* hud;
    
    UIScrollView* wholeScrollView;//整个容器，在超出屏幕时可滑动
    UIView* picsView;//图片容器
    UITextView* contenTextV;//文本框
    UIView* togetherView;//110
    UIView* upPartView;//上半部容器
    UIView* dwonPartView;//下半部容器
    
    UILabel* stateLAB;//设置城市
    UILabel* placeLAB;//设置地点
    UILabel* timeLAB;//设置时间
    UILabel* rangLAB;//设置范围
    UIButton* publishButton;//发布按钮
    
    BOOL isDelete;//是否删除
    
    UIButton* toolBarRightBtn;
    UILabel* toolBarTimeLAB;
    
    NSArray* rangArr;
}

@property(nonatomic,retain) NSMutableArray *selectedImages; //总共选择的照片数组
@property(nonatomic,retain) NSArray *previousSelectedImages;//上一次选择的照片数组
@property(nonatomic,retain) NSMutableDictionary* paraDic;//发动态需要传递的参数字典

@end

@implementation DynamicEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [MobClick beginLogPageView:@"DynamicEditViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"DynamicEditViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = YES;
    }
    
    self.view.backgroundColor = BACKGROUNDCOLOR;
    
    _selectedImages = [[NSMutableArray alloc] init];
    _paraDic = [[NSMutableDictionary alloc] init];
    
    placeHolderText = [self getPlcaeHolderStr];
    
    self.title = [self getTitleStr];
    
    [self initNavBar];
    
    [self initMainUI];
	// Do any additional setup after loading the view.
}

//title
-(NSString*) getTitleStr{
    NSString* str = nil;
    switch (_type) {
        case DynamicTypePic:
            str = @"图文动态";
            break;
        case DynamicTypeTogether:
            str = @"聚聚动态";
            break;
        case DynamicTypeHave:
            str = @"我有动态";
            break;
        case DynamicTypeWant:
            str = @"我要动态";
            break;
        default:
            break;
    }
    
    return str;
}

//获取文本框默认文本
-(NSString*) getPlcaeHolderStr{
    NSString* str = nil;
    switch (_type) {
        case DynamicTypePic:
            str = PICTEXT;
            break;
        case DynamicTypeTogether:
            str = TOGETHERTEXT;
            break;
        case DynamicTypeHave:
            str = HAVETEXT;
            break;
        case DynamicTypeWant:
            str = WANTTEXT;
            break;
        default:
            break;
    }
    return str;
}

//5+文本＋5+图片＋10+时间＋地点＋10     ＋10     40+40
//导航栏
-(void) initNavBar{
    //返回
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(publishBack) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
    
    //发布
    publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    publishButton.frame = CGRectMake(0, 0, 50, 30);
    [publishButton setTitle:@"发布" forState:UIControlStateNormal];
    [publishButton setTitleColor:DARKCOLOR forState:UIControlStateNormal];
    publishButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [publishButton addTarget:self action:@selector(publishClick) forControlEvents:UIControlEventTouchUpInside];
    publishButton.enabled = NO;
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:publishButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem release];
}

#pragma mark - 发布
-(void) publishClick{
    [MobClick event:@"feed_add_btn_click"];
    
    NSString* textStr = contenTextV.text;
    if ([textStr isEqualToString:placeHolderText]) {
        textStr = @"";
    }else{
        textStr = [textStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    //检测字数
    NSString* publishStr = textStr;
    if ([publishStr length] > 140) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"文本字数不要超过140" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    if ([publishStr length] == 0) {
        //除图文可以不发文本外，其他类型都要发文本
        if (_selectedImages.count == 0 || _type != DynamicTypePic) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"说点什么吧..." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            
            return;
        }
    }
    
    //聚聚时检测时间和地址
    if (_type == DynamicTypeTogether) {
        if ([publishStr length] == 0) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"说点什么吧..." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            
            return;
        }
        
        if ([timeLAB.text isEqualToString:@"设置时间"]) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请设置聚聚时间" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            
            return;
        }
        
        if ([placeLAB.text isEqualToString:@"设置地点"]) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请设置聚聚地点" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            
            return;
        }
    }
    
    //org_user_id
    //org_id
    [_paraDic setObject:[UserModel shareUser].orgUserId forKey:@"orgUserId"];
    [_paraDic setObject:[UserModel shareUser].org_id forKey:@"orgId"];
    [_paraDic setObject:[UserModel shareUser].user_id forKey:@"userId"];
    
    //type
    int ptype = 0;
    switch (_type) {
        case DynamicTypePic:
            ptype = 1;
            break;
        case DynamicTypeTogether:
            ptype = 8;
            break;
        case DynamicTypeHave:
            ptype = 3;
            break;
        case DynamicTypeWant:
            ptype = 4;
            break;
        default:
            break;
    }
    [_paraDic setObject:[NSNumber numberWithInt:ptype] forKey:@"type"];
    
    //title
    NSString* title = [Common placeEmoji:textStr];
//    [_paraDic setObject:title forKey:@"title"];
    [_paraDic setObject:title forKey:@"content"];
    
    //city
//    AppDelegate* appde = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    NSString* city = appde.city;
//    if (city) {
//        [_paraDic setObject:city forKey:@"city"];
//    }
    
    //可见组织
    NSString* seeOrgIds = nil;
    if (rangArr) {
        for (NSDictionary* dic in rangArr) {
            if (seeOrgIds == nil) {
                seeOrgIds = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"id"] intValue]];
            }else{
                seeOrgIds = [seeOrgIds stringByAppendingString:[NSString stringWithFormat:@",%d",[[dic objectForKey:@"id"] intValue]]];
            }
        }
    }
    if (seeOrgIds) {
        [_paraDic setObject:seeOrgIds forKey:@"seeOrgIds"];
    }
    
    if (_type == DynamicTypeTogether) {
        //开始时间
        long long startTime = [Common timeIntervalFromString:startTimeStr andFormat:@"YYYY/MM/dd HH:mm"];
        [_paraDic setObject:[self longTimeToTimeStamp:startTime] forKey:@"startTime"];
        
        //结束时间
        long long endTime = [Common timeIntervalFromString:endTimeStr andFormat:@"YYYY/MM/dd HH:mm"];
        [_paraDic setObject:[self longTimeToTimeStamp:endTime] forKey:@"endTime"];
        
        //聚聚地点
//        NSString* location = placeStr;
        NSString* location = [Common placeEmoji:placeStr];
        [_paraDic setObject:location forKey:@"location"];
    }
    
    [self showProgress];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self publishIntoServer];
    });
    
}

//聚聚时间格式转2014-09-28 11:21:54
-(NSString*) longTimeToTimeStamp:(long long) times{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    NSString* timeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:times]];
    [formatter release];
    
    return timeStr;
}

#pragma mark - alertview
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 返回
- (void)publishBack{
    if ((![contenTextV.text isEqualToString:placeHolderText] && [contenTextV.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) || _selectedImages.count) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"确定要放弃发布此动态吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        [alertView release];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//wholeScroll
-(void) initWholeScroll{
    wholeScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    wholeScrollView.delegate = self;
    wholeScrollView.showsVerticalScrollIndicator = NO;
    wholeScrollView.showsHorizontalScrollIndicator = NO;
    wholeScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:wholeScrollView];
    
    [wholeScrollView setContentSize:CGSizeMake(ScreenWidth, ScreenHeight - 64)];
}

//视图布局
-(void) initMainUI{
    [self initWholeScroll];
    
    //上部
    upPartView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 180)];
    upPartView.backgroundColor = [UIColor whiteColor];
    [wholeScrollView addSubview:upPartView];
    
    //文本框
    contenTextV = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, ScreenWidth - 10*2, TEXTHEIGHT)];
    contenTextV.delegate = self;
    contenTextV.text = placeHolderText;
    contenTextV.font = [UIFont systemFontOfSize:14];
//    contenTextV.textColor = RGBACOLOR(204, 204, 204, 1);
    contenTextV.textColor = RGBACOLOR(0, 0, 0, 1);
    contenTextV.backgroundColor = [UIColor clearColor];
    [wholeScrollView addSubview:contenTextV];
    
    //图片容器
    picsView = [[UIView alloc] initWithFrame:CGRectMake((ScreenWidth - IMAGEHEIGHT*4 - 10)/2, CGRectGetMaxY(contenTextV.frame) + 20, IMAGEHEIGHT*4 + 10, IMAGEHEIGHT)];
    picsView.backgroundColor = [UIColor clearColor];
    [wholeScrollView addSubview:picsView];
    
    if (_type == DynamicTypeTogether) {
        //聚聚选框
        togetherView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(picsView.frame), ScreenWidth, 110)];
        togetherView.backgroundColor = [UIColor clearColor];
        [wholeScrollView addSubview:togetherView];
        
        //添加时间地点选项
        UIImageView* timeIMGV = [[UIImageView alloc] init];
        timeIMGV.userInteractionEnabled = YES;
        timeIMGV.tag = 1;
        timeIMGV.frame = CGRectMake(10, 5, ScreenWidth - 10*2, 45);
        UIImage* timg = IMGREADFILE(DynamicPic_publish_time);
        timeIMGV.image = [timg stretchableImageWithLeftCapWidth:50 topCapHeight:0];
        [togetherView addSubview:timeIMGV];
        
        //lab
        timeLAB = [[UILabel alloc] init];
        timeLAB.frame = CGRectMake(60, 0, 200, CGRectGetHeight(timeIMGV.frame));
        timeLAB.backgroundColor = [UIColor clearColor];
        timeLAB.font = [UIFont systemFontOfSize:14];
        timeLAB.textColor = DynamicCardTextColor;
        timeLAB.text = @"设置时间";
        [timeIMGV addSubview:timeLAB];
        
        //向下
        UIImageView* downIMGV = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(timeIMGV.frame) - 45, 0, 45, 45)];
        downIMGV.image = IMGREADFILE(DynamicPic_publish_more);
        [timeIMGV addSubview:downIMGV];
        [downIMGV release];
        
        //添加点击
        UITapGestureRecognizer* ttap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stateAndTimeTouch:)];
        [timeIMGV addGestureRecognizer:ttap];
        [ttap release];
        
        //添加时间地点选项
        UIImageView* stateIMGV = [[UIImageView alloc] init];
        stateIMGV.userInteractionEnabled = YES;
        stateIMGV.tag = 2;
        stateIMGV.frame = CGRectMake(10, 5 + CGRectGetMaxY(timeIMGV.frame), ScreenWidth - 10*2, 45);
        UIImage* simg = IMGREADFILE(DynamicPic_publish_map);
        stateIMGV.image = [simg stretchableImageWithLeftCapWidth:50 topCapHeight:0];
        [togetherView addSubview:stateIMGV];
        
        //lab
        placeLAB = [[UILabel alloc] init];
        placeLAB.frame = CGRectMake(60, 0, 200, CGRectGetHeight(timeIMGV.frame));
        placeLAB.backgroundColor = [UIColor clearColor];
        placeLAB.font = [UIFont systemFontOfSize:14];
        placeLAB.textColor = DynamicCardTextColor;
        placeLAB.text = @"设置地点";
        [stateIMGV addSubview:placeLAB];
        
        //向下
        UIImageView* sdownIMGV = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(stateIMGV.frame) - 45, 0, 45, 45)];
        sdownIMGV.image = IMGREADFILE(DynamicPic_publish_more);
        [stateIMGV addSubview:sdownIMGV];
        [sdownIMGV release];
        
        //添加点击
        UITapGestureRecognizer* stap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stateAndTimeTouch:)];
        [stateIMGV addGestureRecognizer:stap];
        [stap release];
        
        [timeIMGV release];
        [stateIMGV release];
        
        //设置upview高度
        upPartView.frame = CGRectMake(0, 0, ScreenWidth, CGRectGetHeight(upPartView.frame) + CGRectGetHeight(togetherView.frame));
    }
    
    //下部
    dwonPartView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(upPartView.frame) + 10, ScreenWidth, 40)];
    dwonPartView.backgroundColor = [UIColor whiteColor];
    [wholeScrollView addSubview:dwonPartView];
    
    UIImageView* stateImageV = [[UIImageView alloc] init];
    stateImageV.frame = CGRectMake(10, 7.5, 25, 25);
    stateImageV.image = IMGREADFILE(DynamicPic_publish_state);
    [dwonPartView addSubview:stateImageV];
    
    //是否开启定位，没有则关闭，有则打开并展示出城市信息
    AppDelegate* appde = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    stateLAB = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(stateImageV.frame) + 10, 7.5, ScreenWidth - 70 - 45, 25)];
    stateLAB.textColor = DynamicCardTextColor;
    stateLAB.font = [UIFont systemFontOfSize:14];
    
    
    if (appde.isLoction) {
        stateLAB.text = appde.city;
    }else{
        stateLAB.text = @"所在城市";
    }
    
    stateLAB.backgroundColor = [UIColor clearColor];
    [dwonPartView addSubview:stateLAB];
    
    UISwitch* sw = [[UISwitch alloc] init];
    sw.frame = CGRectMake(CGRectGetMaxX(stateLAB.frame) + 5, 5, 80, 30);
    if (!IOS7_OR_LATER) {
        sw.frame = CGRectMake(CGRectGetMaxX(stateLAB.frame)-12, 5, 80, 30);
    }
    if (appde.isLoction) {
        sw.on = YES;
        [_paraDic setObject:appde.city forKey:@"city"];
    }else{
        sw.on = NO;
    }
    
    [sw addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventTouchUpInside];
    [dwonPartView addSubview:sw];
    [sw release];
    
    ////////    只有一级组织的时候隐藏         ////////
    Cicle_org_model* orgModel = [[Cicle_org_model alloc] init];
    orgModel.where = [NSString stringWithFormat:@"parentId != %d",0];
    NSArray* arr = [orgModel getList];
    [orgModel release];
    
//    if (arr.count) {
    if (0) {
        //直线
        UIImage *lineImg1 = [UIImage imageNamed:@"img_group_underline.png"];
        UIImageView* lineImage1 = [[UIImageView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(stateImageV.frame) + 7 + 0.2, ScreenWidth - 20, 0.2)];
        lineImage1.image = lineImg1;
        [dwonPartView addSubview:lineImage1];
        [lineImage1 release];
        
        UIImageView* rangeImageV = [[UIImageView alloc] init];
        rangeImageV.frame = CGRectMake(10, 15 + CGRectGetMaxY(stateImageV.frame), 25, 25);
        rangeImageV.image = IMGREADFILE(DynamicPic_publish_people);
        [dwonPartView addSubview:rangeImageV];
        
        rangLAB = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(rangeImageV.frame) + 10, 47.5, ScreenWidth - 90, 25)];
        rangLAB.textColor = DynamicCardTextColor;
        rangLAB.font = [UIFont systemFontOfSize:14];
        rangLAB.text = @"全部成员";
        rangLAB.backgroundColor = [UIColor clearColor];
        rangLAB.userInteractionEnabled = YES;
        [dwonPartView addSubview:rangLAB];
        
        UIImageView* rangeAccImgV = [[UIImageView alloc] init];
        rangeAccImgV.frame = CGRectMake(ScreenWidth - 10 - 20, 50, 20, 20);
        rangeAccImgV.image = IMGREADFILE(DynamicPic_publish_arrow);
        [dwonPartView addSubview:rangeAccImgV];
        
        //添加点击
        UITapGestureRecognizer* ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rangTouch:)];
        [rangLAB addGestureRecognizer:ges];
        [ges release];
        
        [rangeImageV release];
        [rangeAccImgV release];
        
        dwonPartView.frame = CGRectMake(0, CGRectGetMaxY(upPartView.frame) + 10, ScreenWidth, 80);
    }
    ////////     只有一级组织的时候隐藏         ////////
    
    [stateImageV release];
    
    //填充图片
    [self fillImage];
    
}

#pragma mark - 设置时间
-(void) stateAndTimeTouch:(UIGestureRecognizer*) ges{
    UIView* view = ges.view;
    int tag = view.tag;
    switch (tag) {
        case 1:
        {
            //选择时间
            [self choiceTime];
        }
            break;
        case 2:
        {
            //选择地点
            [self choicePlace];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 指定范围
-(void) rangTouch:(UIGestureRecognizer*) ges{
    AssignCircleViewController* assignVC = [[AssignCircleViewController alloc] init];
    assignVC.delegate = self;
    assignVC.selectArr = rangArr;
    [self.navigationController pushViewController:assignVC animated:YES];
}

#pragma mark - 指定范围回调
-(void) sureCallBack:(NSArray *)arr{
    //解析指定圈子
    rangArr = [arr copy];
    NSString* str = nil;
    
    for (NSDictionary* dic in rangArr) {
        if (str == nil) {
            str = [dic objectForKey:@"name"];
        }else{
            str = [str stringByAppendingString:[NSString stringWithFormat:@",%@",[dic objectForKey:@"name"]]];
        }
    }
    if (str == nil) {
        rangLAB.text = @"全体成员";
    }else{
        rangLAB.text = str;
    }
    
}

//switch相应
-(void) switchClick:(id) sender{
    [MobClick event:@"feed_publish_location_off"];
    
    UISwitch* sw = (UISwitch*)sender;
    
    AppDelegate* appde = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    //是否开启定位
    if (appde.isLoction) {
        
        if (sw.on) {
            stateLAB.text = appde.city;
            [_paraDic setObject:appde.city forKey:@"city"];
        }else{
            stateLAB.text = @"所在城市";
            [_paraDic removeObjectForKey:@"city"];
        }
        
    }else{
        
        sw.on = NO;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位失败" message:@"请在“设置”->“定位服务”中确认“定位”和“云圈”是否为开启状态！" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

//向图片容器中加入imageview
-(void) addImageViewInPicsView{
    [self fillImage];
    
}

//键盘弹起遮罩button
-(void) addPlaceHolderButton{
    UIButton* holerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    holerBtn.backgroundColor = [UIColor clearColor];
    holerBtn.tag = PLACEHOLDERBTNTAG;
    holerBtn.frame = CGRectMake(0, CGRectGetMinY(picsView.frame), ScreenWidth, ScreenHeight - 64 - TEXTHEIGHT - 216 - 40);
    [holerBtn addTarget:self action:@selector(btnHideKeyBord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:holerBtn];
}

-(void) btnHideKeyBord{
    [contenTextV resignFirstResponder];
    if (_type == DynamicTypeTogether) {
        //timepicker隐藏
    }
    
    //移除键盘
    UIButton* btn = (UIButton*)[self.view viewWithTag:PLACEHOLDERBTNTAG];
    if (btn) {
        [btn removeFromSuperview];
    }
}

#pragma mark - textviewdelegate
-(void) textViewDidBeginEditing:(UITextView *)textView{
    [self addPlaceHolderButton];
    if ([textView.text isEqualToString:placeHolderText]) {
        textView.text = @"";
    }
}

-(void) textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        textView.text = placeHolderText;
    }else{
        publishButton.enabled = YES;
        [publishButton setTitleColor:BLUECOLOR forState:UIControlStateNormal];
    }
    UIButton* btn = (UIButton*)[self.view viewWithTag:PLACEHOLDERBTNTAG];
    [btn removeFromSuperview];
}

-(BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    if ([Common isEmoji:text]) {
//        return NO;
//    }
    
    if ([[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 140) {
        textView.text = [textView.text substringToIndex:140];
    }
    
    if (range.location) {
        publishButton.enabled = YES;
        [publishButton setTitleColor:BLUECOLOR forState:UIControlStateNormal];
    }else{
        publishButton.enabled = NO;
        [publishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if ([text isEqualToString:@"\n"]) {
        [contenTextV resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - 图片相关操作
//--------------选择图片或水印照片------------------
-(void)addImagePlaceHolder
{
    //发布按钮状态变化
    NSString* textStr = [contenTextV.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (([textStr length] > 0 && ![contenTextV.text isEqualToString:placeHolderText]) || _selectedImages.count) {
        publishButton.enabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [publishButton setTitleColor:BLUECOLOR forState:UIControlStateNormal];
    }else{
        publishButton.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [publishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if(self.selectedImages.count <= MAXIMGCOUNT)
    {
        int temp = 0;
        if(_selectedImages.count == 0)
        {
            temp = 0;
        }
        else if(_selectedImages.count > 0 && isDelete == NO)
        {
            temp = _previousSelectedImages.count + 1;
        }
        else
        {
            temp = 0;
        }
        for (int i = temp; i <= _selectedImages.count; i++)
        {
            //达到最大图片数后，停止创建
            if(i == MAXIMGCOUNT)
            {
                break;
            }
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(IMGMARGIN + (IMGMARGIN + IMAGEHEIGHT) * (i%4), IMGMARGIN + (IMGMARGIN + IMAGEHEIGHT) * (i/4), IMAGEHEIGHT - 1, IMAGEHEIGHT - 1)];
            imageView.userInteractionEnabled = YES;
            imageView.layer.borderColor = DynamicCardTextColor.CGColor;
            imageView.layer.borderWidth = 0.5;
            imageView.tag = i + IMGFIRSTTAG;
            [picsView addSubview:imageView];
            
            if (i == _selectedImages.count) {
                UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, IMAGEHEIGHT - 1, IMAGEHEIGHT - 1)];
                lab.text = @"添加图片";
                lab.font = KQLboldSystemFont(13);
                lab.textColor = BLUECOLOR;
                lab.textAlignment = NSTextAlignmentCenter;
                lab.backgroundColor = [UIColor clearColor];
                [imageView addSubview:lab];
                RELEASE_SAFE(lab);
                
            }
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToSelect:)];
            [imageView addGestureRecognizer:tap];
            [tap release];
            [imageView release];
        }
    }
    
    //改变布局
    picsView.frame = CGRectMake((ScreenWidth - picsView.bounds.size.width)/2, CGRectGetMaxY(contenTextV.frame), picsView.bounds.size.width, 80 * ((_selectedImages.count)/4 + 1));
    upPartView.frame = CGRectMake(0, 0, CGRectGetWidth(upPartView.frame), CGRectGetMaxY(picsView.frame));
    if (_type == DynamicTypeTogether) {
        togetherView.frame = CGRectMake(0, CGRectGetMaxY(picsView.frame), CGRectGetWidth(togetherView.frame), CGRectGetHeight(togetherView.frame));
        upPartView.frame = CGRectMake(0, 0, CGRectGetWidth(upPartView.frame), CGRectGetMaxY(picsView.frame) + CGRectGetHeight(togetherView.frame));
    }
    
    dwonPartView.frame = CGRectMake(0, CGRectGetMaxY(upPartView.frame) + 10, CGRectGetWidth(dwonPartView.frame), CGRectGetHeight(dwonPartView.frame));
    
    if (CGRectGetMaxY(dwonPartView.frame) > ScreenHeight - 64) {
        [wholeScrollView setContentSize:CGSizeMake(ScreenWidth, CGRectGetMaxY(dwonPartView.frame) + 40)];
    }
    
    [self hideDatePicker];
}

//点击图片
-(void)tapToSelect:(UITapGestureRecognizer *)tapGesture
{
    [self btnHideKeyBord];
    
    UIImageView *imgView = (UIImageView *)tapGesture.view;
    //弹出actionSheet选择图片
    if(_selectedImages.count == imgView.tag - IMGFIRSTTAG)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机",@"从相册选取", nil];
        [actionSheet showInView:self.view];
        [actionSheet release];
    }
    else
    {
        //预览图片
        PreviewImageViewController *previewController = [[PreviewImageViewController alloc]init];
        previewController.imagesArray = _selectedImages;
        previewController.chooseIndex = imgView.tag - IMGFIRSTTAG;
        previewController.delegate = self;
        
        UINavigationController *previewNav = [[UINavigationController alloc]initWithRootViewController:previewController];
        [self presentViewController:previewNav animated:YES completion:nil];
        [previewNav release];
        [previewController release];
    }
}

//预览图片回调
#pragma mark -PreviewImageViewControllerDelegate
-(void)imagesDidRemain:(NSArray *)remainImages
{
    isDelete = YES;
    
    [_selectedImages removeAllObjects];
    if(remainImages != nil)
    {
        [_selectedImages addObjectsFromArray:remainImages];
    }
    self.previousSelectedImages = remainImages;
    [self deleteImage];
}

//删除图片   刷新界面
-(void)deleteImage
{
    for (UIView *view in picsView.subviews)
    {
        [view removeFromSuperview];
    }
    
    [self addImagePlaceHolder];
    
    for (int i = 0; i < _selectedImages.count; i++)
    {
        UIImageView *imageView = (UIImageView *)[picsView viewWithTag:i + IMGFIRSTTAG];
        imageView.image = [_selectedImages objectAtIndex:i];
    }
}
//------------end---------------//

#pragma mark -UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self showCameraView];
        }else{
            NSLog(@"don't support camera");
        }
        
    }
    else if (buttonIndex == 1)
    {
        [self showSelectImageView];
    }
}

//调用水印相机
-(void) showCameraView{
    [MobClick event:@"feed_publish_take_photo"];
    
//    WatermarkCameraViewController *watermarkCamera = [[WatermarkCameraViewController alloc]init];
//    watermarkCamera.type = 1;
//    watermarkCamera.currentImageCount = _selectedImages.count;
//    watermarkCamera.delegate = self;
//    [self presentViewController:watermarkCamera animated:YES completion:nil];
//    [watermarkCamera release];
    
    BOOL canUseCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    if (canUseCamera) {
        UIImagePickerController * imageCamera = [[UIImagePickerController alloc]init];
        imageCamera.editing = YES;
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

//水印相机回调
#pragma mark -watermarkCameraViewControllerDelegate
-(void)didSelectImages:(NSArray *)images
{
    NSArray *array = [_selectedImages arrayByAddingObjectsFromArray:images];
    [_selectedImages addObjectsFromArray:images];
    [self fillImage];
    self.previousSelectedImages = array;
}

//从相册选择的图片数组中提取图片
-(NSArray *)getImagesFromArray:(NSArray *)array
{
    NSMutableArray *imageList = [NSMutableArray array];
    for (NSDictionary *dic in array)
    {
        UIImage *image = [dic objectForKey:UIImagePickerControllerOriginalImage];
        [imageList addObject:image];
    }
    return imageList;
}

//选择相册照片回调
#pragma mark -QBImagePickerControllerDelegate,UIImagePickerControllerDelegate
-(void)imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    if([imagePickerController isKindOfClass:[QBImagePickerController class]])
    {
        if(imagePickerController.allowsMultipleSelection)
        {
            NSArray *mediaInfoArray = [self getImagesFromArray:info];
            NSArray *array = [_selectedImages arrayByAddingObjectsFromArray:mediaInfoArray];
            [_selectedImages addObjectsFromArray:mediaInfoArray];
            [self fillImage];
            self.previousSelectedImages = array;
        }
        [imagePickerController dismissViewControllerAnimated:YES completion:nil];
    }
    else if ([imagePickerController isKindOfClass:[UIImagePickerController class]])
    {
        UIImage* img = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage * img2 = [img fixOrientation];
        //拍照保存到相册
        UIImageWriteToSavedPhotosAlbum(img2, nil, nil, nil);
        NSArray* arr = [NSArray arrayWithObject:img2];
        NSArray *array = [_selectedImages arrayByAddingObjectsFromArray:arr];
        [_selectedImages addObjectsFromArray:arr];
        [self fillImage];
        self.previousSelectedImages = array;
        [imagePickerController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

//选择本地图片
-(void)showSelectImageView
{
    [MobClick event:@"feed_publish_pick_image"];
    
    QBImagePickerController *imagePicker = [[QBImagePickerController alloc]init];
    imagePicker.showsCancelButton = YES;
    imagePicker.filterType = QBImagePickerFilterTypeAllPhotos;
    imagePicker.fullScreenLayoutEnabled = YES;
    imagePicker.allowsMultipleSelection = YES;
    imagePicker.limitsMaximumNumberOfSelection = YES;
    imagePicker.maximumNumberOfSelection = MAXIMGCOUNT - _selectedImages.count;
    imagePicker.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:imagePicker];
    [self presentViewController:nav animated:YES completion:nil];
    [nav release];
    [imagePicker release];
}

//添加选择图片框
-(void)fillImage
{
    NSLog(@"--selectedImages:%@--",_selectedImages);
    
    [self addImagePlaceHolder];
    
    int count = 0;
    if(_selectedImages.count == 0)
    {
        count = 1;
    }
    else
    {
        count = _selectedImages.count;
    }
    
    if(_selectedImages.count > 0)
    {
        for (int i = _previousSelectedImages.count; i < count; i++)
        {
            UIImageView *imageView = (UIImageView *)[picsView viewWithTag:i + IMGFIRSTTAG];
            
            UIImage *image = [_selectedImages objectAtIndex:i];
//            imageView.image = [image fillSize:CGSizeMake(IMAGEHEIGHT, IMAGEHEIGHT)];
            imageView.image = image;
            
            for (UILabel* lab in imageView.subviews) {
                [lab removeFromSuperview];
            }
        }
    }
}
////////////////-------------///////////////////////////

#pragma mark - 设置地点
-(void) setOpenTimePlace:(NSString *)str{
    if (str && str.length) {
        placeStr = [str copy];
        placeLAB.text = placeStr;
        
    }
}

#pragma mark - 聚聚
///////////---------聚聚-----------/////////////////

-(void) choicePlace{
    [self hideDatePicker];
    
    SetPlaceViewController* placeVC = [[SetPlaceViewController alloc] init];
    placeVC.delegate = self;
    if (placeStr) {
        placeVC.placeStr = placeStr;
    }
    
    UINavigationController* crnav = [[UINavigationController alloc] initWithRootViewController:placeVC];
    [self presentViewController:crnav animated:YES completion:nil];
    
    [placeVC release];
    [crnav release];
    
}

-(void) choiceTime{
    if (datePicker == nil) {
        
        contraitV = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 40)];
        contraitV.backgroundColor = [UIColor clearColor];
        
        toolBarTimeLAB = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
        toolBarTimeLAB.textColor = [UIColor redColor];
        toolBarTimeLAB.backgroundColor = [UIColor clearColor];
        toolBarTimeLAB.textAlignment = NSTextAlignmentCenter;
        toolBarTimeLAB.tag = 3002;
        toolBarTimeLAB.userInteractionEnabled = YES;
        [contraitV addSubview:toolBarTimeLAB];
        
        toolBarRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        toolBarRightBtn.backgroundColor = [UIColor clearColor];
        toolBarRightBtn.frame = CGRectMake(240, 0, 80, 40);
        toolBarRightBtn.tag = 3004;
        [toolBarRightBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [toolBarRightBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [toolBarRightBtn addTarget:self action:@selector(endButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [contraitV addSubview:toolBarRightBtn];
        
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height + 20, self.view.bounds.size.width - 40, 0)];
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        [datePicker addTarget:self action:@selector(dateDidChange) forControlEvents:UIControlEventValueChanged];
        datePicker.date = [NSDate date];
        datePicker.tag = 3000;
        datePicker.backgroundColor = [UIColor whiteColor];
        
        UIButton* placeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        placeButton.backgroundColor = [UIColor clearColor];
        [placeButton addTarget:self action:@selector(placeButtonClick) forControlEvents:UIControlEventTouchUpInside];
        placeButton.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 256 - 44);
        placeButton.tag = 999;
        [self.view addSubview:placeButton];
        
        toolBarTimeLAB.text = [Common makeTime:[datePicker.date timeIntervalSince1970] withFormat:@"YYYY/MM/dd HH:mm"];
        
        [Common checkProgressHUDShowInAppKeyWindow:@"请设置开始时间" andImage:nil];
    }
    
    [self.view addSubview:contraitV];
    [self.view addSubview:datePicker];
    
    [UIView animateWithDuration:0.3 animations:^{
        UIButton* btn = (UIButton*)[self.view viewWithTag:999];
        btn.hidden = NO;
        
        contraitV.frame = CGRectMake(0, self.view.bounds.size.height - 256, self.view.bounds.size.width, 40);
        datePicker.frame = CGRectMake(0, self.view.bounds.size.height - 216, 0, 0);
        
        wholeScrollView.frame = CGRectMake(0, - 246 + ScreenHeight - 44 - CGRectGetMaxY(togetherView.frame), ScreenWidth, ScreenHeight - 44);
    }];
}

-(void) placeButtonClick{
    [self hideDatePicker];
}

-(void) endButtonClick:(UIButton*) btn{
    if (btn.tag == 3004) {
        long long startInt = [Common timeIntervalFromString:startTimeStr andFormat:@"YYYY/MM/dd HH:mm"];
        long long nowInt = [[NSDate date] timeIntervalSince1970];
        if (startInt < nowInt) {
            [Common checkProgressHUDShowInAppKeyWindow:@"开始时间不能小于当前时间" andImage:nil];
            return;
        }
        
        toolBarTimeLAB.text = startTimeStr;
        [toolBarRightBtn setTitle:@"确定" forState:UIControlStateNormal];
        
        toolBarTimeLAB.tag = 3001;
        toolBarRightBtn.tag = 3003;
        
        [Common checkProgressHUDShowInAppKeyWindow:@"请设置结束时间" andImage:nil];
        
    }else if (btn.tag == 3003) {
        long long startInt = [Common timeIntervalFromString:startTimeStr andFormat:@"YYYY/MM/dd HH:mm"];
        long long endInt = [Common timeIntervalFromString:endTimeStr andFormat:@"YYYY/MM/dd HH:mm"];
        if (startInt < endInt) {
            timeLAB.text = [NSString stringWithFormat:@"%@ -- %@",[startTimeStr substringFromIndex:5],[endTimeStr substringFromIndex:5]];
            
            [self hideDatePicker];
        }else{
            [Common checkProgressHUDShowInAppKeyWindow:@"您设置的聚聚时间不合适" andImage:nil];
        }
        
    }
}

-(void) hideDatePicker{
    
    [UIView animateWithDuration:0.3 animations:^{
        UIButton* btn = (UIButton*)[self.view viewWithTag:999];
        [btn removeFromSuperview];
        
        wholeScrollView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 44);
        
        contraitV.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 40);
        datePicker.frame = CGRectMake(0, self.view.bounds.size.height + 20, 0, 0);
        
    }];
    
    [contraitV removeFromSuperview];
    [datePicker removeFromSuperview];
    
    datePicker = nil;
}

-(void) dateDidChange{
    NSString* dateStr = [Common makeTime:[datePicker.date timeIntervalSince1970] withFormat:@"YYYY/MM/dd HH:mm"];
    
    if (toolBarTimeLAB.tag == 3002) {
        startTimeStr = [dateStr copy];
    }else if (toolBarTimeLAB.tag == 3001) {
        endTimeStr = [dateStr copy];
    }
    
    toolBarTimeLAB.text = dateStr;
    
}

//////////--------------------/////////////////

#pragma mark - 网络
-(void) publishIntoServer{
    
    NSMutableArray* dataArr = [NSMutableArray arrayWithCapacity:0];
    if (_selectedImages.count == 0) {
        dataArr = nil;
    }
    
    for (int i = 0;i < _selectedImages.count; i++) {
        UIImage* image = [_selectedImages objectAtIndex:i];
//        UIImage* newImage = [image fixOrientation];
//        image = nil;
        NSData* imgData = UIImageJPEGRepresentation(image, 0.1);
        [dataArr addObject:imgData];
    }
    
    DynamicEditManager* editManager = [[DynamicEditManager alloc] init];
    editManager.delegate = self;
    [editManager accessDynamicEditPublish:_paraDic dataList:dataArr];
    
}

-(void) getDynamicEditHttpCallBack:(NSArray *)arr interface:(LinkedBe_WInterface)interface{
    [self dismissProgress];
    
    if (arr.count) {
        [Common checkProgressHUDShowInAppKeyWindow:@"发布成功" andImage:nil];
        
        //有图片，缓存起来
        NSDictionary* dic = [arr firstObject];
        NSArray* picsArr = [dic objectForKey:@"images"];
        if ([picsArr count]) {
            [self cacheImage:picsArr];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        if (_delegate && [_delegate respondsToSelector:@selector(publishSuccessCallBackWith:)]) {
            [_delegate publishSuccessCallBackWith:nil];
        }
    }
}

//将发送成功的图片缓存在本地
-(void) cacheImage:(NSArray*) names{
    for (int i = 0; i < names.count; i++) {
        UIImage* image = [_selectedImages objectAtIndex:i];
        NSString* name = [names objectAtIndex:i];
        [[SDImageCache sharedImageCache] storeImage:image forKey:name toDisk:YES];
    }
}

#pragma mark - 加载框
//加载框显示
-(void) showProgress{
    hud = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    hud.labelText = @"正在发布...";
    hud.mode = MBProgressHUDModeIndeterminate;
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    [hud show:YES];
    
}
//加载框收起
-(void) dismissProgress{
    [hud hide:YES];
    [hud removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc{
    _delegate = nil;
    
    if (datePicker) {
        [datePicker release];
    }
    if (contraitV) {
        [contraitV release];
    }
    
    if (placeLAB) {
        [placeLAB release];
    }
    if (timeLAB) {
        [timeLAB release];
    }

    if (togetherView) {
        [togetherView release];
    }
    
    [stateLAB release];
    
    [rangLAB release];
    
    [picsView release];
    [contenTextV release];
    
    [upPartView release];
    [dwonPartView release];
    
    [wholeScrollView release];
    
    [_selectedImages release];
    [_paraDic release];
    
    self.previousSelectedImages = nil;
    
    datePicker = nil;
    contraitV = nil;
    placeLAB = nil;
    timeLAB = nil;
    togetherView = nil;
    
    stateLAB = nil;
    rangLAB = nil;
    
    picsView = nil;
    contenTextV = nil;
    upPartView = nil;
    dwonPartView = nil;
    wholeScrollView = nil;
    
    [super dealloc];
}

@end
