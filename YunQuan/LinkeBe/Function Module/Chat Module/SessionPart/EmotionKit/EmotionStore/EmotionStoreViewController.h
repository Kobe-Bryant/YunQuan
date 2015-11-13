//
//  EmotionStoreViewController.h
//  ql
//
//  Created by LazySnail on 14-8-21.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EmotionStoreViewControllerDelegate <NSObject>

- (void)downloadEmoticonSuccess;

@end

@interface EmotionStoreViewController : UIViewController

@property (nonatomic, assign) id <EmotionStoreViewControllerDelegate> delegate;

@end
