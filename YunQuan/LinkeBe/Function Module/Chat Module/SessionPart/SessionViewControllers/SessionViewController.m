//
//  SessionViewController.m
//  ql
//
//  Created by yunlai on 14-3-8.
//  Copyright (c) 2014年 ChenFeng. All rights reserved.
//

#import "SessionViewController.h"
#import "TextMessageCell.h"
#import "SessionDataFactory.h"
#import "SessionCellFactory.h"
#import "MessageDataManager.h"
#import "SBJson.h"
#import "PictureData.h"
#import "QBImagePickerController.h"
#import "XHAudioPlayerHelper.h"
#import "EmotionStoreViewController.h"
#import "MessageListData.h"

//圈子详情页面
#import "UIImage+FixOrientation.h"
#import "UIViewController+NavigationBar.h"

#import "SessionDataOperator.h"
#import "TempChatDetailViewController.h"
#import "MessageListDataOperator.h"
#import "ContactSelectMembersViewController.h"
#import "DynamicDetailViewController.h"
#import "WatermarkCameraViewController.h"
#import "SecretarySingleton.h"
#import "OrgSingleton.h"
#import "MobClick.h"

const int  imgSelectMaxNumber = QBImagePickerMaxSelectNum;

typedef enum{
    kButtonKeyBard,
    kButtonFaceView,
    kButtonRescource,
    kButtonVoice
}kButton;

@interface SessionViewController () <SnailMessageTableViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ASIProgressDelegate,EmotionStoreViewControllerDelegate,SessionDataOperatorDelegate,ContactViewDelegate,OriginTimeStampCellDelegate,WatermarkCameraViewControllerDelegate>
{    
}

@property (nonatomic, retain) UIButton * rightNaviButton;

@property (nonatomic, retain) NSMutableArray * unreadVoiceObjects;

@property (nonatomic, retain) NSMutableArray * sessionInfoList;


@property (nonatomic, retain) NSDictionary * circleInfoDic;

@property (nonatomic, assign) long long senderID;

@property (nonatomic, assign) int talkType;

@property (nonatomic, assign) long long userID;

@property (nonatomic, assign) BOOL scrollToButtonIndicator;

@property (nonatomic, assign) NSInteger currentHistoryDataIndex;

@end

@implementation SessionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.chatType = NormalChatType;
        self.currentHistoryDataIndex = 0; //change by snail
        self.isPopToRootViewController = NO;
        self.isShowRightButtom = YES;
        self.scrollToButtonIndicator = YES;
        
        self.sessionInfoList = [[[NSMutableArray alloc]init]autorelease];
        [SessionDataOperator shareOperator].delegate = self;
        
        //初始化未读语音Cell数组
        NSMutableArray * arr = [[[NSMutableArray alloc]init]autorelease];
        self.unreadVoiceObjects = arr;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(makeupSelf) name:TempCircleMemberChanged object:nil];
    }
    return self;
}

#pragma mark - DataSource Change

- (void)exChangeMessageDataSourceQueue:(void (^)())queue {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), queue);
}

- (void)exMainQueue:(void (^)())queue {
    dispatch_async(dispatch_get_main_queue(), queue);
}

// http://stackoverflow.com/a/11602040 Keep UITableView static when inserting rows at the top
static CGPoint  delayOffset = {0.0};
- (void)insertMessage:(MessageData *)insertMessage atIndext:(NSInteger)index
{
    [self.sessionInfoList insertObject:insertMessage atIndex:index];
    
    delayOffset = self.messageTableView.contentOffset;
    
    delayOffset.y += [self calculateCellHeightWithData:insertMessage];
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:1];
    [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    
    [UIView setAnimationsEnabled:NO];
    [self.messageTableView beginUpdates];
    [self.messageTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.messageTableView setContentOffset:delayOffset animated:NO];
    [self.messageTableView endUpdates];
    [UIView setAnimationsEnabled:YES];
    
    //判断并根据index将这个Cell插入到未读消息列表
    [self judgeObjectAndInsertItToUnreadArrWithData:insertMessage withIndex:index];
}

