//
//  SnailVedioViewController.m
//  VoiceRecorderDemo
//
//  Created by LazySnail on 14-6-20.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailMessageViewController.h"
#import "XHVoiceRecordHelper.h"
#import "XHVoiceRecordHUD.h"

#import "XHAudioPlayerHelper.h"
#import "SnailMacro.h"
#import "SnailMessageInputView.h"
#import "UIScrollView+XHkeyboardControl.h"
#import "XHEmotionManagerView.h"
#import "SnailCacheManager.h"
#import "amrFileCodec.h"
#import "EmoticonItemData.h"

#import <AVFoundation/AVFoundation.h>
#import "emoticon_item_list_model.h"
#import "emoticon_list_model.h"
#import "TQRichTextEmojiRun.h"

#define kSelfViewHeight         self.view.bounds.size.height
#define kSelfViewWidth          self.view.bounds.size.width

@interface SnailMessageViewController () <UITableViewDataSource,UITableViewDelegate,SnailMessageInputViewDelegate,XHShareMenuViewDelegate,XHEmotionManagerViewDataSource>
{
    XHVoiceRecordHUD * _voiceRecordHUD;
    XHVoiceRecordHelper * _voiceRecordHelper;
    NSMutableArray * _messageLists;
    SnailMessageInputView * _messageInputView;
    
}

@property (nonatomic, retain) XHVoiceRecordHUD * voiceRecordHUD;

@property (nonatomic, retain) XHVoiceRecordHelper * voiceRecordHelper;

@property (nonatomic, retain) NSMutableArray * messageLists;

@property (nonatomic, assign) CGFloat previousTextViewContentHeight;

@property (nonatomic, weak, readwrite) XHShareMenuView *shareMenuView;

@property (nonatomic, strong) NSArray *shareMenuItems;

@property (nonatomic, assign) XHInputViewType textViewInputViewType;

@property (nonatomic, strong) NSArray *emotionManagers;



/**
 *  记录键盘的高度，为了适配iPad和iPhone
 */
@property (nonatomic, assign) CGFloat keyboardViewHeight;

@property (nonatomic, strong) UIView *headerContainerView;

@property (nonatomic, strong) UIActivityIndicatorView *loadMoreActivityIndicatorView;

@end


@implementation SnailMessageViewController

- (UIView *)headerContainerView {
    if (!_headerContainerView) {
        _headerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 0)];
        _headerContainerView.backgroundColor = self.messageTableView.backgroundColor;
        [_headerContainerView addSubview:self.loadMoreActivityIndicatorView];
    }
    return _headerContainerView;
}
- (UIActivityIndicatorView *)loadMoreActivityIndicatorView {
    if (!_loadMoreActivityIndicatorView) {
        _loadMoreActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadMoreActivityIndicatorView.center = CGPointMake(CGRectGetWidth(_headerContainerView.bounds) / 2.0, CGRectGetHeight(_headerContainerView.bounds) / 2.0);
    }
    return _loadMoreActivityIndicatorView;
}
- (void)setLoadingMoreMessage:(BOOL)loadingMoreMessage {
    _loadingMoreMessage = loadingMoreMessage;
    if (loadingMoreMessage) {
        [self.loadMoreActivityIndicatorView startAnimating];
    } else {
        [self.loadMoreActivityIndicatorView stopAnimating];
    }
}

- (XHVoiceRecordHUD *)voiceRecordHUD {
    if (!_voiceRecordHUD) {
        _voiceRecordHUD = [[XHVoiceRecordHUD alloc] initWithFrame:CGRectMake(0, 0, 140, 200)];
    }
    return _voiceRecordHUD;
}

