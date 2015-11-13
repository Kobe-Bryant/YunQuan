//
//  WarmTipsViewController.m
//  ql
//
//  Created by yunlai on 14-2-22.
//  Copyright (c) 2014年 ChenFeng. All rights reserved.
//

#import "WarmTipsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Common.h"
#import "ChatBubbleCell.h"
#import "UIImageView+WebCache.h"

#import "MessageDataManager.h"
#import "TcpRequestHelper.h"
#import "ChatTcpHelper.h"

#import "secretary_feedback_model.h"
#import "secretary_privilege_model.h"
#import "secretary_tool_model.h"
#import "secret_message_model.h"

#import "UIViewController+NavigationBar.h"
#import "TextData.h"
#import "ThemeManager.h"
#import "config.h"
#import "Global.h"
#import "NetManager.h"
#import "UIImageScale.h"

#define KCommentBarHeight 50 
#define kHeadImageWH 50
#define kPadding 10

@interface WarmTipsViewController ()<TcpRequestHelperDelegate>
{
    HPGrowingTextView *textView;
    UIView *containerView;
    NSString *tempTextContent;
    
    MessageDataManager *dataManager;
}
@property (nonatomic ,retain) NSString *tempTextContent;

@end

@implementation WarmTipsViewController
@synthesize chatTabelView = _chatTabelView;
@synthesize listArray = _listArray;
@synthesize tempTextContent,tipsString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //注册键盘通知
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification
												   object:nil];
        
        _listArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tipsMessageReceive:) name:@"tipsMessageReceive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishmessageSend:) name:@"messageSendSuccess" object:nil];
    
    [super viewDidLoad];
	self.view.backgroundColor = [[ThemeManager shareInstance] getColorWithName:@"COLOR_LIGHTWEIGHT"];
//    self.view.backgroundColor = COLOR_LIGHTWEIGHT;
    
    self.title = @"小秘书";
    
    if (IOS_VERSION_7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    secret_message_model* sMod = [[secret_message_model alloc] init];
    int msgtype = 0;
    switch (_ttype) {
        case NoAcoutTips:
        {
            msgtype = 1;
        }
            break;
        case ToolTips:
        {
            msgtype = 3;
        }
            break;
        case PriTips:
        {
            msgtype = 3;
        }
            break;
        case FeedbackTips:
        {
            msgtype = 4;
        }
            break;
        default:
            break;
    }
    
    sMod.where = [NSString stringWithFormat:@"type = %d",msgtype];
    NSArray* arr = [sMod getList];
    NSDictionary* msgDic = [arr lastObject];
    
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"0",@"id",
                         [NSNumber numberWithInt:[[[Global sharedGlobal].secretInfo objectForKey:@"user_id"] intValue]],@"user_id",
                         [[Global sharedGlobal].secretInfo objectForKey:@"portrait"],@"portrait",
                         [[Global sharedGlobal].secretInfo objectForKey:@"realname"],@"realname",
                         [msgDic objectForKey:@"message"],@"message",
                         nil];
    
    [_listArray addObject:dic];
    
    if (_ttype != NoAcoutTips) {
        [self readHistoryMsg];
    }
    
    [self backBar];
    [self mainlayoutView];
}

-(void) readHistoryMsg{
    switch (_ttype) {
        case FeedbackTips:
        {
            secretary_feedback_model* fMod = [[secretary_feedback_model alloc] init];
            fMod.orderType = @"asc";
            fMod.orderBy = @"created";
            [_listArray addObjectsFromArray:[fMod getList]];
            
            [fMod release];
        }
            break;
        case ToolTips:
        {
            secretary_tool_model* tMod = [[secretary_tool_model alloc] init];
            tMod.orderType = @"asc";
            tMod.orderBy = @"created";
            [_listArray addObjectsFromArray:[tMod getList]];
            
            [tMod release];
        }
            break;
        case PriTips:
        {
            secretary_privilege_model* pMod = [[secretary_privilege_model alloc] init];
            pMod.orderType = @"asc";
            pMod.orderBy = @"created";
            [_listArray addObjectsFromArray:[pMod getList]];
            
            [pMod release];
        }
            break;
        default:
            break;
    }
}

