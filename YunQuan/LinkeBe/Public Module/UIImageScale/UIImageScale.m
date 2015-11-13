//
//  UIImageScale.m
//  飞飞Q信
//
//  Created by Eamon.Lin on 11-6-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImageScale.h"

@implementation UIImage (scale)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (CGSize) fitSize: (CGSize)thisSize inSize: (CGSize) aSize
{
	CGFloat scale;
	CGSize newsize = CGSizeMake(thisSize.width * 2, thisSize.height * 2);
	
	if (newsize.height && (newsize.height > aSize.height))
	{
		scale = aSize.height / newsize.height;
		newsize.width *= scale;
		newsize.height *= scale;
	}
	
	if (newsize.width && (newsize.width >= aSize.width))
	{
		scale = aSize.width / newsize.width;
		newsize.width *= scale;
		newsize.height *= scale;
	}
	
	return newsize;
}

- (UIImage *)scaleToSize:(CGSize)viewsize
{
   /* // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;*/
	CGSize newSize = CGSizeMake(viewsize.width * 2, viewsize.height * 2);
	viewsize = newSize;
	CGSize size = [self fitSize:self.size inSize:viewsize];
	
	UIGraphicsBeginImageContext(viewsize);
	
	float dwidth = (viewsize.width - size.width) / 2.0f;
	float dheight = (viewsize.height - size.height) / 2.0f;
	
	CGRect rect = CGRectMake(dwidth, dheight, size.width, size.height);
	[self drawInRect:rect];
	
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
	
    return newimg;  
	
}

- (UIImage *)fillSize:(CGSize)viewsize
{
	CGSize newSize = CGSizeMake(viewsize.width * 2, viewsize.height * 2);
	viewsize = newSize;
	CGSize size = self.size;
	
	CGFloat scalex = viewsize.width / size.width;
	CGFloat scaley = viewsize.height / size.height; 
	CGFloat scale = MAX(scalex, scaley);	
	
	UIGraphicsBeginImageContext(viewsize);
	
	CGFloat width = size.width * scale;
	CGFloat height = size.height * scale;
	
	float dwidth = ((viewsize.width - width) / 2.0f);
	float dheight = ((viewsize.height - height) / 2.0f);
	
	CGRect rect = CGRectMake(dwidth, dheight, size.width * scale, size.height * scale);
	[self drawInRect:rect];
	
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  

    return newimg;  
}

// 图片
+ (UIImage *)imageCwNamed:(NSString *)named
{
    if (named.length == 0 || named == nil) {
        return nil;
    }
    
    NSRange rang = [named rangeOfString:@"."];
    
    NSString *back = [named substringFromIndex:rang.location + rang.length];
    
    NSString *front = [named substringWithRange:NSMakeRange(0,rang.location)];
    
    NSString *path = [[NSBundle mainBundle]pathForResource:front ofType:back];
    
    return [UIImage imageWithContentsOfFile:path];
}

// 等比缩放返回新的CGSize 
+ (CGSize)fitsize:(CGSize)thisSize size:(CGSize)oldSize
{
    if (thisSize.width == 0.f && thisSize.height == 0.f)
        return CGSizeMake(0.f, 0.f);
    CGFloat wscale = thisSize.width / oldSize.width;
    CGFloat hscale = thisSize.height / oldSize.height;
    CGFloat scale = (wscale > hscale) ? wscale : hscale;
    CGSize newSize = CGSizeMake(thisSize.width/scale, thisSize.height/scale);
    return newSize;
}

// 等比缩放返回新的CGSize (按宽度)
+ (CGSize)fitsize:(CGSize)thisSize width:(CGFloat)width
{
    if (thisSize.width == 0.f && thisSize.height == 0.f)
        return CGSizeMake(0.f, 0.f);
    CGFloat wscale = thisSize.width / width;
    CGSize newSize = CGSizeMake(thisSize.width/wscale, thisSize.height/wscale);
    return newSize;
}

// 等比缩放返回新的CGSize (按高度)
+ (CGSize)fitsize:(CGSize)thisSize height:(CGFloat)height
{
    if (thisSize.width == 0.f && thisSize.height == 0.f)
        return CGSizeMake(0.f, 0.f);
    CGFloat hscale = thisSize.height / height;
    CGSize newSize = CGSizeMake(thisSize.width/hscale, thisSize.height/hscale);
    return newSize;
}

// UIScrollView截图
- (UIImage *)captureScrollView:(UIScrollView *)scrollView
{
    UIImage* image = nil;
    UIGraphicsBeginImageContext(scrollView.contentSize);
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    
    if (image != nil) {
        return image;
    }
    return nil;
}

@end
