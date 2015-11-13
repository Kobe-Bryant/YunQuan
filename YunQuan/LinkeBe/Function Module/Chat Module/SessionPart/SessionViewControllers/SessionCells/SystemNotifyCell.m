//
//  SystemNotifyCell.m
//  ql
//
//  Created by LazySnail on 14-7-8.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "SystemNotifyCell.h"
#import "MessageData.h"

const int           LRMargin =              10;
const int           MessageFront =          14;
const float         MessageStrMaxWidtH =    220.f;
const float         PlasViewDistance   =    10;

@interface SystemNotifyCell ()
{
    
}

@property (nonatomic, retain) UILabel * timeLabel;

@property (nonatomic, retain) UITextView * systemMsgTextView;

@end

@implementation SystemNotifyCell

+ (float)caculateCellHightWithMessageData:(MessageData *)data
{
    float cellHeight = [OriginTimeStampCell caculateCellHightWithMessageData:data];
    
    CGSize strSize = [SystemNotifyCell caculateMessageSizeFromData:data andMaxWith:MessageStrMaxWidtH];
    cellHeight = cellHeight + strSize.height +PlasViewDistance;
    return cellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
                
        self.systemMsgTextView = [[[UITextView alloc]initWithFrame:CGRectZero] autorelease];
        self.systemMsgTextView.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1.0f];
        
        self.systemMsgTextView.textColor = [UIColor colorWithRed:136.0f/255.f green:136.0f/255.f blue:136.0f/255.f alpha:1.0f];
        self.systemMsgTextView.textAlignment = NSTextAlignmentCenter;
        self.systemMsgTextView.font = KQLSystemFont(MessageFront);
        self.systemMsgTextView.layer.cornerRadius = 5.f;
        self.systemMsgTextView.layer.masksToBounds = YES;
        self.systemMsgTextView.userInteractionEnabled = NO;
        self.systemMsgTextView.contentInset = UIEdgeInsetsMake(-4, 0, 0, 0);
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.systemMsgTextView];
        
        self.timeLabel = [[[UILabel alloc]initWithFrame:CGRectZero] autorelease];
        [self.contentView addSubview:self.timeLabel];
    }
    return self;
}

+ (CGSize)caculateMessageSizeFromData:(MessageData *)data andMaxWith:(float)maxWidth
{
    NSString * systemMessageStr = [data.sessionData valueForKey:@"txt"];
    
    CGSize strSize = [systemMessageStr sizeWithFont:KQLSystemFont(MessageFront) constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    return strSize;
}

- (void)freshWithInfoData:(MessageData *)data
{
    [super freshWithInfoData:data];
    
    self.systemMsgTextView.text = [data.sessionData valueForKey:@"txt"];

    CGSize strSize = [SystemNotifyCell caculateMessageSizeFromData:data andMaxWith:MessageStrMaxWidtH];
    
    float appendHeight = 10;
    if ([[UIDevice currentDevice]systemVersion].intValue < 7.0) {
        appendHeight = strSize.height * 0.3;
    }
    
    self.systemMsgTextView.frame = CGRectMake(KUIScreenWidth/2 - strSize.width/2 -5, CGRectGetMaxY(self.timeLabel.frame), strSize.width + 10, strSize.height + appendHeight);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)dealloc
{
    [super dealloc];
}
@end
