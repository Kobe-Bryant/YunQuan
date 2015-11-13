//
//  WatermarkCameraViewController.m
//  LinkeBe
//
//  Created by Dream on 14-9-19.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "WatermarkCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImageScale.h"

#define kTopButtonSize CGSizeMake(40.0f,40.0f)
#define kTopViewHeight_4 75.0f
#define kTopViewHeight_5 75.0f + 44.0f
#define kToolBarHeight 60.0f
#define kWinSize [UIScreen mainScreen].bounds.size
#define kWatermarkScrollViewSize CGSizeMake(kWinSize.width,80.0f)
#define kCameraViewSize CGSizeMake(kWinSize.width,kWinSize.width)

#define kWatermarkViewMagin 5
#define kNumberPerLine 4

@interface WatermarkCameraViewController ()

@property (nonatomic,retain) UIView *cameraView;
//@property (nonatomic,retain) UIScrollView *watermarkScrollView;
//@property (nonatomic,retain) UIImageView *overlayWatermarkView;
@property (nonatomic,retain) UIScrollView *overlayWatermarkView;
@property (nonatomic,retain) UIButton *flashBtn;
@property (nonatomic,retain) UIButton *switchBtn;
@property (nonatomic,retain) UIButton *closeBtn;
@property (nonatomic,retain) UIButton *cameraBtn;

@property (nonatomic,retain) AVCaptureSession *captureSession;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic,retain) AVCaptureDevice *device;
@property (nonatomic,retain) AVCaptureDeviceInput *input;
@property (nonatomic,retain) AVCaptureStillImageOutput *output;

@property (nonatomic,retain) NSMutableArray *watermarks;
@property (nonatomic,assign) NSInteger selectWatermarkIndex;
@property (nonatomic,copy) UIImage *shootImage; //摄像头捕抓的图像
@property (nonatomic,copy) UIImage *resultImage;
//@property (nonatomic,retain) NSArray *localImages; //选择的本地图片

@end

@implementation WatermarkCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openCamera) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //    self.watermarks = [[NSMutableArray alloc]initWithCapacity:8];
    //    for (int i = 0; i < 8; i++) {
    //        NSString *watermarkName = [NSString stringWithFormat:@"eatShow_watermark_icon%d",i + 1];
    //        [_watermarks addObject:watermarkName];
    //    }
	
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //隐藏状态栏
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    [self setup];
}