- (XHVoiceRecordHelper *)voiceRecordHelper {
    if (!_voiceRecordHelper) {
        WEAKSELF
        _voiceRecordHelper = [[XHVoiceRecordHelper alloc] init];
        _voiceRecordHelper.maxTimeStopRecorderCompletion = ^{
            [weakSelf finishRecorded];
        };
        _voiceRecordHelper.peakPowerForChannel = ^(float peakPowerForChannel) {
            weakSelf.voiceRecordHUD.peakPower = peakPowerForChannel;
        };
        _voiceRecordHelper.maxRecordTime = kVoiceRecorderTotalTime;
    }
    return _voiceRecordHelper;
}

- (XHShareMenuView *)shareMenuView {
    if (!_shareMenuView) {
        XHShareMenuView *shareMenuView = [[XHShareMenuView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), self.keyboardViewHeight)];
        shareMenuView.delegate = self;
        shareMenuView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
        shareMenuView.alpha = 0.0;
        shareMenuView.shareMenuItems = self.shareMenuItems;
        [self.view addSubview:shareMenuView];
        _shareMenuView = shareMenuView;
    }
    [self.view bringSubviewToFront:_shareMenuView];
    return _shareMenuView;
}
- (NSMutableArray *)messageLists
{
    if (!_messageLists) {
        _messageLists = [NSMutableArray new];
    }
    return _messageLists;
}

- (XHEmotionManagerView *)emotionManagerView {
    if (!_emotionManagerView) {
        XHEmotionManagerView *emotionManagerView = [[XHEmotionManagerView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), self.keyboardViewHeight)];
        emotionManagerView.delegate = self;
        emotionManagerView.dataSource = self;
        emotionManagerView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
        emotionManagerView.alpha = 0.0;
        [emotionManagerView graySendButton];
        _emotionManagerView = emotionManagerView;

        [self.view addSubview:_emotionManagerView];
    }
    [self.view bringSubviewToFront:_emotionManagerView];    
    return _emotionManagerView;
}

#pragma mark - UIViewControllerLifeCircle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadSetup];
    [self loadInputBarAndMessageTable];
    [self loadEmotionView];
}

- (void)loadEmotionView
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *emotionManagers = [NSMutableArray array];
        // 加载系统自带Emoji表情 1 个
        
        XHEmotionManager * emotionManager = [XHEmotionManager new];
        emotionManager.emotionIcon = @"Expression_1@2x.png";
        emotionManager.emotionName = @"系统表情";
        [emotionManagers addObject:emotionManager];

        NSMutableArray * emoticonsArr = [emoticon_list_model getDownloadedEmoticons];
        // 加载动态表情
        for (NSInteger i = 0; i < emoticonsArr.count; i ++) {
            NSDictionary * emoticonDic = [emoticonsArr objectAtIndex:i];
            
            XHEmotionManager *emotionManager = [[XHEmotionManager alloc] init];
            emotionManager.emotionName = [emoticonDic objectForKey:@"title"];
            emotionManager.emotionIcon = [emoticonDic objectForKey:@"chatIcon"];
            
            NSArray * emoticonItemsArr = [emoticon_item_list_model getAllItemWithEmoticonID:[[emoticonDic objectForKey:@"packetId"] longLongValue]];
            NSMutableArray *emoticons = [NSMutableArray array];
            for (NSInteger j = 0; j < emoticonItemsArr.count; j ++) {
                NSDictionary * itemDic = [emoticonItemsArr objectAtIndex:j];
                EmoticonItemData * itemData = [[EmoticonItemData alloc]initWithDic:itemDic];
                [emoticons addObject:itemData];
            }
            emotionManager.emotions = emoticons;
            [emotionManagers addObject:emotionManager];
        }
        self.emotionManagers = emotionManagers;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.emotionManagerView reloadData];
        });
    });
}

