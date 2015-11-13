//
//  CustomEmotionData.m
//  ql
//
//  Created by LazySnail on 14-8-20.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import "CustomEmotionData.h"

#import "UIImage+GIF.h"

#define CustomEmoticonTitle         @"title"
#define CustomEmoticonID            @"eid"
#define CustomEmoticonPackgePath    @"path"
#define CustomEmoticonThumbnail     @"tburl"
#define CustomEmoticonUrl           @"emourl"

@implementation CustomEmotionData

@synthesize objtype = m_objtype;
@synthesize emotionUrl = m_emotionUrl;

- (instancetype)init
{
    if (self = [super init]) {
        m_objtype = DataMessageTypeCustomEmotion;
        m_emotionUrl = @"";
    }
    return self;
}

- (instancetype)initWithDic:(NSDictionary *)dic
{
    
    self = [super initWithDic:dic];
    m_objtype = DataMessageTypeCustomEmotion;
    
    self.title = [self.dataDic objectForKey:CustomEmoticonTitle];
    self.filePath = [self.dataDic objectForKey:CustomEmoticonPackgePath];
    self.thumbUrl = [self.dataDic objectForKey:CustomEmoticonThumbnail];
    self.emotionUrl = [self.dataDic objectForKey:CustomEmoticonUrl];
    self.emoticonItemID = [[self.dataDic objectForKey:CustomEmoticonID]intValue];
    
    return self;
}



- (NSDictionary *)getDic
{
    NSDictionary * dataDic = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:self.emoticonItemID],CustomEmoticonID,
                              self.filePath,CustomEmoticonPackgePath,
                              self.thumbUrl,CustomEmoticonThumbnail,
                              self.emotionUrl,CustomEmoticonUrl,
                              self.title,CustomEmoticonTitle,
                              nil];
    self.dataDic = dataDic;
    
    return [self genterateComplateDic];
}

-(void) getGifImg{
    NSString* documentPAth = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* path = [documentPAth stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d.gif",self.filePath,self.emoticonItemID]];
    
    BOOL existPath = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    if (!existPath) {
        [self downTheEmotionImg];
    }else{
        NSData* data = [NSData dataWithContentsOfFile:path];
        UIImage *image = [UIImage sd_animatedGIFWithData:data];
        if (_delegate && [_delegate respondsToSelector:@selector(getGifUIImageSuccessWithUIImage:)]) {
            [_delegate getGifUIImageSuccessWithUIImage:image];
        }
    }
}

-(void) getThumbImg{
    NSString* documentPAth = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* path = [documentPAth stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d.png",self.filePath,self.emoticonItemID]];
    
    BOOL existPath = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    if (!existPath) {
        path = [documentPAth stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d.jpg",self.filePath,self.emoticonItemID]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSData* data = [NSData dataWithContentsOfFile:path];
            UIImage* image = [UIImage sd_animatedGIFWithData:data];
            if (_delegate && [_delegate respondsToSelector:@selector(getGifUIImageSuccessWithUIImage:)]) {
                [_delegate getGifUIImageSuccessWithUIImage:image];
            }
        }else{
            [self downTheThumbImg];
        }
        
    }else{
        NSData* data = [NSData dataWithContentsOfFile:path];
        UIImage* image = [UIImage sd_animatedGIFWithData:data];
        if (_delegate && [_delegate respondsToSelector:@selector(getGifUIImageSuccessWithUIImage:)]) {
            [_delegate getGifUIImageSuccessWithUIImage:image];
        }
    }
}

//图片下载
-(void) downTheThumbImg{
    //文件夹目录,不会自动创建目录
    NSString* dirPath = [self getEmotionPath:[NSString stringWithFormat:@"%@",self.filePath]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:self.thumbUrl]];
    request.delegate = self;
    request.downloadDestinationPath = [self getEmotionPath:[NSString stringWithFormat:@"%@/%d.png",self.filePath,self.emoticonItemID]];
    request.didFinishSelector = @selector(requestFinishedThumb:);
    request.didFailSelector = @selector(requestFailedThumb:);
    [request startAsynchronous];
    RELEASE_SAFE(request);
}

-(void) downTheEmotionImg{
    //文件夹目录,不会自动创建目录
    NSString* dirPath = [self getEmotionPath:[NSString stringWithFormat:@"%@",self.filePath]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:self.emotionUrl]];
    request.delegate = self;
    request.downloadDestinationPath = [self getEmotionPath:[NSString stringWithFormat:@"%@/%d.gif",self.filePath,self.emoticonItemID]];
    request.didFinishSelector = @selector(requestFinishedGIF:);
    request.didFailSelector = @selector(requestFailedGIF:);
    [request startAsynchronous];
    RELEASE_SAFE(request);
}

//获取路径
-(NSString*) getEmotionPath:(NSString*) emoticonPath{
    NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentPath stringByAppendingPathComponent:emoticonPath];
}

#pragma mark - asihttp
-(void) requestFinishedThumb:(ASIHTTPRequest *)request{
    NSString* path = [self getEmotionPath:[NSString stringWithFormat:@"%@/%d.png",self.filePath,self.emoticonItemID]];
    
    NSData* data = [NSData dataWithContentsOfFile:path];
    UIImage* image = [UIImage imageWithData:data];
    [_delegate getThumbUIImageSuccessWithUIImage:image];
}

-(void) requestFailedThumb:(ASIHTTPRequest*) request{
    NSLog(@"png failed:%@",request.responseString);
}

-(void) requestFinishedGIF:(ASIHTTPRequest *)request{
    NSData* data = [NSData dataWithContentsOfFile:[self getEmotionPath:[NSString stringWithFormat:@"%@/%d.gif",self.filePath,self.emoticonItemID]]];
    UIImage* image = [UIImage sd_animatedGIFWithData:data];
    [_delegate getGifUIImageSuccessWithUIImage:image];
}

-(void) requestFailedGIF:(ASIHTTPRequest*) request{
    NSLog(@"gif failed");
}

- (NSString *)dataListDescreption
{
    return [NSString stringWithFormat:@"[表情]"];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    CustomEmotionData * copyObj = [[CustomEmotionData alloc]init];
    copyObj.title = [[self.title copy] autorelease];
    copyObj.emoticonItemID = self.emoticonItemID;
    copyObj.filePath = [[self.filePath copy] autorelease];
    copyObj.thumbUrl = [[self.thumbUrl copy] autorelease];
    copyObj.emotionUrl = [[self.emotionUrl copy] autorelease];
    return copyObj;
}

- (void)dealloc
{
    LOG_RELESE_SELF;
    self.title = nil;
    self.filePath = nil;
    self.thumbUrl = nil;
    self.emotionUrl = nil;
    [super dealloc];
}

@end
