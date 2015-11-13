//
//  NSObject+Time.m
//  CommunityAPP
//
//  Created by Stone on 14-3-21.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "NSObject+Time.h"

@implementation NSObject (Time)

+(NSString *) getCurrentTime {
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timeString = [dateFormatter stringFromDate:nowDate];
    return timeString;
}

+(NSDate *)fromatterDateFromStr:(NSString *)time{
    NSDateFormatter *inputFormatter = [[[NSDateFormatter alloc] init] autorelease];
    //inputFormatter.dateStyle = kCFDateFormatterMediumStyle;
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *inputDate = [inputFormatter dateFromString:time];
    
    return inputDate;
}

+ (NSString *)formatterDate:(NSString *)time{
    //Mar 7, 2014 7:03:03 PM
    //[dFormate setDateFormat:@"MM dd, yyyy hh:mm:mma"];
   
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    //inputFormatter.dateStyle = kCFDateFormatterMediumStyle;
    [inputFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss aa"];
    NSDate *inputDate = [inputFormatter dateFromString:time];
    
    NSDateFormatter *outPutFormatter = [[NSDateFormatter alloc] init];
    [outPutFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timeString = [outPutFormatter stringFromDate:inputDate];
    
    return timeString;
}

+(NSString *) compareCurrentTime:(NSDate*) compareDate
{
    
    NSTimeInterval  timeInterval = [compareDate timeIntervalSinceNow];
    
    timeInterval = -timeInterval;
    
    int temp = 0;
    
    NSString *result;
    
    if (timeInterval < 60) {
        
        result = [NSString stringWithFormat:@"刚刚"];
        
    }
    
    else if((temp = timeInterval/60) <60){
        
        result = [NSString stringWithFormat:@"%d分前",temp];
        
    }
    
    
    
    else if((temp = temp/60) <24){
        
        result = [NSString stringWithFormat:@"%d小时前",temp];
        
    }
    
    
    
    else if((temp = temp/24) <30){
        
        result = [NSString stringWithFormat:@"%d天前",temp];
        
    }
    
    
    
    else if((temp = temp/30) <12){
        
        result = [NSString stringWithFormat:@"%d月前",temp];
        
    }
    
    else{
        
        temp = temp/12;
        
        result = [NSString stringWithFormat:@"%d年前",temp];
        
    }
    
    
    
    return  result;
    
}


@end