/**
 *  返回按钮
 */
- (void)backBar{
    
    //返回按钮  add vincnet
    UIButton *backButton = [self setBackBarButton:nil];
    [backButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    [self setBackBarButtonItem:backButton];
}

-(void) backTo{
    if (self.ttype == NoAcoutTips) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

/**
 *  主界面
 */
- (void)mainlayoutView{
    
    //聊天消息列表
    _chatTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KUIScreenWidth, KUIScreenHeight - KUpBarHeight - KCommentBarHeight) style:UITableViewStylePlain];
    _chatTabelView.delegate = self;
    _chatTabelView.dataSource = self;
	[_chatTabelView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_chatTabelView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_chatTabelView];
    
    [_chatTabelView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_listArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    //发消息框
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, KUIScreenHeight - KUpBarHeight - KCommentBarHeight, KUIScreenWidth, KCommentBarHeight)];
//    containerView.backgroundColor = [UIColor whiteColor];
    containerView.backgroundColor = [UIColor colorWithPatternImage:[[ThemeManager shareInstance] getThemeImage:@"under_bar.png"]];
    [self.view addSubview:containerView];
    
    UIView *textBgView = [[UIView alloc] initWithFrame:CGRectMake(5,5, 310-65, KCommentBarHeight - kPadding)];
    textBgView.layer.cornerRadius = 3;
    textBgView.layer.masksToBounds = YES;
    textBgView.backgroundColor = COLOR_LIGHTWEIGHT;
    textBgView.layer.borderColor = [UIColor whiteColor].CGColor;
    textBgView.layer.borderWidth = 1;
    textBgView.tag = 2000;
    [containerView addSubview:textBgView];
    
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(0, 0, 310-65, textBgView.frame.size.height)];
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 3;
	textView.font = [UIFont systemFontOfSize:15.0f];
    textView.textColor = [UIColor grayColor];
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor clearColor];
    textView.placeholder = @"戳这里输入...";
	[textBgView addSubview:textView];
    [textBgView release];
    
    //字数统计
	UILabel *remainCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(265.0f, 5.0f, 50.0f, 20.0f)];
	[remainCountLabel setFont:[UIFont systemFontOfSize:12.0f]];
	remainCountLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
	remainCountLabel.tag = 2004;
	remainCountLabel.text = @"140/140";
	remainCountLabel.hidden = YES;
	remainCountLabel.backgroundColor = [UIColor clearColor];
	remainCountLabel.lineBreakMode = NSLineBreakByCharWrapping | NSLineBreakByTruncatingTail;
	remainCountLabel.textAlignment = NSTextAlignmentCenter;
	[containerView addSubview:remainCountLabel];
	[remainCountLabel release];
	
	//添加发送按钮
	
	UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	sendBtn.frame = CGRectMake(containerView.frame.size.width - 65, 8, 60, KCommentBarHeight - kPadding-5);
	sendBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    sendBtn.layer.borderColor = [UIColor grayColor].CGColor;
    sendBtn.layer.borderWidth = 0.5f;
    sendBtn.layer.cornerRadius = 4.0;
    sendBtn.layer.masksToBounds = YES;
    [sendBtn setTitleColor:COLOR_FONT forState:UIControlStateNormal];
	[sendBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
	sendBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
	sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
	sendBtn.tag = 2003;
	//sendBtn.hidden = YES;
    sendBtn.backgroundColor = [UIColor whiteColor];
	[sendBtn addTarget:self action:@selector(publishComment:) forControlEvents:UIControlEventTouchUpInside];
	
	[containerView addSubview:sendBtn];
}

