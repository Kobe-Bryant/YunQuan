//
//  SessinDataOperator.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SessionDataOperator.h"
#import "HttpRequest.h"
#import "MessageListData.h"
#import "SessionDataFactory.h"
#import "MessageDataManager.h"
#import "SnailiMDataManager.h"
#import "SDImageCache.h"
#import "SnailRequestPostObject.h"
#import "SnailNetWorkManager.h"
#import "SessionViewController.h"
#import "MessageHistoryRecordTable_model.h"
#import "ChatMacro.h"
#import "SelfBusinessCardViewController.h"
#import "OthersBusinessCardViewController.h"
#import "Circle_member_model.h"
#import "TempChat_list_model.h"
#import "DBImageView.h"
#import "DBImageViewCache.h"
#import "SnailCacheManager.h"
#import "UIImageScale.h"

#import "DynamicIMManager.h"

typedef enum {
    SubmitIndicatorSending,
    SubmitIndicatorNormal
}SubmitIndicator;

@interface SessionDataOperator () <HttpRequestDelegate>
{
    
}

@property (nonatomic, retain) NSMutableArray * sendingMessageArr;
@property (nonatomic, retain) NSMutableArray * WaitingAuthorityArr;

@property (nonatomic, assign) SubmitIndicator submitIndicator;

@end

@implementation SessionDataOperator

static id m_sessionDataOperator = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sendingMessageArr = [[[NSMutableArray alloc]init]autorelease];
        self.WaitingAuthorityArr = [[[NSMutableArray alloc]init]autorelease];
        self.submitIndicator = SubmitIndicatorNormal;
        dispatch_queue_t queue = dispatch_queue_create(DBModifyQueueName, DISPATCH_QUEUE_CONCURRENT);
        self.dbModifyDispatchQueue = queue;
    }
    return self;
}

+ (SessionDataOperator *)shareOperator
{
    [SDImageCache sharedImageCache].maxMemoryCost = 1024 * 1;
    
    if (m_sessionDataOperator == nil) {
        m_sessionDataOperator = [[SessionDataOperator alloc]init];
    }
    return m_sessionDataOperator;
}

- (MessageData *)sendTextDataWithText:(NSString *)text andMessageListData:(MessageListData *)listData
{
    TextData * data = (TextData *)[SessionDataFactory dataWithDataType:DataMessageTypeText];
    data.txt = text;
    
    MessageData * messageData = [listData generateSendOriginData];
    messageData.sessionData = data;
    messageData.statusType = MessageStatusTypeSending;
    
    [self addMessageToSendQueue:messageData];
    return messageData;
}

- (MessageData *)sendGetheringMessageWithTempCircleID:(long long)tempCID andMessageID:(int)messageID andMsgTxt:(NSString *)txt andMsgDesc:(NSString *)msgDesc
{
    TogetherData * data  = (TogetherData *)[SessionDataFactory dataWithDataType:DataMessageTypeTogether];
    data.txt = txt;
    data.msgdesc = msgDesc;
    data.dataID = messageID;
    
    MessageData * messageData = [self addMessageDataToSendQueueWithSessionType:SessionTypeTempCircle andObjectID:tempCID andSessionData:data];
    return messageData;
}

- (MessageData *)sendiHaveMessageWitHaveID:(int)haveID andReceiverID:(long long)receiverID andtbDesc:(NSString *)tbDesc andtBurl:(NSString *)tbUrl andTxt:(NSString *)txt andMsgDesc:(NSString *)msgDesc
{
    IHaveData * data = (IHaveData *)[SessionDataFactory dataWithDataType:DataMessageTypeIHave];
    data.dataID = haveID;
    data.tbdesc = tbDesc;
    data.tburl = tbUrl;
    data.txt = txt;
    data.msgdesc = msgDesc;
    
    MessageData * messageData = [self addMessageDataToSendQueueWithSessionType:SessionTypePerson andObjectID:receiverID andSessionData:data];
    
    return messageData;
}

