//
//  DynamicDetailViewController.m
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "DynamicDetailViewController.h"
#import "UIViewController+NavigationBar.h"

#import "CommentCell.h"
#import "DetailHeadView.h"

#import "MJRefresh.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

#import "faceView.h"
#import "HPGrowingTextView.h"
#import "emoji.h"
#import "MJRefresh.h"

#import "DynamicDetailManager.h"

#import "Dynamic_card_model.h"

#import "OthersBusinessCardViewController.h"
#import "SelfBusinessCardViewController.h"

#import "DynamicIMManager.h"
#import "MobClick.h"

#define KEYBOARD_HEIGHT 216.0f
#define KEYBOARD_DURATION 0.25f
#define KEYBOARD_CURVE 0.0f

#define kBottomViewHeight 50.0f

//删除动态alert tag
#define DELETETAG   1000
#define ISDELETED   2000

@interface DynamicDetailViewController ()<DetailHeaderDelegate,CommentCellDelegate,HPGrowingTextViewDelegate,faceViewDelegate,DynamicDetailManagerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,DynamicIMDelegate>{
    UIView *containerView;
    UIButton *faceButton;
    HPGrowingTextView *textView;
    faceView *faceKeyboardView;
    
    UIButton *backGrougBtn;
    UILabel *remainCountLabel;
    UIImageView* inputBgImgV;
    
    BOOL isChangKeyboard;
    BOOL isKeyboardDown;
    
    //    是不是回复
    BOOL isResponse;
    
    NSIndexPath* selectIndexPath;
    
    UIButton* selectButton;
    
    BOOL yesOrNo;//判断是否为当前的viewController
}

@property(nonatomic,retain) DetailHeadView* detailHeadV;

@end

@implementation DynamicDetailViewController

@synthesize detailDic = _detailDic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //注册动态删除通知
        [[DynamicIMManager shareManager] setDimDelegate:self];
        
        yesOrNo = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"DynamicDetailViewPage"];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"DynamicDetailViewPage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = YES;
    }
    
    self.title = @"动态详情";
    
    self.view.backgroundColor = BACKGROUNDCOLOR;
    
    [self initNavBar];
    
    commentArr = [[NSMutableArray alloc] init];
    
    [self initPageData];
    
    [self initTable];
    
    [self addContainerView];
    
    if (_isShowKeyBoard) {
        [textView becomeFirstResponder];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //获取评论列表
        [self accessCommentList];
        
        //更新动态详情
        [self accessDynamicDetail];
    });
	// Do any additional setup after loading the view.
}

//数据初始化
-(void) initPageData{
    pages = 1;
    pageNum = 1;
    ts = 0;
    pageSize = 20;
    totalCount = 0;

    int type = [[_detailDic objectForKey:@"type"] intValue];
    if (type == 3) {
        self.title = @"我有动态详情";
    }else if (type == 4) {
        self.title = @"我要动态详情";
    }else if (type == 8) {
        self.title = @"聚聚动态详情";
    }else{
        self.title = @"图文动态详情";
    }
    
    commentNum = [[_detailDic objectForKey:@"commentSum"] intValue] + [[_detailDic objectForKey:@"zanSum"] intValue] + [[_detailDic objectForKey:@"heheSum"] intValue];
    zanHeheSum = [[_detailDic objectForKey:@"zanSum"] intValue] + [[_detailDic objectForKey:@"heheSum"] intValue];
}

//导航栏
-(void) initNavBar{
    //返回
    UIButton *backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(detailBack) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
    
    //更多
    UIButton* moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(0, 0, 30, 30);
    [moreBtn setImage:IMGREADFILE(DynamicPic_detail_more) forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
    moreBtn.enabled = NO;
    moreBtn.hidden = YES;
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem release];
}