- (void)judgeObjectAndInsertItToUnreadArrWithData:(MessageData *)data withIndex:(NSInteger)index
{
    if (data.sessionData.objtype == DataMessageTypeVoice) {
        VoiceData * voice = (VoiceData *)data.sessionData;
        if (voice.dataStatus == OriginDataStatusUnread) {
            //如果Index 大于0 则插入到最后 unreadVoiceObjects 的index 明显小于 列表的index
            if (index == 0) {
                [self.unreadVoiceObjects insertObject:voice atIndex:0];
            } else {
                [self.unreadVoiceObjects addObject:voice];
            }
        }
    }
}

- (void)addMessage:(MessageData *)addedMessageData {
    [self.sessionInfoList addObject:addedMessageData];
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:1];
    [indexPaths addObject:[NSIndexPath indexPathForRow:self.sessionInfoList.count - 1 inSection:0]];
    
    [self.messageTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self scrollToBottomAnimated:YES];
    
    [self judgeObjectAndInsertItToUnreadArrWithData:addedMessageData withIndex:self.sessionInfoList.count - 1];
}

- (void)removeMessageAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.sessionInfoList.count)
        return;
    [self.sessionInfoList removeObjectAtIndex:indexPath.row];
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:1];
    [indexPaths addObject:indexPath];
    
    [self.messageTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
}

//自己被踢出
-(void) circleBeOutNotify{
    if (self.talkType != MessageListTypeCircle && self.talkType != MessageListTypeTempCircle) {
        return;
    }
    
    [self.messageInputView resignFirstResponder];
    self.messageInputView.hidden = YES;
    self.rightNaviButton.hidden = YES;
}

#pragma mark- UIViewControllerLifeCircle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    //设置页面基本属性
    [self makeupSelf];
    //设置导航Bar 按钮
    [self putNavigationBarButton];
  
    //初始化聊天历史记录 并判断是否展示消息输入框 并滚到最后一栏
    [self loadSessionListAndScrollToBottomOrNot:YES];
    //初始化聊天信息的tableview
    [self loadTapGesture];
 
    //加载上拉刷新视图
    [self loadMoreLoadingView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.scrollToButtonIndicator) {
        [self scrollToBottomAnimated:NO];
    }
    [MobClick beginLogPageView:@"SessionViewPage"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cleanUnreadSignForSessionObject];
    if ([[XHAudioPlayerHelper shareInstance]isPlaying]) {
        [[XHAudioPlayerHelper shareInstance]stopAudio];
    }
    [MobClick endLogPageView:@"SessionViewPage"];
}

- (void)putNavigationBarButton
{
    UIButton * backButton = [self setBackBarButton:@"返回"];
    [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self setBackBarButtonItem:backButton];
    
    if (self.isShowRightButtom == YES && [[SecretarySingleton shareSecretary]secretaryID] != self.listData.ObjectID && [[OrgSingleton shareOrg]orgID] != self.listData.ObjectID) {
        UIImage *rightImg = [UIImage imageNamed:@"ico_chat_add.png"];
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(20, 7, 30, 30);
        [rightBtn setImage:rightImg forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        self.navigationItem.rightBarButtonItem = rightItem;
        [rightItem release];
    }
}

//重置页面状态
- (void)makeupSelf
{
    ObjectData * object = [ObjectData objectForLatestMessage:self.listData.latestMessage];
    
    switch (self.listData.latestMessage.sessionType) {
        case SessionTypePerson:
        {
            self.title = object.objectName;
        }
            break;
        case SessionTypeTempCircle:
        {
            NSInteger memberCount = [[SessionDataOperator shareOperator]getTempCircleMemberCountWithTempCircleID:(self.listData.ObjectID)];
            
            if (object.objectName != nil) {
                BOOL toLongJudger = object.objectName.length > 8;
                NSInteger  titleLong = toLongJudger ? 8 : object.objectName.length;
                NSRange titleMaxRage = NSMakeRange(0, titleLong);
                NSString * subTitleStr = [object.objectName substringWithRange:titleMaxRage];
                NSString * titleStr = nil;
                
                if (toLongJudger) {
                    titleStr = [NSString stringWithFormat:@"%@...(%d)",subTitleStr,memberCount];
                } else {
                    titleStr = [NSString stringWithFormat:@"%@(%d)",subTitleStr,memberCount];
                }
                
                self.title = titleStr;
            }
        }
            
        default:
            break;
    }
    self.messageInputView.backgroundColor = [UIColor whiteColor];
    self.messageTableView.backgroundColor = SessionTableBackColor;
}


//上拉刷新视图
- (void)loadMoreLoadingView
{
    // 上拉刷新   add by devin
    EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -50, self.view.bounds.size.width, 50)];
    view.delegate = self;
    view.backgroundColor = [UIColor clearColor];
    [self.messageTableView addSubview:view];
    headerView = view;
    RELEASE_SAFE(view);
}

