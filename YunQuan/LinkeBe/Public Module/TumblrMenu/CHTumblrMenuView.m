//
//  CHTumblrMenuView.m
//  TumblrMenu
//
//  Created by HangChen on 12/9/13.
//  Copyright (c) 2013 Hang Chen (https://github.com/cyndibaby905)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "CHTumblrMenuView.h"
#import "Global.h"

#define CHTumblrMenuViewTag 1999
#define CHTumblrMenuViewImageHeight 60
#define CHTumblrMenuViewTitleHeight 20
#define CHTumblrMenuViewVerticalPadding 40
#define CHTumblrMenuViewHorizontalMargin 30
#define CHTumblrMenuViewRriseAnimationID @"CHTumblrMenuViewRriseAnimationID"
#define CHTumblrMenuViewDismissAnimationID @"CHTumblrMenuViewDismissAnimationID"
#define CHTumblrMenuViewAnimationTime 0.36
#define CHTumblrMenuViewAnimationInterval (CHTumblrMenuViewAnimationTime / 5)

#define TumblrBlue [UIColor colorWithRed:45/255.0f green:68/255.0f blue:94/255.0f alpha:1.0]

#define PI 3.1415926

#define columnCount 2

@interface CHTumblrMenuItemButton : UIButton
+ (id)TumblrMenuItemButtonWithTitle:(NSString*)title andIcon:(UIImage*)icon andSelectedBlock:(CHTumblrMenuViewSelectedBlock)block;
@property(nonatomic,copy)CHTumblrMenuViewSelectedBlock selectedBlock;
@end

@implementation CHTumblrMenuItemButton

+ (id)TumblrMenuItemButtonWithTitle:(NSString*)title andIcon:(UIImage*)icon andSelectedBlock:(CHTumblrMenuViewSelectedBlock)block
{
    CHTumblrMenuItemButton *button = [CHTumblrMenuItemButton buttonWithType:UIButtonTypeCustom];
    [button setImage:icon forState:UIControlStateNormal];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    button.selectedBlock = block;
 
    return button;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, CHTumblrMenuViewImageHeight, CHTumblrMenuViewImageHeight);
    self.titleLabel.frame = CGRectMake(0, CHTumblrMenuViewImageHeight +5, CHTumblrMenuViewImageHeight, CHTumblrMenuViewTitleHeight);
}

-(void) dealloc{
    [super dealloc];
}

@end

@implementation CHTumblrMenuView
{
    UIImageView *backgroundView_;
    NSMutableArray *buttons_;
    UIButton* btmBtn;
}
@synthesize backgroundImgView = backgroundView_;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        ges.delegate = self;
        [self addGestureRecognizer:ges];
        [ges release];
        
        self.backgroundColor = [UIColor clearColor];
        backgroundView_ = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundView_.backgroundColor = [UIColor blackColor];
        backgroundView_.alpha = 0.8;
        backgroundView_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:backgroundView_];
        buttons_ = [[NSMutableArray alloc] initWithCapacity:6];
        
        
        CGSize scSize = [UIScreen mainScreen].bounds.size;
        UIView* v = [[UIView alloc] init];
        v.frame = CGRectMake(0, scSize.height - 50, scSize.width, 50);
        
//        v.backgroundColor = [UIColor colorWithRed:0.20 green:0.22 blue:0.23 alpha:1.0];
        v.backgroundColor = [UIColor clearColor];
        [self addSubview:v];
        
        btmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        btmBtn.frame = CGRectMake((scSize.width - 50)/2, 0, 50, 50);
        [btmBtn addTarget:self action:@selector(buttomBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [btmBtn setImage:IMGREADFILE(DynamicPic_list_close) forState:UIControlStateNormal];
        
        [v addSubview:btmBtn];
        
        [v release];
        
        NSLog(@"--btmBtn:%@--",NSStringFromCGRect(btmBtn.frame));
    }
    return self;
}

-(void) buttomBtnClick{
    [self dismiss:nil];
}

- (void)addMenuItemWithTitle:(NSString*)title andIcon:(UIImage*)icon andSelectedBlock:(CHTumblrMenuViewSelectedBlock)block
{
    CHTumblrMenuItemButton *button = [CHTumblrMenuItemButton TumblrMenuItemButtonWithTitle:title andIcon:icon andSelectedBlock:block];
    
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    [buttons_ addObject:button];
}

