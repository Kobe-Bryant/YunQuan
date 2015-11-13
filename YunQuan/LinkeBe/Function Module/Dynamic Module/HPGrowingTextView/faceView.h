//
//  faceView.h
//  myFace
//
//  Created by siphp on 13-9-12.
//
//

#import <UIKit/UIKit.h>

@protocol faceViewDelegate;

@interface faceView : UIView<UIScrollViewDelegate>
{
    NSObject<faceViewDelegate> *delegate;
    UIView *barView;
    UIScrollView *customFaceScrollView;
    UIScrollView *sysFaceScrollView;
    UIScrollView *stringFaceScrollView;
    int currentSelectedIndex;
    UIPageControl *customFacePageControll;
    UIPageControl *sysFacePageControll;
    UIPageControl *stringFacePageControll;
}

@property (nonatomic, assign) NSObject<faceViewDelegate> *delegate;

@end

@protocol faceViewDelegate
-(void) sendbuttonClick;
@optional
-(void) addEmotionClick;

@optional
- (void)faceView:(faceView *)faceView didSelectAtString:(NSString *)faceString;
- (void)delFaceString;
@end