- (void)loadSetup
{
    self.keyboardViewHeight = (kIsiPad ? 264 : 216);
    self.shouldScrollToLastCell = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.previousTextViewContentHeight = 36;
    
    _allowsPanToDismissKeyboard = YES;
    _allowsSendVoice = YES;
    _allowsSendMultiMedia = YES;
    _allowsSendFace = YES;
    _inputViewStyle = SnailMessageInputViewStyleFlat;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 添加第三方接入数据
        NSMutableArray *shareMenuItems = [NSMutableArray array];
        NSArray *plugIcons = @[@"ico_chat_photo.png", @"ico_chat_pic.png"];
        NSArray *plugTitle = @[@"照片", @"拍摄"];
        
        for (NSString *plugIcon in plugIcons) {
            XHShareMenuItem *shareMenuItem = [[XHShareMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:plugIcon] title:[plugTitle objectAtIndex:[plugIcons indexOfObject:plugIcon]]];
            [shareMenuItems addObject:shareMenuItem];
        }
        
        self.shareMenuItems = shareMenuItems;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.shareMenuView reloadData];

        });
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // KVO 检查contentSize
    [self.messageInputView.inputTextView addObserver:self
                                          forKeyPath:@"contentSize"
                                             options:NSKeyValueObservingOptionNew
                                             context:nil];
    [self.messageTableView setupPanGestureControlKeyboardHide:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 取消输入框
    [self.messageInputView.inputTextView resignFirstResponder];
    [self setEditing:NO animated:YES];
    
    // remove KVO
    //添加异常处理判断
    if (self.messageInputView.inputTextView.observationInfo != nil) {
        [self.messageInputView.inputTextView removeObserver:self forKeyPath:@"contentSize"];
    }
    [self.messageTableView disSetupPanGestureControlKeyboardHide:YES];
}

