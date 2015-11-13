//
//  PATools.h
//  PABank
//
//  Created by ZQM on 11-3-15.
//  Copyright 2011 郭伟坤. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 功能：去掉字符串中的空格换行
 * 参数：
 *       str    要trim的字符串
 */
#define TRIMSTRING(str)	[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
/**
 * 功能：通过rgb获得颜色
 * 参数：
 *      r	红
 *		g	绿
 *		b	蓝
 *		a	透明度
 */
#define GETCOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

/**
 * 功能：拉伸图片
 * 参数：
 *        NSString     imageName		图片 名称.类型
 *        int          w                宽从什么地方开始拉
 *        int          h				高从什么地方开始拉
 * 返回：拉伸后的图片
 */
#define STRETCHIMAGE(imageName,w,h) [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:w topCapHeight:h]

@interface PATools : NSObject {

}

/**
 * 功能：获得app的window
 * 返回：window
 */
+(UIWindow *)getAppWindowView;
/**
 * 功能：判断字符串是否为null
 * 参数：
 *		NSString     string     要判断的字符串
 * 返回：字符串
 */
+(NSString *)formatNullString:(NSString *)string;
/*
 *功能:email验证 支援格式 xxx.xxx@xxx.xxx.xxx
 *错误联系　徐岽茗
 */
+(BOOL) emailCheck:(NSString*) str;

/*
把字典转换成数组
 */
+ (NSMutableArray*)getArrayByData:(NSDictionary*)dic;

//删除document目录下指定的fileName文件
+ (NSData*)readNSDataFromFile:(NSString *)fileName;
+ (BOOL)deleteFile:(NSString *)fileName;

//从document目录读取提定fileName的文件的十进制字符串用于上传
+ (NSString*)readStringContentOfFile:(NSString*)fileName;

//判断文件是否存在于Documents文件夹
+ (BOOL)isFileExistInDocumentsDir:(NSString*)fileName;
+ (BOOL)writeNSData:(NSData *)data ToFileName:(NSString *)fileName;


+(void)setShowUserDefaultData:(NSString *)key flag:(NSInteger)flag;

//	open url from string (current app will exit)打开外部连接,当前程序会退出
+(void)goUrl:(NSString*)url;

//把科学计数法表示的数字转换为正常数字
+(NSString *)confvertEnumberTodoubleString:(NSString *)value;
+(NSString *)confvertEnumberTodoubleString:(NSString *)value Letter:(NSString *)letter;
@end
