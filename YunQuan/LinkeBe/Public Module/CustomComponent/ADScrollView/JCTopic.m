//
//  JCTopic.m
//  PSCollectionViewDemo
//
//  Created by vincent on 14-1-7.
//
//

#import "JCTopic.h"
#import "UIImageView+WebCache.h"
#import "Global.h"

@implementation JCTopic
@synthesize JCdelegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        [self setSelf];
    }
    return self;
}
-(void)setSelf{
    self.pagingEnabled = YES;
    self.scrollEnabled = YES;
    self.delegate = self;
    self.alwaysBounceHorizontal = YES;
    self.alwaysBounceVertical = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.backgroundColor = [UIColor clearColor];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self setSelf];
    
    // Drawing code
}
-(void)upDate{
    NSMutableArray * tempImageArray = [[[NSMutableArray alloc]init] autorelease];
    if ([self.pics count] > 1) {
        self.scrollEnabled = YES;
        [tempImageArray addObject:[self.pics lastObject]];
        for (id obj in self.pics) {
            [tempImageArray addObject:obj];
        }
        [tempImageArray addObject:[self.pics objectAtIndex:0]];
        self.pics = Nil;
        self.pics = tempImageArray;
        
        int i = 0;
        for (id obj in self.pics) {
            pic= Nil;
            pic = [UIButton buttonWithType:UIButtonTypeCustom];
            pic.imageView.contentMode = UIViewContentModeTop;
            [pic setFrame:CGRectMake(i*self.frame.size.width,0, self.frame.size.width, self.frame.size.height)];
            
            UIImageView * tempImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, pic.frame.size.width, pic.frame.size.height)];
            tempImage.contentMode = UIViewContentModeScaleAspectFill;
            [tempImage setClipsToBounds:YES];
            
            [tempImage setImage:[UIImage imageNamed:obj]];

            [pic addSubview:tempImage];
            [tempImage release];
            [pic setBackgroundColor:[UIColor clearColor]];
            pic.tag = i;
            [pic addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:pic];
            i ++;
        }
        [self setContentSize:CGSizeMake(self.frame.size.width*[self.pics count], self.frame.size.height)];
        [self setContentOffset:CGPointMake(self.frame.size.width, 0) animated:NO];
        
        if (scrollTimer) {
            [scrollTimer invalidate];
            scrollTimer = nil;
        }
        if ([self.pics count]>3) {
            scrollTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(scrollTopic) userInfo:nil repeats:YES];
        }
    }else if(self.pics.count == 1){
        
        NSDictionary *dic = [self.pics firstObject];
        
        UIImageView * tempImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        tempImage.contentMode = UIViewContentModeScaleAspectFill;
        [tempImage setClipsToBounds:YES];
        if ([[dic objectForKey:@"isLoc"]boolValue]) {
            [tempImage setImage:[dic objectForKey:@"pic"]];
        }else{
            [tempImage setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"pic"]] placeholderImage:[UIImage imageNamed:@"login_before_image.png"]];
        }
        [self addSubview:tempImage];
        [tempImage release];
        self.scrollEnabled = NO;
    }
}

-(void)click:(id)sender{
    [JCdelegate didClick:[sender tag]];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat Width=self.frame.size.width;
    if (scrollView.contentOffset.x == self.frame.size.width) {
        flag = YES;
    }
    if (flag) {
        if (scrollView.contentOffset.x <= 0) {
            [self setContentOffset:CGPointMake(Width*([self.pics count]-2), 0) animated:NO];
        }else if (scrollView.contentOffset.x >= Width*([self.pics count]-1)) {
            [self setContentOffset:CGPointMake(self.frame.size.width, 0) animated:NO];
        }
    }
    currentPage = scrollView.contentOffset.x/self.frame.size.width-1;
    [JCdelegate currentPage:currentPage total:[self.pics count]-2];
    scrollTopicFlag = currentPage+2==2?2:currentPage+2;

}
-(void)scrollTopic{
    [self setContentOffset:CGPointMake(self.frame.size.width*scrollTopicFlag, 0) animated:YES];
    
    if (scrollTopicFlag > [self.pics count]) {
        scrollTopicFlag = 1;
    }else {
        scrollTopicFlag++;
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([self.pics count] >3) {
        scrollTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(scrollTopic) userInfo:nil repeats:YES];
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollTimer) {
        [scrollTimer invalidate];
        scrollTimer = nil;
    }
    
}
-(void)releaseTimer{
    if (scrollTimer) {
        [scrollTimer invalidate];
        scrollTimer = nil;
        
    }
}
- (void)setupTimer{
    if (scrollTimer) {
        [scrollTimer invalidate];
        scrollTimer = nil;
        
    }
    if ([self.pics count]>3) {
        scrollTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(scrollTopic) userInfo:nil repeats:YES];
    }
}

@end
