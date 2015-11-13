//
//  faceView.m
//  myFace
//
//  Created by siphp on 13-9-12.
//
//

#import "faceView.h"
#import "faceBarButton.h"
#import "emoji.h"
#import <QuartzCore/QuartzCore.h>

@implementation faceView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.backgroundColor = [UIColor whiteColor];
    
    //底部切换bar
    barView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , self.frame.size.height - 36.0f , self.frame.size.width , 36.0f)];
    barView.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.0];
    [self addSubview:barView];

    [self performSelector:@selector(showCustomFaceScrollView) withObject:nil afterDelay:0.0f];
    
    //创建按钮
    NSArray *tabArray = [NSArray arrayWithObjects:@"",@"",@"",@"",@"发送",nil];;
    NSArray *tabPicNameArray = [NSArray arrayWithObjects:@"Expression_1@2x.png",@"",@"",@"",@"",nil];
	int viewCount = [tabArray count];
	double _width = self.frame.size.width / viewCount;
	
	for (int i = 0; i < viewCount; i++) {
		UIButton *btn = [faceBarButton buttonWithType:UIButtonTypeCustom];
		btn.frame = CGRectMake(i*_width, 0.0f , _width, 36.0f);
		[btn addTarget:self action:@selector(selectedTab:) forControlEvents:UIControlEventTouchUpInside];
		btn.tag = i+80000;
        
//        //未选中图片
        NSString *normalImgString = [tabPicNameArray objectAtIndex:i];
        if (![normalImgString isEqualToString:@""]) {
            UIImage * btnImg = [UIImage imageNamed:normalImgString];
            [btn setImage:btnImg forState:UIControlStateNormal];
        }
        
        //字体居中跟大小
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        
        //未选中文字
        [btn setTitle:[tabArray objectAtIndex:i] forState:UIControlStateNormal];
        
        //选中后文字
        [btn setTitle:[tabArray objectAtIndex:i] forState:UIControlStateSelected];
        
        //未选中文字颜色
        UIColor *colorUnselectedTabBar = [UIColor grayColor];
        [btn setTitleColor:colorUnselectedTabBar forState:UIControlStateNormal];
        
        //选中后文字颜色
        UIColor *colorSelectedTabBar = [UIColor orangeColor];
        [btn setTitleColor:colorSelectedTabBar forState:UIControlStateSelected];
        [btn setTitleColor:colorSelectedTabBar forState:UIControlStateHighlighted];
        
        if (i== viewCount -1) {
            btn.backgroundColor = BLUECOLOR;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
		[barView addSubview:btn];
	}
    
    //默认选中第一个
    currentSelectedIndex = 80000;
    UIButton *button = (UIButton*)[self viewWithTag:currentSelectedIndex];
    [self selectedTab:button];
}

-(void) sendClick{
    
}

//点击
- (void)selectedTab:(UIButton *)button
{
    //取消上一次选中
    UIButton *currentSelectedButton = (UIButton*)[self viewWithTag:currentSelectedIndex];
    if ([currentSelectedButton isKindOfClass:[UIButton class]])
    {
        [currentSelectedButton setSelected:NO];
    }
    
    //设置本次选中
    [button setSelected:YES];
    currentSelectedIndex = button.tag;
    
    int selectedIndex = currentSelectedIndex - 80000;
    switch (selectedIndex)
    {
		case 0:
        {
			[self performSelector:@selector(showCustomFaceScrollView) withObject:nil afterDelay:0.0f];
        }
			break;
		case 1:
        {
			[self performSelector:@selector(showSysFaceScrollView) withObject:nil afterDelay:0.0f];
		}
            break;
        case 2:
        {
            [self performSelector:@selector(showStringFaceScrollView) withObject:nil afterDelay:0.0f];
            break;
		}
        case 3:
        {
            if ([delegate respondsToSelector:@selector(addEmotionClick)]) {
                [delegate addEmotionClick];
            }
            break;
        }
        case 4:
        {
            if ([delegate respondsToSelector:@selector(sendbuttonClick)]) {
                [delegate sendbuttonClick];
            }
            
            break;
        }
        default:
			break;
	}
}

