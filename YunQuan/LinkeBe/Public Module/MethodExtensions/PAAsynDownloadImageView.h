//
//  PAAsynImageView.h
//  PAEBank_iPad
//
//  Created by james on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PAAsynDownloadImageView;
@protocol PAAsynDownloadImageViewDelegate

- (void)asynDownloadImageViewDidFinishLoading:(PAAsynDownloadImageView*)asynDownloadImageView;

@end


@interface PAAsynDownloadImageView : UIImageView {
	NSURLConnection* connection;
	NSMutableData* data;
	UIActivityIndicatorView *indicatorView;
	NSString *theImageName;
	BOOL isFinishFlag;
	id   asynDownloadDelegate;
    NSURL *theURL;
    BOOL needFreshFlag;
}

@property(nonatomic) BOOL isFinishFlag;
@property(nonatomic,assign)id   asynDownloadDelegate;

- (void)setImageWithName:(NSString*)imageName URLStr:(NSString*)urlString;
- (void)setImageWithName:(NSString*)imageName URLStr:(NSString*)urlString needFresh:(BOOL)needFresh;
- (void)loadImageFromURL:(NSURL*)url;
- (void)cancelRequest;
- (void)setImageWithImg:(UIImage*)img;
@end
