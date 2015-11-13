//
//  PreviewImageViewController.h
//  LinkeBe
//
//  Created by yunlai on 14-9-22.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "myImageView.h"

@protocol previewImageViewControllerDelegate <NSObject>

-(void)imagesDidRemain:(NSArray *)remainImages;

@end

@interface PreviewImageViewController : UIViewController<UIScrollViewDelegate,myImageViewDelegate>

@property (nonatomic,copy) NSArray *imagesArray; //用copy防止两边同一个引用
@property (nonatomic,assign) NSInteger chooseIndex;

@property (nonatomic,assign) id<previewImageViewControllerDelegate> delegate;

@end
