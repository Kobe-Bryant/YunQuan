//
//  PictureMessageCell.m
//  ql
//
//  Created by LazySnail on 14-6-6.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//
#import "PictureData.h"
#import "PictureMessageCell.h"
#import "UIImageView+WebCache.h"
#import "SnailCacheManager.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

@interface PictureMessageCell ()
{
    
}

@property (nonatomic, retain) UIImageView * imgMessageView;

@end

@implementation PictureMessageCell
{
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIImageView * imageView = [[UIImageView alloc]init];
        self.imgMessageView = imageView;
        self.imgMessageView.frame = (CGRect){.origin = CGPointMake(10, 10),.size = kChatThumbnailSize};
        //        booky 8.6
        self.imgMessageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imgMessageView.clipsToBounds = YES;
        self.imgMessageView.userInteractionEnabled = YES;
        RELEASE_SAFE(imageView);
        
        UITapGestureRecognizer * singleTap = [UITapGestureRecognizer new];
        singleTap.numberOfTapsRequired = 1;
        [singleTap addTarget:self action:@selector(showTheWholePic)];
        [self.imgMessageView addGestureRecognizer:singleTap];
        RELEASE_SAFE(singleTap);
    }
    return self;
}

- (void)showTheWholePic
{
    PictureData * picData = (PictureData *)self.msgObject.sessionData;
//    self.wholeImgUrlStr = picData.url;
    MJPhoto * selectPhoto = [[MJPhoto alloc]init];
    
    UIImage * wholeImage = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:picData.url];
    selectPhoto.image = wholeImage;
    selectPhoto.srcImageView = self.imgMessageView;
    if (wholeImage == nil) {
        selectPhoto.url = [NSURL URLWithString:picData.url];
    }
   
    NSMutableArray * photos = [NSMutableArray arrayWithCapacity:1];
    [photos addObject:selectPhoto];
    
    MJPhotoBrowser * photoBrowser = [[MJPhotoBrowser alloc]init];
    photoBrowser.photos = photos;
    [photoBrowser show];
    RELEASE_SAFE(photoBrowser);
    RELEASE_SAFE(selectPhoto);
    
    [self.delegate haveClickPicture];
//    [_imgBrowser showWithAnimation:YES];
}

//- (void)setWholeImgUrlStr:(NSString *)wholeImgUrlStr
//{
//    NSArray * photoArr = [NSArray arrayWithObjects:wholeImgUrlStr, nil];
//    if (_imgBrowser != nil) {
//        RELEASE_SAFE(_imgBrowser);
//        _imgBrowser = [[ImageBrowser alloc]initWithPhotoList:photoArr];
//        _imgBrowser.delegate = self;
//    } else{
//        _imgBrowser = [[ImageBrowser alloc]initWithPhotoList:photoArr];
//        _imgBrowser.delegate = self;
//    }
//}

+ (float)caculateCellHightWithMessageData:(MessageData *)data
{
    return kChatThumbnailSize.height + PictureCellFrameMargin * 2 + [MessageCell caculateCellHightWithMessageData:data];
}

- (void)freshWithInfoData:(MessageData *)data
{
    PictureData * picData = (PictureData *)data.sessionData;
    
    //读取缓存区图片
    if (picData.image != nil) {
        self.imgMessageView.image = picData.image;
    } else {
        UIImage * thumbImg = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:picData.tburl];
        UIImage * defaultImg = [UIImage imageNamed:@"img_landing_default220.png"];

        if (thumbImg != nil) {
            self.imgMessageView.image = thumbImg;
        } else {
            NSURL * thumbnailUrl = [NSURL URLWithString:picData.tburl];
            [self.imgMessageView setImageWithURL:thumbnailUrl placeholderImage:defaultImg];
        } if (picData.tburl == nil) {
            NSURL * wholeUrl = [NSURL URLWithString:picData.url];
            [self.imgMessageView setImageWithURL:wholeUrl placeholderImage:defaultImg];
        }
    }
    
    //将图片imageView 设置为Cell 的content View
    _messageContentView = _imgMessageView;
    [super freshWithInfoData:data];
    
    if (_indicatorView != nil) {
        _indicatorView.frame = CGRectMake(CGRectGetMinX(_sessionBackView.frame) + CGRectGetWidth(_sessionBackView.frame)/2 - CGRectGetWidth(_indicatorView.frame)/2, CGRectGetMaxY(_sessionBackView.frame) - CGRectGetWidth(_sessionBackView.frame)/2 - CGRectGetWidth(_indicatorView.frame)/2, _indicatorView.frame.size.width, _indicatorView.frame.size.height);
        UIView * shadowBack = [[UIView alloc]initWithFrame:_imgMessageView.frame];
        shadowBack.backgroundColor = [UIColor whiteColor];
        shadowBack.alpha = 0.5f;
        [_sessionBackView addSubview:shadowBack];
        self.shadowBackView = shadowBack;
        RELEASE_SAFE(shadowBack);
    }
}

#pragma mark - ImageBrowserDelegate

- (void)shouldHideImageBrowser
{
    [self.delegate shouldHideWholePictureBrowser];
}

#pragma makr - MessageSendSuccessMethod OverideFatherMethod

- (void)recieveMessageSendNoti:(NSNotification *)notif
{
    if ([super judgeSendedNofityMessageWithNoti:notif]) {
        if (self.shadowBackView != nil) {
            if ([self.shadowBackView superview] != nil) {
                [self.shadowBackView removeFromSuperview];
            }
        }
    }
}


- (void)dealloc
{
    self.imgMessageView.image = nil;
    self.imgMessageView = nil;
    self.msgObject.delegate = nil;
    self.shadowBackView = nil;
    self.msgObject = nil;
    LOG_RELESE_SELF;
    [super dealloc];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
