//
//  WatermarkCameraViewController.h
//  LinkeBe
//
//  Created by Dream on 14-9-19.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBImagePickerController.h"
@protocol WatermarkCameraViewControllerDelegate <NSObject>

-(void)didSelectImages:(NSArray *)images;

@end

@interface WatermarkCameraViewController : UIViewController<UIScrollViewDelegate,QBImagePickerControllerDelegate>

@property (nonatomic,assign) id<WatermarkCameraViewControllerDelegate> delegate;
@property (nonatomic,assign) int type;
@property (nonatomic,assign) int currentImageCount;

@end