- (void)dealloc
{
//    [dataManager release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tipsMessageReceive" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"messageSendSuccess" object:nil];
    [_chatTabelView release];
    [_listArray release];
    [tempTextContent release];

    [super dealloc];
}
//发送消息
-(void)publishComment:(id)sender
{
    NSString *content = textView.text;
    //NSLog(@"content===%@",content);
    //把回车 转化成 空格
    content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    if ([content length] > 0)
    {
        if ([content length] > 140)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"回复内容不能超过140个字符" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
        }
        else
        {
//            NSMutableDictionary *dic =  [self appendTableWith:textView.text];
            switch (_ttype) {
                case NoAcoutTips:
                {
                    [self accessSendNoCountTips];
                }
                    break;
                case ToolTips:
                {
                    [self accessSendToolTips];
                }
                    break;
                case PriTips:
                {
                    [self accessSendPriTips];
                }
                    break;
                case FeedbackTips:
                {
                    [self accessSendFeedback];
                }
                    break;
                default:
                    break;
            }
        }
    }
    else
    {
        [self hiddenKeyboard];
    }
}

- (NSMutableDictionary *)appendTableWith:(NSString *)text
{
    //把回车 转化成 空格
    text = [text stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    self.chatTabelView.scrollEnabled = YES;
    UILabel *label = (UILabel *)[self.view viewWithTag:11];
    if (label != nil) {
        [label removeFromSuperview];
    }
    
    //填充数据
    int oldCount = [self.listArray count];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                text,@"message",
                                [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]],@"created",
                                @"",@"portrait",
                                [NSNumber numberWithInt:4],@"type",
                                @"sendMessageSelf",@"sendMessageSelf",
                                nil];
    
    NSLog(@"==dic:%@==",dic);
    
    [self.listArray addObject:dic];
    
    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:1];
    
    for (int i = 0; i < (self.listArray.count - oldCount); i++) {
        NSIndexPath *insertNewPath = [NSIndexPath indexPathForRow:oldCount + i inSection:0];
        [insertIndexPaths addObject:insertNewPath];
    }
    
    if ([self.listArray count] != 0 )
    {
        
        [self.chatTabelView insertRowsAtIndexPaths:insertIndexPaths
                                withRowAnimation:UITableViewRowAnimationFade];
        
        //滚动到最后一行
        if ([self.listArray count] > 0)
        {
            [self.chatTabelView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.listArray count]-1 inSection:0]
                                    atScrollPosition:UITableViewScrollPositionBottom
                                            animated:NO];
        }
        
        [self.chatTabelView reloadRowsAtIndexPaths:insertIndexPaths
                                withRowAnimation:UITableViewRowAnimationRight];
    }
    else
    {
        [self.chatTabelView insertRowsAtIndexPaths:insertIndexPaths
                                withRowAnimation:UITableViewRowAnimationLeft];
    }

    [_chatTabelView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_listArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [_chatTabelView reloadData];
    return dic;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
 
    return [self.listArray count];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //return 80.0f;
    if (self.listArray != nil && [self.listArray count] > 0) {
        
        NSDictionary *commentDic = [self.listArray objectAtIndex:[indexPath row]];
        NSString *text = [commentDic objectForKey:@"message"];//content
        
        
       // float length = text.length * 20;
       // float width = length > 200 ? 200 : length;
        CGSize titleSize = [text sizeWithFont:[UIFont systemFontOfSize:16]
                            constrainedToSize:CGSizeMake(310-65,MAXFLOAT)
                                lineBreakMode:NSLineBreakByWordWrapping];
        //20为气泡上下间隔,50为头像高度 30为时间高度
        CGFloat height = (titleSize.height + 20) > kHeadImageWH ? titleSize.height + 20 : kHeadImageWH;
        return height + 30 + 30;
        
    }else{
        return 0.f;
    }
    
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tableCell";
    ChatBubbleCell *cell = (ChatBubbleCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[[ChatBubbleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
    }
   
    NSMutableDictionary *dic = [self.listArray objectAtIndex:[indexPath row]];

    int createTime = [[dic objectForKey:@"created"] intValue];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:createTime];
    NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
    [outputFormat setDateFormat:@"MM-dd HH:mm"];
    NSString *dateString = [outputFormat stringFromDate:date];
    cell.timeLabel.text = dateString;
    [outputFormat release];

    
    if (indexPath.row == 0) {
        cell.type = BubbleTypeSomeoneElse;
    }else{
        if ([[dic objectForKey:@"user_id"] intValue] == [[[Global sharedGlobal].secretInfo objectForKey:@"user_id"] intValue]) {
            cell.type = BubbleTypeSomeoneElse;
        }else{
            cell.type = BubbleTypeMine;
        }
    }

    cell.contentL.text = [dic objectForKey:@"message"];
    
    float length = cell.contentL.text.length * 20;
    float width = length > 200 ? 200 : length;
    CGSize titleSize = [cell.contentL.text sizeWithFont:[UIFont systemFontOfSize:16]
                              constrainedToSize:CGSizeMake(width,MAXFLOAT)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    
    
    UIImage *balloonImg = nil;
    
    // 对方消息显示
    if (cell.type == BubbleTypeSomeoneElse)
    {
        cell.bgView.frame = CGRectMake(70, 30,  titleSize.width+20, titleSize.height+kPadding*2);

        cell.headerImageView.frame = CGRectMake(kPadding, 25, kHeadImageWH, kHeadImageWH);
    
        [cell.headerImageView setImageWithURL:[NSURL URLWithString:[[Global sharedGlobal].secretInfo objectForKey:@"portrait"]] placeholderImage:IMG(@"kf.jpg")];
        
        cell.contentL.frame = CGRectMake(15, 5, titleSize.width, titleSize.height);
        
        balloonImg = [UIImage imageNamed:@"bg_common_dialog_white.png"];
        
        //小秘书时间不显示
        if (indexPath.row == 0) {
            cell.timeLabel.hidden = YES;
        }
    }
    else
    {//自己发送的消息
//        UIImage *headerImage = [UIImage imageCwNamed:@"15.png"];
//        cell.headerImageView.image = [headerImage fillSize:CGSizeMake(kHeadImageWH, kHeadImageWH)];
        switch (_ttype) {
            case NoAcoutTips:
            {
                UIImage *headerImage = [UIImage imageCwNamed:DEFAULT_MALE_PORTRAIT_NAME];
                cell.headerImageView.image = [headerImage fillSize:CGSizeMake(kHeadImageWH, kHeadImageWH)];
            }
                break;
            case PriTips:
            {
                [cell.headerImageView setImageWithURL:[NSURL URLWithString:[[Global sharedGlobal].userInfo objectForKey:@"portrait"]] placeholderImage:IMG(DEFAULT_MALE_PORTRAIT_NAME)];
            }
                break;
            case ToolTips:
            {
                [cell.headerImageView setImageWithURL:[NSURL URLWithString:[[Global sharedGlobal].userInfo objectForKey:@"portrait"]] placeholderImage:IMG(DEFAULT_MALE_PORTRAIT_NAME)];
            }
                break;
            case FeedbackTips:
            {
                [cell.headerImageView setImageWithURL:[NSURL URLWithString:[[Global sharedGlobal].userInfo objectForKey:@"portrait"]] placeholderImage:IMG(DEFAULT_MALE_PORTRAIT_NAME)];
            }
                break;
            default:
                break;
        }
        cell.headerImageView.frame = CGRectMake(320-60, 25, kHeadImageWH, kHeadImageWH);
        
        cell.bgView.frame = CGRectMake(320-70-titleSize.width - 20, 30,  titleSize.width+20, titleSize.height+kHeadImageWH);
        
        cell.contentL.frame = CGRectMake(kPadding, kPadding, titleSize.width, titleSize.height);
        balloonImg = [UIImage imageNamed:@"bg_common_dialog_blue.png"];
    }
    

    balloonImg = [balloonImg stretchableImageWithLeftCapWidth:23 topCapHeight:23];
    cell.imageBgView.frame = CGRectMake(0, 0, titleSize.width+25, titleSize.height+20);
    cell.imageBgView.image = balloonImg;
        
    
    return cell;
}
#pragma mark 键盘通知调用
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
	
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
	
    UIButton *bgBtn = (UIButton *)[self.view viewWithTag:2005];
    if (bgBtn != nil) {
        [bgBtn removeFromSuperview];
    }
	//新增一个遮罩按钮
	UIButton *backGrougBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	backGrougBtn.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (keyboardBounds.size.height + containerFrame.size.height) - 20);
	backGrougBtn.tag = 2005;
	[backGrougBtn addTarget:self action:@selector(hiddenKeyboard) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backGrougBtn];
	
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	containerView.frame = containerFrame;
    
    self.chatTabelView.frame = CGRectMake(0, 0, 320, 371);
    
	// commit animations
	[UIView commitAnimations];
    
    //改变tableView的大小以及位置
    [self performSelector:@selector(setTableViewSizeAndOrigin) withObject:nil afterDelay:[duration doubleValue]];
	
	//更改按钮状态
	[self buttonChange:YES];
	
}

