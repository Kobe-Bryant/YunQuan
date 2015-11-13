//
//  EmotionStoreManager.m
//  ql
//
//  Created by LazySnail on 14-8-21.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "EmotionStoreManager.h"
#import "NetManager.h"
#import "HttpRequest.h"
#import "emoticon_store_info_model.h"
#import "emoticon_list_model.h"
#import "emoticon_detail_info_model.h"
#import "emoticon_item_list_model.h"
#import "NSDictionary+URLJointExtension.h"
#import "SBJson.h"
#import "EmotionStoreData.h"
#import "SnailNetWorkManager.h"
#import "SnailRequestGet.h"
#import "SnailRequestPut.h"
#import "ZipArchive.h"

typedef enum{
    CustomEmoticonModifySignDownload = 1,
    CustomEmoticonModifySignDelete = 2,
}CustomEmoticonModifySign;

@interface EmotionStoreManager () <HttpRequestDelegate,ZipArchiveDelegate>
{
    
}

@property (nonatomic,retain) NSMutableArray * downloadProgressArr;

@property (nonatomic,retain) EmotionStoreData *emoticonData;

@end

@implementation EmotionStoreManager

- (instancetype)init
{
    self =  [super init];
    if (self) {
    }
    return self;
}

- (void)getEmotionStoreDataDic
{
    NSNumber * userIDNum = [[UserModel shareUser]user_id];
    NSString * requestStr = [NSString stringWithFormat:@"/emoticon/list/%lld",[userIDNum longLongValue]];
    
    NSDictionary * latestStoreInfoDic =[emoticon_store_info_model getLatestData];
    NSNumber * timeSign = [latestStoreInfoDic objectForKey:@"ts"];
    if (timeSign == nil) {
        timeSign = [NSNumber numberWithInt:0];
    }

    SnailRequestGet * getRequest = [[SnailRequestGet alloc]init];
    getRequest.requestInterface = requestStr;
    getRequest.command = LinkedBe_Command_GetEmotionList;
    getRequest.requestParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              userIDNum,@"userId",
                              timeSign,@"ts", nil];
    [[SnailNetWorkManager shareManager]sendHttpRequest:getRequest fromDelegate:self andParam:nil];

    RELEASE_SAFE(getRequest);
}

- (void)getemotionDetailDataForEmotionID:(NSInteger)emotionID
{
    NSString * requestStr = [NSString stringWithFormat:@"/emoticon/%d",emotionID];
    NSNumber * userIDNum = [[UserModel shareUser]user_id];
    NSDictionary * detailInfoDic = [emoticon_detail_info_model getLatestDetailInfoDic];
    NSNumber * timeSign = [detailInfoDic objectForKey:@"ts"];
    if (timeSign.intValue == 0 || timeSign == nil) {
        timeSign = [NSNumber numberWithInt:0];
    }

    NSNumber * emotionIDNum = [NSNumber numberWithInt:emotionID];
    
    NSMutableDictionary * requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        userIDNum,@"userId",
                                        timeSign,@"ts",
                                        emotionIDNum,@"packetId",
                                        nil];
    SnailRequestGet * getRequest = [[SnailRequestGet alloc]init];
    getRequest.requestInterface = requestStr;
    getRequest.requestParam = requestDic;
    getRequest.command = LinkedBe_Command_GetEmotionDetail;
    
    [[SnailNetWorkManager shareManager]sendHttpRequest:getRequest fromDelegate:self andParam:nil];
    RELEASE_SAFE(getRequest);
}

- (void)sendDownloadModifySign:(CustomEmoticonModifySign)theSign andEmotionID:(NSInteger)emoticonID
{
    NSString *requestStr = @"/emoticon/ops";
    NSNumber *modifySignNum = [NSNumber numberWithInt:theSign];
    NSNumber *userIDNum = [[UserModel shareUser]user_id];
    NSMutableDictionary * requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        userIDNum,@"userId",
                                        modifySignNum,@"ops",
                                        [NSNumber numberWithInt:emoticonID],@"packetId",
                                        nil];
    SnailRequestPut * putRequest = [[SnailRequestPut alloc]init];
    putRequest.requestInterface = requestStr;
    putRequest.command = LinkedBe_Command_GetEmotionModifyPakageStatus;
    putRequest.requestParam = requestDic;
    
    [[SnailNetWorkManager shareManager]sendHttpRequest:putRequest fromDelegate:self andParam:requestDic];
    RELEASE_SAFE(putRequest);
}

- (BOOL)judgeFirstInstallAndLoadDownloadedEmoticon
{
    NSDictionary * emoticonDic = [emoticon_store_info_model getLatestData];
    NSNumber * timeStamp = [emoticonDic objectForKey:@"ts"];
    if (timeStamp.intValue == 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getEmotionStoreDataDic];
        });
        return YES;
    }
    return NO;
}

