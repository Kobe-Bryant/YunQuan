//
//  OriginTimeStampCell.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-19.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageData;

//各个Cell 之间的间隙
#define CellDistance        20
//时间戳字体大小
#define timeLabelFront      9
//时间戳宽
#define timeLabelWidth      180
//时间戳高
#define timeLabelHeight     25
//顶部的间距
#define timeUpMargin        1

@protocol OriginTimeStampCellDelegate <NSObject>

- (void)portraitViewHaveClickedWithMessageData:(MessageData *)messageData;

//图片Cell点击后回调
@optional
- (void)haveClickPicture;
- (void)shouldHideWholePictureBrowser;
- (void)voiceMessageDidFinishedPlay:(id)sender;
- (void)callBackEnterDynamicDetail:(int)pubishId;
- (void)resendMessageWithMessage:(MessageData *)messageData;


@end

@interface OriginTimeStampCell : UITableViewCell

@property (nonatomic, retain) UILabel * timeLabel;
@property (nonatomic, assign) id <OriginTimeStampCellDelegate> delegate;

+ (float)caculateCellHightWithMessageData:(MessageData *)data;

- (void)freshWithInfoData:(MessageData *)data;


@end