//手机唤醒时打开相机重新拍照
-(void)openCamera
{
    if(_captureSession)
    {
        [_captureSession startRunning];
        
        //改变按钮图片
        [_cameraBtn setSelected:NO];
        [_cameraBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eatShow_takePhoto_save_btn_normal" ofType:@"png"]] forState:UIControlStateNormal];
        [_cameraBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eatShow_takePhoto_save_btn_highlighted" ofType:@"png"]] forState:UIControlStateHighlighted];
    }
}

-(void)setup
{
    UIView *topBackView = nil;
    if(kWinSize.height > 480.0f)
    {
        topBackView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, kWinSize.width, kTopViewHeight_5)];
    }
    else
    {
        topBackView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, kWinSize.width, kTopViewHeight_4)];
    }
    
    topBackView.backgroundColor = [UIColor blackColor];
    
    //闪关灯
    UIImage *flashImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eatShow_takePhoto_flash_btn_normal_auto" ofType:@"png"]];
    self.flashBtn = [[UIButton alloc] initWithFrame:CGRectMake(30.0f, (topBackView.bounds.size.height - flashImage.size.height) / 2.0f, kTopButtonSize.width, kTopButtonSize.height)];
    [_flashBtn setImage:flashImage forState:UIControlStateNormal];
    [_flashBtn addTarget:self action:@selector(flashClick:) forControlEvents:UIControlEventTouchUpInside];
    [topBackView addSubview:_flashBtn];
    
    //切换摄像头
    UIImage *switchImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eatShow_takePhoto_switch_btn_normal" ofType:@"png"]];
    self.switchBtn = [[UIButton alloc] initWithFrame:CGRectMake(kWinSize.width - 30.0f - kTopButtonSize.width, (topBackView.bounds.size.height - switchImage.size.height) / 2.0f, kTopButtonSize.width, kTopButtonSize.height)];
    [_switchBtn setImage:switchImage forState:UIControlStateNormal];
    [_switchBtn addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
    [topBackView addSubview:_switchBtn];
    
    //拍摄区域
    //    self.cameraView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.cameraView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topBackView.frame), kWinSize.width, kWinSize.width)];
    _cameraView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_cameraView];
    
    [self.view addSubview:topBackView];
    [topBackView release];
    
    //底部视图和拍摄区域的黑色部分，高度根据屏幕尺寸决定，使拍摄区域为正方形
    UIView *blackView = nil;
    if(kWinSize.height > 480.0f)
    {
        blackView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, kTopViewHeight_5 + kWinSize.width, kWinSize.width, kWinSize.height - kTopViewHeight_5 - kToolBarHeight - kWinSize.width)];
    }
    else
    {
        blackView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, kTopViewHeight_4 + kWinSize.width, kWinSize.width, kWinSize.height - kTopViewHeight_4 - kToolBarHeight - kWinSize.width)];
    }
    
    blackView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:blackView];
    [blackView release];
    
    //底部视图
    UIImage *backImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eatShow_takePhoto_bar_bg" ofType:@"png"]];
    UIImageView *bottomToolView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, kWinSize.height - kToolBarHeight, kWinSize.width, kToolBarHeight)];
    bottomToolView.image = backImage;
    bottomToolView.userInteractionEnabled = YES;
    
    //关闭按钮
    UIImage *closeImage_normal = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eatShow_takePhoto_close_btn_normal" ofType:@"png"]];
    UIImage *closeImage_selected = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eatShow_takePhoto_close_btn_selected" ofType:@"png"]];
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeBtn.frame = CGRectMake(20.0f, (kToolBarHeight - closeImage_normal.size.height) / 2.0f, closeImage_normal.size.width, closeImage_normal.size.height);
    [_closeBtn setImage:closeImage_normal forState:UIControlStateNormal];
    [_closeBtn setImage:closeImage_selected forState:UIControlStateSelected];
    [_closeBtn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolView addSubview:_closeBtn];
    
    //拍摄按钮
    UIImage *cameraImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eatShow_takePhoto_camera_btn_normal" ofType:@"png"]];
    self.cameraBtn = [[UIButton alloc]initWithFrame:CGRectMake((kWinSize.width - cameraImage.size.width) / 2.0f, (kToolBarHeight - cameraImage.size.height) / 2.0f, cameraImage.size.width, cameraImage.size.height)];
    [_cameraBtn setImage:cameraImage forState:UIControlStateNormal];
    [_cameraBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eatShow_takePhoto_camera_btn_highlighted" ofType:@"png"]] forState:UIControlStateHighlighted];
    [_cameraBtn addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolView addSubview:_cameraBtn];
    
    //选择图片按钮
    //    UIImage *localImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eatShow_takePhoto_localImage_btn_normal" ofType:@"png"]];
    //    UIButton *selectImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    selectImgBtn.frame = CGRectMake(kWinSize.width - 20.0f - localImage.size.width, (kToolBarHeight - localImage.size.height) / 2.0f, localImage.size.width, localImage.size.height);
    //    [selectImgBtn setImage:localImage forState:UIControlStateNormal];
    //    [selectImgBtn addTarget:self action:@selector(selectLocalImage:) forControlEvents:UIControlEventTouchUpInside];
    //    [bottomToolView addSubview:selectImgBtn];
    
    [self.view addSubview:bottomToolView];
    [bottomToolView release];
    
    [self initAVCapture];
    
    //选择水印的scrollview
    //    [self initWatermarkScrollView];
}

