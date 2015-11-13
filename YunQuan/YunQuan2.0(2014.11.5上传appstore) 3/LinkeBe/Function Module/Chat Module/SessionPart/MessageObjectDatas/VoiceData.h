//
//  VoiceData.h
//  ql
//
//  Created by LazySnail on 14-6-26.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "OriginUrlData.h"

@interface VoiceData : OriginUrlData <NSCopying>

@property (nonatomic ,assign) float duration;

@property (nonatomic, assign) UITableViewCell * currentCell;

@end
