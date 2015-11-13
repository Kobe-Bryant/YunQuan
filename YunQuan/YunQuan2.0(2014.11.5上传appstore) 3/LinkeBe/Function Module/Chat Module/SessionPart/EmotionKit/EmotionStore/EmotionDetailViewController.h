//
//  EmotionDetailViewController.h
//  ql
//
//  Created by LazySnail on 14-8-25.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmotionStoreData.h"

@class EmotionStoreData;

@protocol EmotionDetailViewControllerDelegate <NSObject>

- (void)detailDownloadEmotionWithData:(EmotionStoreData *)emotionData;

@end

@interface EmotionDetailViewController : UIViewController

@property (nonatomic, retain) EmotionStoreData * emotionData;

@property (nonatomic, assign) id <EmotionDetailViewControllerDelegate> delegate;

- (void)downloadEmoticonSuccess;

@end