- (void)loadInputBarAndMessageTable
{
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // 初始化message tableView
	XHMessageTableView *messageTableView = [[XHMessageTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	messageTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	messageTableView.dataSource = self;
	messageTableView.delegate = self;
    messageTableView.separatorColor = [UIColor clearColor];
    messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 设置整体背景颜色
    messageTableView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:messageTableView];
    [self.view sendSubviewToBack:messageTableView];
	self.messageTableView = messageTableView;
    
    messageTableView.tableHeaderView = self.headerContainerView;
    
    // 设置Message TableView 的bottom edg
    CGFloat inputViewHeight = (self.inputViewStyle == SnailMessageInputViewStyleFlat) ? 50.0f : 45.0f;
    [self setTableViewInsetsWithBottomValue:inputViewHeight];
    
 
    // 输入工具条的frame
    CGRect inputFrame = CGRectMake(0.0f,
                                   self.view.frame.size.height - inputViewHeight,
                                   self.view.frame.size.width,
                                   inputViewHeight);
    
    // 初始化输入工具条
    self.messageInputView = [[SnailMessageInputView alloc]initWithFrame:inputFrame];
    self.messageInputView.delegate = self;
    [self.view addSubview:self.messageInputView];
    
    WEAKSELF
    if (self.allowsPanToDismissKeyboard) {
        // 控制输入工具条的位置块
        void (^AnimationForMessageInputViewAtPoint)(CGPoint point) = ^(CGPoint point) {
            CGRect inputViewFrame = weakSelf.messageInputView.frame;
            CGPoint keyboardOrigin = [weakSelf.view convertPoint:point fromView:nil];
            inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;
            weakSelf.messageInputView.frame = inputViewFrame;
        };
        
        self.messageTableView.keyboardDidScrollToPoint = ^(CGPoint point) {
            if (weakSelf.textViewInputViewType == XHInputViewTypeText)
                AnimationForMessageInputViewAtPoint(point);
        };
        
        self.messageTableView.keyboardWillSnapBackToPoint = ^(CGPoint point) {
            if (weakSelf.textViewInputViewType == XHInputViewTypeText)
                AnimationForMessageInputViewAtPoint(point);
        };
        
        self.messageTableView.keyboardWillBeDismissed = ^() {
            CGRect inputViewFrame = weakSelf.messageInputView.frame;
            inputViewFrame.origin.y = weakSelf.view.bounds.size.height - inputViewFrame.size.height;
            weakSelf.messageInputView.frame = inputViewFrame;
        };
    }
    
    // block回调键盘通知
    self.messageTableView.keyboardWillChange = ^(CGRect keyboardRect, UIViewAnimationOptions options, double duration, BOOL showKeyborad) {
        if (weakSelf.textViewInputViewType == XHInputViewTypeText) {
            if (showKeyborad) {
                //首先隐藏表情选择视图和多媒体分享选择视图
                weakSelf.shareMenuView.alpha = 0.0;
                weakSelf.emotionManagerView.alpha = 0.0;
                weakSelf.messageInputView.multiMediaSendButton.transform = CGAffineTransformIdentity;
            }
         
            [UIView animateWithDuration:duration
                                  delay:0.0
                                options:options
                             animations:^{
                                 CGFloat keyboardY = [weakSelf.view convertRect:keyboardRect fromView:nil].origin.y;
                                 
                                 CGRect inputViewFrame = weakSelf.messageInputView.frame;
                                 CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
                                 
                                 // for ipad modal form presentations
                                 CGFloat messageViewFrameBottom = weakSelf.view.frame.size.height - inputViewFrame.size.height;
                                 if (inputViewFrameY > messageViewFrameBottom)
                                     inputViewFrameY = messageViewFrameBottom;
                                 
                                 weakSelf.messageInputView.frame = CGRectMake(inputViewFrame.origin.x,
                                                                              inputViewFrameY,
                                                                              inputViewFrame.size.width,
                                                                              inputViewFrame.size.height);
                                 
                                 [weakSelf setTableViewInsetsWithBottomValue:weakSelf.view.frame.size.height
                                  - weakSelf.messageInputView.frame.origin.y];
                                 if (showKeyborad)
                                 {
                                     [weakSelf scrollToBottomAnimated:NO];
                                 }
                             }
                             completion:^(BOOL finished) {
                             }];
        }
    };
    
    self.messageTableView.keyboardDidChange = ^(BOOL didShowed) {
        if ([weakSelf.messageInputView.inputTextView isFirstResponder]) {
            if (didShowed) {
                if (weakSelf.textViewInputViewType == XHInputViewTypeText) {
                    weakSelf.shareMenuView.alpha = 0.0;
                    weakSelf.emotionManagerView.alpha = 0.0;
                }
            }
        }
    };
    
    self.messageTableView.keyboardDidHide = ^() {
        [weakSelf.messageInputView.inputTextView resignFirstResponder];
    };
    
    // 设置手势滑动，默认添加一个bar的高度值
    self.messageTableView.messageInputBarHeight = CGRectGetHeight(_messageInputView.bounds);
}

- (void)setBackgroundColor:(UIColor *)color {
    self.view.backgroundColor = color;
    _messageTableView.backgroundColor = color;
}


- (void)scrollToBottomAnimated:(BOOL)animated {
	
    NSInteger rows = [self.messageTableView numberOfRowsInSection:0];
    
    if (rows > 0) {
        [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                                     atScrollPosition:UITableViewScrollPositionBottom
                                             animated:animated];
    }
}


- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
			  atScrollPosition:(UITableViewScrollPosition)position
					  animated:(BOOL)animated {
	[self.messageTableView scrollToRowAtIndexPath:indexPath
                                 atScrollPosition:position
                                         animated:animated];
}

#pragma mark - Scroll Message TableView Helper Method

- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
    self.messageTableView.contentInset = insets;
    self.messageTableView.scrollIndicatorInsets = insets;
}

- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        insets.top = 0;
    }
    
    insets.bottom = bottom;
    
    return insets;
}


#pragma mark - SnailMessageInputViewDelegate 
//
- (void)didStartRecordingVoiceAction {
    [self startRecord];
}

- (void)didCancelRecordingVoiceAction {
    [self cancelRecord];
}

