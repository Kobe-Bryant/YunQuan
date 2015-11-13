//
//  UIImage+extra.m
//  CommunityAPP
//
//  Created by Stone on 14-4-1.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "UIImage+extra.h"
#import<objc/runtime.h>
#import "NSFileManager+Community.h"

static void *kFileName = (void *)@"kfileName";
static void *kFilePath = (void *)@"kFilePath";

@implementation UIImage (extra)

- (NSString *)fileName{
    return objc_getAssociatedObject(self, kFileName);
}

- (void)setFileName:(NSString *)fileName{
    objc_setAssociatedObject(self, kFileName, fileName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)filePath{
    return objc_getAssociatedObject(self, kFilePath);
}

- (void)setFilePath:(NSString *)filePath{
    objc_setAssociatedObject(self, kFilePath, filePath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}




+ (UIImage *)writeImageToSandBox:(UIImage *)image name:(NSString *)fileName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [fileManager applicationTemporaryDirectory];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];   // 保存文件的名称
    image.filePath = [filePath retain];
    
    NSData *data = UIImageJPEGRepresentation(image,0.2);
    NSLog(@"%d",[data length]);
    UIImage *editImage = [UIImage imageWithData:data];
    editImage.fileName = fileName;
    editImage.filePath = filePath;
    
    BOOL result = [data writeToFile:filePath atomically:YES]; // 保存成功会返回YES
    
    if (result) {
        
    }
    
    return editImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