- (MessageData *)sendiWantMessageWithWantID:(int)wantID andReceiverID:(long long)receiverID andtbDesc:(NSString *)tbDesc andtBurl:(NSString *)tbUrl andTxt:(NSString *)txt andMsgDesc:(NSString *)msgDesc
{
    IWantData * data = (IWantData *)[SessionDataFactory dataWithDataType:DataMessageTypeIWant];
    data.dataID = wantID;
    data.tbdesc = tbDesc;
    data.tburl = tbUrl;
    data.txt = txt;
    data.msgdesc = msgDesc;
    
    MessageData * messageData = [self addMessageDataToSendQueueWithSessionType:SessionTypePerson andObjectID:receiverID andSessionData:data];
    
    return messageData;
}

- (MessageData *)addMessageDataToSendQueueWithSessionType:(SessionType)type andObjectID:(long long)objectID andSessionData:(OriginData *)data
{
    MessageData * messageData = [[MessageData alloc]init];
    messageData.objectID = objectID;
    messageData.sessionData = data;
    messageData.sessionType = type;
    messageData.operationType = MessageOperationTypeSend;
    messageData.statusType = MessageStatusTypeSending;
    [messageData judgeShowTimeIndicator];
    messageData.sendtime = [self getCurrentTimeStamp];
    
    [self addMessageToSendQueue:messageData];
    return [[messageData retain] autorelease];
}

- (MessageData *)updateAndSendMessage:(MessageData *)message
{
    MessageData * updateData = [message copy];
    updateData.statusType = MessageStatusTypeSendFailed;
    dispatch_sync(self.dbModifyDispatchQueue, ^{
        [[MessageDataManager shareMessageDataManager]updateData:updateData];
    });
    RELEASE_SAFE(updateData);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SnailiMDataManager shareiMDataManager]sendMessageData:message];
        message.statusType = MessageStatusTypeSending;
    });
    return message;
}

- (void)resendMessageWithMessage:(MessageData *)message
{
    message.msgid = [self getCurrentTimeStamp] * MessageMidPlus;
    
    switch (message.sessionData.objtype) {
        case DataMessageTypePicture:
        {
            PictureData * picData = (PictureData *)message.sessionData;
            UIImage * wholeImg = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:picData.url];
            NSData *compressData = UIImageJPEGRepresentation(wholeImg, ChatImgCompressionQuality);
            message.sendData = compressData;
        }
            break;
        case DataMessageTypeVoice:
        {
            VoiceData * voiceData = (VoiceData *)message.sessionData;
            NSData * sendData = [SnailCacheManager getAndCacheDataFromUrlStr:voiceData.url complation:nil];
            message.sendData = sendData;
        }
            break;
        default:
            break;
    }
    
    
    [self addMessageToSendQueue:message];
}

- (NSMutableArray *)sendPictureDataWithImageArr:(NSMutableArray *)imgArr andMessageListData:(MessageListData *)listData
{
    NSTimeInterval timeStamp = [self getCurrentTimeStamp];
    NSString * thumbnailSufix = @"Thumbnail";
    NSMutableArray * messageResultArr = [[NSMutableArray alloc]initWithCapacity:imgArr.count];
    
    for (int i = 0;i < imgArr.count; i++) {
        UIImage *img =  [imgArr objectAtIndex:i];
        NSString *wholeUrl = [NSString stringWithFormat:@"%d_%d.png",(int)timeStamp,i];
        NSString *thumbnailUlr = [NSString stringWithFormat:@"%@_%@",wholeUrl,thumbnailSufix];
        UIImage * thumbImage = [img fillSize:kChatThumbnailSize];
        //本地对压缩图片做缓存
        //注意本地发送的时候保存的是大图。缩略图则是用压缩图
        
        PictureData * theData = (PictureData *)[SessionDataFactory dataWithDataType:DataMessageTypePicture];
        theData.image = thumbImage;
        theData.url = wholeUrl;
        theData.tburl = thumbnailUlr;
        
        MessageData * messageData = [listData generateSendOriginData];
        messageData.sessionData = theData;
        messageData.statusType = MessageStatusTypeSending;
        [messageResultArr addObject:messageData];
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *compressData = UIImageJPEGRepresentation(img, ChatImgCompressionQuality);
            messageData.sendData = compressData;
            [self addMessageToSendQueue:messageData];
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[SDImageCache sharedImageCache]storeImage:img forKey:wholeUrl toMemory:NO];
            [[SDImageCache sharedImageCache]storeImage:thumbImage forKey:thumbnailUlr];
        });
    }
    return [messageResultArr autorelease];
}