- (void)didFinishRecoingVoiceAction {
    //延迟1s停止记录。解决recorder记录语音比实际短的缺陷
    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(finishRecorded) userInfo:nil repeats:NO];
}

- (void)didDragOutsideAction {
    [self pauseRecord];
}

- (void)didDragInsideAction {
    [self resumeRecord];
}

- (void)didChangeSendVoiceAction:(BOOL)changed {
    if (changed) {
        if (self.textViewInputViewType == XHInputViewTypeText)
            return;
        // 在这之前，textViewInputViewType已经不是XHTextViewTextInputType
        [self layoutOtherMenuViewHiden:YES];
    }
}

- (void)didSendTextAction:(NSString *)text {
   
    //判断是否为空消息并展示提示框
    if ([self judgeNilMessageAndShowAlertForText:text]) {
        return;
    };
    
    //重置输入状态
//    [self layoutOtherMenuViewHiden:NO];
    [self.messageInputView.inputTextView setText:nil];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.messageInputView.inputTextView.enablesReturnKeyAutomatically = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.messageInputView.inputTextView.enablesReturnKeyAutomatically = YES;
            [self.messageInputView.inputTextView reloadInputViews];
        });
    }

    //空消息判断 并发送消息
    if (text != nil && ![text isEqualToString:@""]) {
        if ([self.delegate respondsToSelector:@selector(didSendText:fromSender:onDate:)]) {
            [self.delegate didSendText:text fromSender:nil onDate:[NSDate date]];
        }
    } else {
        self.messageInputView.inputTextView.placeHolder = @"不能发送空消息";
    }
}

