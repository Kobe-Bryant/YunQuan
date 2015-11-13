//
//  MessageListCellFactory.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-17.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "MessageListCellFactory.h"
#import "MessageListData.h"

@implementation MessageListCellFactory

+ (OriginCell *)cellFromData:(MessageListData *)listData andTableView:(UITableView *)tableView
{
    NSString * reuseIdentifyStr = nil;
    OriginCell * cell = nil;
    switch (listData.latestMessage.sessionType) {
        case SessionTypePerson:
        {
            reuseIdentifyStr = @"PersonalCellIdentify";
            cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifyStr];
            if (cell == nil) {
                cell = [[[PersonalMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifyStr]autorelease];
                
                cell.backgroundColor = [UIColor whiteColor];
                //直线
                UIImage *line = [UIImage imageNamed:@"img_group_underline.png"];
                UIImageView *lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 59.5, ScreenWidth, 0.5)];
                lineImage.image = line;
                [cell addSubview:lineImage];
                [lineImage release];
            }
        }
            break;
        case SessionTypeTempCircle:
        {
            reuseIdentifyStr = @"CircleCellIdentify";
            cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifyStr];
            if (cell == nil) {
                cell = [[[CircleMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifyStr]autorelease];
                
                cell.backgroundColor = [UIColor whiteColor];
                //直线
                UIImage *line = [UIImage imageNamed:@"img_group_underline.png"];
                UIImageView *lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 59.5, ScreenWidth, 0.5)];
                lineImage.image = line;
                [cell addSubview:lineImage];
                [lineImage release];
            }
        }
            break;
        default:
            break;
    }
    return cell;
}

@end