- (MessageData *)sendVoiceDataWithVoiceData:(VoiceData *)voice andMessageListData:(MessageListData *)listData
{
    MessageData * messageData = [listData generateSendOriginData];
    messageData.sessionData = voice;
    messageData.statusType = MessageStatusTypeSending;
    messageData.sendData = [NSData dataWithContentsOfFile:voice.url];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager * defaultManager =[NSFileManager defaultManager];
        [defaultManager removeItemAtPath:voice.url error:nil];
        [SnailCacheManager setObject:messageData.sendData forKey:voice.url complation:nil];
    });
    
    [self addMessageToSendQueue:messageData];
    return messageData;
}

- (MessageData *)sendCustomEmoticonDataWithCustomeEmoticonData:(CustomEmotionData *)emoticonData andMessageListData:(MessageListData *)listData
{
    MessageData * messageData = [listData generateSendOriginData];
    messageData.sessionData = emoticonData;
    messageData.statusType = MessageStatusTypeSending;
    [self addMessageToSendQueue:messageData];
    
    return messageData;
}

- (void)addMessageToSendQueue:(MessageData *)messageData
{
    if (messageData != nil) {
        MessageData * newStoreData = [messageData copy];
        newStoreData.statusType = MessageStatusTypeSendFailed;
        //存储会生成 locmsgid
        dispatch_sync(self.dbModifyDispatchQueue, ^{
            [[MessageDataManager shareMessageDataManager]restoreData:newStoreData];
            //将生成的 locmsgid 同步给原始数据
            messageData.locmsgid = newStoreData.locmsgid;
        });
        
        RELEASE_SAFE(newStoreData);
        [self.sendingMessageArr addObject:messageData];
    }
    
    if (self.submitIndicator == SubmitIndicatorNormal) {
        MessageData * currentSendData = [self.sendingMessageArr firstObject];
        if (currentSendData.sendData != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self submitData:currentSendData.sendData andParamDic:currentSendData];
            });
        } else if (currentSendData != nil) {
            
            [self updateAndSendMessage:currentSendData];
            [self.sendingMessageArr removeObject:currentSendData];
            [self.WaitingAuthorityArr addObject:currentSendData];
            if (self.sendingMessageArr.count > 0) {
                [self addMessageToSendQueue:nil];
            } else {
                return;
            }
        }
    }
}

- (NSTimeInterval)getCurrentTimeStamp
{
    NSTimeInterval resultTime = [[NSDate date]timeIntervalSince1970];
    return resultTime;
}

#pragma mark - HttpRequestMethod

- (void)submitData:(NSData *)data andParamDic:(MessageData *)messageData
{
    self.submitIndicator = SubmitIndicatorSending;
    SnailRequestPostObject * postObject = [[SnailRequestPostObject alloc]init];
    
    postObject.postData = data;
    postObject.requestInterface = @"/upload";
    postObject.command = LinkedBe_Command_UploadData;
    
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      messageData,@"msgObject", nil];
    
    [[SnailNetWorkManager shareManager] sendHttpRequest:postObject fromDelegate:self andParam:paramDic];
    RELEASE_SAFE(postObject);
}

#pragma mark - HttpRequestDelegate