#pragma mark - back
-(void) detailBack{
    
    if (_delegate && [_delegate respondsToSelector:@selector(heheZanCallBack)]) {
        [_delegate heheZanCallBack];
    }
    yesOrNo = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - share
-(void) shareClick{
    
}

-(void) initTable{
    commentTable = [[UITableView alloc] init];
    commentTable.frame = CGRectMake(5, 0, ScreenWidth - 10, ScreenHeight - 64 - 50);
    commentTable.delegate = self;
    commentTable.dataSource = self;
    commentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    commentTable.showsVerticalScrollIndicator = NO;
    [self.view addSubview:commentTable];
    
    [self initHeader];
    
//    [commentTable addFooterWithTarget:self action:@selector(accessCommentList)];
//    commentTable.footerHidden = YES;
}

//初始化head
-(void) initHeader{
    if (_detailDic) {
        //headview
        DetailHeadView* detailHV = [[DetailHeadView alloc] init];
        detailHV.delegate = self;
        [detailHV writeDataInCell:_detailDic];
        self.detailHeadV = detailHV;
        [detailHV release];
        
        commentTable.tableHeaderView = self.detailHeadV;
    }
}

#pragma mark - tabledelegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (commentArr.count) {
        return commentArr.count;
    }
    return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (commentArr.count) {
        return [CommentCell getCommentCellHeightWith:[commentArr objectAtIndex:indexPath.row]];
    }
    return 80;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (commentArr.count) {
        if (indexPath.row%2 != 0) {
            cell.backgroundColor = RGBACOLOR(248, 248, 248, 1);
        }else{
            cell.backgroundColor = [UIColor clearColor];
        }
    }
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (commentArr.count) {
        static NSString* commentIden = @"commentCell";
        CommentCell* cell = [tableView dequeueReusableCellWithIdentifier:commentIden];
        if (cell == nil) {
            cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commentIden];
        }
        [cell writeCommentDataInCell:[commentArr objectAtIndex:indexPath.row]];
        
        cell.delegate = self;
        
        return cell;
        
    }else{
        static NSString* noneIden = @"noneCell";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:noneIden];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noneIden];
            
            //空视图
            UILabel* noneLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 80)];
            noneLab.text = @"虚席以待";
            noneLab.textColor = DynamicCardTextColor;
            noneLab.textAlignment = NSTextAlignmentCenter;
            noneLab.font = [UIFont systemFontOfSize:16];
            noneLab.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:noneLab];
            [noneLab release];
        }
        
        return cell;
        
    }
    
    return nil;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (commentArr.count) {
        selectIndexPath = [indexPath copy];
        
        NSDictionary* dic = [commentArr objectAtIndex:indexPath.row];
        //选中的是自己的评论，做删除操作，不是的话就做回复操作
        if ([[dic objectForKey:@"fromId"] intValue] == [[UserModel shareUser].user_id intValue]) {
            UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil, nil];
            [sheet showInView:self.view];
            [sheet release];
        }else{
            [MobClick event:@"feed_detail_reply_comment"];
            
            isResponse = YES;
            textView.placeholder = [NSString stringWithFormat:@"回复%@",[dic objectForKey:@"fromName"]];
            [self showKeyBoard];
        }
    }
    
}

