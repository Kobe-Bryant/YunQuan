//
//  CustomEmotionData.h
//  ql
//
//  Created by LazySnail on 14-8-20.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OriginData.h"

#import "ASIHTTPRequest.h"

@protocol CustomEmotionDataDelegate <NSObject>

@optional
- (void)getGifUIImageSuccessWithUIImage:(UIImage *)gifImg;

- (void)getThumbUIImageSuccessWithUIImage:(UIImage *)thumbImg;

@end

@interface CustomEmotionData : OriginData<ASIHTTPRequestDelegate>

@property (nonatomic, retain) NSString * title;

@property (nonatomic, assign) NSInteger emoticonItemID;

@property (nonatomic, retain) NSString * filePath;

@property (nonatomic, retain) NSString * thumbUrl;

@property (nonatomic, retain) NSString * emotionUrl;

@property(nonatomic,assign) id<CustomEmotionDataDelegate> delegate;

- (void)getThumbImg;

- (void)getGifImg;

@end