- (void)didFinishCommand:(NSDictionary *)jsonDic cmd:(LinkedBe_WInterface)commandid withVersion:(int)ver andParam:(NSMutableDictionary *)param
{
    self.submitIndicator = SubmitIndicatorNormal;
    int errcode = [[jsonDic objectForKey:@"errcode"]intValue];
    MessageData * messageData = [param objectForKey:@"msgObject"];
    if (messageData != nil) {
        switch (errcode) {
            case RequestErrorCodeFailed:
            {
                messageData.statusType = MessageStatusTypeSendFailed;
                [self.sendingMessageArr removeObject:messageData];
            }
                break;
            case RequestErrorCodeTimeOut:
            {
                messageData.statusType = MessageStatusTypeSendFailed;
                [self.sendingMessageArr removeObject:messageData];
            }
                break;
            default:
                break;
        }
    }
    
    ParseMethod method = ^(){
        NSString * thumbnailUrl = [jsonDic objectForKey:@"tburl"];
        NSString * url = [jsonDic objectForKey:@"url"];
        
        switch (errcode) {
            case RequestErrorCodeSuccess:
            {
                switch (commandid) {
                    case LinkedBe_Command_UploadData:
                    {
                        OriginUrlData * urlData = (OriginUrlData *)messageData.sessionData;
                        switch (urlData.objtype) {
                            case DataMessageTypePicture:
                            {
                                PictureData * picture = (PictureData *)urlData;
                                float width = [[jsonDic objectForKey:@"w"]floatValue];
                                float height = [[jsonDic objectForKey:@"h"]floatValue];
                                picture.width = width;
                                picture.height = height;
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                    [[SDImageCache sharedImageCache]removeImageForKey:urlData.tburl];
                                    [[SDImageCache sharedImageCache]storeImage:picture.image forKey:thumbnailUrl];
                                    [[SDImageCache sharedImageCache]removeImageForKey:urlData.url];
                                    UIImage * complateImg = [UIImage imageWithData:messageData.sendData];
                                    [[SDImageCache sharedImageCache]storeImage:complateImg forKey:url toMemory:NO];
                                });
                            }
                                break;
                            case DataMessageTypeVoice:
                            {
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                    if ([urlData.url isEqualToString:url]) {
                                        return;
                                    }
                                    [SnailCacheManager removeObjectForKey:urlData.url];
                                    [SnailCacheManager setObject:messageData.sendData forKey:url complation:nil];
                                });
                            }
                                break;
                            default:
                                break;
                        }
                        
                        urlData.url = url;
                        urlData.tburl = thumbnailUrl;
                        
                        self.submitIndicator = SubmitIndicatorNormal;
                        messageData.sendData = nil;
                        [self addMessageToSendQueue:nil];
                    }
                        break;
                        
                    default:
                        break;
                }
                
            }
                break;
                
            default:
                break;
        }
    };
    
    [Common securelyparseHttpResultDic:jsonDic andMethod:method];
}

//收到发送成功过后的反馈
- (void)receiveSendMessageSuccessWithDic:(NSDictionary *)dic
{
    long long nativeID = [[dic objectForKey:@"locmid"]longLongValue];
    long long messageID = [[dic objectForKey:@"mid"]longLongValue];
    
    MessageData * oldMessageData = nil;
    for (MessageData * data in self.WaitingAuthorityArr) {
        if (data.locmsgid == nativeID) {
            data.msgid = messageID;
            data.statusType = MessageStatusTypeSendSuccessed;
            dispatch_sync(self.dbModifyDispatchQueue, ^{
                [[MessageDataManager shareMessageDataManager]updateData:data];
            });
            oldMessageData = data;
        }
    }
    [self.WaitingAuthorityArr removeObject:oldMessageData];
    
    DataMessageType type = oldMessageData.sessionData.objtype;
    switch (type) {
        case DataMessageTypeIHave:
            [[DynamicIMManager shareManager] receiveHaveCallBack:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [dic objectForKey:@"rcode"],@"rcode",
                                                                  nil]];
            break;
        case DataMessageTypeIWant:
            [[DynamicIMManager shareManager] receiveWantCallBack:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [dic objectForKey:@"rcode"],@"rcode",
                                                                  nil]];
            break;
        case DataMessageTypeTogether:
            //聚聚消息
            [[DynamicIMManager shareManager] receiveTogetherMessage:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [dic objectForKey:@"rcode"],@"rcode",
                                                                     nil]];
            break;
        default:
            break;
    }
    
}