- (BOOL)judgeNilMessageAndShowAlertForText:(NSString *)text
{
    NSString * regex = @" *";
    //添加空白文本判断
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL isWholeSpace = [predicate evaluateWithObject:text] || [text isEqualToString:@""];
    if (isWholeSpace) {
        [self.messageInputView.inputTextView setText:nil];
        UIAlertView * wholeSpaceAlert = [[UIAlertView alloc]initWithTitle:@"不能发送空白消息" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [wholeSpaceAlert show];
    }
    return isWholeSpace;
}

- (void)didSelectedMultipleMediaAction:(BOOL)openMutipleMedia {
    if (openMutipleMedia) {
        self.textViewInputViewType = XHInputViewTypeShareMenu;
        [self layoutOtherMenuViewHiden:NO];
    } else {
        self.textViewInputViewType = XHInputViewTypeText;
        self.shareMenuView.alpha = 0.0f;
        [self.messageInputView.inputTextView becomeFirstResponder];
    }
    
}

- (void)didSendFaceAction:(BOOL)sendFace {
    if (sendFace) {
        self.textViewInputViewType = XHInputViewTypeEmotion;
        [self layoutOtherMenuViewHiden:NO];
    } else {
        self.emotionManagerView.alpha = 0.0f;
        [self.messageInputView.inputTextView becomeFirstResponder];
    }
}

- (void)didSendMessageWithVoice:(NSString *)voicePath voiceDuration:(NSString*)voiceDuration {
    if ([self.delegate respondsToSelector:@selector(didSendVoice:voiceDuration:fromSender:onDate:)]) {
        [self.delegate didSendVoice:voicePath voiceDuration:voiceDuration fromSender:nil onDate:[NSDate date]];
    }
}

#pragma mark - Voice Recording Helper Method

- (void)startRecord {
    WEAKSELF
    [self.voiceRecordHUD startRecordingHUDAtView:self.view];
    [self.voiceRecordHelper startRecordingWithPath:[self getRecorderPath] StartRecorderCompletion:^{
        self.voiceRecordHelper.maxRecordTime = 60.0;
        self.voiceRecordHelper.countdownTime = 11.0f;;
    }];
    
    //设置倒计时触发方法
    self.voiceRecordHelper.timeCountdownShow = ^(){
        [weakSelf.voiceRecordHUD showCountdownAnimation];
    };
    
    //设置
    self.voiceRecordHelper.maxTimeStopRecorderCompletion = ^(){
        [weakSelf.voiceRecordHUD hideCountdownAnimation];
        [weakSelf.messageInputView.holdDownButton cancelTrackingWithEvent:nil];
        [weakSelf finishRecorded];
    };
}

- (void)finishRecorded {
    WEAKSELF
    [self.voiceRecordHUD stopRecordCompled:^(BOOL fnished) {
        weakSelf.voiceRecordHUD = nil;
    }];
    [self.voiceRecordHelper stopRecordingWithStopRecorderCompletion:^{
        
        // 将录制下来caf文件转码成amr文件
        NSString * currentCafPath = weakSelf.voiceRecordHelper.recordPath;
        NSString * currentDuration = weakSelf.voiceRecordHelper.recordDuration;
        float duration = [currentDuration intValue];
        NSLog(@"%f",duration);
        if (duration < 1) {
            [Common checkProgressHUD:@"语音时间太短 取消发送" andImage:nil showInView:APPKEYWINDOW];
            [[NSFileManager defaultManager]removeItemAtPath:weakSelf.voiceRecordHelper.recordPath error:nil];
            return ;
        }
        
        NSData * cafVoiceData = [NSData dataWithContentsOfFile:currentCafPath];
        NSData * amrVoiceData = EncodeWAVEToAMR(cafVoiceData, 1, 16);
        
        NSString * voiceAmrFilePath = [currentCafPath substringToIndex:currentCafPath.length - 4];
        voiceAmrFilePath = [voiceAmrFilePath stringByAppendingString:@".amr"];
        BOOL convertSuccess = NO;
        convertSuccess =  [amrVoiceData writeToFile:voiceAmrFilePath atomically:YES];
        if (convertSuccess) {
            [[NSFileManager defaultManager] removeItemAtPath:currentCafPath error:nil];
        }
        
        [weakSelf didSendMessageWithVoice:voiceAmrFilePath voiceDuration:weakSelf.voiceRecordHelper.recordDuration];
    }];
}


- (void)pauseRecord {
    [self.voiceRecordHUD pauseRecord];
}

- (void)resumeRecord {
    [self.voiceRecordHUD resaueRecord];
}

- (void)cancelRecord {
    WEAKSELF
    [self.voiceRecordHUD cancelRecordCompled:^(BOOL fnished) {
        weakSelf.voiceRecordHUD = nil;
    }];
    [self.voiceRecordHelper cancelledDeleteWithCompletion:^{
        
    }];
}

- (NSString *)getRecorderPath {
    NSString *recorderPath = nil;

    recorderPath = [SnailCacheManager getOrCreateFiledWithPathKind:VoiceFilePath];
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //    dateFormatter.dateFormat = @"hh-mm-ss";
    dateFormatter.dateFormat = @"yyyy-MM-dd-hh-mm-ss";
    NSString * voiceComponentName = [NSString stringWithFormat:@"%@-MySound.caf",[dateFormatter stringFromDate:now]];
    recorderPath = [recorderPath stringByAppendingPathComponent:voiceComponentName];
    
    return recorderPath;
}

#pragma mark - Calculate Cell Height 



#pragma mark- UITableViewDataScource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"SnailTableViewCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"This is father table method must override by children %d",indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor blackColor];
    return cell;
}

#pragma mark - Table View Delegate 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    id <XHMessageModel> message  = [self.messageLists objectAtIndex:indexPath.row];
//    return [self calculateCellHeightWithMessage:message atIndexPath:indexPath];
    return 80;
}

#pragma mark - Key-value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.messageInputView.inputTextView && [keyPath isEqualToString:@"contentSize"]) {
        [self layoutAndAnimateMessageInputTextView:object];
    }
}

#pragma mark - Layout Message Input View Helper Method

