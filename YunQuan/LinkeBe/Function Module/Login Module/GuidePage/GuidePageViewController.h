//
//  GuidePageViewController.h
//  ql
//
//  Created by yunlai on 14-2-24.
//  Copyright (c) 2014年 ChenFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCTopic.h"

@interface GuidePageViewController : UIViewController<UIScrollViewDelegate,JCTopicDelegate>

- (id)initNibView:(NSDictionary *)dic;

@end