//收到新消息处理逻辑
- (void)receiveNewMessageWithMessageData:(MessageData *)messageData
{
    //添加过滤器，服务端会重复推送客户端做异常处理，很不合理。暂时简单处理。后期商量修改方案
    if (![messageData judgeHaveBeenReceived]) {
        //收到消息 震动提醒
        [[SnailiMDataManager shareiMDataManager]playVibrate];
        
        [[MessageDataManager shareMessageDataManager]restoreData:messageData];
        //判断接发送方id是否和当前聊天页面的对象一直如果一致则做界面展现，若不一致则忽略
        MessageListData *listData = nil;
        if (self.delegate != nil && [self.delegate isKindOfClass:[SessionViewController class]]) {
            SessionViewController * sessionViewController = (SessionViewController *)self.delegate;
            listData = sessionViewController.listData;
        }
        if (messageData.objectID == listData.ObjectID && [self.delegate respondsToSelector:@selector(receiveMessage:)]) {
            [self.delegate receiveMessage:messageData];
        }
    }
}

- (NSMutableArray *)historyMessageArrWithCurrentPage:(int)currentPage forObjectID:(long long)objectID
{
    NSArray * historyDicList = [MessageHistoryRecordTable_model getHistoryWithObjectID:objectID CurrentPage:currentPage andPageNumber:ChatHistoryMessagePrePage];
    NSMutableArray * historyMsgArr = [NSMutableArray arrayWithCapacity:ChatHistoryMessagePrePage];
    for (int i = 0; i < historyDicList.count; i ++) {
        NSDictionary * messageDic = [historyDicList objectAtIndex:i];
        MessageData * msg = [[MessageData alloc]initWithDBDic:messageDic];
        [historyMsgArr addObject:msg];
        RELEASE_SAFE(msg);
    }
    return historyMsgArr ;
}

+ (void)otherSystemTurnToSessionWithSender:(UIViewController *)viewController andObjectID:(long long)objectID andSessionType:(SessionType)sessionType isPopToRootViewController:(BOOL)rootPop isShowRightButton:(BOOL)rightButtonShow
{
    MessageListData * listData = [MessageListData generateOriginListDataWithObjectID:objectID andSessionType:sessionType];
    SessionViewController * newSessionViewController = [[SessionViewController alloc]init];
    newSessionViewController.listData = listData;
    newSessionViewController.hidesBottomBarWhenPushed = YES;
    newSessionViewController.chatType = TabbarChatType;
    newSessionViewController.isPopToRootViewController = rootPop;
    newSessionViewController.isShowRightButtom = rightButtonShow;
    [viewController.navigationController pushViewController:newSessionViewController animated:YES];
    RELEASE_SAFE(newSessionViewController);
}

- (void)turnToIntroduceCardViewControllerWithSender:(UIViewController *)viewController andObjectID:(long long)objectID
{
    BusinessCardViewController * cardView = nil;
    if (objectID == [[UserModel shareUser]user_id].longLongValue) {
        cardView = [[SelfBusinessCardViewController alloc]init];
    } else {
        ObjectData * person = [ObjectData objectFromMemberListWithID:objectID];
        long long orgUserID = person.orgUserID;
        //        if ([ObjectData isSpecialObjectWithObjectID:objectID]) {
        //            orgUserID = objectID;
        //        } else {
        //            NSDictionary * memberDic = [Circle_member_model getMemberDicWithUserID:objectID];
        //           orgUserID = [[memberDic objectForKey:@"orgUserId"]longLongValue];
        //        }
        //
        OthersBusinessCardViewController * otherCardView = [[OthersBusinessCardViewController alloc]init];
        otherCardView.orgUserId = [NSString stringWithFormat:@"%lld",orgUserID];
        cardView =otherCardView;
    }
    [viewController.navigationController pushViewController:cardView animated:YES];
    RELEASE_SAFE(cardView);
}

- (NSInteger)getTempCircleMemberCountWithTempCircleID:(long long)tempCircleID
{
    NSDictionary * tempInfoDic = [TempChat_list_model getTempChatContentDataWith:tempCircleID];
    NSArray * membersArr = [tempInfoDic objectForKey:@"members"];
    return membersArr.count;
}

- (void)dealloc
{
    self.sendingMessageArr = nil;
    [super dealloc];
}

@end