-(void) keyboardWillHide:(NSNotification *)note{
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    self.chatTabelView.frame = CGRectMake(0, 0 - keyboardBounds.size.height, 320, 124);
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	containerView.frame = containerFrame;
    
    self.chatTabelView.frame = CGRectMake(0, 0, 320, self.view.frame.size.height - KCommentBarHeight);
    
	// commit animations
	[UIView commitAnimations];
    
	//移出遮罩按钮
	UIButton *backGrougBtn = (UIButton *)[self.view viewWithTag:2005];
	[backGrougBtn removeFromSuperview];
	
	//更改按钮状态
	[self buttonChange:NO];
}

//关闭键盘
-(void)hiddenKeyboard
{
    //输入内容 存起来
	self.tempTextContent = textView.text;
//	textView.placeholder = @"戳这里输入...";
    textView.text = textView.text;
	textView.textColor = [UIColor grayColor];
	[textView resignFirstResponder];
}


#pragma mark 改变键盘按钮
-(void)buttonChange:(BOOL)isKeyboardShow
{
//	//判断软键盘显示
//	if (isKeyboardShow)
//	{
        UIButton *sendBtn = (UIButton *)[containerView viewWithTag:2003];
        
        //缩小输入框
        if (sendBtn.hidden)
        {
            UIView *entryImageView = (UIView *)[containerView viewWithTag:2000];
            CGRect entryFrame = entryImageView.frame;
            entryFrame.size.width -= 65.0f;
            
            CGRect textFrame = textView.frame;
            textFrame.size.width -= 65.0f;
            
            entryImageView.frame = entryFrame;
            textView.frame = textFrame;
        }
		
		//显示字数统计
		UILabel *remainCountLabel = (UILabel *)[containerView viewWithTag:2004];
		remainCountLabel.hidden = NO;
		
		//显示发送按钮
		sendBtn.hidden = NO;
        
//	}
//	else
//	{
//		//拉长输入框
//        //隐藏字数统计
//		UILabel *remainCountLabel = (UILabel *)[containerView viewWithTag:2004];
//		remainCountLabel.hidden = YES;
//		
//		//隐藏发送按钮
//		UIButton *sendBtn = (UIButton *)[containerView viewWithTag:2003];
//		sendBtn.hidden = YES;
//        
//		UIView *entryImageView = (UIView *)[containerView viewWithTag:2000];
//		CGRect entryFrame = entryImageView.frame;
//		entryFrame.size.width += 65.0f;
//		
//		CGRect textFrame = textView.frame;
//		textFrame.size.width += 65.0f;
//		
//		entryImageView.frame = entryFrame;
//		textView.frame = textFrame;
//		
//	}

}

