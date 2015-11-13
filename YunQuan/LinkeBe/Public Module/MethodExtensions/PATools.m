//
//  PATools.m
//  PABank
//
//  Created by ZQM on 11-3-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PATools.h"
#import "AppDelegate.h"
#import "NSMutableDictionary_extra.h"

@implementation PATools

#pragma mark -
#pragma mark ============================
AppDelegate *_appDelegate;
/**
 * 功能：获得app的window
 * 返回：window
 */
+(UIWindow *)getAppWindowView{
	
	if (_appDelegate == nil) {
		_appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	}
	return _appDelegate.window;
}

#pragma mark -
#pragma mark ============================
/**
 * 功能：判断字符串是否为null
 * 参数：
 *		NSString     string     要判断的字符串
 * 返回：字符串
 */
+(NSString *)formatNullString:(NSString *)string{
	NSString *_string = TRIMSTRING(string);
	if ([_string isEqualToString:@"null"] || [_string isEqualToString:@"NULL"]) {
		return @"";
	}else {
		return _string;
	}	
}
/*
 *功能:email验证 支援格式 xxx.xxx@xxx.xxx.xxx
 *错误联系　徐岽茗
 */
+(BOOL) emailCheck:(NSString*) str
{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	if ([str rangeOfString:@".@"].length>0||[str rangeOfString:@"@."].length>0) 
	{
		return FALSE;
	}
	if (![str rangeOfString:@"@"].length>0) 
	{
		return FALSE;
	}else
	{
		NSString *headStr=[str substringToIndex:[str rangeOfString:@"@"].location];
		NSString *endStr=[str substringFromIndex:[str rangeOfString:@"@"].location];
		
		if ([headStr length]==0) 
		{
			return FALSE;
		}
		if ([headStr characterAtIndex:0]=='.') 
		{
			return FALSE;
		}
		if ([endStr length]==0) {
			return FALSE;
		}
		if ([endStr rangeOfString:@"."].length==0) 
		{
			return FALSE;
		}
		if ([endStr characterAtIndex:[endStr length]-1]=='.') 
		{
			return FALSE;
		}
	}
	[pool release];
	return TRUE;
}
/*
 把dictionary转换成数组，用于转换公共模块解析后的list类型
 dic值为[superDic getObjectByKey:@"Data/responseBody/eventList"]
 */
+ (NSMutableArray*)getArrayByData:(NSDictionary*)dic {
	if (![dic isKindOfClass:NSClassFromString(@"NSDictionary")] || ![dic isKindOfClass:NSClassFromString(@"NSMutableDictionary")]) {
		return [NSMutableArray array];
	}
	
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSArray *keys = [dic allSortedKeys];
	for (int i=0; i<[keys count]; i++) {
		NSString *key = [keys objectAtIndex:i];
		[array addObject:[dic objectForKey:key]];
	}
	return [array autorelease];
}

//判断文件是否存在于Documents文件夹
+ (BOOL)isFileExistInDocumentsDir:(NSString*)fileName{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);        
	NSString *documentsDirectory = [paths objectAtIndex:0];  
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
	return  [[NSFileManager defaultManager] fileExistsAtPath:filePath]; 
}

//将NSData写入NSDocument中指定的文件名中
+ (BOOL)writeNSData:(NSData *)data ToFileName:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);        
	NSString *documentsDirectory = [paths objectAtIndex:0];        
	
	//如果應用程式中的Documents目錄不存在
	if (!documentsDirectory) {                
		return NO;                
	}
	
	NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];        
	return ([data writeToFile:appFile atomically:YES]);        
}


//從指定的暫存檔案讀取資料
+ (NSData*)readNSDataFromFile:(NSString *)fileName
{        
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);        
	NSString *documentsDirectory = [paths objectAtIndex:0];        
	NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];        
	NSData *myData = [[[NSData alloc] initWithContentsOfFile:appFile] autorelease];        
	return myData;
}

//删除document目录下指定的fileName文件
+ (BOOL)deleteFile:(NSString *)fileName{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName]; 
	//删除你的文件 
	return [fileManager removeItemAtPath:filePath error:nil];
}

//从document目录读取提定fileName的文件的十进制字符串用于上传
+ (NSString*)readStringContentOfFile:(NSString*)fileName{
	NSMutableString *content = [NSMutableString string];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName]; 
	const char *c = [filePath cStringUsingEncoding:NSMacOSRomanStringEncoding];
	int ch;
	FILE* fp;
	fp=fopen(c,"r"); //只供读取
	if(fp==NULL) //如果失败了
	{
		printf("错误！");
        fclose(fp); //关闭文件
        return @"";
	}
	while((ch=getc(fp))!=EOF)
	{
		[content appendString:[NSString stringWithFormat:@"%d,",ch]];
	}
	fclose(fp); //关闭文件 
	return [content substringToIndex:[content length]-1];
}


+(void)setShowUserDefaultData:(NSString *)key flag:(NSInteger)flag
{
	//写入配置集
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:flag forKey:key];
	[defaults synchronize];
}

//	open url from string (current app will exit)打开外部连接,当前程序会退出
+(void)goUrl:(NSString*)url{
	NSString* _s = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:_s]];
}

//把科学计数法表示的数字转换为正常数字
+(NSString *)confvertEnumberTodoubleString:(NSString *)value
{
    if (nil == value || NULL == value) {
        return @"";
    }
    
    NSString *value2 = @"";    
	if ([value rangeOfString:@"E"].length > 0 ||
        [value rangeOfString:@"e"].length > 0)
    {
        if ([value rangeOfString:@"E"].location != NSNotFound)
        {
            value2 = [PATools confvertEnumberTodoubleString:value Letter:@"E"];
        }
        else if ([value rangeOfString:@"e"].location != NSNotFound)
        {
            value2 = [PATools confvertEnumberTodoubleString:value Letter:@"e"];
        }
        return value2;
    }
    else{
        return value;
    }
}

/**
 * 把科学计数法表示的数字转换为正常数字
 * 参数
 * value : 待转换的科学计数法数值
 * letter: E 或者 e 字母
 */
+(NSString *)confvertEnumberTodoubleString:(NSString *)value Letter:(NSString *)letter
{
    if (nil == value || NULL ==value) {
        return @"";
    }
	if (![value rangeOfString:letter].length>0)
	{
		return value;
	}
	NSString *leftStr=[value substringToIndex:[value rangeOfString:letter].location];
	NSString *rightStr=[value substringFromIndex:[value rangeOfString:letter].location+1];
	double v1 = [leftStr doubleValue];
	int v2 = [rightStr intValue];
	double v3 = 1;
    
    if (v2 >= 0)
    {
        for (int i=0; i<v2; i++) {
            v3 *=10;
        }
    }
    else
    {
        v2 = -1 * v2;
        for (int i=0; i<v2; i++) {
            v3 /=10;
        }
    }
    
	NSLog(@"%@",[NSString stringWithFormat:@"=========number==========%.2f", v1 * v3]);
	return [NSString stringWithFormat:@"%.2f", v1 * v3];
}

@end
