//
//  imageBrowser.h
//  sliderDemo
//
//  Created by yunlai on 14-3-31.
//  Copyright (c) 2014年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageBrowserDelegate <NSObject>

- (void)shouldHideImageBrowser;

@end

@interface ImageBrowser : UIView<UIScrollViewDelegate,UIAlertViewDelegate>

@property (nonatomic, assign) int currentIndex;
@property (nonatomic, assign) id <ImageBrowserDelegate> delegate;
@property(nonatomic,retain) NSArray* photos;

-(id) initWithPhotoList:(NSArray*) photos;
-(void) showWithAnimation:(BOOL) animation;
-(void) hideWithAnimation:(BOOL) animation;

@end
