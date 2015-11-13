//
//  PAAsynDownloadFile.h
//  PAEBank
//
//  Created by james on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PAAsynDownloadFileDelegate

- (void)asynDownloadFileDidFinishLoading:(NSData*)fileData;
- (void)asynDownloadFileDidFailWithError:(NSError *)error;

@end

@interface PAAsynDownloadFile : NSObject {
	NSURLConnection* connection;
	NSMutableData* data;
	id asynDownloadFileDelegate;
}
@property(nonatomic,retain) id asynDownloadFileDelegate;

- (void)loadFileFromURL:(NSString*)url;
@end
