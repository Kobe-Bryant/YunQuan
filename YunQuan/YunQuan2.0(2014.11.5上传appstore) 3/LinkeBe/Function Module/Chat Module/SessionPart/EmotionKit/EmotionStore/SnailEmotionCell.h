//
//  SnailEmotionCell.h
//  ql
//
//  Created by LazySnail on 14-8-22.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EmotionStoreData;

@protocol SnailEmotionCellDelegate <NSObject>

- (void)emoticonCelldownloadEmoticonSuccess;

@end

@interface SnailEmotionCell : UITableViewCell

@property (nonatomic, retain) NSIndexPath *index;

@property (nonatomic, assign) id <SnailEmotionCellDelegate> delegate;

- (void)freshCellWithEmotionData:(EmotionStoreData *)emotionData;

- (void)downloadEmoticon;

@end
