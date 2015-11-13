//
//  SessionCellFactory.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-19.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SessionCellFactory.h"

@implementation SessionCellFactory

+ (OriginTimeStampCell *)cellForMeesageData:(MessageData *)data forTableView:(UITableView *)tableView withDelegate:(id)sender
{
    OriginTimeStampCell *cell = nil;
    //只有邀请信息有这个字段 所以用它来判断
    
    switch (data.sessionData.objtype) {
        case DataMessageTypeText:
        {
            NSString * textCellIdentify = @"textMessageCell";
            cell =  [tableView dequeueReusableCellWithIdentifier:textCellIdentify];
            if (cell == nil || ![cell isKindOfClass:[TextMessageCell class]]) {
                cell = [[[TextMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textCellIdentify] autorelease];
            }
        }
            break;
        case DataMessageTypePicture:
        {
            NSString * pictureCellIdentify = @"pictureMessageCell";
            cell = [tableView dequeueReusableCellWithIdentifier:pictureCellIdentify];
            if (cell == nil) {
                cell = [[[PictureMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pictureCellIdentify]autorelease];
            }
            PictureMessageCell * pictureCell = (PictureMessageCell *)cell;
            pictureCell.delegate = sender;
        }
            break;
        case DataMessageTypeVoice:
        {
            NSString * voiceMessageCellIdentify = @"voiceMessageCell";
            cell = [tableView dequeueReusableCellWithIdentifier:voiceMessageCellIdentify];
            if (cell == nil) {
                cell = [[[VoiceMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:voiceMessageCellIdentify]autorelease];
            }
            
            VoiceMessageCell * voiceCell = (VoiceMessageCell *)cell;
            voiceCell.delegate = sender;
            
            
            //将cell作为消息对象的成员变量 后面的语音轮播使用
            VoiceData * voiceData = (VoiceData *)data.sessionData;
            voiceData.currentCell = cell;
        }
            break;
        case DataMessageTypeIWant:
        {
            NSString* IWantCellIdentify = @"IWantCell";
            cell = [tableView dequeueReusableCellWithIdentifier:IWantCellIdentify];
            if (cell == nil) {
                cell = [[[IWantCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IWantCellIdentify] autorelease];
            }
            IWantCell *wangCell = (IWantCell *)cell;
            wangCell.delegate = sender;
        }
            break;
        case DataMessageTypeIHave:
        {
            NSString* IHaveCellIdentify = @"IHaveCell";
            cell = [tableView dequeueReusableCellWithIdentifier:IHaveCellIdentify];
            if (cell == nil) {
                cell = [[[IHaveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IHaveCellIdentify] autorelease];
            }
            IHaveCell *haveCell = (IHaveCell *)cell;
            haveCell.delegate = sender;
        }
            break;
        case DataMessageTypeTogether:
        {
            NSString* togetherCellIdentify = @"togetherCell";
            cell = [tableView dequeueReusableCellWithIdentifier:togetherCellIdentify];
            if (cell == nil) {
                cell = [[[TogetherCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:togetherCellIdentify] autorelease];
            }
            TogetherCell *togetherCell = (TogetherCell *)cell;
            togetherCell.delegate = sender;
//            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterDynamicDetail:)];
//            [cell.contentView addGestureRecognizer:tap];
//            [tap release];
//            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togetherTap:)];
//            cell.contentView.tag = [[infoDic objectForKey:@"id"] intValue];
//            [cell.contentView addGestureRecognizer:tap];
//            [tap release];
//            
//            TogetherCell* wantCell = (TogetherCell *)cell;
//            [wantCell freshWithInfoDic:infoDic];

        }
            break;
        case DataMessageTypeCustomEmotion:
        {
            NSString * customEmoticonCell = @"customEmoticonCell";
            cell = [tableView dequeueReusableCellWithIdentifier:customEmoticonCell];
            if (cell == nil) {
                cell = [[CustomEmoticonCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customEmoticonCell];
            }
        }
            break;
        case DataMessageTypeSystemNofity:
        {
            NSString * systemNotifyCellIdentify = @"SystemNotifyCell";
            cell = [tableView dequeueReusableCellWithIdentifier:systemNotifyCellIdentify];
            if (cell == nil) {
                cell = [[SystemNotifyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:systemNotifyCellIdentify];
            }
        }
            break;
        default:
            break;
    }
    
    cell.delegate = sender;
    return cell;
}

+ (float)caculateCellHeightForMessageData:(MessageData *)data
{
    switch (data.sessionData.objtype) {
        case DataMessageTypeText:
        {
            return [TextMessageCell caculateCellHightWithMessageData:data];
            
        }
            break;
        case DataMessageTypeVoice:
        {
            return [VoiceMessageCell caculateCellHightWithMessageData:data];
        }
            break;
        case DataMessageTypePicture:
        {
            return [PictureMessageCell caculateCellHightWithMessageData:data];
        }
            break;
        case DataMessageTypeIHave:
        {
            return [IHaveCell caculateCellHightWithMessageData:data];
        }
            break;
        case DataMessageTypeIWant:
        {
            return [IWantCell caculateCellHightWithMessageData:data];
        }
            break;
        case DataMessageTypeTogether:
        {
            return [TogetherCell caculateCellHightWithMessageData:data];
        }
            break;
        case DataMessageTypeCustomEmotion:
        {
            return [CustomEmoticonCell caculateCellHightWithMessageData:data];
        }
            break;
        case DataMessageTypeSystemNofity:
        {
            return [SystemNotifyCell caculateCellHightWithMessageData:data];
        }
            break;
        default:
        {
            return 80;
        }
            break;
    }
}

@end
