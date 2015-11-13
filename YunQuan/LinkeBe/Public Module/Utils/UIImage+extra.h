//
//  UIImage+extra.h
//  CommunityAPP
//
//  Created by Stone on 14-4-1.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (extra)

@property (nonatomic, retain) NSString *fileName;

@property (nonatomic, retain) NSString *filePath;

/**
 *  把图片写入沙盒，并返回压缩后的UIImage
 *
 *  @param image    压缩前UIImage
 *  @param fileName image name
 *
 *  @return 压缩后的UIiamge
 */
+ (UIImage *)writeImageToSandBox:(UIImage *)image name:(NSString *)fileName;

/**
 *  利用UIColor生成纯色图片
 *
 *  @param color 生成纯色的图片
 *  @param size  生成图片的尺寸
 *
 *  @return 纯色的UIImage
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end
