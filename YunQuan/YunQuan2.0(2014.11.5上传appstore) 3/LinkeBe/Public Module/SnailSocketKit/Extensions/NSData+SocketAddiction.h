//
//  NSData+SocketAddiction.h
//  ql
//
//  Created by LazySnail on 14-6-4.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SocketAddiction)

- (short)rw_int16AtOffset:(size_t)offset;
- (char)rw_int8AtOffset:(size_t)offset;
- (int)rw_int32AtOffset:(size_t)offset;
- (long long)rw_int64AtOffset:(size_t)offset;
- (NSString *)rw_stringAtOffset:(size_t)offset bytesRead:(size_t *)amount;

@end

@interface NSMutableData (SocketAddiction)

- (void)rw_appendInt64:(long long)value;
- (void)rw_appendInt32:(int)value;
- (void)rw_appendInt16:(short)value;
- (void)rw_appendInt8:(char)value;
- (void)rw_appendString:(NSString *)string;

@end