//初始化个人历史信息列表
- (void)loadSessionListAndScrollToBottomOrNot:(BOOL)isScroll
{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray * messageArr = [[SessionDataOperator shareOperator]historyMessageArrWithCurrentPage:self.currentHistoryDataIndex forObjectID:self.listData.ObjectID];
        self.currentHistoryDataIndex += ChatHistoryMessagePrePage;
        
        [self cleanUnreadSignForSessionObject];
//        dispatch_async(dispatch_get_main_queue(), ^{
            for (int i = 0; i < messageArr.count; i++) {
                MessageData * data = [messageArr objectAtIndex:i];
                [self insertMessage:data atIndext:0];
            }
            if (isScroll) {
                self.scrollToButtonIndicator = isScroll;
//                [self scrollToBottomAnimated:NO];
            }
//        });
//    });
}

- (void)cleanUnreadSignForSessionObject
{
    [[MessageListDataOperator shareOperator]cleanUnreadSignForChatObjectID:self.listData.ObjectID andSessionType:self.listData.latestMessage.sessionType];
}

- (void)tapTohideOtherviews
{
    if ([self.messageInputView isInputSomething]) {
        [self layoutOtherMenuViewHiden:YES];
        [self.messageInputView resetAllButton];
    }
}

- (void)loadTapGesture
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UITapGestureRecognizer * singleTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self  action:@selector(tapTohideOtherviews)];
        singleTapRecognizer.delegate = self;
        [self.messageTableView addGestureRecognizer:singleTapRecognizer];
    });
}

#pragma mark - Button Click Method
/**
 *  返回事件
 */
- (void)backButtonClick{
    
    if (self.isPopToRootViewController) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (self.chatType == TabbarChatType) {
        self.tabBarController.tabBar.hidden = YES; //圈子搜索里面跳转 会需要
    }
}

// 右边按钮点击事件
- (void)rightButtonClick
{
    // 单聊 还是临时会话
    if (self.listData.latestMessage.sessionType == SessionTypePerson) {
        ContactSelectMembersViewController *contactSelectMembersVC = [[ContactSelectMembersViewController alloc]init];
        contactSelectMembersVC.delegate = self;
        contactSelectMembersVC.listData = self.listData;
        [self.navigationController pushViewController:contactSelectMembersVC animated:YES];
        [contactSelectMembersVC release];
    } else if(self.listData.latestMessage.sessionType == SessionTypeTempCircle) {
        [MobClick event:@"chat_detail_info"];
        
        TempChatDetailViewController *tempChatDetailVC = [[TempChatDetailViewController alloc]init];
        tempChatDetailVC.listData = self.listData;
        [self.navigationController pushViewController:tempChatDetailVC animated:YES];
        [tempChatDetailVC release];
    }
}

#pragma mark - SubmitMessageMethod

// 发送文本信息
- (void)submitMessageWithText:(NSString *)text
{    
    //使用iMMessageDataManager 封装消息数据 并且向iM 服务器发送消息
    MessageData * sendingMessage = [[SessionDataOperator shareOperator]sendTextDataWithText:text andMessageListData:self.listData];
    [self addMessage:sendingMessage];
}

