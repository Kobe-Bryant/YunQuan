//
//  SnailSystemiMOperator.h
//  LinkeBe
//
//  Created by LazySnail on 14-1-27.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SnailSystemiMOperatorDelegate <NSObject>

@end

@interface SnailSystemiMOperator : NSObject

//用户登录iM 服务端
- (void)loginIMServer;

//用户注销iM 服务端
- (void)loginIMServerOut;

@end
