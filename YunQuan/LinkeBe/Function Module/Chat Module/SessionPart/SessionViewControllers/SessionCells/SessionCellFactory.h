//
//  SessionCellFactory.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-19.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SystemNotifyCell.h"
#import "CustomEmoticonCell.h"
#import "TogetherCell.h"
#import "IWantCell.h"
#import "IHaveCell.h"
#import "PictureMessageCell.h"
#import "TextMessageCell.h"
#import "VoiceMessageCell.h"

@class MessageData;

@interface SessionCellFactory : NSObject

+ (OriginTimeStampCell *)cellForMeesageData:(MessageData *)data forTableView:(UITableView *)tableView withDelegate:(id)sender;

+ (float)caculateCellHeightForMessageData:(MessageData *)data;

@end
