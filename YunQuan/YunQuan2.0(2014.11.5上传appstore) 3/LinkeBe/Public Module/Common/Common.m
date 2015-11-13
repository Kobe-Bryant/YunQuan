//
//  Common.m
//  Profession
//
//  Created by MC374 on 12-8-7.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Common.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "SBJson.h"
#import "base64.h"
#import "Encry.h"
#import <CommonCrypto/CommonCryptor.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>  
#include <net/if.h>
#include <net/if_dl.h>
#include <netdb.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <Security/Security.h>
#import "NSString+DES.h"
#import <CoreLocation/CLLocationManager.h>
#import "Global.h"
#import "SvUDIDTools.h"
#import "ChatMacro.h"

@implementation Common

+ (BOOL)connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags");
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	
    return (isReachable && !needsConnection) ? YES : NO;
}

+ (NSString*)TransformJson:(NSMutableDictionary*)sourceDic withLinkStr:(NSString*)strurl
{
	SBJsonWriter *writer = [[SBJsonWriter alloc]init];
	NSString *jsonConvertedObj = [writer stringWithObject:sourceDic];
	NSLog(@"jsonConvertedObj:%@",jsonConvertedObj);
    [writer release];
//	NSString *b64 = [Common encodeBase64:(NSMutableData *)[jsonConvertedObj dataUsingEncoding: NSUTF8StringEncoding]];
	
    //des加密
    NSString *urlEncode = [NSString encryptUseDES:jsonConvertedObj key:SignSecureKey];
    
    NSString *urlEncodes = [Common URLEncodedString:urlEncode];
    
	NSString *reqStr = [NSString stringWithFormat:@"%@%@",strurl,urlEncodes];
	
//    NSLog(@"req_string:%@",reqStr);
    
	return reqStr;
}

+ (NSString*)encodeBase64:(NSMutableData*)data
{
	size_t outputDataSize = EstimateBas64EncodedDataSize([data length]);
	Byte outputData[outputDataSize];
	Base64EncodeData([data bytes], [data length], (char *)outputData,&outputDataSize, YES);
	NSData *theData = [[NSData alloc]initWithBytes:outputData length:outputDataSize];//create a NSData object from the decoded data
	NSString *stringValue1 = [[NSString alloc]initWithData:theData encoding:NSUTF8StringEncoding];
	//NSLog(@"reqdata string base64 %@",stringValue1);
	[theData release];
	return [stringValue1 autorelease];
}

+ (NSString*)encryptPutString:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+ (NSString*)URLEncodedString:(NSString*)input
{  
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,  
                                                                           (CFStringRef)input,  
                                                                           NULL,  
                                                                           CFSTR("!*'();:@&=+$,/?%#[]"),  
                                                                           kCFStringEncodingUTF8);  
    [result autorelease];  
    return result;  
}

+ (NSString*)URLDecodedString:(NSString*)input  
{  
    NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,  
                                                                                           (CFStringRef)input,  
                                                                                           CFSTR(""),  
                                                                                           kCFStringEncodingUTF8);  
    [result autorelease];  
    return result;    
}  

+ (double)lantitudeLongitudeToDist:(double)lon1 Latitude1:(double)lat1 long2:(double)lon2 Latitude2:(double)lat2
{
	double er = 6378137; // 6378700.0f;

	double radlat1 = PI*lat1 / 180.0f;
	double radlat2 = PI*lat2 / 180.0f;

	double radlong1 = PI*lon1 / 180.0f;
	double radlong2 = PI*lon2 / 180.0f;
    
	if( radlat1 < 0 ) radlat1 = PI/2 + fabs(radlat1);// south
    
	if( radlat1 > 0 ) radlat1 = PI/2 - fabs(radlat1);// north
    
	if( radlong1 < 0 ) radlong1 = PI*2 - fabs(radlong1);//west
    
	if( radlat2 < 0 ) radlat2 = PI/2 + fabs(radlat2);// south
    
	if( radlat2 > 0 ) radlat2 = PI/2 - fabs(radlat2);// north
    
	if( radlong2 < 0 ) radlong2 = PI*2 - fabs(radlong2);// west

	double x1 = er * cos(radlong1) * sin(radlat1);
	double y1 = er * sin(radlong1) * sin(radlat1);
	double z1 = er * cos(radlat1);
	double x2 = er * cos(radlong2) * sin(radlat2);
	double y2 = er * sin(radlong2) * sin(radlat2);
	double z2 = er * cos(radlat2);
    
	double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    
	//side, side, side, law of cosines and arccos
	double theta = acos((er*er+er*er-d*d)/(2*er*er));
	double dist  = theta*er;
    
	return dist;
}