-(void)showCustomFaceScrollView
{
    sysFaceScrollView.hidden = YES;
    sysFacePageControll.hidden = YES;
    stringFaceScrollView.hidden = YES;
    stringFacePageControll.hidden = YES;
    
    if (customFaceScrollView == nil)
    {
        customFaceScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , self.frame.size.width, self.frame.size.height - barView.frame.size.height)];
        customFaceScrollView.contentSize = CGSizeMake(customFaceScrollView.frame.size.width, customFaceScrollView.frame.size.height);
        customFaceScrollView.clipsToBounds = NO;
        customFaceScrollView.pagingEnabled = YES;
        customFaceScrollView.delegate = self;
        customFaceScrollView.showsHorizontalScrollIndicator = NO;
        customFaceScrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:customFaceScrollView];
        
        int faceCount = 100;    
        int pageCount = 20;     //一页多少表情
        int rowCount = 7;       //一行多少个表情
        int row = 3;
        int residueNum = 0;     //余数
        int divisibleNum = 0;   //整除数
        
        CGFloat imgWidth = 30.0f;   //表情图片宽度
        CGFloat imgHeight = 30.0f;  //表情图片高度
        
        CGFloat buttonViewWidth = 320.0f - 40.0f;   //表情容器宽度
        CGFloat buttonViewHeight = 120.0f;          //表情容器高度
        
        CGFloat fixMarginWidth = imgWidth+((buttonViewWidth - (rowCount*imgWidth))/(rowCount-1));
        CGFloat fixMarginHeight = imgHeight+((buttonViewHeight - (row*imgHeight))/(row-1));
        
        
        for (int i=0 ; i < faceCount; i++)
        {
            residueNum = i%pageCount;
            divisibleNum = i/pageCount;
            if (residueNum == 0)
            {
                UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake( (customFaceScrollView.frame.size.width) * divisibleNum + 20.0f , 20.0f , buttonViewWidth, buttonViewHeight)];
                buttonView.tag = 10000 + divisibleNum;
                buttonView.backgroundColor = [UIColor clearColor];  // 调试 设置一下颜色
                [customFaceScrollView addSubview:buttonView];
                [buttonView release];
                
                customFaceScrollView.contentSize = CGSizeMake(customFaceScrollView.frame.size.width*(divisibleNum+1), customFaceScrollView.frame.size.height);
                
                //最后添加删除按钮
                UIButton *delFaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
                delFaceButton.frame = CGRectMake( (rowCount-1)*fixMarginWidth , (row-1)*fixMarginHeight , imgWidth , imgWidth);
                [delFaceButton addTarget:self action:@selector(delFace) forControlEvents:UIControlEventTouchUpInside];
                [buttonView addSubview:delFaceButton];
                
                UIImage *delFaceButtonImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DeleteEmoticonBtn@2x" ofType:@"png"]];
                [delFaceButton setBackgroundImage:delFaceButtonImage forState:UIControlStateNormal];
                [delFaceButtonImage release];
                
            }
            
            UIView *buttonView = (UIView *)[customFaceScrollView viewWithTag:10000+divisibleNum];

            UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            faceButton.frame = CGRectMake( (residueNum%rowCount)*fixMarginWidth , (residueNum/rowCount)*fixMarginHeight , imgWidth , imgHeight);
            [faceButton addTarget:self action:@selector(selectedCustomFaceButton:) forControlEvents:UIControlEventTouchUpInside];
            faceButton.tag = i+20000;
            
            UIImage *faceButtonImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Expression_%d@2x",i+1] ofType:@"png"]];
            [faceButton setBackgroundImage:faceButtonImage forState:UIControlStateNormal];
            [faceButtonImage release];
            
            [buttonView addSubview:faceButton];
            
        }
        
        //底部page
        if (faceCount > 1)
        {
            int pageUnitWidth = 20.0f;
            CGFloat pageControllWidth = pageUnitWidth * faceCount/pageCount;
            CGFloat pageControllHeight = 30.0f;
            if(customFacePageControll == nil)
            {
                customFacePageControll = [[UIPageControl alloc] initWithFrame:CGRectMake(self.center.x - (pageControllWidth/2.0), CGRectGetMaxY(customFaceScrollView.frame) - pageControllHeight, pageControllWidth, pageControllHeight)];
                [customFacePageControll addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
                [self addSubview:customFacePageControll];
            }
            customFacePageControll.numberOfPages = ceil((CGFloat)faceCount/(CGFloat)pageCount);
            customFacePageControll.currentPage = 0;
            if([customFacePageControll respondsToSelector:@selector(setPageIndicatorTintColor:)])
            {
                customFacePageControll.pageIndicatorTintColor = [UIColor colorWithRed:0.90f green:0.90f blue:0.90f alpha:1.0];
            }
            if([customFacePageControll respondsToSelector:@selector(setCurrentPageIndicatorTintColor:)])
            {
                customFacePageControll.currentPageIndicatorTintColor = [UIColor colorWithRed:0.60f green:0.60f blue:0.60f alpha:1.0];
            }
        }
    }
    
    customFaceScrollView.hidden = NO;
    customFacePageControll.hidden = NO;
}