#pragma mark 点击监听
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//输入内容 存起来
	self.tempTextContent = textView.text;
	textView.placeholder = @"戳这里输入...";
	textView.textColor = [UIColor grayColor];
    
	//[textView resignFirstResponder];
}


#pragma mark -----HPGrowingTextViewDelegate methods
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
	CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	containerView.frame = r;
    
    UIView *entryImageView = (UIView *)[containerView viewWithTag:2000];
    CGRect entryFrame = entryImageView.frame;
    entryFrame.size.height -= diff;
    entryImageView.frame = entryFrame;
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
//    add vincent
//    growingTextView.text = @"";
    return YES;
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
	if([growingTextView.text isEqualToString:@"戳这里输入..."])
	{
		//内容设置回来
		growingTextView.text = self.tempTextContent;
	}
	growingTextView.textColor = [UIColor grayColor];
	
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	[self performSelectorOnMainThread:@selector(doEditing) withObject:nil waitUntilDone:NO];
	return YES;
}

#pragma mark - private mothod

-(void)doEditing
{
	UILabel *remainCountLabel = (UILabel *)[containerView viewWithTag:2004];
	int textCount = [textView.text length];
	if (textCount > 140)
	{
		remainCountLabel.textColor = [UIColor colorWithRed:1.0 green: 0.0 blue: 0.0 alpha:1.0];
	}
	else
	{
		remainCountLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
	}
	
	remainCountLabel.text = [NSString stringWithFormat:@"%d/140",140 - [textView.text length]];
}

