//
// QR Code Generator - generates UIImage from NSString
//
// Copyright (C) 2012 http://moqod.com Andrew Kopanev <andrew@moqod.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
// of the Software, and to permit persons to whom the Software is furnished to do so, 
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all 
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.
//

#import "myQRCodeGenerator.h"
#import "qrencode.h"

enum {
	qr_margin = 1
};

@implementation myQRCodeGenerator

//普通二维码
+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size {
	if (![string length]) {
		return nil;
	}
	
	QRcode *code = QRcode_encodeString([string UTF8String], 0, QR_ECLEVEL_L, QR_MODE_8, 1);
	if (!code) {
		return nil;
	}
	
	// create context
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(0, size, size, 8, size * 4, colorSpace, kCGImageAlphaPremultipliedLast);
	
	CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -size);
	CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1, -1);
	CGContextConcatCTM(ctx, CGAffineTransformConcat(translateTransform, scaleTransform));
	
	// draw QR on this context	
	[myQRCodeGenerator drawQRCode:code context:ctx size:size];
	
	// get image
	CGImageRef qrCGImage = CGBitmapContextCreateImage(ctx);
	UIImage * qrImage = [UIImage imageWithCGImage:qrCGImage];
	
	// some releases
	CGContextRelease(ctx);
	CGImageRelease(qrCGImage);
	CGColorSpaceRelease(colorSpace);
	QRcode_free(code);
	
	return qrImage;
}

//彩色二维码 支持中间添加图片
+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size withImage:(UIImage *)image withColor:(UIColor *)color
{
    if (![string length]) {
		return nil;
	}
	
	QRcode *code = QRcode_encodeString([string UTF8String], 0, QR_ECLEVEL_L, QR_MODE_8, 1);
	if (!code) {
		return nil;
	}
    
    //翻转图片
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGRect bounds = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeTranslation(0.0, height);
    transform = CGAffineTransformScale(transform, 1.0, -1.0);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0, -height);
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *rotateImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
	
	// create context
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(0, size, size, 8, size * 4, colorSpace, kCGImageAlphaPremultipliedLast);
	
	CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -size);
	CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1, -1);
	CGContextConcatCTM(ctx, CGAffineTransformConcat(translateTransform, scaleTransform));
	
	// draw QR on this context
	[myQRCodeGenerator drawQRCode:code context:ctx size:size withImage:rotateImage withColor:color];
	
	// get image
	CGImageRef qrCGImage = CGBitmapContextCreateImage(ctx);
	UIImage * qrImage = [UIImage imageWithCGImage:qrCGImage];
	
	// some releases
	CGContextRelease(ctx);
	CGImageRelease(qrCGImage);
	CGColorSpaceRelease(colorSpace);
	QRcode_free(code);
	
	return qrImage;
}

//图形 透明二维码
+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size withPositionType:(QRPositionType)positionType;
{
    if (![string length]) {
		return nil;
	}
	
	QRcode *code = QRcode_encodeString([string UTF8String], 0, QR_ECLEVEL_L, QR_MODE_8, 1);
	if (!code) {
		return nil;
	}
	
	// create context
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(0, size, size, 8, size * 4, colorSpace, kCGImageAlphaPremultipliedLast);
	
	CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -size);
	CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1, -1);
	CGContextConcatCTM(ctx, CGAffineTransformConcat(translateTransform, scaleTransform));
	
	// draw QR on this context
	[myQRCodeGenerator drawQRCode:code context:ctx size:size withPositionType:positionType];
	
	// get image
	CGImageRef qrCGImage = CGBitmapContextCreateImage(ctx);
	UIImage * qrImage = [UIImage imageWithCGImage:qrCGImage];
	
	// some releases
	CGContextRelease(ctx);
	CGImageRelease(qrCGImage);
	CGColorSpaceRelease(colorSpace);
	QRcode_free(code);
	
	return qrImage;
}