+ (NSString*)getSecureString:(NSString *)keystring
{
	NSString *securekey = [Encry md5:keystring];
	return securekey;
}

#define	CTL_NET		4		/* network, see socket.h */
+ (NSString*)getMacAddress
{
	return [SvUDIDTools UDID];
}

// 判断NSString中的字符是否为中文的正确方法
+ (BOOL)isIncludeChineseInString:(NSString*)str {
    for (int i=0; i<str.length; i++) {
        unichar ch = [str characterAtIndex:i];
        if (0x4e00 < ch  && ch < 0x9fff) {
            return true;
        }
    }
    return false;
}

// 错误提示
+ (void)MsgBox:(NSString *)title messege:(NSString *)message cancel:(NSString *)cancel other:(NSString *)other delegate:(id)delegate
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title
                                                   message:message
                                                  delegate:delegate
                                         cancelButtonTitle:cancel
                                         otherButtonTitles:other,nil];
    [alert show];
    [alert release];
}

+ (NSNumber*)getVersion:(int)commandId
{
//    version_model *versionMod = [[version_model alloc] init];
//    versionMod.where = [NSString stringWithFormat:@"command_id = %d",commandId];
//    NSMutableArray *versionArray = [versionMod getList];
//    [versionMod release];
//    
//    if ([versionArray count] > 0)
//    {
//        NSDictionary *versionDic = [versionArray objectAtIndex:0];
//        return [NSNumber numberWithInt:[[versionDic objectForKey:@"ver"] intValue]];
//    }
    
    return [NSNumber numberWithInt:0];
}

+ (NSNumber*)getVersion:(int)commandId desc:(NSString *)desc
{
//    version_model *versionMod = [[version_model alloc] init];
//    versionMod.where = [NSString stringWithFormat:@"command_id = %d and desc = '%@'",commandId,desc];
//    NSMutableArray *versionArray = [versionMod getList];
//    [versionMod release];
//    
//    if ([versionArray count] > 0)
//    {
//        NSDictionary *versionDic = [versionArray objectAtIndex:0];
//        return [NSNumber numberWithInt:[[versionDic objectForKey:@"ver"] intValue]];
//    }
    
    return [NSNumber numberWithInt:0];
}

+ (BOOL)updateVersion:(int)commandId withVersion:(int)version withDesc:(NSString*)desc
{
//    version_model *versionMod = [[version_model alloc] init];
//    
//    //不存在 则插入 存在则更新
//    versionMod.where = [NSString stringWithFormat:@"command_id = %d",commandId];
//    NSMutableArray *versionArray = [versionMod getList];
//    
//    
//    NSDictionary *versionDic = [NSDictionary dictionaryWithObjectsAndKeys:
//                                [NSNumber numberWithInt:commandId],@"command_id",
//                                [NSNumber numberWithInt:version],@"ver",
//                                desc,@"desc",
//                                nil];
//    
//    if ([versionArray count] > 0) {
//        [versionMod updateDB:versionDic];
//    } else {
//        [versionMod insertDB:versionDic];
//    }
//    
//    [versionMod release];
    return YES;
}

+ (NSNumber*)getCatVersion:(int)commandId withId:(int)cat_Id
{
//    cat_version_model *versionMod = [[cat_version_model alloc] init];
//    versionMod.where = [NSString stringWithFormat:@"command_id = %d and catId = %d",commandId,cat_Id];
//    NSMutableArray *versionArray = [versionMod getList];
//    [versionMod release];
//    
//    if ([versionArray count] > 0)
//    {
//        NSDictionary *versionDic = [versionArray objectAtIndex:0];
//        return [NSNumber numberWithInt:[[versionDic objectForKey:@"ver"] intValue]];
//    }
//    
    return [NSNumber numberWithInt:0];
}