- (void)setTableViewSizeAndOrigin
{
    self.chatTabelView.frame = CGRectMake(0, 0, 320, 225);
    
    //滚动到最后一行
    if ([self.listArray count] > 0)
    {
        [self.chatTabelView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.listArray count]-1 inSection:0]
                                atScrollPosition:UITableViewScrollPositionBottom
                                        animated:NO];
    }
    
}

-(void) accessSendFeedback{
    NSTimeInterval timeInt = [[NSDate date]timeIntervalSince1970];
    
    NSDictionary *textObject = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"objtype",@"1",@"txttype",textView.text,@"txt",nil];
    
    NSMutableArray * dataArr = [NSMutableArray arrayWithObjects:textObject,nil];
    
    MessageData * textMessageData = [[MessageData alloc] init];
    textMessageData.msg = dataArr;
    textMessageData.senderID = [[Global sharedGlobal].user_id intValue];
    textMessageData.receiverID = [[[Global sharedGlobal].secretInfo objectForKey:@"user_id"] intValue];
    
    textMessageData.sendCommandType = CMD_PERSONAL_MSGSEND;
    textMessageData.msgtype = 1;
    textMessageData.flag = 1;
    textMessageData.sendtime = timeInt;
    
    [[ChatTcpHelper shareChatTcpHelper]connectToHost];
    [TcpRequestHelper shareTcpRequestHelperHelper].delegate = self;
    [[TcpRequestHelper shareTcpRequestHelperHelper]sendMessagePackageCommandId:TCP_TEXTMESSAG_EPERSON_COMMAND_ID andMessageData:textMessageData];
    
}

#pragma mark - messageSend
//小秘书消息回调
-(void) tipsMessageReceive:(NSNotification*) notify{
    NSLog(@"==收到小秘书==");
    
    MessageData* msgData = notify.object;
    TextData * tData = [[TextData alloc]initWithDic:[msgData.msg firstObject]];
    
    NSString *message = tData.txt;
    
    NSDictionary* tDic = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:[[[Global sharedGlobal].secretInfo objectForKey:@"id"] intValue]],@"user_id",
                          [[Global sharedGlobal].userInfo objectForKey:@"realname"],@"realname",
                          [[Global sharedGlobal].userInfo objectForKey:@"portrait"],@"portrait",
                          message,@"message",
                          [NSNumber numberWithInt:msgData.sendtime],@"create",
                          nil];
    [self saveMsgToDB:tDic];
    
    [tData release];
    
    [_listArray addObject:tDic];
    [_chatTabelView reloadData];
}

