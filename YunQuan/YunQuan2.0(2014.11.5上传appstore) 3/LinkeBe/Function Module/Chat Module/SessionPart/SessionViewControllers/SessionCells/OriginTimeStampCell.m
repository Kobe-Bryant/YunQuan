//
//  OriginTimeStampCell.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-19.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "OriginTimeStampCell.h"
#import "MessageData.h"

@interface OriginTimeStampCell ()
{
    
}

@end

@implementation OriginTimeStampCell

+ (float)caculateCellHightWithMessageData:(MessageData *)data
{
    float totalHeight = CellDistance ;
    if (data.sessionType == SessionTypeTempCircle && data.operationType == MessageOperationTypeReceive) {
        totalHeight = totalHeight + 10;
    }
    
    if (data.showTimeSign){
        totalHeight = totalHeight + timeLabelHeight + timeUpMargin;
    }
    
    return totalHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        // Initialization code
        self.timeLabel = [[[UILabel alloc]initWithFrame:CGRectZero]autorelease];
        [self.contentView addSubview:self.timeLabel];
    }
    return self;
}

- (void)freshWithInfoData:(MessageData *)data
{
    if (data.showTimeSign) {
        NSTimeInterval timeInterval = data.sendtime;
        NSString * timeStr = [Common makeSessionViewHumanizedTimeForWithTime:timeInterval];
        
        //发送时间
        self.timeLabel.frame = CGRectMake(KUIScreenWidth/2 - timeLabelWidth/2,timeUpMargin, timeLabelWidth, timeLabelHeight);
        self.timeLabel.hidden = NO;
        
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor colorWithRed:136.0f/225.0f green:136.0f/225.0f blue:136.0f/225.0f alpha:1.0f];
        _timeLabel.font = KQLSystemFont(timeLabelFront);
        _timeLabel.text = timeStr;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.numberOfLines = 0;
    } else {
        self.timeLabel.frame = CGRectZero;
        self.timeLabel.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    self.timeLabel = nil;
    [super dealloc];
}

@end
