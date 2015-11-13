//
//  FlashScreenPictureView.m
//  LinkeBe
//
//  Created by yunlai on 14-9-22.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "FlashScreenPictureView.h"
#import "NetManager.h"
#import "LinkedBeHttpRequest.h"

@implementation FlashScreenPictureView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //闪屏效果
        screenView = [[UIView alloc] initWithFrame:self.window.frame];
        changeImage = [[UIImageView alloc] initWithFrame:self.window.frame];
        //从文件夹取出图片，是uiimage的格式（如果是url会有延迟）
        NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,                                                                          NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath2 = [documentsDirectory stringByAppendingPathComponent:[[NSUserDefaults standardUserDefaults] stringForKey:@"ScreenImageUrl"]];
        UIImage *img = [UIImage imageWithContentsOfFile:filePath2];
        [changeImage setImage:img];
        
        [screenView addSubview:changeImage];
        [self addSubview:screenView];
        
        [self performSelector:@selector(changeScreen) withObject:nil afterDelay:1.0]; //1秒后执行TheAnimation
    }
    return self;
}

- (void)changeScreen {
    CATransition *animation = [CATransition animation]; //场转动画
    animation.duration = 0.7 ;  // 动画持续时间(秒)
    animation.timingFunction = UIViewAnimationCurveEaseInOut; //慢进慢出,从头到尾的流畅度
    animation.type = kCATransitionFade;//淡入淡出效果
    [[screenView layer] addAnimation:animation forKey:@"animation"];//要令一个转场生效，组要将动画添加到将要变为动画视图所附着的图层
    
    [self performSelector:@selector(resginScreen) withObject:nil afterDelay:1.0];//1秒后执行TheAnimation
    
}

//闪屏消失
- (void)resginScreen {
    //闪屏消失时移除当前图片闪屏
    [screenView removeFromSuperview];
}


//闪屏网络请求
-(void) changeScreenImage{
    if (_request == nil) {
        _request = [LinkedBeHttpRequest shareInstance];
    }
    
    [_request requsetOrgSplash:self parameterDictionary:nil parameterArray:nil requestType:LinkedBe_GET];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//请求回调
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
        switch (commandid) {
            case LinkedBe_ORG_FlashScreen:
            {
                // 判断是否有网络
                NSDictionary * resultDic = [resultArray firstObject];
                if (resultDic) {
                    int resultInt = [[resultDic objectForKey:@"rcode"] intValue];
                    if (resultInt) {
                        //线程加载图片，以免界面卡死
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            if ([[resultDic objectForKey:@"state"] intValue]==0) {
                                //删除闪屏根目录
                                NSFileManager *fileManager = [NSFileManager defaultManager];
                                NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,                                                                          NSUserDomainMask, YES);
                                NSString *documentsDirectory = [paths objectAtIndex:0];
                                NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[[NSUserDefaults standardUserDefaults] stringForKey:@"ScreenImageUrl"]];
                                if ([filePath isEqualToString:documentsDirectory]) {
                                    return;
                                }
                                [fileManager removeItemAtPath:filePath error:nil];
                            }else{
                                NSString *path = [resultDic objectForKey:@"pic_url"];
                                //此处首先指定了图片存取路径（默认写到应用程序沙盒中）
                                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
                                
                                //取出图片名
                                NSArray* arr = [path componentsSeparatedByString:@"/"];
                                NSString* imgName = [arr lastObject];
                                
                                //并给文件起个文件名，以url作为图片名
                                NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:imgName];
                                
                                BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
                                if (blHave) {
                                    
                                }else{
                                    NSURL *url = [NSURL URLWithString:path];
                                    NSData *data = [NSData dataWithContentsOfURL:url]; //url 转化为data格式
                                    
                                    //此处的方法是将图片写到Documents文件中
                                    BOOL writeSuccess = [data writeToFile:uniquePath atomically:YES];
                                    NSLog(@"--write:%d--",writeSuccess);
                                }
                                //保存图片地址
                                [[NSUserDefaults standardUserDefaults] setValue:imgName forKey:@"ScreenImageUrl"];
                            }
                            //保存个性化闪屏的ts
                            [[NSUserDefaults standardUserDefaults] setValue:[resultDic objectForKey:@"ts"] forKey:@"ScreenImageUrlTS"];
                        });
                    }
                }
            }
                break;
            default:
                break;
        }
}
-(void)dealloc{
    RELEASE_SAFE(changeImage);
    RELEASE_SAFE(screenView);
    [super dealloc];
}
@end
