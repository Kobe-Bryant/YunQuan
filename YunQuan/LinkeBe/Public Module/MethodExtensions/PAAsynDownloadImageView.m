//
//  PAAsynImageView.m
//  PAEBank_iPad
//
//  Created by james on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PAAsynDownloadImageView.h"
#import "PATools.h"

@implementation PAAsynDownloadImageView

@synthesize isFinishFlag;
@synthesize asynDownloadDelegate;

- (void)loadFailAction{
    NSArray *array = [self subviews];
	for(int i=0;i<[array count];i++){
		[[array objectAtIndex:i] removeFromSuperview];
	}
	self.image = nil;
    [self cancelRequest];
    if (needFreshFlag) {
        UIButton *_btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _btn.backgroundColor = [UIColor clearColor];
        UIImage *refreshImage = [UIImage imageNamed:@"refresh_head_img.png"];
        UIImageView *refreshImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_head_img.png"]];
        refreshImageView.tag = 1101;
        int widthOfImageBtn = _btn.frame.size.width;
        int widthOfImage  = refreshImage.size.width;
        if (widthOfImageBtn < widthOfImage) {
            refreshImageView.frame = _btn.frame;
        }else{
            refreshImageView.frame = CGRectMake(0, 0, refreshImage.size.width, refreshImage.size.height);
        }
        refreshImageView.center = _btn.center;
        [self addSubview:refreshImageView];
        [refreshImageView release];
        [_btn addTarget:self action:@selector(refreshImage) forControlEvents:UIControlEventTouchUpInside];
        self.userInteractionEnabled = YES;
        [self addSubview:_btn];
    }
}

- (void)refreshImage{
    if (theURL) {
        [self loadImageFromURL:theURL];
    }
}

- (void)setImageWithImg:(UIImage*)img{
	if (!img) {
		return;
	}
	[self cancelRequest];
	isFinishFlag = YES;
	self.image = img;
}

- (void)setImageWithName:(NSString*)imageName URLStr:(NSString*)urlString{
	if (!imageName) {
        NSLog(@"图片名为空。");
		return;
	}
	[self cancelRequest];
	
    NSString *newImageName = [[imageName componentsSeparatedByString:@"/"] lastObject];
	UIImage* img = [UIImage imageNamed:newImageName];
	
	if (!img) {
		img = [UIImage imageWithData:[PATools readNSDataFromFile:newImageName]];
		self.image = img;
	}
	
	if (!img) {
        if (theURL) {
            [theURL release];
        }
		theURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@",urlString,imageName]];
        if (theImageName) {
            [theImageName release];
            theImageName = nil;
        }
		theImageName = [newImageName retain];
		[self loadImageFromURL:theURL];
	}else {
		self.image = img;
	}
}

- (void)setImageWithName:(NSString*)imageName URLStr:(NSString*)urlString needFresh:(BOOL)needFresh{
    needFreshFlag = needFresh;
    UIImageView *refreshImageView = (UIImageView *)[self viewWithTag:1101];
    [refreshImageView removeFromSuperview];
    [self setImageWithName:imageName URLStr:urlString];
}

- (void)cancelRequest{
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
	if(indicatorView !=nil){
		[indicatorView stopAnimating];
		[indicatorView removeFromSuperview];
		indicatorView=nil;
	}
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

- (void)loadImageFromURL:(NSURL*)url {
	if (theURL!=url) {
        [theURL release];
        theURL = [url retain];
    }
	[self cancelRequest];
    NSArray *array = [self subviews];
	for(int i=0;i<[array count];i++){
		[[array objectAtIndex:i] removeFromSuperview];
	}
#if PA_ENVIRONMENT==1
    [NSMutableURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
#endif
	NSURLRequest* request = [NSURLRequest requestWithURL:url 
											 cachePolicy:NSURLRequestUseProtocolCachePolicy 
										 timeoutInterval:30.0];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
	indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
	indicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
	[indicatorView startAnimating];
	[self addSubview:indicatorView];
}


- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {

	if (data==nil) { data = [[NSMutableData alloc] initWithCapacity:2048]; } 
	[data appendData:incrementalData];
	
}


- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
		
	NSArray *array = [self subviews];
	for(int i=0;i<[array count];i++){
		[[array objectAtIndex:i] removeFromSuperview];
	}	
	
	if (data) {
		self.image = [UIImage imageWithData:data];
		//将文件保存到本地Documents目录
		if( [theImageName length]>0 )
		{
			[PATools writeNSData:data ToFileName:theImageName];
		}
	}

	self.contentMode = UIViewContentModeScaleToFill;
	[self setNeedsLayout];
	
	[self cancelRequest];
	isFinishFlag = TRUE;
	
	if ( asynDownloadDelegate && [asynDownloadDelegate respondsToSelector:@selector(asynDownloadImageViewDidFinishLoading:)]) {
		[asynDownloadDelegate asynDownloadImageViewDidFinishLoading:self];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	
	[self loadFailAction];
}


- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
	[self loadFailAction];
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
	if (theURL) {
        [theURL release];
        theURL = nil;
    }
	if(theImageName !=nil){	
		[theImageName release];
		theImageName=nil;
	}

    [super dealloc];
	
}



@end
