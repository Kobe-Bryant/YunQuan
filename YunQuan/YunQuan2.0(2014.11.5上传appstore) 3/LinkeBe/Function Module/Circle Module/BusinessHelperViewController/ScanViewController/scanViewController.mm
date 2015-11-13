//
//  scanViewController.m
//  myBarCode
//
//  Created by lai yun on 13-1-18.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "scanViewController.h"
#import "scanResultViewController.h"
#import <QRCodeReader.h>
#import <UniversalResultParser.h>
#import <ParsedResult.h>
#import <ResultAction.h>
#import "OpenUrlAction.h"
#import "scanHistoryViewController.h"
#import "Scan_history_model.h"
#import "UIViewController+NavigationBar.h"
#import "MobClick.h"

@interface scanViewController ()

@end

@implementation scanViewController

@synthesize loadingImageView;
@synthesize widController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = RGBACOLOR(232, 237, 241, 1);
        
    CGFloat fixHeight = self.view.frame.size.height < 548 ? -44.0f : 0.0f;
    
    UIImage *loadingImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"yunpai_start_bg" ofType:@"png"]];
    UIImageView *tempLoadingImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f , fixHeight , loadingImage.size.width , loadingImage.size.height)];
    tempLoadingImageView.image = loadingImage;
    [loadingImage release];
    self.loadingImageView = tempLoadingImageView;
    [self.view addSubview:self.loadingImageView];
    [tempLoadingImageView release];
    
}

- (void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    self.loadingImageView.hidden = NO;
    [MobClick beginLogPageView:@"ScanViewPage"];

}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    ZXingWidgetController *tempWidController = [[ZXingWidgetController alloc] initWithDelegate:self OneDMode:NO];  
    QRCodeReader *qrcodeReader = [[QRCodeReader alloc] init];  
    NSSet *readers = [[NSSet alloc ] initWithObjects:qrcodeReader,nil];  
    [qrcodeReader release];  
    tempWidController.readers = readers;  
    [readers release];  
    NSBundle *mainBundle = [NSBundle mainBundle];  
////    aiff
    tempWidController.soundToPlay =[NSURL fileURLWithPath:[mainBundle pathForResource:@"beep-beep" ofType:@"aiff"] isDirectory:NO];
    self.widController = tempWidController;
    //[self presentModalViewController:self.widController animated:NO];
    [self.view addSubview:self.widController.view];
    [tempWidController release];

}

-(void) viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    [MobClick endLogPageView:@"ScanViewPage"];

}

#pragma mark -
#pragma mark 扫描委托

//摄像头启动后事件 
- (void)zxingControllerDidStartRunning:(ZXingWidgetController*)controller {
    
    self.loadingImageView.hidden = YES;
    
    //loading 开场动画
    CGRect topLoadingFrame = controller.overlayView.topLoadingImageView.frame;
    CGRect bottomeLoadingFrame = controller.overlayView.bottomLoadingImageView.frame;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         
                         controller.overlayView.topLoadingImageView.frame = CGRectMake(0.0f , controller.overlayView.topLoadingImageView.frame.origin.y - controller.overlayView.topLoadingImageView.frame.size.height , controller.overlayView.topLoadingImageView.frame.size.width , controller.overlayView.topLoadingImageView.frame.size.height);
                         
                         controller.overlayView.bottomLoadingImageView.frame = CGRectMake(0.0f , controller.overlayView.bottomLoadingImageView.frame.origin.y + controller.overlayView.bottomLoadingImageView.frame.size.height , controller.overlayView.bottomLoadingImageView.frame.size.width , controller.overlayView.bottomLoadingImageView.frame.size.height);
                         
                         
                     } completion:^(BOOL finished){
                         controller.overlayView.topLoadingImageView.hidden = YES;
                         controller.overlayView.bottomLoadingImageView.hidden = YES;
                         controller.overlayView.topLoadingImageView.frame = topLoadingFrame;
                         controller.overlayView.bottomLoadingImageView.frame = bottomeLoadingFrame;
                     }
     ];
    
}

//正常扫描退出事件  
- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result {
    
    //震动接口
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    ParsedResult *pResult = [UniversalResultParser parsedResultForString:result];
    
    //如果是云来的网址直接跳转
    if ([pResult.actions count] > 0)
    {
        ResultAction *resultActions = [[pResult actions] objectAtIndex:0];
        if([resultActions isMemberOfClass:[OpenUrlAction class]])
        {
            //识别到云来的网址 直接打开
            NSString *reuqestString = [NSString stringWithFormat:@"%@",result];
            NSString *yunlaiString = @"yunlai.cn";
            if ([reuqestString rangeOfString:yunlaiString options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                NSString *typeString = @"网页";
                NSString *info = [pResult stringForDisplay];
                
                if (result.length > 0 && info.length > 0)
                {
                    //当前时间
                    NSTimeInterval cTime = [[NSDate date] timeIntervalSince1970];
                    long long int currentTime = (long long int)cTime;
                    NSNumber *time = [NSNumber numberWithInt: currentTime];
                    
                    NSDictionary *scanHistoryDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    typeString,@"type",
                                                    info,@"info",
                                                    result,@"result",
                                                    time,@"created",
                                                    nil];
                    Scan_history_model *scanHistoryMod = [[Scan_history_model alloc] init];
                    
                    //插入数据
                    [scanHistoryMod insertDB:scanHistoryDic];
                    
                    //保证数据只有20条
                    scanHistoryMod.orderBy = @"created";
                    scanHistoryMod.orderType = @"desc";
                    NSMutableArray *historyItems = [scanHistoryMod getList];
                    for (int i = [historyItems count] - 1; i > 19; i--)
                    {
                        NSDictionary *historyDic = [historyItems objectAtIndex:i];
                        NSString *historyId = [historyDic objectForKey:@"id"];
                        
                        scanHistoryMod.where = [NSString stringWithFormat:@"id = %@",historyId];
                        [scanHistoryMod deleteDBdata];
                    }
                    
                    [scanHistoryMod release];
                }
                
                [resultActions performActionWithController:self shouldConfirm:NO];
                
                /* 这里修改为 自带浏览器打开
                browserViewController *browser = [[browserViewController alloc] init];
                browser.url = result;
                [self.navigationController pushViewController:browser animated:YES];
                [browser release];
                 */
                return;
            }
        }
    }
    
    scanResultViewController *scanResultView = [[scanResultViewController alloc] init];
    scanResultView.result = pResult;
    scanResultView.resultString = result;
    scanResultView.dataFromScan = YES;
    [self.navigationController pushViewController:scanResultView animated:YES];
    [scanResultView release];
    
}  
//扫描界面退出按钮事件  
- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {  
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

//扫描界面历史记录按钮事件  
- (void)zxingControllerGoHistory:(ZXingWidgetController*)controller {  
    
    scanHistoryViewController *scanHistoryView = [[scanHistoryViewController alloc] init];
    [self.navigationController pushViewController:scanHistoryView animated:YES];
    [scanHistoryView release];
    
}

- (void)goHome
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark 当前view的截屏
- (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.loadingImageView = nil;
    self.widController = nil;
}

- (void)dealloc {
	[self.loadingImageView release];
    [self.widController release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return NO;
}

@end