+ (BOOL)updateCatVersion:(int)commandId withVersion:(int)version withId:(int)cat_Id withDesc:(NSString*)desc
{
//    cat_version_model *versionMod = [[cat_version_model alloc] init];
//    
//    //不存在 则插入 存在则更新
//    versionMod.where = [NSString stringWithFormat:@"catId = %d",cat_Id];
//    NSMutableArray *versionArray = [versionMod getList];
//    
//    
//    NSDictionary *versionDic = [NSDictionary dictionaryWithObjectsAndKeys:
//                                [NSNumber numberWithInt:commandId],@"command_id",
//                                [NSNumber numberWithInt:version],@"ver",
//                                [NSNumber numberWithInt:cat_Id],@"catId",
//                                desc,@"desc",
//                                nil];
//    
//    if ([versionArray count] > 0)
//    {
//        [versionMod updateDB:versionDic];
//    }
//    else
//    {
//        [versionMod insertDB:versionDic];
//    }
//    
//    [versionMod release];
    return YES;
}


/* ========================================系统相关函数=============================================== */

+ (void)setActivityIndicator:(bool)isShow
{
	UIApplication *app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = isShow;
}

// 手机号码正则表达式
+ (BOOL)phoneNumberChecking:(NSString *)phone
{
//    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    NSString *regex = @"^(1)\\d{10}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:phone];
}

// 判断是否有非法字符正则表达式
+ (BOOL)illegalCharacterChecking:(NSString *)text
{
    NSString *regex = @"^([a-zA-Z0-9\u4E00-\u9FA5]{0,20})";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:text];
}

//邮箱
+ (BOOL) validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}


/*
 *   满足于数组中字典按整数值排序
 *   arr    数组参数里面存放字典数组
 *   field  字典的字段，会根据此字段来读取数据
 *   sort   SortEnum为枚举类型  SortEnumAsc 升 SortEnumDesc 降
 */
+ (NSMutableArray *)sortInt:(NSMutableArray *)arr field:(NSString *)field sort:(SortEnum)sort
{
    NSComparator cmptr = ^(id obj1, id obj2){
        int value1 = [[obj1 objectForKey:field] intValue];
        int value2 = [[obj2 objectForKey:field] intValue];
        
        if (sort == SortEnumAsc) {
            if (value1 > value2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if (value1 < value2) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        } else {
            if (value1 < value2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if (value1 > value2) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }
    };
    
    if (arr.count == 0) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[arr sortedArrayUsingComparator:cmptr]];
    
    return array;
}


//动态获取内容的高度
+ (CGFloat)getTextHeight:(NSString *)contentStr textFont:(int)font textWidth:(float)width
{
    UIFont *fontc = [UIFont fontWithName:@"Arial"size:font];
    CGSize size = CGSizeMake(width,2000);
    CGSize labelsize = [contentStr sizeWithFont:fontc constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    
    return labelsize.height;
}

// 判断总定位功能是否开启
+ (BOOL)isLoctionOpen
{
    if ([CLLocationManager locationServicesEnabled]) {
        return YES;
    } else {
        return NO;
    }
}

// 提示框
+ (void)checkProgressHUD:(NSString *)value andImage:(UIImage *)img showInView:(UIView *)view{
    
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:view];
    progressHUDTmp.center=CGPointMake(view.center.x, view.center.y);
    progressHUDTmp.customView= [[[UIImageView alloc] initWithImage:img] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    progressHUDTmp.labelText = value;
    
    [view addSubview:progressHUDTmp];
    
    [view bringSubviewToFront:progressHUDTmp];
    [progressHUDTmp show:YES];
    
    [progressHUDTmp hide:YES afterDelay:1.5];
    RELEASE_SAFE(progressHUDTmp);
    
}

+ (void)checkProgressHUDShowInAppKeyWindow:(NSString *)value andImage:(UIImage *)img
{
    [Common checkProgressHUD:value andImage:img showInView:APPKEYWINDOW];
}

// 根据时间戳转化时间
+ (NSString *)makeTime:(int)times withFormat:(NSString *)format
{
    NSString *dateString;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:times];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:format];
    dateString = [dateFormat stringFromDate:date];
    [dateFormat release];
    
    return dateString;
}

+ (NSString *)makeTime13To10:(long long)times withFormat:(NSString *)format
{
    NSString *dateString;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:times/1000];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:format];
    dateString = [dateFormat stringFromDate:date];
    [dateFormat release];
    
    return dateString;
}

