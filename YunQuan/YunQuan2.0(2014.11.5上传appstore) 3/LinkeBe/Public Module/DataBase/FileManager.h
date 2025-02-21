//
//  FileManager.h
//  anyVideo
//
//  Created by  apple on 10-10-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileManager : NSObject {
	
}
+ (BOOL) writeFileString:(NSString *)string fileName:(NSString *)filename;
+ (BOOL) isExistsFile:(NSString *) filepath;
+ (void) createFile:(NSString *) filename;
+ (void) writeFileData:(NSString *)filename writeData:(NSString *)data;
+ (void) removeFileDB:(NSString *)filename;
+ (void) removeFile:(NSString *)filename;
+ (UIImage *) saveImageFromURL:(NSString *)strUrl imageName:(NSString*)aName;
+ (UIImage *)getImageFromInfo:(NSString *)imageInfo;//add by zhanghao

+ (NSString *)getFileDBPath:(NSString *)filename;
+ (NSString *)getFilePath:(NSString *)filename;
+ (NSString *) readResFileData:(NSString *)filename;
+ (NSString *) readLocalFileData:(NSString *)filename;

//获取用户数据库文件路径
+ (NSString *)getUserDBPath;

+(bool)savePhoto:(NSString*)photoName withImage:(UIImage*)image;
+(UIImage*)getPhoto:(NSString*)photoName;

@end
