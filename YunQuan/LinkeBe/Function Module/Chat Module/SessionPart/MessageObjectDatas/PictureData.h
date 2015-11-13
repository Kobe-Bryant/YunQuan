//
//  PictureData.h
//  ql
//
//  Created by LazySnail on 14-5-7.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "OriginUrlData.h"

@interface PictureData : OriginUrlData

//客户端用以区分是否接收过
@property (nonatomic, assign) int picID;
//发送时原生的图片
@property (nonatomic, retain) UIImage * image;
//图片宽度
@property (nonatomic, assign) float width;
//图片高度
@property (nonatomic, assign) float height;

@end