-(void)showSysFaceScrollView
{
    customFaceScrollView.hidden = YES;
    customFacePageControll.hidden = YES;
    stringFaceScrollView.hidden = YES;
    stringFacePageControll.hidden = YES;
    
    if (sysFaceScrollView == nil)
    {
        sysFaceScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , self.frame.size.width, self.frame.size.height - barView.frame.size.height)];
        sysFaceScrollView.contentSize = CGSizeMake(sysFaceScrollView.frame.size.width, sysFaceScrollView.frame.size.height);
        sysFaceScrollView.clipsToBounds = NO;
        sysFaceScrollView.pagingEnabled = YES;
        sysFaceScrollView.delegate = self;
        sysFaceScrollView.showsHorizontalScrollIndicator = NO;
        sysFaceScrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:sysFaceScrollView];
        
        NSMutableArray *emojiArray = [emoji getEmoji];
        int faceCount = [emojiArray count];
        
        int pageCount = 27;     //一页多少表情
        int rowCount = 7;       //一行多少个表情
        int row = 4;
        int residueNum = 0;     //余数
        int divisibleNum = 0;   //整除数
        
        CGFloat imgWidth = 25.0f;   //表情图片宽度
        CGFloat imgHeight = 25.0f;  //表情图片高度
        
        CGFloat buttonViewWidth = 320.0f - 40.0f;   //表情容器宽度
        CGFloat buttonViewHeight = 130.0f;          //表情容器高度
        
        CGFloat fixMarginWidth = imgWidth+((buttonViewWidth - (rowCount*imgWidth))/(rowCount-1));
        CGFloat fixMarginHeight = imgHeight+((buttonViewHeight - (row*imgHeight))/(row-1));
        
        for (int i=0 ; i < faceCount; i++)
        {
            residueNum = i%pageCount;
            divisibleNum = i/pageCount;
            if (residueNum == 0)
            {
                UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake( (sysFaceScrollView.frame.size.width) * divisibleNum + 20.0f , 20.0f , buttonViewWidth, buttonViewHeight)];
                buttonView.tag = 10000 + divisibleNum;
                buttonView.backgroundColor = [UIColor clearColor];  // 调试 设置一下颜色
                [sysFaceScrollView addSubview:buttonView];
                [buttonView release];
                
                sysFaceScrollView.contentSize = CGSizeMake(sysFaceScrollView.frame.size.width*(divisibleNum+1), sysFaceScrollView.frame.size.height);
                
                //最后添加删除按钮 
                UIButton *delFaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
                delFaceButton.frame = CGRectMake( (rowCount-1)*fixMarginWidth , (row-1)*fixMarginHeight , imgWidth , imgWidth);
                [delFaceButton addTarget:self action:@selector(delFace) forControlEvents:UIControlEventTouchUpInside];
                [buttonView addSubview:delFaceButton];
                
                UIImage *delFaceButtonImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DeleteEmoticonBtn@2x" ofType:@"png"]];
                [delFaceButton setBackgroundImage:delFaceButtonImage forState:UIControlStateNormal];
                [delFaceButtonImage release];
                
            }
            
            UIView *buttonView = (UIView *)[sysFaceScrollView viewWithTag:10000+divisibleNum];
            
            UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            faceButton.frame = CGRectMake( (residueNum%rowCount)*fixMarginWidth , (residueNum/rowCount)*fixMarginHeight , imgWidth , imgHeight);
            [faceButton addTarget:self action:@selector(selectedSysFaceButton:) forControlEvents:UIControlEventTouchUpInside];
            faceButton.tag = i+20000;
            
            faceButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            faceButton.titleLabel.font = [UIFont systemFontOfSize:18.0f]; //[UIFont fontWithName:@"AppleColorEmoji" size:22.0f];
            [faceButton setTitle:[emojiArray objectAtIndex:i] forState:UIControlStateNormal];
            
            [buttonView addSubview:faceButton];
            
        }
        
        //底部page
        if (faceCount > 1)
        {
            int pageUnitWidth = 20.0f;
            CGFloat pageControllWidth = pageUnitWidth * faceCount/pageCount;
            CGFloat pageControllHeight = 20.0f;
            if(sysFacePageControll == nil)
            {
                sysFacePageControll = [[UIPageControl alloc] initWithFrame:CGRectMake(self.center.x - (pageControllWidth/2.0), CGRectGetMaxY(sysFaceScrollView.frame) - pageControllHeight, pageControllWidth, pageControllHeight)];
                [sysFacePageControll addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
                [self addSubview:sysFacePageControll];
            }
            sysFacePageControll.numberOfPages = ceil((CGFloat)faceCount/(CGFloat)pageCount);
            sysFacePageControll.currentPage = 0;
            if([sysFacePageControll respondsToSelector:@selector(setPageIndicatorTintColor:)])
            {
                sysFacePageControll.pageIndicatorTintColor = [UIColor colorWithRed:0.90f green:0.90f blue:0.90f alpha:1.0];
            }
            if([sysFacePageControll respondsToSelector:@selector(setCurrentPageIndicatorTintColor:)])
            {
                sysFacePageControll.currentPageIndicatorTintColor = [UIColor colorWithRed:0.60f green:0.60f blue:0.60f alpha:1.0];
            }
        }
    }
    
    sysFaceScrollView.hidden = NO;
    sysFacePageControll.hidden = NO;
}