// 根据时间戳转化时间
+ (NSString *)makeShortTime:(int)times
{
    NSString *dateString;
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:times];
    NSDate* currentDate = [NSDate date];
    
    NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
    [outputFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSString *currentDateString = [outputFormat stringFromDate:currentDate];
    NSString *dString = [outputFormat stringFromDate:date];
    
    NSString *format = [currentDateString isEqualToString:dString] ? @"HH:mm" : @"MM月dd日";
    [outputFormat setDateFormat:format];
    dateString = [outputFormat stringFromDate:date];
    [outputFormat release];
    
    return dateString;
    
}

// 根据时间戳转化友好的时间
+ (NSString *)makeFriendTime:(int)times
{
    NSString *dateString;
    NSTimeInterval cTime = [[NSDate date] timeIntervalSince1970];
    
    long long int currentTime = (long long int)cTime*1000;//java时间13位的，需要转化一下
    int countTimes = (int)(currentTime - times)/1000;
    //一分钟秒数
    int oneM = 60;
    //一小时秒数
    int oneH = 60 * oneM;
    //一天秒数
    int oneD = 24 * oneH;
    //三天的秒数
    int threeD = 3 * oneD;
    //一年的秒数
    int oneYearDistant = oneD * 365;
    
    if (countTimes < oneM)
    {
        //60秒之内
        dateString = @"刚刚";
    }
    else if(countTimes < oneH)
    {
        //6小时之内
        int minuteCount = countTimes / oneM;
        dateString = [NSString stringWithFormat:@"%d 分钟前",minuteCount];
    }
    else if(countTimes < oneD)
    {
        //一天之内
        int hoursCount = countTimes / oneH;
        dateString = [NSString stringWithFormat:@"%d 小时前",hoursCount];
    }
    else if(countTimes < threeD)
    {
        //三天之内
        int dayCount = countTimes / oneD;
        if (dayCount == 1) {
            dateString = @"昨天";
        }else{
            dateString = @"前天";
        }
    } else {
     
//        if (countTimes < oneYearDistant) {
//            [outputFormat setDateFormat:@"MM-dd"];
//        } else {
//            [outputFormat setDateFormat:@"yyyy-MM-dd"];
//        }
//        
//        dateString = [outputFormat stringFromDate:date];
//        [outputFormat release];
        if (countTimes < oneYearDistant) {
            dateString = [NSString stringWithFormat:@"%d 天前",countTimes/oneD];
        }else{
            dateString = [NSString stringWithFormat:@"%d 年前",countTimes/oneYearDistant];
        }
        
    }
    return dateString;
}

+ (NSString *)makeSessionViewMessageFriendTime:(int)times
{
    NSString * resultTimeStr;
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSDate * getDate = [NSDate dateWithTimeIntervalSince1970:times];
    
    int currentTimeInt = (int)currentTime;
    int countTimes = (int)(currentTimeInt - times);
    //一天秒数
    int oneS = 60;
    //一小时秒数
    int oneH = 60 * oneS;
    //一天秒数
    int oneD = 24 * oneH;
    //两天的秒数
    int twoD = 2 * oneD;
    
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    if(countTimes < oneD)
    {
        //一天之内
        dateFormatter.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setDateFormat:@"h:mm a"];
        resultTimeStr = [dateFormatter stringFromDate:getDate];
    } else if(oneD < countTimes < twoD) {
        //昨天之内
        dateFormatter.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setDateFormat:@"h:mm a"];
//        NSString *usAmPmStr = [dateFormatter stringFromDate:getDate];
//        resultTimeStr = [NSString stringWithFormat:@"昨天 %@",usAmPmStr];
        resultTimeStr = @"昨天";

    } else {
        //两天以上
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        resultTimeStr = [dateFormatter stringFromDate:getDate];
    }
    RELEASE_SAFE(dateFormatter);
    return resultTimeStr;
}

