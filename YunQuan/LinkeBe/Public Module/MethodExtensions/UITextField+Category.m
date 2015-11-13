//
//  UITextField+Category.m
//  KeyboardExtension
//
//  Created by james li on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITextField+Category.h"
#import "PANumberTextField.h"
#import "Global.h"
@implementation UITextField(Category)

BOOL showKeyboardFlag;
- (void)addButtonToKeyboard:(UIButton*)btn{
    if ([[[UIApplication sharedApplication] windows] count]<2) {
        return;
    }
	UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
	UIView* keyboard;
	for(int i=0; i<[tempWindow.subviews count]; i++) {
		keyboard = [tempWindow.subviews objectAtIndex:i];
		// keyboard found, add the button
        if([[keyboard description] hasPrefix:@"<UIPeripheralHost"]||[[keyboard description] hasPrefix:@"<UIKeyboard"])
        {
            [keyboard.superview addSubview:btn];
            //NSLog(@"addButtonToKeyboard:%@.....",btn);
            return;
        }
	}
    
}

- (void)addDoneButtonToKeyboard {
    //NSLog(@"addDoneButtonToKeyboard.....");
	// create custom button
    self.returnKeyType = UIReturnKeyDone;
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *_doneImage = [UIImage imageNamed:@"queding.png"];
	doneButton.frame = CGRectMake(0, [UIApplication sharedApplication].keyWindow.frame.size.height-53, _doneImage.size.width, _doneImage.size.height);
	doneButton.adjustsImageWhenHighlighted = NO;
    [doneButton setImage:[UIImage imageNamed:@"queding.png"] forState:UIControlStateNormal];
    [doneButton setImage:[UIImage imageNamed:@"queding_b.png"] forState:UIControlStateHighlighted];
    doneButton.tag = 888999;
	[doneButton addTarget:self action:@selector(doneBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addButtonToKeyboard:doneButton];
}

- (void)addPointButtonToKeyboard {
    //NSLog(@"addPointButtonToKeyboard.....");
	// create custom button
	UIButton *pointButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pointButton.tag = 888999;
    UIImage *_pointImage = [UIImage imageNamed:@"dian.png"];
	pointButton.frame = CGRectMake(0, [UIApplication sharedApplication].keyWindow.frame.size.height-53, _pointImage.size.width, _pointImage.size.height);
	pointButton.adjustsImageWhenHighlighted = NO;
    [pointButton setImage:_pointImage forState:UIControlStateNormal];
    [pointButton setImage:[UIImage imageNamed:@"dian_b.png"] forState:UIControlStateHighlighted];
    
	[pointButton addTarget:self action:@selector(pointBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addButtonToKeyboard:pointButton];
}

- (void)openShowKeyboardFlag{
    //NSLog(@"openShowKeyboardFlag.....");
    showKeyboardFlag = YES;
}

- (void)closeKeyboardFlag{
    //NSLog(@"closeKeyboardFlag.....");
    showKeyboardFlag = NO;
}

- (void)handleCustomKeyboard{
    [self removeCustomButton];
    showKeyboardFlag = NO;
    if ([self isKindOfClass:PANumberTextField.class]) {
        SEL runSEL;
        PANumberTextField *_numTextField = (PANumberTextField*)self;
        [_numTextField addObserversForCustomKeyboard];
        if (_numTextField.isDecimalTextField) {
            if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1) {
                self.keyboardType = UIKeyboardTypeDecimalPad;
                return;
            }else{
                self.keyboardType = UIKeyboardTypeNumberPad;
            }
            runSEL = @selector(addPointButtonToKeyboard);
        }else{
            runSEL = @selector(addDoneButtonToKeyboard);
        }
        [self performSelectorOnMainThread:runSEL withObject:nil waitUntilDone:showKeyboardFlag];
    }
}

- (void)removeCustomButton{
    //NSLog(@"removeCustomButton begin.....");
    NSArray *allWindows = [[UIApplication sharedApplication] windows];
    for (int i=[allWindows count]-1; i>=0;i--) {
        UIWindow *keyboardWindow = [allWindows objectAtIndex:i];
        UIButton *customBtn =(UIButton *)[keyboardWindow viewWithTag:888999];
        if (customBtn) {
            [customBtn removeFromSuperview];
            //NSLog(@"removeCustomButton end.....");
            return;
        }
    }
}


- (void)doneBtnAction{
    if ([self.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        [self.delegate textFieldShouldReturn:self];
    }
    [self resignFirstResponder];
}

- (void)pointBtnAction
{
    if ([self.text rangeOfString:@"."].location == NSNotFound) {
        self.text = [NSString stringWithFormat:@"%@%@",self.text,@"."];
        //TO DO James 第一个.要自动显示成0.
        
    }
}

@end