//普通二维码 绘图函数
+ (void)drawQRCode:(QRcode *)code context:(CGContextRef)ctx size:(CGFloat)size {
	unsigned char *data = 0;
	int width;
	data = code->data;
	width = code->width;
	float zoom = (double)size / (code->width + 2.0 * qr_margin);
	CGRect rectDraw = CGRectMake(0, 0, zoom, zoom);
	
	// draw
	CGContextSetFillColor(ctx, CGColorGetComponents([UIColor blackColor].CGColor));
	for(int i = 0; i < width; ++i) {
		for(int j = 0; j < width; ++j) {
			if(*data & 1) {
				rectDraw.origin = CGPointMake((j + qr_margin) * zoom,(i + qr_margin) * zoom);
				CGContextAddRect(ctx, rectDraw);
			}
			++data;
		}
	}
	CGContextFillPath(ctx);
}

//彩色二维码 绘图函数
+ (void)drawQRCode:(QRcode *)code context:(CGContextRef)ctx size:(CGFloat)size withImage:(UIImage *)image withColor:(UIColor *)color
{
	unsigned char *data = 0;
	int width;
	data = code->data;
	width = code->width;
	float zoom = (double)size / (code->width + 2.0 * qr_margin);
	CGRect rectDraw = CGRectMake(0, 0, zoom, zoom);
	
	// draw
	//CGContextSetFillColor(ctx, CGColorGetComponents([UIColor orangeColor].CGColor));
    
    const CGFloat *components;
    if (color == nil)
    {
        CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 0.0f, 1.0);
    }
    else
    {
        components = CGColorGetComponents(color.CGColor);
        CGContextSetRGBFillColor(ctx, components[0], components[1], components[2], components[3]);
    }
    
    
	for(int i = 0; i < width; ++i) {
		for(int j = 0; j < width; ++j) {
			if(*data & 1) {
				rectDraw.origin = CGPointMake((j + qr_margin) * zoom,(i + qr_margin) * zoom);
				CGContextAddRect(ctx, rectDraw);
			}
			++data;
		}
	}
	CGContextFillPath(ctx);
    
    //中间图片
    CGFloat fixSize = size / 5;
    if (image != nil)
    {
        CGContextSetAlpha(ctx, 1.0);
        CGContextDrawImage(ctx, CGRectMake((size - fixSize)/2 , (size - fixSize)/2 , fixSize , fixSize), image.CGImage);
        CGContextFillPath(ctx);
    }
}