- (BOOL)judgeShouldAndLoadDownloadedDetailEmoticonWithEmoticonID:(NSInteger)emoticonID;
{
     NSMutableArray * itemArr = [emoticon_item_list_model getAllItemWithEmoticonID:emoticonID];
    if (itemArr.count == 0) {
        [self getemotionDetailDataForEmotionID:emoticonID];
        return YES;
    }
    return NO;
}

#pragma mark - HttpRequestDelegate

- (void)didFinishCommand:(NSDictionary *)jsonDic cmd:(LinkedBe_WInterface)commandid withVersion:(int)ver andParam:(NSMutableDictionary *)param
{
    
    if (commandid == LinkedBe_Command_GetEmotionModifyPakageStatus) {
        [self.downloadProgressArr addObject:@"SendModifySignSuccess"];
        [self checkDownloadProgress];
        return;
    }
    
    [Common securelyparseHttpResultDic:jsonDic andMethod:^{
        NSDictionary * resultDic = jsonDic;
        switch (commandid) {
            case LinkedBe_Command_GetEmotionList:
            {
                
                NSMutableDictionary * emoticonStoreInfoDic = [NSMutableDictionary dictionaryWithDictionary:resultDic];
                NSArray * emoticonsArr = [emoticonStoreInfoDic objectForKey:@"emoticons"];
                [emoticonStoreInfoDic removeObjectForKey:@"emoticons"];
                
                NSString * resPath = [emoticonStoreInfoDic objectForKey:@"resPath"];
                NSArray * thumbnailsArr = [emoticonStoreInfoDic objectForKey:@"thumbnails"];
                NSMutableArray * wholeThumbnailsArr = [[NSMutableArray alloc]initWithCapacity:3];
                for (NSString * thumbnailStr in thumbnailsArr) {
                    NSString * wholeThumbnailStr = [NSString stringWithFormat:@"%@%@",resPath,thumbnailStr];
                    [wholeThumbnailsArr addObject:wholeThumbnailStr];
                }
                [emoticonStoreInfoDic removeObjectForKey:@"thumbnails"];
                [emoticonStoreInfoDic setObject:[wholeThumbnailsArr JSONRepresentation]forKey:@"thumbnails"];
                [emoticon_store_info_model insertDataWithDic:emoticonStoreInfoDic];
                RELEASE_SAFE(wholeThumbnailsArr);
                
                for (NSDictionary * emoticonDic in emoticonsArr) {
                    NSMutableDictionary * wholeUrlDic = [emoticonDic jointUrlHeadStr:resPath forDicKeys:@"chatIcon",@"icon",@"packetPath",nil];
                    [emoticon_list_model insertOrUpdateListWithDic:wholeUrlDic];
                }
                
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(getEmotionStoreDataSuccessWithDic:sender:)]) {
                    [self.delegate getEmotionStoreDataSuccessWithDic:resultDic sender:self];
                }
            }
                break;
            case LinkedBe_Command_GetEmotionDetail:
            {
                NSDictionary * resultDic = jsonDic;
                NSString * resPath = [resultDic objectForKey:@"resPath"];
                
                NSMutableDictionary * emoticonDic = [NSMutableDictionary dictionaryWithDictionary:[resultDic objectForKey:@"emoticon"]];
                
                if ([emoticonDic objectForKey:@"thumbnail"] != nil) {
                    NSMutableDictionary * wholeUrlDic = [emoticonDic jointUrlHeadStr:resPath forDicKeys:@"thumbnail",@"thumbnail1",@"thumbnail2",nil];
                    
                    NSMutableArray * thumbnails = [NSMutableArray arrayWithCapacity:3];
                    NSString * thumbnail0 = [wholeUrlDic objectForKey:@"thumbnail"];
                    [wholeUrlDic removeObjectForKey:@"thumbnail"];
                    NSString * thumbnail1 = [wholeUrlDic objectForKey:@"thumbnail1"];
                    [wholeUrlDic removeObjectForKey:@"thumbnail1"];
                    NSString * thumbnail2 = [wholeUrlDic objectForKey:@"thumbnail2"];
                    [wholeUrlDic removeObjectForKey:@"thumbnail2"];
                    
                    
                    if (thumbnail0 != nil && ![thumbnail0 isEqualToString:@""]) {
                        [thumbnails addObject:thumbnail0];
                    }
                    
                    if (thumbnail1 != nil && ![thumbnail1 isEqualToString:@""]) {
                        [thumbnails addObject:thumbnail1];
                    }
                    
                    if (thumbnail2 != nil && ![thumbnail2 isEqualToString:@""]) {
                        [thumbnails addObject:thumbnail2];
                    }
                    
                    [wholeUrlDic setObject:[thumbnails JSONRepresentation] forKey:@"thumbnails"];
                    [wholeUrlDic setObject:resPath forKey:@"resPath"];
                    [wholeUrlDic setObject:[resultDic objectForKey:@"ts"] forKey:@"ts"];
                    [emoticon_detail_info_model insertEmoticonDetailInfoWithDic:wholeUrlDic];
                    
                    NSMutableArray * emoticonItemList = [NSMutableArray arrayWithArray:[resultDic objectForKey:@"list"]];
                    
                    for (NSDictionary *itemDic in emoticonItemList) {
                        
                        NSMutableDictionary * wholeDic =[itemDic jointUrlHeadStr:resPath forDicKeys:@"previewIcon",@"emoticonPath",nil];
                        
                        [emoticon_item_list_model insertOrUpdateItemWithDic:wholeDic];
                    }
                }
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(getEmoticonDetailDataSuccessWithSender:)]) {
                    [self.delegate getEmoticonDetailDataSuccessWithSender:self];
                }
                [self.downloadProgressArr addObject:@"downloadDetailItem"];
                [self checkDownloadProgress];
                
                if (self.emoticonData != nil) {
                    [self sendDownloadModifySign:CustomEmoticonModifySignDownload andEmotionID:self.emoticonData.emoticonID];
                }
            }
                break;
          
            default:
                break;
        }

    }];
    
    
}