- (void)layoutAndAnimateMessageInputTextView:(UITextView *)textView {
    CGFloat maxHeight = [SnailMessageInputView maxHeight];
    
    CGFloat contentH = [self getTextViewContentH:textView];
    
    BOOL isShrinking = contentH < self.previousTextViewContentHeight;
    CGFloat changeInHeight = contentH - _previousTextViewContentHeight;
    
    if (!isShrinking && (self.previousTextViewContentHeight == maxHeight || textView.text.length == 0)) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }
    
    if (changeInHeight != 0.0f) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             [self setTableViewInsetsWithBottomValue:self.messageTableView.contentInset.bottom + changeInHeight];
                             
                             [self scrollToBottomAnimated:NO];
                             
                             if (isShrinking) {
                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                                     self.previousTextViewContentHeight = MIN(contentH, maxHeight);
                                 }
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [self.messageInputView adjustTextViewHeightBy:changeInHeight];
                             }
                             
                             CGRect inputViewFrame = self.messageInputView.frame;
                             self.messageInputView.frame = CGRectMake(0.0f,
                                                                      inputViewFrame.origin.y - changeInHeight,
                                                                      inputViewFrame.size.width,
                                                                      inputViewFrame.size.height + changeInHeight);
                             if (!isShrinking) {
                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                                     self.previousTextViewContentHeight = MIN(contentH, maxHeight);
                                 }
                                 // growing the view, animate the text view frame AFTER input view frame
                                 [self.messageInputView adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
        
        self.previousTextViewContentHeight = MIN(contentH, maxHeight);
    }
    
    // Once we reached the max height, we have to consider the bottom offset for the text view.
    // To make visible the last line, again we have to set the content offset.
    if (self.previousTextViewContentHeight == maxHeight) {
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime,
                       dispatch_get_main_queue(),
                       ^(void) {
                           CGPoint bottomOffset = CGPointMake(0.0f, contentH - textView.bounds.size.height);
                           [textView setContentOffset:bottomOffset animated:YES];
                       });
    }
}

#pragma mark - UITextView Helper Method

- (CGFloat)getTextViewContentH:(UITextView *)textView {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return ceilf([textView sizeThatFits:textView.frame.size].height);
    } else {
        return textView.contentSize.height;
    }
}

#pragma mark - Other Menu View Frame Helper Mehtod

- (void)layoutOtherMenuViewHiden:(BOOL)hide {
    
    [self.messageInputView.inputTextView resignFirstResponder];
    
    __block CGRect inputViewFrame = self.messageInputView.frame;
    __block CGRect otherMenuViewFrame = CGRectZero;
    
    void (^InputViewAnimation)(BOOL hide) = ^(BOOL hide) {
        inputViewFrame.origin.y = (hide ? (CGRectGetHeight(self.view.bounds) - CGRectGetHeight(inputViewFrame)) : (CGRectGetMinY(otherMenuViewFrame) - CGRectGetHeight(inputViewFrame)));
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.messageInputView.frame = inputViewFrame;}completion:nil];
    };
    
    void (^EmotionManagerViewAnimation)(BOOL hide) = ^(BOOL hide) {
        otherMenuViewFrame = self.emotionManagerView.frame;
        otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.view.frame) : (CGRectGetHeight(self.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
        self.emotionManagerView.alpha = 1.0f;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.emotionManagerView.frame = otherMenuViewFrame;}completion:nil];
    };
    
    void (^ShareMenuViewAnimation)(BOOL hide) = ^(BOOL hide) {
        otherMenuViewFrame = self.shareMenuView.frame;
        otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.view.frame) : (CGRectGetHeight(self.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
        self.shareMenuView.alpha = 1.0f;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.shareMenuView.frame = otherMenuViewFrame;}completion:nil];
    };
    
    if (hide) {
        switch (self.textViewInputViewType) {
            case XHInputViewTypeEmotion: {
                EmotionManagerViewAnimation(hide);
                break;
            }
            case XHInputViewTypeShareMenu: {
                ShareMenuViewAnimation(hide);
                break;
            }
            default:
                break;
        }
    } else {
        
        // 这里需要注意block的执行顺序，因为otherMenuViewFrame是公用的对象，所以对于被隐藏的Menu的frame的origin的y会是最大值
        switch (self.textViewInputViewType) {
            case XHInputViewTypeEmotion: {
                // 1、先隐藏和自己无关的View
                ShareMenuViewAnimation(!hide);
                // 2、再显示和自己相关的View
                EmotionManagerViewAnimation(hide);
                break;
            }
            case XHInputViewTypeShareMenu: {
                // 1、先隐藏和自己无关的View
                EmotionManagerViewAnimation(!hide);
                // 2、再显示和自己相关的View
                ShareMenuViewAnimation(hide);
                break;
            }
            default:
                break;
        }
    }
    
    InputViewAnimation(hide);
    
    [self setTableViewInsetsWithBottomValue:self.view.frame.size.height
     - self.messageInputView.frame.origin.y];
    
    if (self.shouldScrollToLastCell) {
        [self scrollToBottomAnimated:NO];
    }
    
    //重置所有的聊天按钮
}

