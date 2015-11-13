#import "PANumberTextField.h"

@implementation PANumberTextField
@synthesize isDecimalTextField;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isDecimalTextField = NO;
        isAddedObserversForCustomKeyboard = NO;
    }
    return self;
}

//添加自定义键盘监听方法
- (void)addObserversForCustomKeyboard{
    if (!isAddedObserversForCustomKeyboard) {
        isAddedObserversForCustomKeyboard = YES;
        if (!isDecimalTextField||[[[UIDevice currentDevice] systemVersion] floatValue] < 4.1) {
            self.keyboardType = UIKeyboardTypeNumberPad;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openShowKeyboardFlag) name:UIKeyboardDidShowNotification  object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeKeyboardFlag) name:UIKeyboardDidHideNotification  object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCustomButton) name:UITextFieldTextDidEndEditingNotification  object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCustomButton) name:UIKeyboardWillHideNotification  object:nil];
        }else{
            self.keyboardType = UIKeyboardTypeDecimalPad;
        }
    }
}

- (void)dealloc{
    if (!isDecimalTextField||[[[UIDevice currentDevice] systemVersion] floatValue] < 4.1) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [super dealloc];
}


- (void)openShowKeyboardFlag{

}

- (void)closeKeyboardFlag{
    
}
@end