//图形 透明二维码 绘图函数
+ (void)drawQRCode:(QRcode *)code context:(CGContextRef)ctx size:(CGFloat)size withPositionType:(QRPositionType)positionType
{    
    unsigned char *data = 0;
	int width;
	data = code->data;
	width = code->width;
	int zoom = (double)size / (code->width + 2.0 * qr_margin);
	CGRect rectDraw = CGRectMake(0, 0, zoom, zoom);
    
    int fixWidth = (size - (zoom * code->width)) / 2;
    int fixHeight = fixWidth;
	
	for(int i = 0; i < width; ++i)
    {
		for(int j = 0; j < width; ++j)
        {
			if(*data & 1)
            {
                if ((i<8 && j<8) || (i>width-9 && j<8) || (i<8 && j>width-9) || ((width > 21) && ((i>width-10 && i<width-4) && (j>width-10 && j<width-4))))
                {
                    //四个定位方块 黑色的点
                    if (positionType == QRPositionNormal)
                    {
                        CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 0.0f, 0.6);
                        rectDraw.origin = CGPointMake((j * zoom) + fixWidth ,(i * zoom) + fixHeight);
                        CGContextAddRect(ctx, rectDraw);
                        CGContextFillPath(ctx);
                    }
                }
                else
                {
                    //黑色点背景
                    CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 0.0f, 0.1);
                    rectDraw.origin = CGPointMake((j * zoom) + fixWidth ,(i * zoom) + fixHeight);
                    CGContextAddRect(ctx, rectDraw);
                    CGContextFillPath(ctx);
                    
                    //黑色点
                    CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 0.0f, 0.6);
                    CGRect rectDraw1 = CGRectMake(rectDraw.origin.x + rectDraw.size.width / 3, rectDraw.origin.y + rectDraw.size.height / 3, rectDraw.size.width / 3, rectDraw.size.height / 3);
                    CGContextAddRect(ctx, rectDraw1);
                    CGContextFillPath(ctx);
                }
			}
            else
            {
                //下面条件 ====>  定位旁边 不使用白点
                //if ((i<8 && j<8) || (i>width-9 && j<8) || (i<8 && j>width-9) || ((width > 21) && ((i>width-10 && i<width-4) && (j>width-10 && j<width-4))))
                    
                if ((i<7 && j<7) || (i>width-8 && j<7) || (i<7 && j>width-8) || ((width > 21) && ((i>width-10 && i<width-4) && (j>width-10 && j<width-4))))
                {
                    //四个定位方块 白色的点
                    if (positionType == QRPositionNormal)
                    {
                        CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 0.6);
                        rectDraw.origin = CGPointMake((j * zoom) + fixWidth ,(i * zoom) + fixHeight);
                        CGContextAddRect(ctx, rectDraw);
                        CGContextFillPath(ctx);
                    }
                }
                else
                {
                    //白色点背景
                    CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 0.05);
                    rectDraw.origin = CGPointMake((j * zoom) + fixWidth ,(i * zoom) + fixHeight);
                    CGContextAddRect(ctx, rectDraw);
                    CGContextFillPath(ctx);
                    
                    //白色点
                    CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 0.6);
                    CGRect rectDraw1 = CGRectMake(rectDraw.origin.x + (rectDraw.size.width / 9)*2, rectDraw.origin.y + (rectDraw.size.height / 9)*2, (rectDraw.size.width / 9)*5, (rectDraw.size.height / 9)*5);
                    CGContextAddRect(ctx, rectDraw1);
                    CGContextFillPath(ctx);
                }
            }
			++data;
		}
	}
    
    //自定四个定位角
    if (positionType != QRPositionNormal)
    {
        int fixZoom = zoom*7;
        int fixSZoom = zoom*5;
        
        NSString *positionImageName = nil;
        
        if (positionType == QRPositionRound)
        {
            positionImageName = @"QRPositionRound";
        }
        else if(positionType == QRPositionCenterRound)
        {
            positionImageName = @"QRPositionCenterRound";
        }
        else if(positionType == QRPositionHalfRound)
        {
            positionImageName = @"QRPositionHalfRound";
        }
        
        UIImage *image1 = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:positionImageName ofType:@"png"]];
        CGContextSetAlpha(ctx, 0.6);
        CGContextDrawImage(ctx, CGRectMake(fixWidth, fixHeight, fixZoom , fixZoom), image1.CGImage);
        CGContextFillPath(ctx);
        [image1 release];
        
        UIImage *image2 = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:positionImageName ofType:@"png"]];
        CGContextSetAlpha(ctx, 0.6);
        CGContextDrawImage(ctx, CGRectMake((width - 7)*zoom + fixWidth, fixWidth, fixZoom, fixZoom), image2.CGImage);
        CGContextFillPath(ctx);
        [image2 release];
        
        UIImage *image3 = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:positionImageName ofType:@"png"]];
        CGContextSetAlpha(ctx, 0.6);
        CGContextDrawImage(ctx, CGRectMake(fixWidth, (width - 7)*zoom + fixWidth, fixZoom, fixZoom), image3.CGImage);
        CGContextFillPath(ctx);
        [image3 release];
        
        UIImage *image4 = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"QRPositionS" ofType:@"png"]];
        CGContextSetAlpha(ctx, 0.6);
        CGContextDrawImage(ctx, CGRectMake((width - 9)*zoom + fixWidth, (width - 9)*zoom + fixWidth, fixSZoom, fixSZoom), image4.CGImage);
        CGContextFillPath(ctx);
        [image4 release];
    }
    
}



#pragma mark - custom method

@end