#pragma mark - SnailMessageInputView Delegate

- (void)inputTextViewWillBeginEditing:(SnailMessageTextView *)messageInputTextView {
    self.textViewInputViewType = XHInputViewTypeText;
}

- (void)inputTextViewDidBeginEditing:(SnailMessageTextView *)messageInputTextView {
    if (!self.previousTextViewContentHeight)
		self.previousTextViewContentHeight = [self getTextViewContentH:messageInputTextView];
    
    if (messageInputTextView.text.length > 0) {
        [self.emotionManagerView enabelSendButton];
    } else {
        [self.emotionManagerView graySendButton];
    }
}

#pragma mark - XHEmotionManagerView DataSource

- (NSInteger)numberOfEmotionManagers {
    return self.emotionManagers.count;
}

- (XHEmotionManager *)emotionManagerForColumn:(NSInteger)column {
    if (column < self.emotionManagers.count) {
        return [self.emotionManagers objectAtIndex:column];
    } else {
        return nil;
    }
}

- (NSArray *)emotionManagersAtManager {
    return self.emotionManagers;
}

#pragma mark - XHAudioPlayerDelegate 

- (void)didAudioPlayerBeginPlay:(AVAudioPlayer*)audioPlayer
{
    NSLog(@"Voice begin play");
}

- (void)didAudioPlayerStopPlay:(AVAudioPlayer*)audioPlayer
{
    NSLog(@"Voice stop play");
}
- (void)didAudioPlayerPausePlay:(AVAudioPlayer*)audioPlayer
{
    NSLog(@"Voice pause play");
}

#pragma mark - EmotionFaceViewDelegate


- (void)faceView:(id)emotionView didSelectAtString:(NSString *)faceString
{
    //iOS6当textView处于初始化状态时selectedRange为NSNotFound。在此需要手动设置为0.0
    if ([[UIDevice currentDevice]systemVersion].intValue <7.0 && self.messageInputView.inputTextView.selectedRange.location == NSNotFound) {
        
        NSRange currentRrage = NSMakeRange(0, 0);
        self.messageInputView.inputTextView.selectedRange = currentRrage;
    }
    [self.messageInputView.inputTextView insertText:faceString];
    
    if (self.messageInputView.inputTextView.text.length > 0) {
        [self.emotionManagerView enabelSendButton];
    }
    
}

- (void)delFaceString
{
    if (![TQRichTextEmojiRun deleteLastEmojiStrForTextView:self.messageInputView.inputTextView]) {
        [self.messageInputView.inputTextView deleteBackward];
    }
    
    if (self.messageInputView.inputTextView.text.length == 0) {
        [self.emotionManagerView graySendButton];
    }
}

@end