// 发送图片消息
- (void)submitMessageWithPictureInfo:(id)info
{
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray * imageSendArr = [[NSMutableArray alloc]init];
        if ([info isKindOfClass:[NSDictionary class]]) {
            UIImage * imgOrigin = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            UIImage * fixOrientationImg = [imgOrigin fixOrientation];
            [imageSendArr addObject:fixOrientationImg];
        } else if ([info isKindOfClass:[NSMutableArray class]]) {
            for (NSDictionary *imgDic in info){
                UIImage * img = [imgDic objectForKey:@"UIImagePickerControllerOriginalImage"];
                [imageSendArr addObject:img];
            }
        } else if ([info isKindOfClass:[NSArray class]]){
            [imageSendArr addObjectsFromArray:info];
        }
        NSMutableArray * imageArr = [[SessionDataOperator shareOperator]sendPictureDataWithImageArr:imageSendArr andMessageListData:self.listData];
        RELEASE_SAFE(imageSendArr);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (MessageData *imgData in imageArr) {
                [self addMessage:imgData];
            }
        });
    });
}

// 发送声音消息
- (void)submitMessageWithVoiceData:(VoiceData *)voice
{
    [MobClick event:@"chat_detail_send_recording"];
    MessageData * voiceMessage = [[SessionDataOperator shareOperator]sendVoiceDataWithVoiceData:voice andMessageListData:self.listData];
    [self addMessage:voiceMessage];
}

//发送自定义表情消息
- (void)submitCustomMessageWithCustomEmotionData:(CustomEmotionData *)emotionData
{
    [MobClick event:@"chat_send_customEmoticon"];
    MessageData * customEmotionMessage = [[SessionDataOperator shareOperator]sendCustomEmoticonDataWithCustomeEmoticonData:emotionData andMessageListData:self.listData];
    [self addMessage:customEmotionMessage];
}

// 当从新登陆的时候从新发送存储在MessageDataManager 里面的消息
- (void)resendMessages
{
//    if (self.dataManager.waitToResendQueue.count > 0) {
//        MessageData * mData = [self.dataManager.waitToResendQueue firstObject];
//        [[TcpRequestHelper shareTcpRequestHelperHelper]sendMessagePackageCommandId:TCP_TEXTMESSAG_EPERSON_COMMAND_ID andMessageData:mData];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sessionInfoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageData * cellMessage = [self.sessionInfoList objectAtIndex:indexPath.row];
    OriginTimeStampCell *cell = nil;
    //只有邀请信息有这个字段 所以用它来判断
    cell = [SessionCellFactory cellForMeesageData:cellMessage forTableView:tableView withDelegate:self];
    [cell freshWithInfoData:cellMessage];
    
    //异常处理 如果数据源有问题则会展示一个血红色的cell
    if (cell != nil) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        UITableViewCell * errorCell = [tableView dequeueReusableCellWithIdentifier:@"error"];
        if (errorCell == nil) {
            errorCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"error"];
        }
        errorCell.backgroundColor = [UIColor redColor];
        return errorCell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageData * data = [self.sessionInfoList objectAtIndex:indexPath.row];
    return [self calculateCellHeightWithData:data];
}

- (float)calculateCellHeightWithData:(MessageData *)data
{
    return [SessionCellFactory caculateCellHeightForMessageData:data];
}

#pragma mark - OtherLinkCellDelegate

- (void)callBackEnterDynamicDetail:(int)pubishId {
    NSLog(@"pubishId = %d",pubishId);
    DynamicDetailViewController* detailVC = [[DynamicDetailViewController alloc] init];
    detailVC.publishId = pubishId;
    [self.navigationController pushViewController:detailVC animated:YES];
    RELEASE_SAFE(detailVC);
}

#pragma mark - Add Session ListDic With Message

// add 表示插入最后面也就是最新的
- (void)addSessionListDicWithMessage:(MessageData *)msg
{
    [self.sessionInfoList addObject:msg];
}

#pragma mark -TempPictureMessageSendResolveLogic