- (CGRect)frameForButtonAtIndex:(NSUInteger)index
{
//    NSUInteger columnCount = 3;
//    
    CGFloat hMargin;
//    if (buttons_.count > 2) {
//        columnCount = 3;
//        hMargin = CHTumblrMenuViewHorizontalMargin;
//    }else{
//        columnCount = 2;
//        hMargin = 60.0;
//    }
    
//    columnCount = 2;
    hMargin = 60.0;
    
    NSUInteger columnIndex =  index % columnCount;

    NSUInteger rowCount = buttons_.count / columnCount + (buttons_.count%columnCount>0?1:0);
    NSUInteger rowIndex = index / columnCount;

    CGFloat itemHeight = (CHTumblrMenuViewImageHeight + CHTumblrMenuViewTitleHeight) * rowCount + (rowCount > 1?(rowCount - 1) * CHTumblrMenuViewHorizontalMargin:0);
    CGFloat offsetY = (self.bounds.size.height - itemHeight) / 2.0;
    CGFloat verticalPadding = (self.bounds.size.width - hMargin * 2 - CHTumblrMenuViewImageHeight * columnCount) / (columnCount - 1);
    
    CGFloat offsetX = hMargin;
    
    offsetX += (CHTumblrMenuViewImageHeight+ verticalPadding) * columnIndex;
    
    offsetY += (CHTumblrMenuViewImageHeight + CHTumblrMenuViewTitleHeight + CHTumblrMenuViewVerticalPadding) * rowIndex;

    
    return CGRectMake(offsetX, offsetY, CHTumblrMenuViewImageHeight, (CHTumblrMenuViewImageHeight+CHTumblrMenuViewTitleHeight));

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (NSUInteger i = 0; i < buttons_.count; i++) {
        CHTumblrMenuItemButton *button = buttons_[i];
        button.frame = [self frameForButtonAtIndex:i];
    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer.view isKindOfClass:[CHTumblrMenuItemButton class]]) {
        return NO;
    }
    
    CGPoint location = [gestureRecognizer locationInView:self];
    for (UIView* subview in buttons_) {
        if (CGRectContainsPoint(subview.frame, location)) {
            return NO;
        }
    }
    
    return YES;
}

- (void)dismiss:(id)sender
{
    [self dropAnimation];
    double delayInSeconds = CHTumblrMenuViewAnimationTime  + CHTumblrMenuViewAnimationInterval * (buttons_.count + 1);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self removeFromSuperview];
    });
}


- (void)buttonTapped:(CHTumblrMenuItemButton*)btn
{
//    [self dismiss:nil];
    [self removeFromSuperview];
    btn.selectedBlock();
//    double delayInSeconds = CHTumblrMenuViewAnimationTime  + CHTumblrMenuViewAnimationInterval * (buttons_.count + 1);
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        btn.selectedBlock();
//
//    });
}


- (void)riseAnimation
{
//    NSUInteger columnCount = 3;
//    if (buttons_.count > 2) {
//        columnCount = 3;
//    }else{
//        columnCount = 2;
//    }
//    columnCount = 2;
    NSUInteger rowCount = buttons_.count / columnCount + (buttons_.count%columnCount>0?1:0);

    for (NSUInteger index = 0; index < buttons_.count; index++) {
        CHTumblrMenuItemButton *button = buttons_[index];
        button.layer.opacity = 0;
        CGRect frame = [self frameForButtonAtIndex:index];
        NSUInteger rowIndex = index / columnCount;
        NSUInteger columnIndex = index % columnCount;
        CGPoint fromPosition = CGPointMake(frame.origin.x + CHTumblrMenuViewImageHeight / 2.0,frame.origin.y +  (rowCount - rowIndex + 2)*200 + (CHTumblrMenuViewImageHeight + CHTumblrMenuViewTitleHeight) / 2.0);
        
        CGPoint toPosition = CGPointMake(frame.origin.x + CHTumblrMenuViewImageHeight / 2.0,frame.origin.y + (CHTumblrMenuViewImageHeight + CHTumblrMenuViewTitleHeight) / 2.0);
        
        double delayInSeconds = rowIndex * columnCount * CHTumblrMenuViewAnimationInterval;
        if (!columnIndex) {
            delayInSeconds += CHTumblrMenuViewAnimationInterval;
        }
        else if(columnIndex == 2) {
            delayInSeconds += CHTumblrMenuViewAnimationInterval * 2;
        }

        CABasicAnimation *positionAnimation;
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.45f :1.2f :0.75f :1.0f];
        positionAnimation.duration = CHTumblrMenuViewAnimationTime;
        positionAnimation.beginTime = [button.layer convertTime:CACurrentMediaTime() fromLayer:nil] + delayInSeconds;
        [positionAnimation setValue:[NSNumber numberWithUnsignedInteger:index] forKey:CHTumblrMenuViewRriseAnimationID];
        positionAnimation.delegate = self;
        
        [button.layer addAnimation:positionAnimation forKey:@"riseAnimation"];


        
    }
}

