//

//  UIDeviceHardware.m

//

//  Used to determine EXACT version of device software is running on.

#import "UIDeviceHardware.h"

#include <sys/types.h>

#include <sys/sysctl.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@implementation UIDeviceHardware

- (NSString *) platform{
	
	size_t size;
	
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	
	char *machine = malloc(size);
	
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	
	NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
	
	free(machine);
	
	return platform;
	
}

- (NSString *) platformString{

	NSString *deviceString = [self platform];
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    return deviceString;
	
}

+(NSString*)getCellularProviderName

{
    CTTelephonyNetworkInfo*netInfo = [[CTTelephonyNetworkInfo alloc]init];
    
    CTCarrier*carrier = [netInfo subscriberCellularProvider];
    
    NSString*cellularProviderName = [[[carrier carrierName] retain] autorelease];
    
//    NSString *mcc = [carrier mobileCountryCode];
//    
//    NSString *mnc = [carrier mobileNetworkCode];
    
    return cellularProviderName;
    /*
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc]init];
    
    CTCarrier*carrier = [netInfo subscriberCellularProvider];
    
    [netInfo release];
    
    NSLog(@"carrier:%@",carrier);
    
    NSString * imsi=@"";
    
    if (carrier!=NULL) {
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        
        [dic setObject:[[[carrier carrierName] retain]autorelease] forKey:@"Carriername"];
        
        [dic setObject:[carrier mobileCountryCode] forKey:@"MobileCountryCode"];
        
        [dic setObject:[carrier mobileNetworkCode]forKey:@"MobileNetworkCode"];
        
        [dic setObject:[carrier isoCountryCode] forKey:@"ISOCountryCode"];
        
        [dic setObject:[carrier allowsVOIP]?@"YES":@"NO" forKey:@"AllowsVOIP"];
        
        imsi=[JSONDecoder NSDictionaryJSONString:dic];
        
        [dic release];
        
    }
    
    return imsi;//cellularProviderName;
    
    */
    
}

@end