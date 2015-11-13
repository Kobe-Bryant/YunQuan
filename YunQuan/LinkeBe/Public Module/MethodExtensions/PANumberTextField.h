#import <UIKit/UIKit.h>
#import "UITextField+Category.h"

@interface PANumberTextField:UITextField
{
    BOOL isDecimalTextField;
    BOOL isAddedObserversForCustomKeyboard; //是否添加自定义键盘监听方法

}
@property BOOL isDecimalTextField;

//添加自定义键盘监听方法
- (void)addObserversForCustomKeyboard;

@end