#pragma mark - actionsheet
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSDictionary* dic = [commentArr objectAtIndex:selectIndexPath.row];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self accessDeleteCommentWithID:[[dic objectForKey:@"id"] intValue]];
        });
        
        //如果删除的是zan、hehe，特殊处理
        int comType = [[dic objectForKey:@"type"] intValue];
        NSMutableDictionary* newDic = [NSMutableDictionary dictionaryWithDictionary:_detailDic];
        
        if (comType == 1) {
            //zan
            [newDic setObject:[NSNumber numberWithBool:NO] forKey:@"zan"];
            [newDic setObject:[NSNumber numberWithInt:[[_detailDic objectForKey:@"zanSum"] intValue] - 1] forKey:@"zanSum"];
            
            [self.detailHeadV.optionBtn setTitle:[NSString stringWithFormat:@"%d",zanHeheSum - 1] forState:UIControlStateNormal];
            
            _detailDic = [newDic copy];
            [Dynamic_card_model insertOrUpdateDynamicCardWithDic:newDic];
            
            [self.detailHeadV updateDataWith:_detailDic];
        }else if (comType == 2) {
            //hehe
            [newDic setObject:[NSNumber numberWithBool:NO] forKey:@"hehe"];
            [newDic setObject:[NSNumber numberWithInt:[[_detailDic objectForKey:@"heheSum"] intValue] - 1] forKey:@"heheSum"];
            
            [self.detailHeadV.optionBtn setTitle:[NSString stringWithFormat:@"%d",zanHeheSum - 1] forState:UIControlStateNormal];
            
            _detailDic = [newDic copy];
            [Dynamic_card_model insertOrUpdateDynamicCardWithDic:newDic];
            
            [self.detailHeadV updateDataWith:_detailDic];
        }
        
        [commentArr removeObjectAtIndex:selectIndexPath.row];
        
        zanHeheSum -=1;
        commentNum -= 1;
        [self asynDBdata];
        
        if (commentArr.count == 0) {
            [commentTable reloadData];
        }else{
            [commentTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:selectIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

////////////-------headview代理部分--------////////////////
#pragma mark - headviewdelegate
-(void) touchHeader{
    [MobClick event:@"feed_detail_comment_portrait"];
    
    //点击跳转名片页
    if ([[_detailDic objectForKey:@"userId"] intValue] == [[UserModel shareUser].user_id intValue]) {
        SelfBusinessCardViewController *selfBusinessVC = [[SelfBusinessCardViewController alloc]init];
        [self.navigationController pushViewController:selfBusinessVC animated:YES];
        [selfBusinessVC release];
    } else {
        OthersBusinessCardViewController *otherBusinessVC = [[OthersBusinessCardViewController alloc]init];
        otherBusinessVC.orgUserId = [_detailDic objectForKey:@"orgUserId"];
        [self.navigationController pushViewController:otherBusinessVC animated:YES];
        [otherBusinessVC release];
    }
}

-(void) optionButtonClickWithType:(int)type{
    [self accessPublishComment:@"" type:type];
    
    NSMutableDictionary* newDic = [NSMutableDictionary dictionaryWithDictionary:_detailDic];
    
    if (type == 1) {
        //hehe
        [newDic setObject:[NSNumber numberWithBool:YES] forKey:@"zan"];
        [newDic setObject:[NSNumber numberWithInt:[[_detailDic objectForKey:@"zanSum"] intValue] + 1] forKey:@"zanSum"];
    }else if (type == 2) {
        //zan
        [newDic setObject:[NSNumber numberWithBool:YES] forKey:@"hehe"];
        [newDic setObject:[NSNumber numberWithInt:[[_detailDic objectForKey:@"heheSum"] intValue] + 1] forKey:@"heheSum"];
    }
    
    zanHeheSum +=1;
    
    _detailDic = [newDic copy];
    [Dynamic_card_model insertOrUpdateDynamicCardWithDic:newDic];
    
}

-(void) commentButtonClick{
    [MobClick event:@"feed_detail_add_comment"];
    
    [self showKeyBoard];
}

-(void) midImageTouch:(UIImageView *)imageV{
    [MobClick event:@"feed_detail_image_original"];
    
    NSArray* pics = [_detailDic objectForKey:@"picList"];
    
    UIView* v = imageV.superview;
    
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:[pics count]];
    for (int i = 0; i < [pics count]; i++) {
        // 替换为中等尺寸图片
        UIImageView* imageview = (UIImageView*)[v viewWithTag:i + 30000];
        
//        NSString * getImageStrUrl = [NSString stringWithFormat:@"%@", [pics objectAtIndex:i]];
        MJPhoto *photo = [[MJPhoto alloc] init];
//        photo.url = [NSURL URLWithString: getImageStrUrl]; // 图片路径
        photo.image = imageview.image;
        photo.srcImageView = imageview;
        [photos addObject:photo];
        [photo release];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = _detailHeadV.currentPage; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
    [browser release];
    browser = nil;
}

-(void) roundButtonClickWithType:(DynamicType)dyType sender:(UIButton*) sender{
//    sender.enabled = NO;
    
    if (dyType == DynamicTypeTogether) {
        //判断是不是过时
        long long endTime = [[_detailDic objectForKey:@"endTime"] longLongValue];
        long long nowTime = [[NSDate date] timeIntervalSince1970];
        if (endTime/1000 < nowTime) {
            UIAlertView* outAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"该聚聚已过时" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [outAlert show];
            [outAlert release];
            
            return;
        }
    }
    
    int tag = 0;
    selectButton = sender;
    
    NSString* name = [_detailDic objectForKey:@"realname"];
    NSString* msg = nil;
    //IM接口
    switch (dyType) {
        case DynamicTypeTogether:
        {
            tag = 1;
            msg = [NSString stringWithFormat:@"回应%@，参加这个聚聚",name];
        }
            break;
        case DynamicTypeHave:
        {
            tag = 3;
            msg = [NSString stringWithFormat:@"回应%@发布的我有",name];
        }
            break;
        case DynamicTypeWant:
        {
            tag = 2;
            msg = [NSString stringWithFormat:@"回应%@发布的我要",name];
        }
            break;
        default:
            break;
    }
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = tag;
    [alert show];
    [alert release];
}

-(void) deleteButtonClickWith:(int)publishId{
    //删除
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"确定要删除这条动态吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = DELETETAG;
    [alert show];
    [alert release];
}

#pragma mark - alertview
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {
        switch (alertView.tag) {
            case DELETETAG:
            {
                //删除时不提醒
                [[DynamicIMManager shareManager] setDimDelegate:nil];
                [self accessDeleteDynamic];
            }
                break;
            case 1:
            {
                //IM聚聚
                long long circleId = [[_detailDic objectForKey:@"groupId"] longLongValue];
                NSArray* userIdArr = [NSArray arrayWithObject:[UserModel shareUser].user_id];
                //加入临时会话的数据
                NSDictionary* addDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithLongLong:circleId],@"circleId",
                                        userIdArr,@"uid",
                                        nil];
                //向临时会话发送的消息数据
                int publishId = [[_detailDic objectForKey:@"id"] intValue];
                
                //聚聚描述
                NSString* msgdesc = nil;
                long long startTime = [[_detailDic objectForKey:@"startTime"] longLongValue];
                long long endTime = [[_detailDic objectForKey:@"endTime"] longLongValue];
                
                NSString* startStr = [Common makeTime13To10:startTime withFormat:@"YYYY年MM月dd日 HH:mm"];
                NSString* endStr = [Common makeTime13To10:endTime withFormat:@"YYYY年MM月dd日 HH:mm"];
                
                NSString* location = [_detailDic objectForKey:@"location"];
                if (location == nil) {
                    location = @"";
                }
                NSString* city = [_detailDic objectForKey:@"city"];
                if (city == nil) {
                    city = @"";
                }
                
//                NSString* titleStr = [_detailDic objectForKey:@"title"];
                NSString* titleStr = [_detailDic objectForKey:@"content"];
                
                msgdesc = [NSString stringWithFormat:@"%@ -- %@ ,%@  %@ ,%@",startStr,endStr,city,location,titleStr];
                
                NSMutableDictionary* msgDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithLongLong:circleId],@"circleId",
                                               [NSNumber numberWithInt:publishId],@"msgId",
                                               TOGETHERMESSAGETEXT,@"txt",
                                               msgdesc,@"msgdesc",
                                               nil];
                
                [[DynamicIMManager shareManager] addToTempContact:addDic msgDic:msgDic block:^{
                    selectButton.enabled = NO;
                    //更新列表数据和缓存数据
                    NSMutableDictionary* newDic = [NSMutableDictionary dictionaryWithDictionary:_detailDic];
                    [newDic setObject:[NSNumber numberWithBool:YES] forKey:@"joined"];
                    [Dynamic_card_model insertOrUpdateDynamicCardWithDic:newDic];
                }];
            }
                break;
            case 2:
            {
                //IM我有
                
                long long circleId = [[_detailDic objectForKey:@"groupId"] longLongValue];
                int publishId = [[_detailDic objectForKey:@"id"] intValue];
//                NSString* msgdesc = [_detailDic objectForKey:@"title"];
                NSString* msgdesc = [_detailDic objectForKey:@"content"];
                NSNumber* receiveId = [_detailDic objectForKey:@"userId"];
                NSDictionary* haveDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithLongLong:circleId],@"circleId",
                                         receiveId,@"receiverId",
                                         [NSNumber numberWithInt:publishId],@"msgId",
                                         HAVEMESSAGETEXT,@"txt",
                                         msgdesc,@"msgdesc",
                                         nil];
                [[DynamicIMManager shareManager] sendHaveMessage:haveDic block:^{
                    selectButton.enabled = NO;
                    //更新列表数据和缓存数据
                    NSMutableDictionary* newDic = [NSMutableDictionary dictionaryWithDictionary:_detailDic];
                    [newDic setObject:[NSNumber numberWithBool:YES] forKey:@"joined"];
                    [Dynamic_card_model insertOrUpdateDynamicCardWithDic:newDic];
                }];
                
            }
                break;
            case 3:
            {
                //IM我要
                
                long long circleId = [[_detailDic objectForKey:@"groupId"] longLongValue];
                int publishId = [[_detailDic objectForKey:@"id"] intValue];
//                NSString* msgdesc = [_detailDic objectForKey:@"title"];
                NSString* msgdesc = [_detailDic objectForKey:@"content"];
                NSNumber* receiveId = [_detailDic objectForKey:@"userId"];
                NSDictionary* haveDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithLongLong:circleId],@"circleId",
                                         receiveId,@"receiverId",
                                         [NSNumber numberWithInt:publishId],@"msgId",
                                         HAVEMESSAGETEXT,@"txt",
                                         msgdesc,@"msgdesc",
                                         nil];
                [[DynamicIMManager shareManager] sendWantMessage:haveDic block:^{
                    selectButton.enabled = NO;
                    //更新列表数据和缓存数据
                    NSMutableDictionary* newDic = [NSMutableDictionary dictionaryWithDictionary:_detailDic];
                    [newDic setObject:[NSNumber numberWithBool:YES] forKey:@"joined"];
                    [Dynamic_card_model insertOrUpdateDynamicCardWithDic:newDic];
                }];
            }
                break;
            case ISDELETED:
            {
//                [self.navigationController popViewControllerAnimated:YES];
                [self detailBack];
            }
                break;
            default:
                break;
        }
    }
}