////选择水印的scrollview
//-(void)initWatermarkScrollView
//{
//
//    self.watermarkScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_cameraView.frame), kWatermarkScrollViewSize.width, kWatermarkScrollViewSize.height)];
//    _watermarkScrollView.pagingEnabled = NO;
//    _watermarkScrollView.showsHorizontalScrollIndicator = NO;
//    _watermarkScrollView.showsVerticalScrollIndicator = NO;
//    [self.view addSubview:_watermarkScrollView];
//
//    float width = (kWatermarkScrollViewSize.width - (kNumberPerLine + 1) * kWatermarkViewMagin) / kNumberPerLine;
//    float contentWidth = 0;
//
//    for (int i = 0; i < _watermarks.count; i++)
//    {
//        UIImageView *watermarkView = [[UIImageView alloc]initWithFrame:CGRectMake(kWatermarkViewMagin + (kWatermarkViewMagin + width) * i, kWatermarkViewMagin, width, kWatermarkScrollViewSize.height - 2 * kWatermarkViewMagin)];
//        watermarkView.image = [UIImage imageNamed:[_watermarks objectAtIndex:i]];
//        watermarkView.userInteractionEnabled = YES;
//        watermarkView.tag = 1000 + i;
//        [self.watermarkScrollView addSubview:watermarkView];
//
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectWatermark:)];
//        [watermarkView addGestureRecognizer:tap];
//        [tap release];
//        [watermarkView release];
//        contentWidth = CGRectGetMaxX(watermarkView.frame) + kWatermarkViewMagin;
//    }
//
//    self.watermarkScrollView.contentSize = CGSizeMake(contentWidth,kWatermarkScrollViewSize.height);
//}
//
//-(void)selectWatermark:(UITapGestureRecognizer *)tapGestureRecognizer
//{
//    UIImageView *imageView = (UIImageView *)tapGestureRecognizer.view;
//    [self addWatermarkWithImage:imageView.image];
//
//    int tapIndex = tapGestureRecognizer.view.tag - 1000;
//
//    CGRect rect = CGRectMake(tapIndex * _overlayWatermarkView.bounds.size.width, 0, _overlayWatermarkView.bounds.size.width, _overlayWatermarkView.bounds.size.height);
//
//    [self.overlayWatermarkView scrollRectToVisible:rect animated:YES];
//}

-(void)initAVCapture
{
    self.captureSession = [[AVCaptureSession alloc]init];
    [_captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(_device.flashAvailable)
    {
        [_device lockForConfiguration:nil];
        _device.flashMode = AVCaptureFlashModeAuto;
        [_device unlockForConfiguration];
    }
    
    NSError *error = nil;
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if([_captureSession canAddInput:_input])
    {
        [_captureSession addInput:_input];
    }
    else
    {
        NSLog(@"%@",error);
    }
    
    self.output = [[AVCaptureStillImageOutput alloc]init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    _output.outputSettings = outputSettings;
    [outputSettings release];
    if([_captureSession canAddOutput:_output])
    {
        [_captureSession addOutput:_output];
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    //    _previewLayer.frame = self.cameraView.frame;
    _previewLayer.frame = self.cameraView.bounds;
    _previewLayer.masksToBounds = YES;
    [self.cameraView.layer addSublayer:_previewLayer];
    
    [self addHollowOpenToView:self.cameraView];
    [_captureSession startRunning];
}

//当选择水印时，添加透明水印层
-(void)initWatermarkScrollView
{
    if(self.overlayWatermarkView == nil)
    {
        self.overlayWatermarkView = [[UIScrollView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, kWinSize.width, kWinSize.width)];
        _overlayWatermarkView.backgroundColor = [UIColor clearColor];
        _overlayWatermarkView.pagingEnabled = YES;
        _overlayWatermarkView.showsHorizontalScrollIndicator = NO;
        _overlayWatermarkView.showsVerticalScrollIndicator = NO;
        _overlayWatermarkView.delegate = self;
        if(self.watermarks)
        {
            for (int i = 1; i <= _watermarks.count; i++)
            {
                //水印容器view
                UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(i * _overlayWatermarkView.bounds.size.width, 0, _overlayWatermarkView.bounds.size.width, _overlayWatermarkView.bounds.size.height)];
                containerView.backgroundColor = [UIColor yellowColor];
                containerView.clipsToBounds = YES;
                containerView.tag = 100 + i;
                UIImage *watermark = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[_watermarks objectAtIndex:i - 1] ofType:@"png"]];
                UIImageView *watermarkView = [[UIImageView alloc]initWithFrame:CGRectMake((containerView.bounds.size.width - watermark.size.width) / 2.0f, (containerView.bounds.size.height - watermark.size.height), watermark.size.width, watermark.size.height)];
                watermarkView.userInteractionEnabled = YES;
                watermarkView.image = watermark;
                UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragWatermark:)];
                [watermarkView addGestureRecognizer:panGesture];
                [panGesture release];
                
                [containerView addSubview:watermarkView];
                [watermarkView release];
                [_overlayWatermarkView addSubview:containerView];
                [containerView release];
            }
            _overlayWatermarkView.contentSize = CGSizeMake(_overlayWatermarkView.bounds.size.width * (_watermarks.count + 1), _overlayWatermarkView.bounds.size.height);
        }
        
        [self.cameraView.layer addSublayer:_overlayWatermarkView.layer];
    }
}