+ (NSString *)makeMessageListHumanizedTimeForWithTime:(double)theTime
{
    NSDate *theDate = [NSDate dateWithTimeIntervalSince1970:theTime];
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps;
    
    comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSWeekCalendarUnit) fromDate:theDate];
    NSInteger theYear = [comps year];
    NSInteger theDay = [comps day];
    NSInteger theWeek = [comps week];
    
    comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSWeekCalendarUnit) fromDate:currentDate];
    NSInteger currentYear = [comps year];
    NSInteger currentDay = [comps day];
    NSInteger currentWeek = [comps week];
    
    if (theYear != currentYear || theWeek != currentWeek)
    {//在同一周之外的时间统一显示为年月日
        [formatter setDateFormat:@"yy/MM/dd"];
    } else if (theDay < currentDay - 1)
    {//同周昨天之外显示星期
        formatter.locale = [UserModel currentLocale];
        [formatter setDateFormat:@"EEEE"];
    } else if (theDay == currentDay -1)
    {//昨天的就显示昨天
        if ([UserModel isChineseLanguage]) {
            return @"昨天";
        } else {
            return @"Yesterday";
        }
    } else
    {//同一天之内 显示 h:mm a
        formatter.locale = [UserModel currentLocale];
        if ([UserModel isChinaLocaleCode]) {
            [formatter setDateFormat:@"a h:mm"];
        } else {
            [formatter setDateFormat:@"h:mm a"];
        }

    }
    
    NSString *timeStr = [formatter stringFromDate:theDate];
    RELEASE_SAFE(formatter);
    return timeStr;
}

+ (NSString *)makeSessionViewHumanizedTimeForWithTime:(double)theTime
{
    NSDate *theDate = [NSDate dateWithTimeIntervalSince1970:theTime];
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps;
    
    comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSWeekCalendarUnit) fromDate:theDate];
    NSInteger theYear = [comps year];
    NSInteger theDay = [comps day];
    NSInteger theWeek = [comps week];
    
    comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSWeekCalendarUnit) fromDate:currentDate];
    NSInteger currentYear = [comps year];
    NSInteger currentDay = [comps day];
    NSInteger currentWeek = [comps week];
    
    NSString * hoursFormat = @"h:mm a";
    if ([UserModel isChinaLocaleCode]) {
        hoursFormat = @"a h:mm";
    }
    
    if (theYear != currentYear || theWeek != currentWeek)
    {//在同一周之外的时间统一显示为年月日
        formatter.locale = [UserModel currentLocale];
        [formatter setDateFormat:[NSString stringWithFormat:@"yyyy/MM/dd %@",hoursFormat]];
    } else if (theDay < currentDay - 1)
    {//同周昨天之外显示星期
        formatter.locale = [UserModel currentLocale];
        [formatter setDateFormat:[NSString stringWithFormat:@"EEEE %@",hoursFormat]];
    } else if (theDay == currentDay -1)
    {//昨天的就显示昨天
        formatter.locale = [UserModel currentLocale];
        [formatter setDateFormat:hoursFormat];
        NSString * timeStr = [formatter stringFromDate:theDate];
        NSString *str = nil;
        
        if ([UserModel isChineseLanguage]) {
            str = [NSString stringWithFormat:@"昨天 %@",timeStr];
        } else {
            str = [NSString stringWithFormat:@"Yesterday %@",timeStr];
        }
        return str;
    } else
    {//同一天之内 显示 h:mm a
        formatter.locale = [UserModel currentLocale];
        [formatter setDateFormat:hoursFormat];
    }
    
    NSString *timeStr = [formatter stringFromDate:theDate];
    RELEASE_SAFE(formatter);
    return timeStr;
}

+ (long long)timeIntervalFromString:(NSString *)timeString andFormat:(NSString *)formatStr
{
    NSDateFormatter * format = [[NSDateFormatter alloc]init];
    [format setDateFormat:formatStr];
    NSDate * needDate = [format dateFromString:timeString];
    return [needDate timeIntervalSince1970];
}

+ (NSMutableDictionary *)generatePortraitNameDicJsonStrWithContactArr:(NSArray *)contactsArr;
{
    NSMutableString * nameStr = [[NSMutableString alloc]init];
    NSMutableArray * porMuArr = [[NSMutableArray alloc]init];
    
    for (int i = 0;i < contactsArr.count; i ++) {
        NSDictionary * dic = [contactsArr objectAtIndex:i];
        if (i != contactsArr.count - 1 && i < 2 ) {
            NSString * nameItem = [NSString stringWithFormat:@"%@、",[dic objectForKey:@"realname"]];
            [nameStr appendString:nameItem];
            [porMuArr addObject:[dic objectForKey:@"portrait"]];
            
        } else {
            NSString * nameItem2 = [NSString stringWithFormat:@"%@",[dic objectForKey:@"realname"]];
            [nameStr appendString:nameItem2];
            [porMuArr addObject:[dic objectForKey:@"portrait"]];
        }
        
        if (i == 2) {
            break;
        }
    }
    NSMutableDictionary * resultDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:nameStr,@"title",porMuArr,@"icon_path", nil];
    return resultDic;
}

