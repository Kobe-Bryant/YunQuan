//
//  CommonProgressHUD.m
//  LinkeBe
//
//  Created by yunlai on 14-9-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "CommonProgressHUD.h"
#import "MBProgressHUD.h"

//MBProgressHud
#define HUD_VIEW_WIDTH 200
#define HUD_VIEW_HEIGHT 100

@implementation CommonProgressHUD
+ (BOOL) isPad {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}
+ (MBProgressHUD *) showMBProgressHud:(id)sender SuperView:(UIView *)superView Msg:(NSString *)msg ShowTime:(CGFloat)showtime {
    MBProgressHUD *hudView;
    if ([self isPad]) {
        CGRect rect = superView.bounds;
        rect.origin.x = rect.size.width / 2 - HUD_VIEW_WIDTH / 2;
        rect.origin.y = rect.size.height / 2 - HUD_VIEW_HEIGHT / 2;
        rect.size.width = HUD_VIEW_WIDTH;
        rect.size.height = HUD_VIEW_HEIGHT;
        hudView = [[MBProgressHUD alloc] initWithFrame:rect];
        hudView.userInteractionEnabled = NO;
        [superView addSubview:hudView];
    }else {
        CGRect rect = superView.bounds;
        rect.origin.x = rect.size.width / 2 - HUD_VIEW_WIDTH / 2;
        rect.origin.y = rect.size.height / 2 - HUD_VIEW_HEIGHT / 2;
        rect.size.width = HUD_VIEW_WIDTH;
        rect.size.height = HUD_VIEW_HEIGHT;
        hudView = [[MBProgressHUD alloc] initWithFrame:rect];
        hudView.userInteractionEnabled = NO;
        [superView addSubview:hudView];
        //hudView = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    }
    
    hudView.delegate = sender;
    
    hudView.mode = MBProgressHUDModeIndeterminate;
    hudView.labelText = msg;
    hudView.margin = 10.f;
    //hudView.yOffset = 150.f;
    
    [hudView show:YES];
    [hudView hide:YES afterDelay:showtime];
    return hudView;}

+ (MBProgressHUD *) showMBProgressHud:(id)sender SuperView:(UIView *)superView Msg:(NSString *)msg ShowTime:(CGFloat)showtime LeftOffset:(NSInteger)leftOffset {
    MBProgressHUD *hudView;
    if ([self isPad]) {
        CGRect rect = superView.bounds;
        rect.origin.x = rect.size.width / 2 - HUD_VIEW_WIDTH / 2 - leftOffset;
        rect.origin.y = rect.size.height / 2 - HUD_VIEW_HEIGHT / 2;
        rect.size.width = HUD_VIEW_WIDTH;
        rect.size.height = HUD_VIEW_HEIGHT;
        hudView = [[MBProgressHUD alloc] initWithFrame:rect];
        hudView.userInteractionEnabled = NO;
        [superView addSubview:hudView];
    }else {
        hudView = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    }
    
    hudView.delegate = sender;
    
    hudView.mode = MBProgressHUDModeText;
    hudView.labelText = msg;
    hudView.margin = 10.f;
    //hudView.yOffset = 150.f;
    
    [hudView show:YES];
    [hudView hide:YES afterDelay:showtime];
    return hudView;
}

+ (MBProgressHUD *) showMBProgressHud:(id)sender SuperView:(UIView *)superView Msg:(NSString *)msg {
    MBProgressHUD *hudView;
    if ([self isPad]) {
        CGRect rect = superView.bounds;
        rect.origin.x = rect.size.width / 2 - HUD_VIEW_WIDTH / 2;
        rect.origin.y = rect.size.height / 2 - HUD_VIEW_HEIGHT / 2;
        rect.size.width = HUD_VIEW_WIDTH;
        rect.size.height = HUD_VIEW_HEIGHT;
        hudView = [[MBProgressHUD alloc] initWithFrame:rect];
        hudView.userInteractionEnabled = NO;
        [superView addSubview:hudView];
    }else {
        CGRect rect = superView.bounds;
        rect.origin.x = rect.size.width / 2 - HUD_VIEW_WIDTH / 2;
        rect.origin.y = rect.size.height / 2 - HUD_VIEW_HEIGHT / 2;
        rect.size.width = HUD_VIEW_WIDTH;
        rect.size.height = HUD_VIEW_HEIGHT;
        hudView = [[MBProgressHUD alloc] initWithFrame:rect];
        hudView.userInteractionEnabled = NO;
        [superView addSubview:hudView];
        //hudView = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    }
    
    hudView.delegate = sender;
    
    hudView.mode = MBProgressHUDModeIndeterminate;
    hudView.labelText = msg;
    hudView.margin = 10.f;
    //hudView.yOffset = 150.f;
    
    [hudView show:YES];
    return hudView;
}

+ (MBProgressHUD *) showMBProgressHud:(id)sender SuperView:(UIView *)superView Msg:(NSString *)msg VisibleRect:(CGRect)vRect {
    MBProgressHUD *hudView;
    if ([self isPad]) {
        hudView = [[MBProgressHUD alloc] initWithFrame:vRect];
        [superView addSubview:hudView];
    }else {
        hudView = [[MBProgressHUD alloc] initWithFrame:vRect];
        [superView addSubview:hudView];
    }
    hudView.delegate = sender;
    
    hudView.mode = MBProgressHUDModeIndeterminate;
    hudView.labelText = msg;
    hudView.margin = 10.f;
    //hudView.yOffset = 150.f;
    
    [hudView show:YES];
    NSLog(@"%@", NSStringFromCGRect(hudView.frame));
    return hudView;
}

+ (MBProgressHUD *) showMBProgressHud:(id)sender SuperView:(UIView *)superView Msg:(NSString *)msg LeftOffset:(NSInteger)leftOffset {
    MBProgressHUD *hudView;
    if ([self isPad]) {
        CGRect rect = superView.bounds;
        rect.origin.x = rect.size.width / 2 - 50 - leftOffset;
        rect.origin.y = rect.size.height / 2 - 50;
        rect.size.width = 100;
        rect.size.height = 100;
        hudView = [[MBProgressHUD alloc] initWithFrame:rect];
        hudView.userInteractionEnabled = NO;
        [superView addSubview:hudView];
    }else {
        //hudView = [MBProgressHUD showHUDAddedTo:superView animated:YES];
        CGRect rect = superView.bounds;
        rect.origin.x = rect.size.width / 2 - 50;
        rect.origin.y = rect.size.height / 2 - 50;
        rect.size.width = 100;
        rect.size.height = 100;
        hudView = [[MBProgressHUD alloc] initWithFrame:rect];
        hudView.userInteractionEnabled = NO;
        [superView addSubview:hudView];
    }
    
    hudView.delegate = sender;
    
    hudView.mode = MBProgressHUDModeIndeterminate;
    hudView.labelText = msg;
    hudView.margin = 10.f;
    //hudView.yOffset = 150.f;
    
    [hudView show:YES];
    return hudView;
}

+ (MBProgressHUD *) showMBProgressHudHint:(id)sender SuperView:(UIView *)superView Msg:(NSString *)msg ShowTime:(CGFloat)showtime {
    MBProgressHUD *hudView = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    hudView.delegate = sender;
    
    hudView.mode = MBProgressHUDModeText;
    hudView.labelText = msg;
    hudView.margin = 10.f;
    //hudView.yOffset = 150.f;
    
    [hudView hide:YES afterDelay:showtime];
    return hudView;
}

@end
