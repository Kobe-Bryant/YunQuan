//
//  MessageListCellFactory.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-17.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OriginCell.h"
#import "PersonalMessageCell.h"
#import "CircleMessageCell.h"

@class MessageListData;

@interface MessageListCellFactory : NSObject

+ (OriginCell *)cellFromData:(MessageListData *)listData andTableView:(UITableView *)tableView;


@end
