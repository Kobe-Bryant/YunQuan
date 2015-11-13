//
//  upLoadPicManager.m
//  ql
//
//  Created by yunlai on 14-7-19.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "upLoadPicManager.h"
#import "Common.h"
#import "SBJson.h"
#import "Global.h"

#import "LoginSendClientMessage.h"

@implementation upLoadPicManager

+(NSDictionary*) upLoadPicWithRequestDic:(NSMutableDictionary *)dic
                       dataList:(NSArray *)dataList
                     requestUrl:(NSString *)requestUrl
{
    NSString *reqstr = [Common TransformJson:dic withLinkStr:[HTTPURLPREFIX stringByAppendingString:requestUrl]];
    
    ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:reqstr]];
    request.requestMethod = @"POST";
    
    if (dataList.count) {
        [request setPostFormat:ASIMultipartFormDataPostFormat];
        for (NSData *data in dataList)
        {
            NSInteger index = [dataList indexOfObject:data];
            [request addData:data withFileName:[NSString stringWithFormat:@"iOSPicture%d.jpg",index] andContentType:@"image/jpeg" forKey:@"photos"];
        }
    }
    [request startSynchronous];
    
    NSString* responseStr = [request responseString];
    
    [request release];
    
    if (responseStr == nil) {
        return nil;
    }
    
    return [responseStr JSONValue];
    
}

+(NSDictionary *) upLoadPicWithPara:(NSMutableDictionary *)param
                      dataList:(NSArray *)dataList
                    requestUrl:(NSString *)requestUrl{
    
    NSString *reqstr = [Common TransformJson:param withLinkStr:[HTTPURLPREFIX stringByAppendingString:requestUrl]];
    
    NSLog(@"--reqstr:%@--",reqstr);
    
    NSString *TWITTERFON_FORM_BOUNDARY = @"0xKhTmLbOuNdArY";
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqstr]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:30];
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@\r\n",TWITTERFON_FORM_BOUNDARY];
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"\r\n--%@\r\n",MPboundary];
    
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    
    ////添加分界线，换行
    [myRequestData appendData:[MPboundary dataUsingEncoding:NSUTF8StringEncoding]];
    
    int i = 0;
    for (NSData* data in dataList) {
        ////添加分界线，换行
        [myRequestData appendData:[MPboundary dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableString* picBody = [[NSMutableString alloc] init];
        //声明pic字段
        NSInteger index = [dataList indexOfObject:data];
        [picBody appendFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%d.jpg\"\r\n",index];
        //声明上传文件的格式
        [picBody appendFormat:@"Content-Type: image/jpeg\r\n\r\n"];
        
        //将body字符串转化为UTF8格式的二进制
        [myRequestData appendData:[picBody dataUsingEncoding:NSUTF8StringEncoding]];
        
        //将image的data加入
        [myRequestData appendData:data];
        [picBody release];
        
        i++;
        if (i != [dataList count]) {
            [myRequestData appendData:[endMPboundary dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    //加入结束符--AaB03x--
    NSString* end = [NSString stringWithFormat:@"\r\n--%@--\r\n",TWITTERFON_FORM_BOUNDARY];
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%d", [myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    NSHTTPURLResponse *urlResponese = nil;
    NSError *error = [[NSError alloc]init];
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request   returningResponse:&urlResponese error:&error];
    NSString* result= [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    if([urlResponese statusCode] >=200&&[urlResponese statusCode]<300){
        NSLog(@"返回结果=====%@",result);
        return [result JSONValue];
    }
    return nil;
}

+(NSDictionary*) NewUpLoadPicWithPara:(NSMutableDictionary *)param dataList:(NSArray *)dataList requestUrl:(NSString *)requestUrl{
    
    NSString* reqstr = [NSString stringWithFormat:@"%@%@",@"http://192.168.1.195:8080/appapi",DYNAMIC_PUBLISH_URL];
    
    NSLog(@"--reqstr:%@--",reqstr);
    
    NSString *TWITTERFON_FORM_BOUNDARY = @"0xKhTmLbOuNdArY";
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqstr]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:30];
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@\r\n",TWITTERFON_FORM_BOUNDARY];
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"\r\n--%@\r\n",MPboundary];
    
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    
    ////添加分界线，换行
    [myRequestData appendData:[MPboundary dataUsingEncoding:NSUTF8StringEncoding]];
    
    //参数
    NSArray* keys = [param allKeys];
    int j = 0;
    for (NSString* key in keys) {
        ////添加分界线，换行
        [myRequestData appendData:[MPboundary dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableString* paraBody = [[NSMutableString alloc] init];
        
        //添加字段名称，换2行
        [paraBody appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        //添加字段的值
        [paraBody appendFormat:@"%@\r\n",[param objectForKey:key]];
        
        [myRequestData appendData:[paraBody dataUsingEncoding:NSUTF8StringEncoding]];
        
        [paraBody release];
        
        j++;
        if (j == keys.count) {
            [myRequestData appendData:[endMPboundary dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    int i = 0;
    for (NSData* data in dataList) {
        ////添加分界线，换行
        [myRequestData appendData:[MPboundary dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableString* picBody = [[NSMutableString alloc] init];
        //声明pic字段
        NSInteger index = [dataList indexOfObject:data];
        [picBody appendFormat:@"Content-Disposition: form-data; name=\"files[%d]\"; filename=\"%d.jpg\"\r\n",index,index];
        //声明上传文件的格式
        [picBody appendFormat:@"Content-Type: image/jpeg\r\n\r\n"];
        
        //将body字符串转化为UTF8格式的二进制
        [myRequestData appendData:[picBody dataUsingEncoding:NSUTF8StringEncoding]];
        
        //将image的data加入
        [myRequestData appendData:data];
        [picBody release];
        
        i++;
        if (i != [dataList count]) {
            [myRequestData appendData:[endMPboundary dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    //加入结束符--AaB03x--
    NSString* end = [NSString stringWithFormat:@"\r\n--%@--\r\n",TWITTERFON_FORM_BOUNDARY];
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%d", [myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    
    //认证
    LoginSendClientMessage *loginSendClient = [[LoginSendClientMessage alloc] init];
    NSString *authString = [loginSendClient authorizationReturn];
    
    [request setValue:authString forHTTPHeaderField:@"Authorization"];
    
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    NSLog(@"----httpHeader:%@\nboody:%d---",request.allHTTPHeaderFields,myRequestData.length);
    
    NSHTTPURLResponse *urlResponese = nil;
    NSError *error = [[NSError alloc]init];
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request   returningResponse:&urlResponese error:&error];
    NSString* result= [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    if([urlResponese statusCode] >=200&&[urlResponese statusCode]<300){
        NSLog(@"返回结果=====%@",result);
        return [result JSONValue];
    }
    return nil;
}

@end