//法官一样的block 用于判断http请求是否失败或超时
JudgeMethodBlack judgeMethod = ^(NSDictionary * theDic, ParseMethod theMethod){
    if (![theDic isEqual:@"cwRequestFail"] && ![theDic isEqual:@"cwRequestTimeout"] && theDic != nil) {
        RequestErrorCode errorCode = [[theDic objectForKey:@"errcode"]intValue];
        
        if (errorCode != RequestErrorCodeFailed){
            theMethod();
        }
        
    } else {
        [Common checkProgressHUD:[NSString stringWithFormat:@"网络连接失败，请重试"] andImage:nil showInView:APPKEYWINDOW];//,[theArr lastObject]
    }
};

+ (void)securelyparseHttpResultDic:(NSDictionary *)resultDic andMethod:(ParseMethod)method
{
    judgeMethod(resultDic,method);
}

+ (void)securelyParseHttpResultDic:(NSDictionary *)resultDic andParseBlock:(void (^)(void))block
{
    judgeMethod(resultDic,block);
}

+(NSString*) phoneNumTypeTurnWith:(NSString *)phoneNum{
    NSString* newPhoneStr = phoneNum;
    if (phoneNum != nil && phoneNum.length == 11) {
        //1-3
        NSString* first3 = [phoneNum substringWithRange:NSMakeRange(0, 3)];
        NSString* mid4 = [phoneNum substringWithRange:NSMakeRange(3, 4)];
        NSString* last4 = [phoneNum substringWithRange:NSMakeRange(7, 4)];
        
        newPhoneStr = [NSString stringWithFormat:@"%@-%@-%@",first3,mid4,last4];
    }
    
    return newPhoneStr;
}

//add vincnet
+ (NSString *) abandonPhoneType:(NSString *) phoneNum{
    NSString *phoneString = [phoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return phoneString;
}

//http错误吗判断
+ (BOOL) TestERRCodeWith:(NSNumber*) errCode{
    BOOL haveErr = NO;
    
    int codeNum = [errCode intValue];
    
    NSString* errStr = nil;
    
    switch (codeNum) {
        case SUCC:
            errStr = @"成功";
            break;
        case ERROR:
            errStr = @"失败";
            break;
        case INTERNAL_ERROR:
            errStr = @"服务端内容错误";
            break;
        case BAD_REQUEST:
            errStr = @"错误请求";
            break;
        case METHOD_NOT_ALLOWED:
            errStr = @"方法不允许访问";
            break;
        case UNAUTHORIZED:
            errStr = @"未授权访问";
            break;
        case MISSING_PARAMETER:
            errStr = @"缺少参数";
            break;
        case PARAMETER_TYPE_ERROR:
            errStr = @"参数类型错误";
            break;
        case ARGUMENT_NOT_VALID:
            errStr = @"参数验证失败";
            break;
        case MISSION_REQUEST_PART:
            errStr = @"缺少请求体";
            break;
        case NOT_CIRCLE_CREATOR:
            errStr = @"不是会话创建者";
            break;
        case INVITATION_CODE_INVALID:
            errStr = @"邀请码无效";
            break;
        case VERIFICATION_CODE_INVALID:
            errStr = @"验证码无效";
            break;
        case VERIFICATION_CODE_EXPIRED:
            errStr = @"验证码过期";
            break;
        case USERNAME_PASSWORD_ERROR:
            errStr = @"用户名密码错误";
            break;
        case USER_ALREADY_EXIST:
            errStr = @"用户名已存在";
            break;
        case USER_ALREADY_INVITED:
            errStr = @"用户已被邀请";
            break;
        default:
            break;
    }
    
    [Common checkProgressHUDShowInAppKeyWindow:errStr andImage:nil];
    
    return haveErr;
}

//屏蔽emoji
+(NSString*) placeEmoji:(NSString*) str{
    return str;
//    return [NSString replaceEmojiWithCode:str];
}

//判断是否是emoji字符
+(BOOL) isEmoji:(NSString*) str{
    return [NSString isEmojiWithCode:str];
}

@end