//拖动水印
-(void)dragWatermark:(UIPanGestureRecognizer *)panGesture
{
    UIView *containerView = [_overlayWatermarkView viewWithTag:100 + _selectWatermarkIndex];
    UIImageView *watermarkImageView = (UIImageView *)[containerView.subviews objectAtIndex:0];
    
    CGPoint point = [panGesture translationInView:containerView];
    CGPoint centerPoint = watermarkImageView.center;
    
    CGSize imageSize = watermarkImageView.image.size;
    
    CGFloat newX = centerPoint.x + point.x;
    CGFloat newY = centerPoint.y + point.y;
    if(newX < imageSize.width / 2.0f)
    {
        newX = imageSize.width / 2.0f;
    }
    else if (newX > containerView.bounds.size.width - imageSize.width / 2.0f)
    {
        newX = containerView.bounds.size.width - imageSize.width / 2.0f;
    }
    
    if(newY < imageSize.height / 2.0f)
    {
        newY = imageSize.height / 2.0f;
    }
    else if (newY > containerView.bounds.size.height - imageSize.height / 2.0f)
    {
        newY = containerView.bounds.size.height - imageSize.height / 2.0f;
    }
    
    watermarkImageView.center = CGPointMake(newX, newY);
    [panGesture setTranslation:CGPointMake(0, 0) inView:containerView];
}

