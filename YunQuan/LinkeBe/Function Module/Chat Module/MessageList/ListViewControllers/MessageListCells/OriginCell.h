//
//  originCell.h
//  ql
//
//  Created by LazySnail on 14-4-27.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMacro.h"

@class MessageListData;

#define kleftPadding 15.f
#define kpadding 7.5f
#define smallHeight 20.f

@interface OriginCell : UITableViewCell
{
    UIImageView *_headView;
    UILabel *_markLabel;
    UILabel *_title;
    UILabel *_msgLabel;
    UILabel *_timeLabel;
}

- (void)freshWithInfoDic:(MessageListData *)listData searchText:(NSString *)searchStr;

- (void)freshWithInfoDic:(MessageListData *)listData;

@end
