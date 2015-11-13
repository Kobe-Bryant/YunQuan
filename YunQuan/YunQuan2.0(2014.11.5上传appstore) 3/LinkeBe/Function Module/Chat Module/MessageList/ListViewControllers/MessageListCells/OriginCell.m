//
//  originCell.m
//  ql
//
//  Created by LazySnail on 14-4-27.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "SBJson.h"
#import "OriginCell.h"
#import "Common.h"

#import "UIImageView+WebCache.h"
#import "MessageListData.h"

@interface OriginCell ()
{
    
}

@property (nonatomic , retain) UIImageView *headView;

@property (nonatomic , retain) UILabel *markLabel;

@property (nonatomic , retain) UILabel *title;

@property (nonatomic , retain) UILabel *msgLabel;

@property (nonatomic , retain) UILabel *timeLabel;

@end

@implementation OriginCell
{
}
@synthesize headView = _headView;

@synthesize timeLabel = _timeLabel;

@synthesize markLabel = _markLabel;

@synthesize msgLabel = _msgLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView * portrait = [[UIImageView alloc]initWithFrame:CGRectMake(kpadding, kpadding, 45, 45)];
        self.headView =portrait;
        RELEASE_SAFE(portrait)
        _headView.userInteractionEnabled = YES;
        _headView.layer.cornerRadius = 3.0;
        _headView.clipsToBounds = YES;
        _headView.layer.borderWidth = 0.5f;
        _headView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        _headView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_headView];
        
        UILabel * mark =  [[UILabel alloc]initWithFrame:CGRectMake(kpadding + 35.f, kpadding - 5, 16, 16)];
        self.markLabel = mark;
        RELEASE_SAFE(mark);
        
        //为了防止label background在cell被选起的时候背景被修改，所以添加一个button容器
        UIButton * redBackView = [[UIButton alloc]initWithFrame:CGRectZero];
        [redBackView addSubview:_markLabel];
        
        _markLabel.backgroundColor = [UIColor redColor];
        _markLabel.textColor = [UIColor whiteColor];
        _markLabel.layer.cornerRadius = 8;
        _markLabel.clipsToBounds = YES;
        _markLabel.textAlignment = NSTextAlignmentCenter;
        _markLabel.hidden = NO;
        _markLabel.font = KQLSystemFont(14);
        
        [self.contentView addSubview:redBackView];
        RELEASE_SAFE(redBackView);
        
        UILabel * titleLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxY(_headView.frame) + kleftPadding, kpadding, 150, 30)];
        self.title = titleLable;
        self.title.textColor = [UIColor blackColor];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.font = KQLSystemFont(16);
        [self.contentView addSubview:self.title];
        RELEASE_SAFE(titleLable);
        
        
        UILabel * msgLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxY(_headView.frame) + kleftPadding, CGRectGetMaxY(self.title.frame), 200, 15)];
        self.msgLabel = msgLabel;
        RELEASE_SAFE(msgLabel);
        
        _msgLabel.backgroundColor = [UIColor clearColor];
        _msgLabel.textColor = [UIColor colorWithRed:136.0f/255.0f green:136.0f/255.0f blue:136.0f/255.0f alpha:1.0f];
        _msgLabel.layer.opacity = 0.7;
        _msgLabel.font = KQLSystemFont(12);
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_msgLabel];
        
        UILabel * timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(KUIScreenWidth - 110.f, kpadding, 105, 30)];
        self.timeLabel = timeLabel;
        RELEASE_SAFE(timeLabel);
        
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = KQLSystemFont(10);
        _timeLabel.textColor = LightGrayColor;
        _timeLabel.layer.opacity = 0.7;
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_timeLabel];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)freshWithInfoDic:(MessageListData *)listData
{
    //获取消息数据类型 并刷新名称、时间、消息等类容
    [self getMessageDescriptionWithMessageListData:listData];
    
    ObjectData * object = [ObjectData objectForLatestMessage:listData.latestMessage];
    [self.headView setNoSmoothEffectImageWithKeyStr:object.objectPortrait placeholderImage:[object getDefaultProtraitImg]];

    self.title.text = listData.title;
    
    NSNumber *sendTimeNum = [NSNumber numberWithInt:listData.latestMessage.sendtime];
    self.timeLabel.text = [Common makeMessageListHumanizedTimeForWithTime:sendTimeNum.doubleValue];
    
    if (listData.unreadCount > 0) {
        self.markLabel.hidden = NO;
        self.markLabel.text = [NSString stringWithFormat:@"%d",listData.unreadCount];
    } else {
        self.markLabel.hidden = YES;
        self.markLabel.text = nil;
    }
}