- (void)dropAnimation
{
//    NSUInteger columnCount = 3;
    
//    if (buttons_.count > 2) {
//        columnCount = 3;
//    }else{
//        columnCount = 2;
//    }
//    columnCount = 2;
    
    [UIView animateWithDuration:0.2 animations:^{
        btmBtn.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -PI/4);
    }];
    
    [UIView animateWithDuration:(CHTumblrMenuViewAnimationTime*buttons_.count) animations:^{
        
        for (NSUInteger index = 0; index < buttons_.count; index++) {
            CHTumblrMenuItemButton *button = buttons_[index];
            CGRect frame = [self frameForButtonAtIndex:index];
            NSUInteger rowIndex = index / columnCount;
            NSUInteger columnIndex = index % columnCount;
            
            CGPoint toPosition = CGPointMake(frame.origin.x + CHTumblrMenuViewImageHeight / 2.0,frame.origin.y -  (rowIndex + 2)*200 + (CHTumblrMenuViewImageHeight + CHTumblrMenuViewTitleHeight) / 2.0);
            
            CGPoint fromPosition = CGPointMake(frame.origin.x + CHTumblrMenuViewImageHeight / 2.0,frame.origin.y + (CHTumblrMenuViewImageHeight + CHTumblrMenuViewTitleHeight) / 2.0);
            
            double delayInSeconds = rowIndex * columnCount * CHTumblrMenuViewAnimationInterval;
            if (!columnIndex) {
                delayInSeconds += CHTumblrMenuViewAnimationInterval;
            }
            else if(columnIndex == 2) {
                delayInSeconds += CHTumblrMenuViewAnimationInterval * 2;
            }
            
            CABasicAnimation *positionAnimation;
            
            positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
            positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
            positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
            positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.3 :0.5f :1.0f :1.0f];
            positionAnimation.duration = CHTumblrMenuViewAnimationTime;
            positionAnimation.beginTime = [button.layer convertTime:CACurrentMediaTime() fromLayer:nil] + delayInSeconds;
            [positionAnimation setValue:[NSNumber numberWithUnsignedInteger:index] forKey:CHTumblrMenuViewDismissAnimationID];
            positionAnimation.delegate = self;
            
            [button.layer addAnimation:positionAnimation forKey:@"riseAnimation"];
            
        }
        
        self.alpha = 0.0;
        
    }];
    
}

- (void)animationDidStart:(CAAnimation *)anim
{
//    NSUInteger columnCount = 3;
//    if (buttons_.count > 2) {
//        columnCount = 3;
//    }else{
//        columnCount = 2;
//    }
//    columnCount = 2;
    
    if([anim valueForKey:CHTumblrMenuViewRriseAnimationID]) {
        NSUInteger index = [[anim valueForKey:CHTumblrMenuViewRriseAnimationID] unsignedIntegerValue];
        UIView *view = buttons_[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        CGPoint toPosition = CGPointMake(frame.origin.x + CHTumblrMenuViewImageHeight / 2.0,frame.origin.y + (CHTumblrMenuViewImageHeight + CHTumblrMenuViewTitleHeight) / 2.0);
        CGFloat toAlpha = 1.0;
        
        view.layer.position = toPosition;
        view.layer.opacity = toAlpha;
        
    }
    else if([anim valueForKey:CHTumblrMenuViewDismissAnimationID]) {
        NSUInteger index = [[anim valueForKey:CHTumblrMenuViewDismissAnimationID] unsignedIntegerValue];
        NSUInteger rowIndex = index / columnCount;

        UIView *view = buttons_[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        CGPoint toPosition = CGPointMake(frame.origin.x + CHTumblrMenuViewImageHeight / 2.0,frame.origin.y -  (rowIndex + 2)*250 + (CHTumblrMenuViewImageHeight + CHTumblrMenuViewTitleHeight) / 2.0);
        
        view.layer.position = toPosition;
    }
}


- (void)show
{
    
    UIViewController *appRootViewController;
    UIWindow *window;
    
    window = [UIApplication sharedApplication].keyWindow;
   
        
    appRootViewController = window.rootViewController;
    
 
    
    UIViewController *topViewController = appRootViewController;
    while (topViewController.presentedViewController != nil)
    {
        topViewController = topViewController.presentedViewController;
    }
    
    if ([topViewController.view viewWithTag:CHTumblrMenuViewTag]) {
        [[topViewController.view viewWithTag:CHTumblrMenuViewTag] removeFromSuperview];
    }
    
    self.frame = topViewController.view.bounds;
    [topViewController.view addSubview:self];
    
    [self riseAnimation];
}

-(void) dealloc{
    [buttons_ release];
    [backgroundView_ release];
    [super dealloc];
}
@end
