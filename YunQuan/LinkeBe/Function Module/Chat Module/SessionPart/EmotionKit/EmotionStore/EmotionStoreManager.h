//
//  EmotionStoreManager.h
//  ql
//
//  Created by LazySnail on 14-8-21.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequest.h"

@class EmotionStoreManager;
@class EmotionStoreData;

@protocol EmotionStroeManagerDelegate <NSObject>

@optional
- (void)getEmotionStoreDataSuccessWithDic:(NSDictionary *)dataDic sender:(EmotionStoreManager *)sender;
- (void)getEmotionStoreDataFailed:(EmotionStoreManager *)sender;
- (void)getEmoticonDetailDataSuccessWithSender:(EmotionStoreManager *)sender;
- (void)getEmoticonDetailDataFailed:(EmotionStoreManager *)sender;

//下载完成
- (void)downLoadEmotionSuccess;
//下载失败
- (void)dowmLoadEmotionFailed;

@end

typedef void (^ProgressBlock)(void);

@interface EmotionStoreManager : NSObject<ASIHTTPRequestDelegate>{
}

@property(nonatomic, assign) id <EmotionStroeManagerDelegate> delegate;

- (void)getEmotionStoreDataDic;

- (void)getemotionDetailDataForEmotionID:(NSInteger)emotionID;

//下载表情包
- (void)downLoadEmotionWithParam:(EmotionStoreData *)data andBlock:(ProgressBlock)block progress:(UIProgressView*) pv;

- (BOOL)judgeFirstInstallAndLoadDownloadedEmoticon;

- (BOOL)judgeShouldAndLoadDownloadedDetailEmoticonWithEmoticonID:(NSInteger)emoticonID;

- (BOOL)newEmoticonNotifyJudge;

@end
