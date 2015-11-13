//
//  JCTopic.h
//  PSCollectionViewDemo
//
//  Created by vincent on 14-1-7.
//
//

#import <UIKit/UIKit.h>
@protocol JCTopicDelegate<NSObject>
-(void)didClick:(int)index;
-(void)currentPage:(int)page total:(NSUInteger)total;
@end
@interface JCTopic : UIScrollView<UIScrollViewDelegate>{
    UIButton * pic;
    bool flag;
    int scrollTopicFlag;
    NSTimer * scrollTimer;
    int currentPage;
    CGSize imageSize;
    UIImage *image;
}
@property(nonatomic,strong)  NSArray * pics;
@property(nonatomic,strong)  UIPageControl *page;
@property(nonatomic,retain)  id<JCTopicDelegate> JCdelegate;
-(void)releaseTimer;
-(void)upDate;
- (void)setupTimer;
@end
