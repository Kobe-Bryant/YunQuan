//
//  imageBrowser.m
//  sliderDemo
//
//  Created by yunlai on 14-3-31.
//  Copyright (c) 2014年 ios. All rights reserved.
//

#import "imageBrowser.h"

#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

@interface ImageBrowser ()

@property(nonatomic,retain) UIScrollView* scrollView;
@property(nonatomic,retain) UILabel* labIndicate;
@property(nonatomic,retain) NSMutableArray* photoImageViewArr;

@end

@implementation ImageBrowser

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id) initWithPhotoList:(NSArray *)photos{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.photos = photos;
        [self setup];
    }
    return self;
}

-(void) setup{
    _photoImageViewArr = [[NSMutableArray alloc] init];
    if (_photos) {
        UIScrollView* scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
        scroll.backgroundColor = [UIColor blackColor];
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.showsVerticalScrollIndicator = NO;
        scroll.pagingEnabled = YES;
        scroll.delegate = self;
        scroll.contentSize = CGSizeMake(self.bounds.size.width*_photos.count, self.bounds.size.height);
        self.scrollView = scroll;
        [self addSubview:_scrollView];
        RELEASE_SAFE(scroll);
    }
    if (_scrollView) {
        for (int i = 0; i < _photos.count; i++) {
            UIImageView* imagev = [[UIImageView alloc] init];
            if ([[_photos lastObject] isKindOfClass:[NSString class]]) {
                
                __block UIImageView* mImagev = imagev;
                [imagev setImageWithURL:[NSURL URLWithString:[_photos objectAtIndex:i]] placeholderImage:nil completed:^(UIImage* image,NSError* error,SDImageCacheType SDImageCacheTypeNone){
                    if (image) {
                    }else{
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            UIImage* downImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[_photos objectAtIndex:i]]]];
                            if (downImage) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    mImagev.image = downImage;
                                });
                            }else{
                                NSLog(@"--down nil--");
                            }
                            
                        });
                    }
                }];
                imagev.frame = CGRectMake(i*_scrollView.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
                imagev.contentMode = UIViewContentModeScaleAspectFit;
            }else{
                UIImage* image = [_photos objectAtIndex:i];
                imagev.image = image;
                CGSize size = [self scaleToSizeWithImageSize:image.size];
                imagev.frame = CGRectMake(i*_scrollView.bounds.size.width, 0, size.width, size.height);
                imagev.center = CGPointMake(i*320+160, self.bounds.size.height/2);
            }
            
            [_scrollView addSubview:imagev];
            [_photoImageViewArr addObject:imagev];
            RELEASE_SAFE(imagev);
        }
        _labIndicate = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 70, 320, 50)];
        _labIndicate.backgroundColor = [UIColor clearColor];
        _labIndicate.text = [NSString stringWithFormat:@"%d / %lu",_currentIndex + 1,(unsigned long)_photos.count];
        _labIndicate.font = [UIFont systemFontOfSize:20];
        _labIndicate.textColor = [UIColor whiteColor];
        _labIndicate.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_labIndicate];
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToClose)];
    [self addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToSave:)];
    longPress.minimumPressDuration = 1.0;
    [self addGestureRecognizer:longPress];
    [longPress release];
}

-(void) longPressToSave:(UILongPressGestureRecognizer*) longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        UIImageView* imageV = [_photoImageViewArr objectAtIndex:_currentIndex];
        if (imageV.image) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否保存图片到相册?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
    }
    
}

#pragma mark - alertDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {
        UIImageView* imageV = [_photoImageViewArr objectAtIndex:_currentIndex];
        UIImage* image = imageV.image;
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self saveImageComplete];
        });
    }
}

-(void) saveImageComplete{
//    [Common checkProgressHUD:@"保存成功!" andImage:nil showInView:self];
    [Common checkProgressHUDShowInAppKeyWindow:@"保存成功!" andImage:nil];
}

-(void) tapToClose{
    [self.delegate shouldHideImageBrowser];
    [self hideWithAnimation:YES];
}

//按宽高比缩放图片
-(CGSize)scaleToSizeWithImageSize:(CGSize)imageSize
{
    float widthHeightScale = imageSize.width / imageSize.height; //宽高比
    if(imageSize.width > _scrollView.bounds.size.width)
    {
        float width = _scrollView.bounds.size.width;
        float height = width / widthHeightScale;
        
        imageSize = CGSizeMake(width, height);
    }
    else if (imageSize.height > _scrollView.bounds.size.width)
    {
        float height = _scrollView.bounds.size.height;
        float width = widthHeightScale * height;
        
        imageSize = CGSizeMake(width, height);
    }
    return imageSize;
}

-(void) setCurrentIndex:(int)currentIndex{
    _currentIndex = currentIndex;
    if (_scrollView) {
        _labIndicate.text = [NSString stringWithFormat:@"%d / %lu",_currentIndex + 1,(unsigned long)_photos.count];
        [_scrollView scrollRectToVisible:CGRectMake(_scrollView.bounds.size.width*_currentIndex, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height) animated:YES];
    }
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int pageIndex = scrollView.contentOffset.x/scrollView.bounds.size.width;
    self.currentIndex = pageIndex;
}

-(void) showWithAnimation:(BOOL)animation{
    if (animation) {
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        self.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1.0;
            self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }];
    }
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
}

-(void) hideWithAnimation:(BOOL)animation{
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0.0;
            self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        } completion:^(BOOL complete){
            [self removeFromSuperview];
        }];
    }
}

-(void) dealloc{
    [_labIndicate release];
    [_scrollView release];
    [_photos release];
    RELEASE_SAFE(_photoImageViewArr);
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