- (void)getMessageDescriptionWithMessageListData:(MessageListData *)listData
{
    OriginData * sessionData = listData.latestMessage.sessionData;
    NSString * description = [sessionData dataListDescreption];

    NSString *speakerName = listData.latestMessage.speaker.objectName;
    BOOL isSelf = listData.latestMessage.speaker.objectID == [[[UserModel shareUser]user_id]longLongValue];
    if (speakerName != nil && listData.latestMessage.sessionType == SessionTypeTempCircle && !isSelf) {
        self.msgLabel.text = [NSString stringWithFormat:@"%@:%@",speakerName,description];
    } else {
        self.msgLabel.text = description;
    }
}

#pragma mark - 搜索 devin

- (void)freshWithInfoDic:(MessageListData *)listData searchText:(NSString *)searchStr{
    //获取消息数据类型 并刷新名称、时间、消息等类容
    [self getMessageDescriptionWithMessageListData:listData searchText:searchStr];
    
    ObjectData * object = [ObjectData objectForLatestMessage:listData.latestMessage];
    [self.headView setImageWithURL:[NSURL URLWithString:object.objectPortrait] placeholderImage:[object getDefaultProtraitImg]];
    
    self.title.text = object.objectName;
    
    if (self.title.text) {
        if ([self.title.text rangeOfString:searchStr].location != NSNotFound) {
            NSRange rang1 = [self.title.text rangeOfString:searchStr];
            NSMutableAttributedString  *numStr = [[NSMutableAttributedString alloc] initWithString:self.title.text];
            [numStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:rang1];
            self.title.attributedText = numStr;
            RELEASE_SAFE(numStr);
        }
    }
   
    NSNumber *sendTimeNum = [NSNumber numberWithInt:listData.latestMessage.sendtime];
    self.timeLabel.text = [Common makeMessageListHumanizedTimeForWithTime:sendTimeNum.doubleValue];
    
    if (listData.unreadCount > 0) {
        self.markLabel.hidden = NO;
        self.markLabel.text = [NSString stringWithFormat:@"%d",listData.unreadCount];
    } else {
        self.markLabel.hidden = YES;
        self.markLabel.text = nil;
    }

}

- (void)getMessageDescriptionWithMessageListData:(MessageListData *)listData searchText:(NSString *)searchStr
{
    OriginData * sessionData = listData.latestMessage.sessionData;
    NSString * description = [sessionData dataListDescreption];

    NSString *speakerName = listData.latestMessage.speaker.objectName;
    if (speakerName != nil && listData.latestMessage.sessionType == SessionTypeTempCircle) {
        self.msgLabel.text = [NSString stringWithFormat:@"%@:%@",speakerName,description];
    } else {
        self.msgLabel.text = description;
    }
    
    if (self.msgLabel.text) {
        if ([self.msgLabel.text rangeOfString:searchStr].location != NSNotFound) {
            NSRange rang1 = [self.msgLabel.text rangeOfString:searchStr];
            NSMutableAttributedString  *numStr = [[NSMutableAttributedString alloc] initWithString:self.msgLabel.text];
            [numStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:rang1];
            self.msgLabel.attributedText = numStr;
            RELEASE_SAFE(numStr);
        }
    }
}

- (void)dealloc
{
    self.markLabel = nil;
    self.headView = nil;
    self.timeLabel = nil;
    self.msgLabel = nil;
    [super dealloc];
}
@end