//闪光灯开关
-(void)flashClick:(id)sender
{
    if(self.device)
    {
        [self.flashBtn setEnabled:NO];
        [_device lockForConfiguration:nil];
        if(self.device.flashMode == AVCaptureFlashModeAuto)
        {
            self.device.flashMode = AVCaptureFlashModeOff;
            [_flashBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eatShow_takePhoto_flash_btn_normal_off" ofType:@"png"]] forState:UIControlStateNormal];
        }
        else if (self.device.flashMode == AVCaptureFlashModeOff)
        {
            self.device.flashMode = AVCaptureFlashModeOn;
            [_flashBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eatShow_takePhoto_flash_btn_normal_on" ofType:@"png"]] forState:UIControlStateNormal];
        }
        else if (self.device.flashMode == AVCaptureFlashModeOn)
        {
            self.device.flashMode = AVCaptureFlashModeAuto;
            [_flashBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eatShow_takePhoto_flash_btn_normal_auto" ofType:@"png"]] forState:UIControlStateNormal];
        }
        [_device unlockForConfiguration];
        [_flashBtn setEnabled:YES];
    }
}

//切换摄像头
-(void)switchCamera:(id)sender
{
    //添加动画
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.8f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"oglFlip";
    if (_device.position == AVCaptureDevicePositionFront) {
        animation.subtype = kCATransitionFromRight;
    }
    else if(_device.position == AVCaptureDevicePositionBack){
        animation.subtype = kCATransitionFromLeft;
    }
    [_previewLayer addAnimation:animation forKey:@"animation"];
    
    NSArray *inputs = _captureSession.inputs;
    for ( AVCaptureDeviceInput *input in inputs )
    {
        AVCaptureDevice *device = input.device;
        if ([device hasMediaType:AVMediaTypeVideo])
        {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (position == AVCaptureDevicePositionFront)
            {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            }
            else
            {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            }
            self.device = newCamera;
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            // beginConfiguration ensures that pending changes are not applied immediately
            [_captureSession beginConfiguration];
            
            [_captureSession removeInput:input];
            [_captureSession addInput:newInput];
            
            // Changes take effect once the outermost commitConfiguration is invoked.
            [_captureSession commitConfiguration];
            break;
        }
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == position)
        {
            return device;
        }
    }
    return nil;
}

//拍照的动画
- (void)addHollowOpenToView:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5f;
    animation.delegate = self;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeForwards;
    animation.type = @"cameraIrisHollowOpen";
    [view.layer addAnimation:animation forKey:@"animation"];
}

- (void)addHollowCloseToView:(UIView *)view
{
    CATransition *animation = [CATransition animation];//初始化动画
    animation.duration = 0.5f;//间隔的时间
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"cameraIrisHollowClose";
    
    [view.layer addAnimation:animation forKey:@"HollowClose"];
}

//编辑完成，退出页面
-(void)editFinish
{
    //在图片上加上水印并保存
    if(self.shootImage)
    {
        UIImage *watermarkImage = nil;
        if(_selectWatermarkIndex > 0)
        {
            NSString *selectImgStr = [_watermarks objectAtIndex:_selectWatermarkIndex - 1];
            watermarkImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:selectImgStr ofType:@"png"]];
        }
        
        CGRect rect = CGRectMake(0.0f, 0.0f, kWinSize.width, kWinSize.width);
        
        if(watermarkImage)
        {
            self.resultImage = [self composeWatermarkImage:watermarkImage OriginalImage:_shootImage InRect:rect];
        }
        else
        {
            self.resultImage = _shootImage;
        }
        
        UIImageWriteToSavedPhotosAlbum(_resultImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
        //加上水印后退出
        if(_delegate && [_delegate respondsToSelector:@selector(didSelectImages:)])
        {
            [_delegate didSelectImages:[NSArray arrayWithObject:_resultImage]];
        }
        
        //水印统计
        //        NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:_selectWatermarkIndex] forKey:@"id"];
        //        [[NetManager sharedManager] accessService:requestDic data:nil command:WATERMARK_STATISTICAL_COMMAND_ID accessAdress:@"watermarkedstatistics.do?param=" delegate:nil withParam:nil];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//拍照
-(void)takePhoto:(id)sender
{
    UIButton *btn = sender;
    if(btn.isSelected)
    {
        [self editFinish];
    }
    else
    {
        [_closeBtn setSelected:YES];
        
        //改变按钮图片
        [btn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eatShow_takePhoto_save_btn_normal" ofType:@"png"]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eatShow_takePhoto_save_btn_highlighted" ofType:@"png"]] forState:UIControlStateHighlighted];
        
        //点击拍照
        [btn setSelected:YES];
        AVCaptureConnection *connection = nil;
        for (AVCaptureConnection *conn in self.output.connections) {
            for (AVCaptureInputPort *port in conn.inputPorts) {
                if([port.mediaType isEqualToString:AVMediaTypeVideo])
                {
                    connection = conn;
                    break;
                }
            }
        }
        
        if(connection)
        {
            [self.output captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error)
             {
                 [self addHollowCloseToView:self.cameraView];
                 [self.captureSession stopRunning];
                 
                 CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                 if (exifAttachments) {
                     
                 }
                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                 UIImage *image = [[UIImage alloc]initWithData:imageData];
                 self.shootImage = [self cropImage:image];
                 
                 [image release];
             }];
        }
    }
}

//保存照片到相册
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"save  seccess==================");
}

//在视图的指定区域内截取图片
- (UIImage *)cropImage:(UIImage *)imageToCrop
{
    CGSize size = [imageToCrop size];
    int padding = 0;
    int pictureSize;
    float startY;
    float startCroppingPosition;
    float scale; //比例
    
    if(kWinSize.height > 480.0f)
    {
        startY = kTopViewHeight_5 - 20.0f;
    }
    else
    {
        startY = kTopViewHeight_4 - 20.0f;
    }
    
    if (size.height > size.width)
    {
        pictureSize = size.width - (2.0 * padding);
        scale = pictureSize / kWinSize.width;
    }
    else
    {
        pictureSize = size.height - (2.0 * padding);
        scale = pictureSize / kWinSize.height;
    }
    startCroppingPosition = startY * scale;
    CGRect cropRect = CGRectMake(startCroppingPosition, padding, pictureSize, pictureSize);
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], cropRect);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:imageToCrop.imageOrientation];
//    UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    
    return newImage;
}

