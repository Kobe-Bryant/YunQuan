//
//  UIView_extra.h
//  PAEBank
//
//  Created by pingan_tiger on 11-6-2.
//  Copyright 2011 pingan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(PAE2) 
// 添加图片
-(void) addSubImageView:(UIImage*)image Rect:(CGRect)rect;
// 添加标签
-(void) addSubLabel:(NSString*)string Rect:(CGRect)rect Font:(UIFont*)font Color:(UIColor*)color Tag:(NSInteger)index;
// 添加按钮
-(void) addSubButton:(id)sender buttonImg:(UIImage*)buttonImg pressedButtonImg:(UIImage*)pressedButtonImg Rect:(CGRect)rect Tag:(NSInteger)index;
//  添加普通按钮
-(void) addSubButtonNormal:(id)sender Title:(NSString*)title Rect:(CGRect)rect Tag:(NSInteger)index;
@end