//小秘书单聊回调
-(void) finishmessageSend:(NSNotification*)notify{
    NSDictionary* retDic = notify.object;
    NSLog(@"In Warm Message Sended With dic %@ ",retDic);
    
    if ([[retDic objectForKey:@"rcode"]intValue] == 0) {
        
//        [self insertMsg];
        [self hiddenKeyboard];
        
        NSString* contentStr = textView.text;
        
        NSDictionary* fDic = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"0",@"id",
                              [NSNumber numberWithInt:[[Global sharedGlobal].user_id intValue]],@"user_id",
                              [[Global sharedGlobal].userInfo objectForKey:@"realname"],@"realname",
                              [[Global sharedGlobal].userInfo objectForKey:@"portrait"],@"portrait",
                              contentStr,@"message",
                              [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]],@"created",
                              nil];
        [_listArray addObject:fDic];
        [_chatTabelView reloadData];
        [_chatTabelView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_listArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [self saveMsgToDB:fDic];
        
        textView.text = @"";
    }else{
        [Common checkProgressHUDShowInAppKeyWindow:@"发送失败" andImage:KAccessFailedIMG];
    }
}

-(void) insertMsg{
    switch (_ttype) {
        case FeedbackTips:
        {
            secretary_feedback_model* fMod = [[secretary_feedback_model alloc] init];
            
            [_listArray addObjectsFromArray:[fMod getList]];
            
            [fMod release];
        }
            break;
        case ToolTips:
        {
            secretary_tool_model* tMod = [[secretary_tool_model alloc] init];
            
            [_listArray addObjectsFromArray:[tMod getList]];
            
            [tMod release];
        }
            break;
        case PriTips:
        {
            secretary_privilege_model* pMod = [[secretary_privilege_model alloc] init];
            
            [_listArray addObjectsFromArray:[pMod getList]];
            
            [pMod release];
        }
            break;
        default:
            break;
    }
}

-(void) saveMsgToDB:(NSDictionary*) dic{
    switch (_ttype) {
        case FeedbackTips:
        {
            secretary_feedback_model* fMod = [[secretary_feedback_model alloc] init];
            
            NSDictionary* fDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:[[dic objectForKey:@"user_id"] intValue]],@"user_id",
                                  [dic objectForKey:@"realname"],@"realname",
                                  [dic objectForKey:@"portrait"],@"portrait",
                                  [dic objectForKey:@"message"],@"message",
                                  [NSNumber numberWithInteger:[[dic objectForKey:@"created"] intValue]],@"created",
                                  nil];
            NSLog(@"fDic:%@",fDic);
            [fMod insertDB:fDic];
            
            [fMod release];
        }
            break;
        case ToolTips:
        {
            secretary_tool_model* tMod = [[secretary_tool_model alloc] init];
            
            NSDictionary* fDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:[[dic objectForKey:@"user_id"] intValue]],@"user_id",
                                  [dic objectForKey:@"realname"],@"realname",
                                  [dic objectForKey:@"portrait"],@"portrait",
                                  [dic objectForKey:@"message"],@"message",
                                  [NSNumber numberWithInteger:[[dic objectForKey:@"created"] intValue]],@"created",
                                  nil];
            [tMod insertDB:fDic];
            
            [tMod release];
        }
            break;
        case PriTips:
        {
            secretary_privilege_model* pMod = [[secretary_privilege_model alloc] init];
            
            NSDictionary* fDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:[[dic objectForKey:@"user_id"] intValue]],@"user_id",
                                  [dic objectForKey:@"realname"],@"realname",
                                  [dic objectForKey:@"portrait"],@"portrait",
                                  [dic objectForKey:@"message"],@"message",
                                  [NSNumber numberWithInteger:[[dic objectForKey:@"created"] intValue]],@"created",
                                  nil];
            [pMod insertDB:fDic];
            
            [pMod release];
        }
            break;
        default:
            break;
    }
}