////////////---------------////////////////

////////////-------评论输入框部分--------////////////////
//启用键盘
-(void) showKeyBoard{
    [textView becomeFirstResponder];
//    containerView.hidden = NO;
}

//添加底部bar 用于唤醒键盘
-(void)addContainerView
{
    [self resignKeyNotify];
    
    //底部工具栏
	containerView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 64 - 50, ScreenWidth, 50)];
    containerView.backgroundColor = [UIColor whiteColor];
    
    //工具栏背景
    inputBgImgV = [[UIImageView alloc] init];
    inputBgImgV.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    inputBgImgV.image = [IMGREADFILE(@"bg_input_box.png") stretchableImageWithLeftCapWidth:20 topCapHeight:20];
	
	[containerView addSubview:inputBgImgV];
    
	textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(15, 10, 240, 30)];
    textView.backgroundColor = [UIColor clearColor];
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 3;
	textView.font = [UIFont systemFontOfSize:14.0f];
	textView.textColor = [UIColor grayColor];
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 0, 0);
	textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	textView.text = @"";
    textView.returnKeyType = UIReturnKeySend;
    textView.placeholder = @"说点什么吧...";
    
    [containerView addSubview:textView];
    
    //表情键盘
//    faceKeyboardView = [[faceView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 64, ScreenWidth, KEYBOARD_HEIGHT)];
//    faceKeyboardView.delegate = self;
//    [self.view addSubview:faceKeyboardView];
    
	//表情按钮