- (void)httpSubmitPictureSuccess:(NSNotification *)noti
{
    MessageData * msg = [noti object];
    [self addMessage:msg];
}

#pragma mark - SessionDataOperatorDelegate
- (void)receiveMessage:(MessageData *)message
{
    if (self.isViewLoaded) {
        [self addMessage:message];
    }
}

#pragma mark - QBImagePickerControllerDelegate
- (void)imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id )info
{
    if ([imagePickerController isKindOfClass:[UIImagePickerController class]]) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self submitMessageWithPictureInfo:info];
        }];
    } else {
        [self submitMessageWithPictureInfo:info];
        [imagePickerController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - WaterMarkCamora
- (void)didSelectImages:(NSArray *)images
{
    [self.navigationController popViewControllerAnimated:YES];
    [self submitMessageWithPictureInfo:images];
}

#pragma mark - MessageCellDelegate

- (void)haveClickPicture
{
    // 设置是否将table View 滚到底部cell的标示为NO table view 将不会滚动到底部
    self.shouldScrollToLastCell = NO;
    [self tapTohideOtherviews];
}

- (void)shouldHideWholePictureBrowser
{
    // 影藏图片全图浏览是恢复table view 滚动底部标示
    self.shouldScrollToLastCell = YES;
}

- (void)portraitViewHaveClickedWithMessageData:(MessageData *)messageData
{
    if (messageData.objectID == [[SecretarySingleton shareSecretary]secretaryID]) {
        return;
    }
    [[SessionDataOperator shareOperator]turnToIntroduceCardViewControllerWithSender:self andObjectID:messageData.speaker.objectID];
}

- (void)resendMessageWithMessage:(MessageData *)msgData
{
    NSInteger index = [self.sessionInfoList indexOfObject:msgData];
    [self.sessionInfoList removeObject:msgData];
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:1];
    [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    [self.messageTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    [MessageDataManager deleteDBChatMessage:msgData];
    [[SessionDataOperator shareOperator]resendMessageWithMessage:msgData];
    msgData.statusType = MessageStatusTypeSending;
    [self addMessage:msgData];
}

#pragma mark - FatherDelegate

- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date
{
    [self submitMessageWithText:text];
}

- (void)didSendVoice:(NSString *)voicePath voiceDuration:(NSString*)voiceDuration fromSender:(NSString *)sender onDate:(NSDate *)date
{
    VoiceData * voice = [[VoiceData alloc]init];
    voice.url = voicePath;
    voice.duration = [voiceDuration floatValue];
    voice.dataStatus = OriginDataStatusReaded;
    [self submitMessageWithVoiceData:voice];
    RELEASE_SAFE(voice);
}

#pragma mark - Media ShareViewDelegate
//点击多媒体选择控件中的按钮回调 目前只开放了选择图片功能
- (void)didSelecteShareMenuItem:(XHShareMenuItem *)shareMenuItem atIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            [MobClick event:@"chat_detail_pick_image"];
            QBImagePickerController *imagePicker = [[QBImagePickerController alloc]init];
            imagePicker.showsCancelButton = YES;
            imagePicker.filterType = QBImagePickerFilterTypeAllPhotos;
            imagePicker.fullScreenLayoutEnabled = YES;
            imagePicker.allowsMultipleSelection = YES;
            imagePicker.limitsMaximumNumberOfSelection = YES;
            imagePicker.maximumNumberOfSelection = imgSelectMaxNumber;
            imagePicker.delegate = self;
            
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:imagePicker];
            [self presentViewController:nav animated:YES completion:nil];
            [nav release];
//            [self.navigationController pushViewController:imagePicker animated:YES];
            
            RELEASE_SAFE(imagePicker);
        }
            break;
        case 1:
        {
//            WatermarkCameraViewController * watermarkCamera = [[WatermarkCameraViewController alloc]init];
//            watermarkCamera.delegate = self;
//            watermarkCamera.type = 0;
//            [self.navigationController pushViewController:watermarkCamera animated:YES];
//            RELEASE_SAFE(watermarkCamera);
            [MobClick event:@"chat_detail_take_photo"];
            BOOL canUseCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
            if (canUseCamera) {
                UIImagePickerController * imageCamera = [[UIImagePickerController alloc]init];
                imageCamera.editing = YES;
                imageCamera.delegate = self;
                imageCamera.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imageCamera animated:YES completion:^{
                    
                }];
                RELEASE_SAFE(imageCamera);
            } else {
                [Common checkProgressHUDShowInAppKeyWindow:@"设备不支持该功能" andImage:nil];
            }
        }
            break;
        case 2:
        {
            [Common checkProgressHUD:@"尽请期待" andImage:nil showInView:APPKEYWINDOW];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - EmotionViewDelegate

- (void)sendMessage
{
    NSString * text = self.messageInputView.inputTextView.text;
    if ([self judgeNilMessageAndShowAlertForText:text]) {
        return;
    }
    [self submitMessageWithText:self.messageInputView.inputTextView.text];
    self.messageInputView.inputTextView.text = nil;
}

- (void)openEmotionStore
{
    [MobClick event:@"chat_detail_emoticon_lib"];
    
    EmotionStoreViewController * storeController = [[EmotionStoreViewController alloc]init];
    storeController.delegate = self;
    [self.navigationController pushViewController:storeController animated:YES];
    RELEASE_SAFE(storeController);
}

- (void)didSelecteEmoticonItem:(EmoticonItemData *)emoticonItem atIndexPath:(NSIndexPath *)indexPath
{
    CustomEmotionData * tempEmoticonData =  [emoticonItem generateCustomEmotionData];
    [self submitCustomMessageWithCustomEmotionData:tempEmoticonData];
}

#pragma mark - scrollDelegate

-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    [headerView egoRefreshScrollViewDidScroll:scrollView];
}
-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [headerView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - egoRefreshTableHeaderDelegate

-(void) egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view{
    [self LoadingTableViewData]; //加载数据
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];//加载完成
}