-(void) accessSendPriTips{
    NSTimeInterval timeInt = [[NSDate date]timeIntervalSince1970];
    
    NSDictionary *textObject = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"objtype",@"1",@"txttype",textView.text,@"txt",nil];
    
    NSMutableArray * dataArr = [NSMutableArray arrayWithObjects:textObject,nil];
    
    MessageData * textMessageData = [[MessageData alloc] init];
    textMessageData.title = @"";
    textMessageData.msg = dataArr;
    textMessageData.senderID = [[Global sharedGlobal].user_id intValue];
    textMessageData.receiverID = [[[Global sharedGlobal].secretInfo objectForKey:@"user_id"] intValue];
    textMessageData.sendCommandType = CMD_PERSONAL_MSGSEND;
    textMessageData.msgtype = 1;
    textMessageData.talkType = 2;
    textMessageData.flag = 1;
    textMessageData.sendtime = timeInt;
    
    [[ChatTcpHelper shareChatTcpHelper]connectToHost];
    [[TcpRequestHelper shareTcpRequestHelperHelper]sendMessagePackageCommandId:TCP_TEXTMESSAG_EPERSON_COMMAND_ID andMessageData:textMessageData];
//    [dataManager release];
}

-(void) accessSendNoCountTips{
    [textView resignFirstResponder];
    NSString* reqUrl = @"feedback.do?param=";
    NSMutableDictionary* requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                       [[Global sharedGlobal].secretInfo objectForKey:@"id"],@"to_id",
                                       textView.text,@"content",
//                                       [NSNumber numberWithInt:[[Global sharedGlobal].org_id intValue]],@"org_id",
                                       nil];
    
    [[NetManager sharedManager] accessService:requestDic data:nil command:MEMBER_NOCOUNTTIPS_COMMAND_ID accessAdress:reqUrl delegate:self withParam:nil];
    
}

-(void) accessSendToolTips{
    NSTimeInterval timeInt = [[NSDate date]timeIntervalSince1970];
    
    NSDictionary *textObject = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"objtype",@"1",@"txttype",textView.text,@"txt",nil];
    
    NSMutableArray * dataArr = [NSMutableArray arrayWithObjects:textObject,nil];
    
    MessageData * textMessageData = [[MessageData alloc] init];
    textMessageData.msg = dataArr;
    textMessageData.senderID = [[Global sharedGlobal].user_id intValue];
    textMessageData.receiverID = [[[Global sharedGlobal].secretInfo objectForKey:@"user_id"] intValue];
    textMessageData.sendCommandType = CMD_PERSONAL_MSGSEND;
    textMessageData.msgtype = 1;
    textMessageData.flag = 1;
    textMessageData.sendtime = timeInt;
    
    
    [[ChatTcpHelper shareChatTcpHelper]connectToHost];
    [TcpRequestHelper shareTcpRequestHelperHelper].delegate = self;
    [[TcpRequestHelper shareTcpRequestHelperHelper]sendMessagePackageCommandId:TCP_TEXTMESSAG_EPERSON_COMMAND_ID andMessageData:textMessageData];
}

//请求回调
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
    NSLog(@"====");
    if (resultArray && ![[resultArray lastObject] isKindOfClass:[NSString class]]) {
        switch (commandid) {
            case MEMBER_NOCOUNTTIPS_COMMAND_ID:
            {
                //没有帐号小秘书
                if ([[[resultArray lastObject] objectForKey:@"ret"] intValue] == 1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self noAcountSendSuccess];
                        
                    });
                }else{
                    [Common checkProgressHUDShowInAppKeyWindow:@"发送失败" andImage:KAccessFailedIMG];
                }
            }
                break;
            default:
                break;
        }
    }
}

-(void) noAcountSendSuccess{
    [self hiddenKeyboard];
    [self appendTableWith:textView.text];
    //初始化
    textView.text = @"";
    tempTextContent = @"";
}

@end
