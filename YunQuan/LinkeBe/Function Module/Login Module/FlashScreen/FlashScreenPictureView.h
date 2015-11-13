//
//  FlashScreenPictureView.h
//  LinkeBe
//
//  Created by yunlai on 14-9-22.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinkedBeHttpRequest.h"

@interface FlashScreenPictureView : UIView{
    UIView *screenView;
    UIImageView *changeImage;
    
    LinkedBeHttpRequest *_request;
}

@end