-(void)showStringFaceScrollView
{
    customFaceScrollView.hidden = YES;
    customFacePageControll.hidden = YES;
    sysFaceScrollView.hidden = YES;
    sysFacePageControll.hidden = YES;
    
    if (stringFaceScrollView == nil)
    {
        stringFaceScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , self.frame.size.width, self.frame.size.height - barView.frame.size.height)];
        stringFaceScrollView.contentSize = CGSizeMake(stringFaceScrollView.frame.size.width, stringFaceScrollView.frame.size.height);
        stringFaceScrollView.clipsToBounds = NO;
        stringFaceScrollView.pagingEnabled = YES;
        stringFaceScrollView.delegate = self;
        stringFaceScrollView.showsHorizontalScrollIndicator = NO;
        stringFaceScrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:stringFaceScrollView];
        
        NSMutableArray *emojiArray = [emoji getStringEmoji];
        int faceCount = [emojiArray count];
        
        int pageCount = 16;     //一页多少表情
        int rowCount = 4;       //一行多少个表情
        int row = 4;
        int residueNum = 0;     //余数
        int divisibleNum = 0;   //整除数
        
        CGFloat imgWidth = 80.0f;   //表情图片宽度
        CGFloat imgHeight = 40.0f;  //表情图片高度
        
        CGFloat buttonViewWidth = 320.0f;   //表情容器宽度
        CGFloat buttonViewHeight = 160.0f;          //表情容器高度
        
        CGFloat fixMarginWidth = imgWidth+((buttonViewWidth - (rowCount*imgWidth))/(rowCount-1));
        CGFloat fixMarginHeight = imgHeight+((buttonViewHeight - (row*imgHeight))/(row-1));
        
        for (int i=0 ; i < faceCount; i++)
        {
            residueNum = i%pageCount;
            divisibleNum = i/pageCount;
            if (residueNum == 0)
            {
                UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake( (stringFaceScrollView.frame.size.width) * divisibleNum , 0.0f , buttonViewWidth, buttonViewHeight)];
                buttonView.tag = 10000 + divisibleNum;
                buttonView.backgroundColor = [UIColor clearColor];  // 调试 设置一下颜色
                [stringFaceScrollView addSubview:buttonView];
                [buttonView release];
                
                stringFaceScrollView.contentSize = CGSizeMake(stringFaceScrollView.frame.size.width*(divisibleNum+1), stringFaceScrollView.frame.size.height);
                
            }
            
            UIView *buttonView = (UIView *)[stringFaceScrollView viewWithTag:10000+divisibleNum];
            
            UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            faceButton.frame = CGRectMake( (residueNum%rowCount)*fixMarginWidth , (residueNum/rowCount)*fixMarginHeight , imgWidth , imgHeight);
            [faceButton addTarget:self action:@selector(selectedStringFaceButton:) forControlEvents:UIControlEventTouchUpInside];
            faceButton.tag = i+20000;
            
            faceButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            faceButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
            [faceButton setTitleColor:[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0] forState:UIControlStateNormal];
            [faceButton setTitle:[NSString stringWithFormat:@"%@",[emojiArray objectAtIndex:i]] forState:UIControlStateNormal];
            faceButton.layer.borderWidth = 0.5f;
            faceButton.layer.borderColor = [[UIColor colorWithRed:0.90f green:0.90f blue:0.90f alpha:1.0] CGColor];
            
            [buttonView addSubview:faceButton];
            
        }
        
        //底部page
        if (faceCount > 1)
        {
            int pageUnitWidth = 20.0f;
            CGFloat pageControllWidth = pageUnitWidth * faceCount/pageCount;
            CGFloat pageControllHeight = 20.0f;
            if(stringFacePageControll == nil)
            {
                stringFacePageControll = [[UIPageControl alloc] initWithFrame:CGRectMake(self.center.x - (pageControllWidth/2.0), CGRectGetMaxY(stringFaceScrollView.frame) - pageControllHeight, pageControllWidth, pageControllHeight)];
                [stringFacePageControll addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
                [self addSubview:stringFacePageControll];
            }
            stringFacePageControll.numberOfPages = ceil((CGFloat)faceCount/(CGFloat)pageCount);
            stringFacePageControll.currentPage = 0;
            if([stringFacePageControll respondsToSelector:@selector(setPageIndicatorTintColor:)])
            {
                stringFacePageControll.pageIndicatorTintColor = [UIColor colorWithRed:0.90f green:0.90f blue:0.90f alpha:1.0];
            }
            if([stringFacePageControll respondsToSelector:@selector(setCurrentPageIndicatorTintColor:)])
            {
                stringFacePageControll.currentPageIndicatorTintColor = [UIColor colorWithRed:0.60f green:0.60f blue:0.60f alpha:1.0];
            }
        }
    }
    
    stringFaceScrollView.hidden = NO;
    stringFacePageControll.hidden = NO;
}