//    UIImage *faceImage = IMGREADFILE(@"ico_common_expression.png");
//    
//    UIImage *selectedFaceImage = IMGREADFILE(@"ico_common_keyboard.png");
//	faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    faceButton.frame = CGRectMake(CGRectGetMaxX(textView.frame) + 15 , 10.0f , 30.0f, 30.0f);
//	[faceButton addTarget:self action:@selector(showFace:) forControlEvents:UIControlEventTouchUpInside];
//    [faceButton setBackgroundImage:faceImage forState:UIControlStateNormal];
//    [faceButton setBackgroundImage:selectedFaceImage forState:UIControlStateSelected];
//    faceButton.tag = 200;
//	[containerView addSubview:faceButton];
    
    //发送按钮
	UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
	sendButton.frame = CGRectMake(CGRectGetMaxX(textView.frame) + 5.0f , 10.0f , 50.0f, 30.0f);
	[sendButton addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventTouchUpInside];
    sendButton.backgroundColor = BLUECOLOR;
    sendButton.layer.masksToBounds = YES;
    sendButton.layer.cornerRadius = 5.0f;
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
	[containerView addSubview:sendButton];
	
	//字数统计
	remainCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(textView.frame) + 5.0f, 40.0f, 55.0f, 10.0f)];
	[remainCountLabel setFont:[UIFont systemFontOfSize:10.0f]];
	remainCountLabel.textColor = [UIColor darkGrayColor];
	remainCountLabel.text = @"140/140";
	remainCountLabel.hidden = YES;
	remainCountLabel.backgroundColor = [UIColor clearColor];
	remainCountLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
	remainCountLabel.textAlignment = NSTextAlignmentCenter;
	[containerView addSubview:remainCountLabel];
	
	[self.view addSubview:containerView];
    
//    containerView.hidden = YES;
}

#pragma mark - 发送
//发送评论 做字数检测
-(void)sendComment{
    [MobClick event:@"feed_detail_comment_send"];
    
    NSString* textStr = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (textStr.length == 0) {
        [self hiddenKeyboard];
        isResponse = NO;
        return;
    }else if (textStr.length > 140) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"字数不要超过140" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [self hiddenKeyboard];
        isResponse = NO;
        return;
    }
    
    NSString* str = [[NSString alloc] initWithString:[Common placeEmoji:textView.text]];
    
    [self hiddenKeyboard];
    
    //点击发送按钮后，清空状态
    [self performSelector:@selector(backReplyTopic) withObject:nil afterDelay:KEYBOARD_DURATION];
    
    if (isResponse) {
        [self accessResponseComment:str];
    }else{
        [self accessPublishComment:str type:0];
    }
    
}

