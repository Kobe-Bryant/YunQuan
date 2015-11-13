//
//  UIView_extra.m
//  PAEBank
//
//  Created by pingan_tiger on 11-6-2.
//  Copyright 2011 pingan. All rights reserved.
//

#import "UIView_extra.h"

@implementation UIView(PAE2)

-(void) addSubImageView:(UIImage*)image Rect:(CGRect)rect
{
	UIImageView *addImageView = [[UIImageView alloc]initWithImage:image];
	addImageView.frame = rect;
	[self addSubview:addImageView];
	[addImageView release];
}
-(void) addSubLabel:(NSString*)string Rect:(CGRect)rect Font:(UIFont*)font Color:(UIColor*)color Tag:(NSInteger)index
{
	UILabel *label = [[UILabel alloc]initWithFrame:rect];
	label.text=string;
	label.font=font;
	label.adjustsFontSizeToFitWidth=YES;
	if (color!=nil) {
		label.textColor=color;
	}else {
		label.textColor = [UIColor  colorWithRed:0.27 green:0.24 blue:0.16 alpha:1.0];
	}
	
	if(index!=0 && index>21){
		label.textAlignment=NSTextAlignmentRight;
	}
	label.backgroundColor=[UIColor colorWithWhite:0 alpha:0];
	[self addSubview:label];
	[label release];
}
-(void) addSubButton:(id)sender buttonImg:(UIImage*)buttonImg pressedButtonImg:(UIImage*)pressedButtonImg Rect:(CGRect)rect Tag:(NSInteger)index
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setBackgroundImage:buttonImg forState:UIControlStateNormal];
	[button setBackgroundImage:pressedButtonImg forState:UIControlStateHighlighted];	
	button.frame=rect;
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	button.tag=index;
	[button.titleLabel setFont:[UIFont systemFontOfSize:15]];
//	[button addTarget:sender action:@selector(makeAction:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:button];
}
-(void) addSubButtonNormal:(id)sender Title:(NSString*)title Rect:(CGRect)rect Tag:(NSInteger)index
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setTitle:title forState:UIControlStateNormal];
	button.frame=rect;
	button.tag=index;
//	[button addTarget:sender action:@selector(makeAction:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:button];
}

@end