//在照片上画上水印。
//originalImage ---拍摄到的原始图片
-(UIImage *)composeWatermarkImage:(UIImage *)watermarkImage OriginalImage:(UIImage *)originalImage InRect:(CGRect)rect
{
    CGSize superSize = originalImage.size;
    
    UIView *containerView = [_overlayWatermarkView viewWithTag:100 + _selectWatermarkIndex];
    UIImageView *watermarkView = (UIImageView *)[containerView.subviews objectAtIndex:0];//水印层
    CGRect watermarkFrame = watermarkView.frame;
    
    CGFloat widthScale = watermarkFrame.size.width / rect.size.width;
    CGFloat heightScale = watermarkFrame.size.height / rect.size.height;
    CGFloat xScale = watermarkFrame.origin.x / rect.size.width;
    CGFloat yScale = watermarkFrame.origin.y / rect.size.height;
    
    CGRect scaleWatermarkFrame = CGRectMake(xScale * superSize.width, yScale * superSize.height, widthScale * superSize.width, heightScale * superSize.height);
    
    UIGraphicsBeginImageContext(superSize);
    [originalImage drawInRect:CGRectMake(0, 0, superSize.width, superSize.height)];
    [watermarkImage drawInRect:scaleWatermarkFrame];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

//关闭照相机
-(void)closeView
{
    if(_type == 1 && _shootImage == nil)
    {
        [self dismissViewControllerAnimated:NO completion:nil];
        NSString *notifStr = [NSString stringWithFormat:@"%@notificationHidePopView",@"shareFoodViewController"];
        [[NSNotificationCenter defaultCenter] postNotificationName:notifStr object:nil];
    }
    else if (_type == 0 && _shootImage == nil)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [_closeBtn setSelected:NO];
        
        [_cameraBtn setSelected:NO];
        [_cameraBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eatShow_takePhoto_camera_btn_normal" ofType:@"png"]] forState:UIControlStateNormal];
        [_cameraBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eatShow_takePhoto_camera_btn_highlighted" ofType:@"png"]] forState:UIControlStateHighlighted];
        self.shootImage = nil;
        [_captureSession startRunning];
    }
}

//选择本地照片
//-(void)selectLocalImage:(id)sender
//{
//    //停止捕抓图像
//    [self.captureSession stopRunning];
//
//    QBImagePickerController *imagePicker = [[QBImagePickerController alloc]init];
//    imagePicker.showsCancelButton = YES;
//    imagePicker.filterType = QBImagePickerFilterTypeAllPhotos;
//    imagePicker.fullScreenLayoutEnabled = YES;
//    imagePicker.allowsMultipleSelection = YES;
//    imagePicker.limitsMaximumNumberOfSelection = YES;
//    imagePicker.maximumNumberOfSelection = 5 - _currentImageCount;
//    imagePicker.delegate = self;
//
//    myNavigationController *nav = [[myNavigationController alloc]initWithRootViewController:imagePicker];
//    [self presentViewController:nav animated:YES completion:nil];
//    [nav release];
//    [imagePicker release];
//}

//从相册选择的图片数组中提取图片
-(NSArray *)getImagesFromArray:(NSArray *)array
{
    NSMutableArray *imageList = [NSMutableArray array];
    for (NSDictionary *dic in array)
    {
        UIImage *image = [dic objectForKey:UIImagePickerControllerOriginalImage];
        [imageList addObject:image];
    }
    return imageList;
}

//选择相册照片回调
#pragma mark -QBImagePickerControllerDelegate
-(void)imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    if(imagePickerController.allowsMultipleSelection)
    {
        NSArray *mediaInfoArray = [self getImagesFromArray:info];
        
        if(_delegate && [_delegate respondsToSelector:@selector(didSelectImages:)])
        {
            [_delegate didSelectImages:mediaInfoArray];
        }
    }
    
    [imagePickerController dismissViewControllerAnimated:NO completion:^{
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    
}

-(void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
    
    //开始捕抓图像
    [self.captureSession startRunning];
}

#pragma mark -UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.selectWatermarkIndex = page;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //隐藏状态栏
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.delegate = nil;
    
    self.cameraView = nil; [_cameraView release];
    self.overlayWatermarkView = nil; [_overlayWatermarkView release];
    self.flashBtn = nil; [_flashBtn release];
    self.switchBtn = nil; [_switchBtn release];
    self.cameraBtn = nil; [_cameraBtn release];
    
    self.captureSession = nil; [_captureSession release];
    self.previewLayer = nil; [_previewLayer release];
    self.device = nil; [_device release];
    self.input = nil; [_input release];
    self.output = nil; [_output release];
    
    //    self.watermarks = nil; [_watermarks release];
    self.shootImage = nil; [_shootImage release];
    self.resultImage = nil; [_resultImage release];
    
    [super dealloc];
}

@end