//注册键盘通知
-(void) resignKeyNotify{
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
//注销键盘通知
-(void) cancelKeyNotify{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(void) keyboardWillShow:(NSNotification *)note
{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    [self containerViewUpAnimation:keyboardBounds withDuration:duration withCurve:curve];
    
    //表情按钮重置
    [self someViewAnimation:faceKeyboardView withUpOrDown:NO];
    [faceButton setSelected:NO];
	
    isKeyboardDown = NO;
}

-(void) keyboardWillHide:(NSNotification *)note
{
    [self hiddenKeyboard];
}

-(void) backGrougBtnClick{
//    containerView.hidden = YES;
    [self hiddenKeyboard];
}

//回复bar 往上动画
- (void)containerViewUpAnimation:(CGRect)keyboardBounds withDuration:(NSNumber *)duration withCurve:(NSNumber *)curve
{
    // get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
	
	//新增一个遮罩按钮
    if (backGrougBtn == nil)
    {
        backGrougBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backGrougBtn addTarget:self action:@selector(backGrougBtnClick) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:backGrougBtn];
        backGrougBtn.backgroundColor = [UIColor clearColor];
    }
    backGrougBtn.frame = CGRectMake(0, 64.0f, self.view.frame.size.width, self.view.frame.size.height - (keyboardBounds.size.height + containerFrame.size.height) - 64.0f);
	
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	containerView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}

//回复bar 往下动画
- (void)containerViewDownAnimation:(NSNumber *)duration withCurve:(NSNumber *)curve
{
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    NSLog(@"==============  %f",containerFrame.origin.y);
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    
    // set views with new info
    containerView.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
    
    //移出遮罩按钮
    [backGrougBtn removeFromSuperview];
    backGrougBtn = nil;
}

//关闭键盘
-(void)hiddenKeyboard
{
    //关闭所有
    [self containerViewDownAnimation:[NSNumber numberWithFloat:KEYBOARD_DURATION] withCurve:[NSNumber numberWithFloat:KEYBOARD_CURVE]];
    //    [self someViewAnimation:pPView withUpOrDown:NO];
    [self someViewAnimation:faceKeyboardView withUpOrDown:NO];
    
	[textView resignFirstResponder];
    [faceButton setSelected:YES];
    
//    [self performSelector:@selector(backReplyTopic) withObject:nil afterDelay:KEYBOARD_DURATION];
}

//点击空白处键盘消失，返回回复话题
-(void)backReplyTopic
{
    if(containerView.frame.origin.y <= self.view.bounds.size.height - 50.0f && containerView.frame.origin.y > self.view.bounds.size.height - KEYBOARD_HEIGHT)
    {
        //        self.replyIndexPath = nil;
        textView.text = @"";
        isResponse = NO;
        textView.placeholder = @"说点什么吧...";
    }
}

//编辑中
-(BOOL)doEditing
{
    BOOL canEdit= NO;
	int textCount = [textView.text length];
	if (textCount > 140)
    {
		remainCountLabel.textColor = [UIColor colorWithRed:1.0 green: 0.0 blue: 0.0 alpha:1.0];
        canEdit = NO;
	}
    else
    {
		remainCountLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
        canEdit = YES;
        remainCountLabel.text = [NSString stringWithFormat:@"%d/140",140 - textCount];
	}
    
    return canEdit;
}

//动画
- (void)someViewAnimation:(UIView *)someView withUpOrDown:(BOOL)upOrDown
{
    CGRect someViewFrame = someView.frame;
    someViewFrame.origin.y = upOrDown ? self.view.frame.size.height - KEYBOARD_HEIGHT : self.view.frame.size.height;
    
    [UIView animateWithDuration:KEYBOARD_DURATION animations:^{
        someView.frame = someViewFrame;
    } completion:^(BOOL finished) {
        
    }];
}

//显示表情
-(void)showFace:(UIButton *)sender
{
    [sender setSelected:!sender.selected];
    
    //无论是键盘还是表情 先隐藏图片选择器
    //    [self someViewAnimation:pPView withUpOrDown:NO];
    
    if (sender.selected)
    {
        //选择表情 隐藏键盘
        if (textView.isFirstResponder)
        {
            isChangKeyboard = YES;
            [textView resignFirstResponder];
        }
        
        CGRect rect = CGRectMake(0,0,self.view.frame.size.width,KEYBOARD_HEIGHT);
        [self containerViewUpAnimation:rect withDuration:[NSNumber numberWithFloat:KEYBOARD_DURATION] withCurve:[NSNumber numberWithFloat:KEYBOARD_CURVE]];
        [self someViewAnimation:faceKeyboardView withUpOrDown:YES];
    }
    else
    {
        //选择键盘 隐藏表情
        isChangKeyboard = NO;
        [textView becomeFirstResponder];
        
        //移至 keyboardWillShow 中实现
        //[self someViewAnimation:faceKeyboardView withUpOrDown:NO];
    }
    
}

#pragma mark -
#pragma mark faceViewDelegate 委托
//发表评论
-(void) sendbuttonClick{
    [self sendComment];
}

- (void)faceView:(faceView *)faceView didSelectAtString:(NSString *)faceString
{
    if (textView.text.length >= 140) {
        return;
    }
    
    NSRange range = textView.selectedRange;
    NSMutableString *textString = [NSMutableString stringWithString:textView.text];
    [textString insertString:faceString atIndex:range.location];
    range.location = range.location + faceString.length;
    textView.text = textString;
    if (range.location <= textString.length)
    {
        textView.selectedRange = range;
    }
    
    [self performSelectorOnMainThread:@selector(doEditing) withObject:nil waitUntilDone:NO];
}

- (void)delFaceString
{
    NSRange range = textView.selectedRange;
    if (range.location > 0)
    {
        NSMutableString *textString = [NSMutableString stringWithString:textView.text];
        
        //先判断是否是系统表情
        range.length = 2;
        range.location = range.location - 2;
        NSString *emojiString = [textString substringWithRange:range];
        NSRange currentRange;
        NSRange delRange = range;
        
        if (![[emoji getEmoji] containsObject:emojiString])
        {
            range.length = 1;
            range.location = textView.selectedRange.location - 1;
            delRange = range;
            
            NSString *rightBracket = [textString substringWithRange:range];
            
            //判断是否是自定义表情
            if ([rightBracket isEqualToString:@"]"])
            {
                if (textString.length >= 3)
                {
                    NSRange range1 = (NSRange){range.location - 2, 1};
                    NSString *leftBracket1 = [textString substringWithRange:range1];
                    if ([leftBracket1 isEqualToString:@"["])
                    {
                        delRange = range1;
                        delRange.length = 3;
                        //currentRange = (NSRange){delRange.location, 0};
                    }
                    else
                    {
                        if (textString.length >= 4)
                        {
                            NSRange range2 = (NSRange){range.location - 3, 1};
                            NSString *leftBracket2 = [textString substringWithRange:range2];
                            if([leftBracket2 isEqualToString:@"["])
                            {
                                delRange = range2;
                                delRange.length = 4;
                                //currentRange = (NSRange){delRange.location, 0};
                            }
                            else
                            {
                                if (textString.length >= 5)
                                {
                                    NSRange range3 = (NSRange){range.location - 4, 1};
                                    NSString *leftBracket3 = [textString substringWithRange:range3];
                                    if([leftBracket3 isEqualToString:@"["])
                                    {
                                        delRange = range3;
                                        delRange.length = 5;
                                        //currentRange = (NSRange){delRange.location, 0};
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        
        currentRange = (NSRange){delRange.location, 0};
        
        [textString deleteCharactersInRange:delRange];
        textView.text = textString;
        if (currentRange.location < textString.length)
        {
            textView.selectedRange = currentRange;
        }
    }
    [self performSelectorOnMainThread:@selector(doEditing) withObject:nil waitUntilDone:NO];
}

#pragma mark -
#pragma mark HPGrowingTextView 委托
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	containerView.frame = r;
    
    inputBgImgV.frame = CGRectMake(0, 0, r.size.width, r.size.height);
    
    backGrougBtn.frame = CGRectMake(backGrougBtn.frame.origin.x, backGrougBtn.frame.origin.y, backGrougBtn.frame.size.width, backGrougBtn.frame.size.height + diff);
    
    if (height > 45.0f)
    {
        remainCountLabel.hidden = NO;
    }
    else
    {
        remainCountLabel.hidden = YES;
    }
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
	return YES;
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self sendComment];
    }
    
    if (![self doEditing]) {
        textView.text = [textView.text substringToIndex:140];
    }
    
	return YES;
}

////////////---------------////////////////

////////////-------cell代理部分--------////////////////
#pragma mark - commentCell
-(void) headAndNameTouchWithUserId:(NSDictionary*) dic{
    NSLog(@"----head---");
    //点击跳转名片页
    if ([[dic objectForKey:@"fromId"] intValue] == [[UserModel shareUser].user_id intValue]) {
        SelfBusinessCardViewController *selfBusinessVC = [[SelfBusinessCardViewController alloc]init];
        [self.navigationController pushViewController:selfBusinessVC animated:YES];
        [selfBusinessVC release];
    } else {
        OthersBusinessCardViewController *otherBusinessVC = [[OthersBusinessCardViewController alloc]init];
        otherBusinessVC.orgUserId = [dic objectForKey:@"fromOrgUserId"];
        [self.navigationController pushViewController:otherBusinessVC animated:YES];
        [otherBusinessVC release];
    }
}

-(void) nameButtonClick:(NSDictionary*) dic{
    NSLog(@"----to_name---");
    //点击跳转名片页
    if ([[dic objectForKey:@"toId"] intValue] == [[UserModel shareUser].user_id intValue]) {
        SelfBusinessCardViewController *selfBusinessVC = [[SelfBusinessCardViewController alloc]init];
        [self.navigationController pushViewController:selfBusinessVC animated:YES];
        [selfBusinessVC release];
    } else {
        OthersBusinessCardViewController *otherBusinessVC = [[OthersBusinessCardViewController alloc]init];
        otherBusinessVC.orgUserId = [dic objectForKey:@"toOrgUserId"];
        [self.navigationController pushViewController:otherBusinessVC animated:YES];
        [otherBusinessVC release];
    }
}

////////////---------------////////////////

////////////-------网络请求部分--------////////////////
#pragma mark - 网络请求
//评论列表
-(void) accessCommentList{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithInt:_publishId],@"publishId",
                         [UserModel shareUser].org_id,@"orgId",
//                         [NSNumber numberWithInt:pageNum],@"pageNumber",
//                         [NSNumber numberWithInt:pageSize],@"pageSize",//java暂时没分页
//                         [NSNumber numberWithLongLong:ts],@"ts",
                         nil];
    
    DynamicDetailManager* ddManager = [[DynamicDetailManager alloc] init];
    ddManager.delegate = self;
    [ddManager accessCommentListWith:dic];
    
}

//回复
-(void) accessResponseComment:(NSString* )str{
    NSDictionary* selectDic = [commentArr objectAtIndex:selectIndexPath.row];
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:_publishId],@"publishId",
                                [UserModel shareUser].org_id,@"orgId",
                                [UserModel shareUser].user_id,@"fromId",
                                [NSNumber numberWithInt:3],@"type",
                                [selectDic objectForKey:@"fromId"],@"toId",
                                [selectDic objectForKey:@"id"],@"commentId",
                                str,@"content",
                                nil];
    
    DynamicDetailManager* ddManager = [[DynamicDetailManager alloc] init];
    ddManager.delegate = self;
    [ddManager accessDynamicDetailComment:dic];
    
}

//评论
-(void) accessPublishComment:(NSString*) str type:(int) type{
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:_publishId],@"publishId",
                                [UserModel shareUser].org_id,@"orgId",
                                [UserModel shareUser].user_id,@"fromId",
                                [NSNumber numberWithInt:type],@"type",
                                [_detailDic objectForKey:@"userId"],@"toId",
                                str,@"content",
                                nil];
    
    DynamicDetailManager* ddManager = [[DynamicDetailManager alloc] init];
    ddManager.delegate = self;
    [ddManager accessDynamicDetailComment:dic];
    
}