-(void) downLoadEmotionWithParam:(EmotionStoreData *)data andBlock:(ProgressBlock)block progress:(UIProgressView *)pv
{
    self.emoticonData = data;
    self.downloadProgressArr = [[[NSMutableArray alloc]initWithCapacity:3]autorelease];
    
    ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:data.packetPath]];
    request.delegate = self;
    request.downloadDestinationPath = [self getEmotionPath:[NSString stringWithFormat:@"%@.zip",data.packetName]];
    request.downloadProgressDelegate = pv;
    request.showAccurateProgress = YES;
    [request startAsynchronous];
    RELEASE_SAFE(request);
    block();
    
    //加载对应的详情数据
    [self getemotionDetailDataForEmotionID:data.emoticonID];
}

#pragma mark - asihttp
-(void) requestFinished:(ASIHTTPRequest *)request{
    [self unzipEmoticonPath:[self getEmotionPath:self.emoticonData.packetName]];
    
}

-(void) requestFailed:(ASIHTTPRequest *)request{
    if (_delegate && [_delegate respondsToSelector:@selector(dowmLoadEmotionFailed)]) {
        [_delegate dowmLoadEmotionFailed];
        
        [self updateEmotionListStatus:0];
    }
}

//更改list表的status状态
-(void) updateEmotionListStatus:(int) status{
    [emoticon_list_model insertOrUpdateListWithDic:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNumber numberWithInteger:self.emoticonData.emoticonID],@"packetId",
                                                    [NSNumber numberWithInt:status],@"status",
                                                    nil]];
}

//获取路径
-(NSString*) getEmotionPath:(NSString*) emoticonPath{
    NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentPath stringByAppendingPathComponent:emoticonPath];
}

//解压zip包
-(void) unzipEmoticonPath:(NSString*) path{
    ZipArchive *za = [[ZipArchive alloc] init];
    za.delegate = self;
    
    //在内存中解压缩文件
    if ([za UnzipOpenFile:[NSString stringWithFormat:@"%@.zip",path]]) {
        //将解压缩的内容写到缓存目录中
        BOOL ret = [za UnzipFileTo:path overWrite: YES];
        if (NO == ret){} [za UnzipCloseFile];
    }
}

#pragma mark - ZipArchiveDelegate

- (void)zipArchiveSuccess
{
    NSFileManager *fileManger = [[NSFileManager alloc]init];
    [fileManger removeItemAtPath:[self getEmotionPath:[NSString stringWithFormat:@"%@.zip",self.emoticonData.packetName]] error:nil];
    RELEASE_SAFE(fileManger);
    
    [self.downloadProgressArr addObject:@"unZipSuccess"];
    [self checkDownloadProgress];
}

- (void)checkDownloadProgress
{
    if (self.downloadProgressArr.count == 3) {
        [self updateEmotionListStatus:1];
        self.emoticonData = nil;
        self.downloadProgressArr = nil;

        if (self.delegate && [self.delegate respondsToSelector:@selector(downLoadEmotionSuccess)]) {
            [self.delegate downLoadEmotionSuccess];
     
        }
    }
}

- (BOOL)newEmoticonNotifyJudge
{
    BOOL judger = [[NSUserDefaults standardUserDefaults]boolForKey:@"emoticonFirst"];
    if (judger) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Dealloc

- (void)dealloc
{
    self.delegate = nil;
    self.emoticonData = nil;
    self.downloadProgressArr = nil;
    [super dealloc];
}

@end
