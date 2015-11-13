//
//  PAAsynDownloadFile.m
//  PAEBank
//
//  Created by james on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PAAsynDownloadFile.h"


@implementation PAAsynDownloadFile
@synthesize asynDownloadFileDelegate;

- (void)cancelRequest{
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
	if (connection!=nil) {
		[connection cancel];
		[connection release];
		connection=nil;
	}
	if (data!=nil) { 
		[data release]; 
		data=nil;
	}
}

- (void)loadFileFromURL:(NSString*)url {
	
	[self cancelRequest];
	
	NSURL *_url = [[NSURL alloc] initWithString:url];
	
	NSURLRequest* request = [NSURLRequest requestWithURL:_url 
											 cachePolicy:NSURLRequestUseProtocolCachePolicy 
										 timeoutInterval:30.0];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    [_url release];
}


- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
	
	if (data==nil) { data = [[NSMutableData alloc] initWithCapacity:2048]; } 
	[data appendData:incrementalData];
	
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	if (asynDownloadFileDelegate&&[asynDownloadFileDelegate respondsToSelector:@selector(asynDownloadFileDidFinishLoading:)]) {
		[asynDownloadFileDelegate asynDownloadFileDidFinishLoading:data];
	}
	[self cancelRequest];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	if (asynDownloadFileDelegate&&[asynDownloadFileDelegate respondsToSelector:@selector(asynDownloadFileDidFailWithError:)]) {
		[asynDownloadFileDelegate asynDownloadFileDidFailWithError:error];
	}
	[self cancelRequest];
}


- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
	[self cancelRequest];
}


- (void)dealloc {
	
	if(connection !=nil){
		[connection cancel];
		[connection release];
		connection=nil;
	}
	if(data !=nil){	
		[data release];
		data=nil;
	}
	
	[asynDownloadFileDelegate release];
    [super dealloc];
}

@end