//上拉刷新加载数据
-(void)LoadingTableViewData{
    [self loadSessionListAndScrollToBottomOrNot:NO];
}

// 加载完成
-(void)doneLoadingTableViewData{
    [headerView egoRefreshScrollViewDataSourceDidFinishedLoading:self.messageTableView];
}

#pragma mark - VoiceCellDelegate 

- (void)voiceMessageDidFinishedPlay:(id)sender
{
    VoiceMessageCell * currentCell = (VoiceMessageCell *)sender;
    
    NSInteger currentCellIndex;
    currentCellIndex = [self.unreadVoiceObjects indexOfObject:currentCell.voiceObject];
    //取出下一条未读消息播放并从未读数组移除
    if (currentCellIndex >= 0 && currentCellIndex +1 < self.unreadVoiceObjects.count)
    {
        VoiceData * nextVoiceData = [self.unreadVoiceObjects objectAtIndex:currentCellIndex + 1];
        VoiceMessageCell * nextCell = (VoiceMessageCell *)nextVoiceData.currentCell;
        if (nextCell != nil && [nextCell respondsToSelector:@selector(playCurrentVoice)]) {
            [nextCell playCurrentVoice];
        }
    }
    [self.unreadVoiceObjects removeObject:currentCell.voiceObject];
}

#pragma mark - EmoticonStoreViewControllerDelegate

- (void)downloadEmoticonSuccess
{
    [self loadEmotionView];
}

#pragma mark - ContactViewDelegate

- (void)callBackSelectedMembers:(NSMutableArray *)array {

    [self.navigationController popViewControllerAnimated:NO];
    [self.sessionDelegate callBackPassMembers:array];
}

- (void)dealloc
{
    //booky
    self.unreadVoiceObjects = nil;
    self.sessionInfoList = nil;
    self.circleInfoDic = nil;
    self.messageTableView.delegate = nil;
    self.messageTableView = nil;
    self.listData = nil;
    self.emotionManagerView = nil;
    self.messageInputView = nil;
    

    [SessionDataOperator shareOperator].delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TempCircleMemberChanged object:nil];
    
    [super dealloc];
}

@end