- (void) pageTurn: (UIPageControl *)pageControl
{
	int whichPage = pageControl.currentPage;
	
    if (pageControl == customFacePageControll)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        customFaceScrollView.contentOffset = CGPointMake(customFaceScrollView.frame.size.width * whichPage, 0.0f);
        [UIView commitAnimations];
    }
    else if(pageControl == sysFacePageControll)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        sysFaceScrollView.contentOffset = CGPointMake(sysFaceScrollView.frame.size.width * whichPage, 0.0f);
        [UIView commitAnimations];
    }
    else if(pageControl == stringFacePageControll)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        stringFaceScrollView.contentOffset = CGPointMake(stringFaceScrollView.frame.size.width * whichPage, 0.0f);
        [UIView commitAnimations];
    }
	
}

//自定义按钮选中
-(void)selectedCustomFaceButton:(UIButton *)sender
{
    int index = sender.tag - 20000;
    if ([delegate respondsToSelector:@selector(faceView: didSelectAtString:)])
    {
        NSString *faceImageName = [NSString stringWithFormat:@"Expression_%d@2x",index+1];
        NSArray *faceStringArray = [[emoji getCustomEmoji] allKeysForObject:faceImageName];
        if ([faceStringArray count] > 0)
        {
            NSString *faceString = [faceStringArray lastObject];
            [delegate faceView:self didSelectAtString:faceString];
        }
    }
}

//系统按钮选中
-(void)selectedSysFaceButton:(UIButton *)sender
{
    //int index = sender.tag - 20000;
    if ([delegate respondsToSelector:@selector(faceView: didSelectAtString:)])
    {
        NSString *faceString = sender.titleLabel.text;
        [delegate faceView:self didSelectAtString:faceString];
    }
}

//符号按钮选中
-(void)selectedStringFaceButton:(UIButton *)sender
{
    //int index = sender.tag - 20000;
    if ([delegate respondsToSelector:@selector(faceView: didSelectAtString:)])
    {
        NSString *faceString = sender.titleLabel.text;
        [delegate faceView:self didSelectAtString:faceString];
    }
}

//删除
-(void)delFace
{
    if ([delegate respondsToSelector:@selector(delFaceString)])
    {
        [delegate delFaceString];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView == customFaceScrollView)
    {
        CGPoint offset = scrollView.contentOffset;
        customFacePageControll.currentPage = offset.x / customFaceScrollView.frame.size.width;
    }
    else if(scrollView == sysFaceScrollView)
    {
        CGPoint offset = scrollView.contentOffset;
        sysFacePageControll.currentPage = offset.x / sysFaceScrollView.frame.size.width;
    }
    else if(scrollView == stringFaceScrollView)
    {
        CGPoint offset = scrollView.contentOffset;
        stringFacePageControll.currentPage = offset.x / stringFaceScrollView.frame.size.width;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) dealloc {
    [barView release];
    [customFaceScrollView release];
    [sysFaceScrollView release];
    [stringFaceScrollView release];
    [customFacePageControll release];
    [sysFacePageControll release];
    [stringFacePageControll release];
    [super dealloc];
}

@end
