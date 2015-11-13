//
//  TogetherData.h
//  ql
//
//  Created by yunlai on 14-8-20.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "OriginData.h"

@interface TogetherData : OriginData

@property(nonatomic,assign) int dataID;

@property(nonatomic,retain) NSString * txt;
@property(nonatomic,retain) NSString * msgdesc;

@end
