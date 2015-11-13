//
//  TextData.h
//  ql
//
//  Created by LazySnail on 14-5-7.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "OriginData.h"

@interface TextData : OriginData

//字体类型（据此区分不同的显示效果)
@property (nonatomic, assign) int txttype;
//消息文本
@property (nonatomic, retain) NSString * txt;

@end