//动态详情
-(void) accessDynamicDetail{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithInt:_publishId],@"publishId",
                         [UserModel shareUser].user_id,@"userId",
                         [NSNumber numberWithLongLong:[Dynamic_card_model getDynamicTsWithPublishId:_publishId]],@"ts",
                         nil];
    
    DynamicDetailManager* ddManager = [[DynamicDetailManager alloc] init];
    ddManager.delegate = self;
    [ddManager accessDynamicDetailWith:dic];
    
}

//删除评论
-(void) accessDeleteCommentWithID:(int) comId{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithInt:comId],@"commentId",
                         [UserModel shareUser].org_id,@"orgId",
                         nil];
    
    DynamicDetailManager* ddManager = [[DynamicDetailManager alloc] init];
    ddManager.delegate = self;
    [ddManager accessCommentDeleteWith:dic];
    
}

//删除动态
-(void) accessDeleteDynamic{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithInt:_publishId],@"publishId",
                         [UserModel shareUser].org_id,@"orgId",
                         nil];
    
    DynamicDetailManager* ddManager = [[DynamicDetailManager alloc] init];
    ddManager.delegate = self;
    [ddManager accessDynamicDeleteWith:dic];
    
}

#pragma mark - http回调
-(void) getDynamicDetailHttpCallBack:(NSArray *)arr interface:(LinkedBe_WInterface)interface{
    
    [commentTable footerEndRefreshing];
    
    if (arr.count) {
        switch (interface) {
            case LinkedBe_Comment_dynamic:
            {
                commentNum += 1;
                [self asynDBdata];
                
                [self accessCommentList];
            }
                break;
            case LinkedBe_Comment_list:
            {
                pageNum = [[[arr firstObject] objectForKey:@"pageNumber"] intValue];
                pageSize = [[[arr firstObject] objectForKey:@"pageSize"] intValue];
                pages = [[[arr firstObject] objectForKey:@"pages"] intValue];
                totalCount = [[[arr firstObject] objectForKey:@"totalCount"] intValue];
                ts = [[[arr firstObject] objectForKey:@"ts"] longLongValue];
                
                NSMutableArray* comResultArr = [NSMutableArray arrayWithCapacity:0];
                NSArray* tempArr = [[arr firstObject] objectForKey:@"comments"];
                //过滤掉delete为1得
                for (NSDictionary* dic in tempArr) {
                    if ([[dic objectForKey:@"stats"] intValue] == 0) {
                        [comResultArr addObject:dic];
                    }
                }
                
                [commentArr removeAllObjects];
                
                [commentArr addObjectsFromArray:comResultArr];
//                [commentArr addObjectsFromArray:[[arr firstObject] objectForKey:@"comments"]];
                [commentTable reloadData];
                
                if (commentArr.count) {
                    commentTable.footerHidden = NO;
                }else{
                    commentTable.footerHidden = YES;
                }
                
            }
                break;
            case LinkedBe_Dynamic_detail:
            {
                NSDictionary* dic = [arr firstObject];
                
                if ([[dic objectForKey:@"delete"] intValue] == 1) {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"这条动态已被删除" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    alert.tag = ISDELETED;
                    [alert show];
                    [alert release];
                    return;
                }
                
                if (_detailDic == nil) {
                    _detailDic = [dic copy];
                    [self initPageData];
                    
                    [self initHeader];
                    
                    [commentTable reloadData];
                }else{
                    _detailDic = [dic copy];
                    [self initPageData];
                    
                    [self.detailHeadV updateDataWith:dic];
                }
                
            }
                break;
            case LinkedBe_Delete_comment:
            {
                if (commentArr.count == 0) {
                    commentTable.footerHidden = NO;
                }
            }
                break;
            case LinkedBe_Delete_dynamic:
            {
                if (_delegate && [_delegate respondsToSelector:@selector(deleteDynamicCallBack:)]) {
                    [_delegate deleteDynamicCallBack:_publishId];
                    
                    //删除本地数据库数据
                    [Dynamic_card_model deleteDynamicCardWithPublishId:_publishId];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
                break;
            default:
                break;
        }
    }
}

////////////---------------////////////////
#pragma mark - 同步交互数字
-(void) asynDBdata{
    [self.detailHeadV.commentBtn setTitle:[NSString stringWithFormat:@"%d",commentNum] forState:UIControlStateNormal];
    
    NSMutableDictionary* newDic = [NSMutableDictionary dictionaryWithDictionary:_detailDic];
    
    [newDic setObject:[NSNumber numberWithInt:commentNum - zanHeheSum] forKey:@"commentSum"];
    
    _detailDic = [newDic copy];
    [Dynamic_card_model insertOrUpdateDynamicCardWithDic:newDic];
}

#pragma mark - scrollview
-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    UIView* v = [self.detailHeadV viewWithTag:10000];
    if (v) {
        [v removeFromSuperview];
    }
}

#pragma mark - DynamicIMManager
-(void) receiveDynamicDeleteWithDic:(NSDictionary *)dic{
    int dpublishId = [[dic objectForKey:@"fid"] intValue];
    if (dpublishId == _publishId) {
        if (!yesOrNo) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"这条动态已被删除" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            alert.tag = ISDELETED;
            [alert show];
            [alert release];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc{
    [[DynamicIMManager shareManager] setDimDelegate:nil];
    
    [commentTable release];
    [commentArr release];
    
    [_detailHeadV release];
    
    [containerView release];
    [textView release];
    
    [remainCountLabel release];
    [inputBgImgV release];
    
    _delegate = nil;
    
    [super dealloc];
}

@end
