//
//  DetailHeadView.m
//  LinkeBe
//
//  Created by yunlai on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "DetailHeadView.h"

#import "Circle_member_model.h"

#define OPTIONVIEWTAG   10000
#define OPTIONPLACEVIEWTAG  20000

@implementation DetailHeadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIView* cardV = [[UIView alloc] initWithFrame:CGRectMake(0, DynamicCardSpace, ScreenWidth - 2*DynamicCardEdge, 80)];
        cardV.backgroundColor = [UIColor whiteColor];
//        cardV.layer.cornerRadius = 2.0;
//        cardV.clipsToBounds = YES;
        
        //边框
//        cardV.layer.borderColor = DynamicCardBordColor.CGColor;
//        cardV.layer.borderWidth = 0.5;
        
        self.cardView = cardV;
        [self addSubview:cardV];
        [cardV release];
    }
    return self;
}

//初始化视图部件
-(void) setUp{
    [self initHead];
    [self initMid];
    [self initButtom];
}

//获取文本高度
-(CGFloat) getTextHeightWith:(NSString*) str{
    CGSize size = [str sizeWithFont:KQLboldSystemFont(13) constrainedToSize:CGSizeMake(ScreenWidth - 2*DynamicCardEdge - 10, 200) lineBreakMode:NSLineBreakByWordWrapping];
    
    return size.height + 20;
}

//初始化中间
-(void) initMid{
    //是否有图片
    BOOL haveImage = YES;
    
    NSArray* picArr = [_dataDic objectForKey:@"picList"];
    if (picArr == nil || picArr.count == 0) {
        haveImage = NO;
    }
    
    //是否有文本
    BOOL haveText = YES;
//    if ([[_dataDic objectForKey:@"title"] length] == 0) {
//        haveText = NO;
//    }

    if ([[_dataDic objectForKey:@"content"] length] == 0) {
        haveText = NO;
    }
    
    //文本框位置
    CGFloat textY = 5;
    //文本框高度
    CGFloat textHeight = 0;
    if (haveText) {
        
        textHeight = [self getTextHeightWith:_textStr];
    }
    
    //我有我要，聚聚，按钮高度,15+45+15
    CGFloat roundBtnHeight = 45;
    
    //midview高度
    CGFloat midHeight = 0;
    
    UIView* midV = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headView.frame), CGRectGetWidth(self.cardView.frame), 0)];
    midV.backgroundColor = [UIColor clearColor];
    self.midView = midV;
    [self.cardView addSubview:midV];
    [midV release];
    
    //添加图片部分
    if (haveImage) {
        textY += DynamicCardImageHeight;
        
        UIScrollView* scrollView = [[UIScrollView alloc] init];
        scrollView.delegate = self;
        scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.cardView.frame), DynamicCardImageHeight);
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        scrollView.bounces = NO;
        scrollView.contentOffset = CGPointMake(0, 0);
        [self.midView addSubview:scrollView];
        
        for (int i = 0; i < picArr.count; i++) {
            //添加图片
            UIImageView* imageV = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.cardView.frame) * i, 0, CGRectGetWidth(self.cardView.frame), DynamicCardImageHeight)];
            imageV.backgroundColor = DynamicCardBackGround;
            [imageV setImageWithURL:[NSURL URLWithString:[picArr objectAtIndex:i]] placeholderImage:nil];
            imageV.contentMode = UIViewContentModeScaleAspectFill;
            imageV.clipsToBounds = YES;
            imageV.userInteractionEnabled = YES;
            imageV.tag = i + 30000;
            [scrollView addSubview:imageV];
            
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(midImgTouch:)];
            [imageV addGestureRecognizer:tap];
            [tap release];
            
            [imageV release];
        }
        
        scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.cardView.frame)*picArr.count, DynamicCardImageHeight);
        
        [scrollView release];
        
        //数字
        UILabel* numLab = [[UILabel alloc] init];
        numLab.frame = CGRectMake(CGRectGetWidth(self.cardView.frame) - 30 - 5, 5, 30, 15);
        numLab.backgroundColor = [UIColor blackColor];
        numLab.alpha = 0.5;
        numLab.textColor = [UIColor whiteColor];
        numLab.textAlignment = NSTextAlignmentCenter;
        numLab.font = KQLboldSystemFont(11);
        numLab.layer.cornerRadius = numLab.frame.size.height/2;
        numLab.layer.masksToBounds = YES;
        
        numLab.text = [NSString stringWithFormat:@"1/%d",picArr.count];
        self.imgNumLab = numLab;
        [self.midView addSubview:numLab];
        [numLab release];
        
        midHeight += DynamicCardImageHeight;
    }
    
    //添加文本部分
    if (haveText) {
        UILabel* textview = [[UILabel alloc] init];
        textview.frame = CGRectMake(5, textY, CGRectGetWidth(self.cardView.frame) - 5*2, textHeight);
        textview.backgroundColor = [UIColor clearColor];
        textview.textColor = DynamicCardTextColor;
        textview.font = KQLboldSystemFont(13);
        textview.lineBreakMode = NSLineBreakByWordWrapping;
        textview.numberOfLines = 0;
        
        textview.text = _textStr;
        
        [self.midView addSubview:textview];
        [textview release];
        
        midHeight += textHeight + 5;
    }
    
    //添加按钮部分
    if (_type != DynamicTypePic) {
        CGFloat btnY = 0;
        
        UIButton* roundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (haveImage) {
            btnY = DynamicCardImageHeight - 15 - roundBtnHeight;
        }else{
            btnY = 15 + textHeight;
        }
        
        roundButton.frame = CGRectMake((CGRectGetWidth(self.cardView.frame) - roundBtnHeight)/2, btnY, roundBtnHeight, roundBtnHeight);
        roundButton.layer.cornerRadius = roundBtnHeight/2;
        
        UIImage* btnImg = nil;
        UIImage* enableImg = nil;
        
        switch (_type) {
            case 1:
            {
                enableImg = IMGREADFILE(DynamicPic_card_party_gray);
                btnImg = IMGREADFILE(DynamicPic_card_party);
            }
                break;
            case 3:
            {
                enableImg = IMGREADFILE(DynamicPic_card_have_gray);
                btnImg = IMGREADFILE(DynamicPic_card_have);
            }
                break;
            case 4:
            {
                enableImg = IMGREADFILE(DynamicPic_card_want_gray);
                btnImg = IMGREADFILE(DynamicPic_card_want);
            }
                break;
            default:
                break;
        }
        
        [roundButton setImage:btnImg forState:UIControlStateNormal];
        [roundButton setImage:enableImg forState:UIControlStateDisabled];
        [roundButton addTarget:self action:@selector(roundBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.midView addSubview:roundButton];
        
        if ([[_dataDic objectForKey:@"userId"] intValue] == [[UserModel shareUser].user_id intValue]) {
            roundButton.enabled = NO;
        }else{
            roundButton.enabled = YES;
        }
        
        if ([[_dataDic objectForKey:@"joined"] intValue] == 1) {
            roundButton.enabled = NO;
        }
        
        if (_type == DynamicTypeTogether) {
            long long endTime = [[_dataDic objectForKey:@"endTime"] longLongValue];
            long long nowTime = [[NSDate date] timeIntervalSince1970];
            if (endTime/1000 < nowTime) {
                roundButton.enabled = NO;
            }
        }
        
        if (!haveImage) {
            midHeight += roundBtnHeight + 15;
        }
    }
    
    self.midView.frame = CGRectMake(0, CGRectGetMaxY(self.headView.frame), CGRectGetWidth(self.cardView.frame), midHeight);
    
}

//初始化head
-(void) initHead{
    UIView* headV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.cardView.bounds.size.width, DynamicCardHeadHeight)];
    headV.backgroundColor = [UIColor whiteColor];
    self.headView = headV;
    [self.cardView addSubview:headV];
    [headV release];
    
    //头像
    UIImageView* headImgV = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, DynamicCardHeadHeight - 5*2, DynamicCardHeadHeight - 5*2)];
    headImgV.layer.cornerRadius = 2.0;
    headImgV.clipsToBounds = YES;
    headImgV.userInteractionEnabled = YES;
    
    headImgV.backgroundColor = DynamicCardBackGround;
//    [headImgV setImageWithURL:[NSURL URLWithString:[_dataDic objectForKey:@"portrait"]] placeholderImage:PLACEHOLDERIMAGE(_userId)];
    NSString* portraitStr = [Circle_member_model getMemberPortraitWithUserId:_userId];
    if (portraitStr == nil) {
        portraitStr = [_dataDic objectForKey:@"portrait"];
    }
    [headImgV setImageWithURL:[NSURL URLWithString:portraitStr] placeholderImage:PLACEHOLDERIMAGE(_userId)];
    
    self.headImageV = headImgV;
    [self.headView addSubview:headImgV];
    [headImgV release];
    
    //添加点击事件
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headTouch)];
    [self.headImageV addGestureRecognizer:tap];
    [tap release];
    
    //名字
    UILabel* nameL = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.headImageV.frame) + 10, CGRectGetMinY(self.headImageV.frame), 100, 15)];
    nameL.font = KQLboldSystemFont(14);
    nameL.textColor = DynamicCardNameColor;
    nameL.textAlignment = NSTextAlignmentLeft;
    nameL.userInteractionEnabled = YES;
    
    nameL.text = [_dataDic objectForKey:@"realname"];
    
    self.userNameLab = nameL;
    [self.headView addSubview:nameL];
    [nameL release];
    
    //添加点击事件
    UITapGestureRecognizer* nameTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headTouch)];
    [self.userNameLab addGestureRecognizer:nameTap];
    [nameTap release];
    
    //时间
    UILabel* timeL = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.headImageV.frame) + 10, CGRectGetMaxY(self.userNameLab.frame) + 5, 60, 10)];
    timeL.font = KQLboldSystemFont(10);
    timeL.textColor = DynamicCardTextColor;
    timeL.textAlignment = NSTextAlignmentLeft;
    
    timeL.text = [Common makeFriendTime:[[_dataDic objectForKey:@"createdTime"] intValue]];
    
    self.timeLab = timeL;
    [self.headView addSubview:timeL];
    [timeL release];
    
    //位置
    if ([[_dataDic objectForKey:@"city"] length] != 0) {
        UIImageView* stateImgV = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.timeLab.frame), CGRectGetMinY(self.timeLab.frame), 10, 10)];
        stateImgV.image = IMGREADFILE(DynamicPic_card_place);
        [self.headView addSubview:stateImgV];
        [stateImgV release];
        
        UILabel* stateL = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.timeLab.frame) + 12, CGRectGetMinY(self.timeLab.frame), 100, 10)];
        stateL.font = KQLboldSystemFont(10);
        stateL.textColor = DynamicCardTextColor;
        stateL.textAlignment = NSTextAlignmentLeft;
        stateL.text = [_dataDic objectForKey:@"city"];
        self.stateLab = stateL;
        [self.headView addSubview:stateL];
        [stateL release];
    }
    
    //类型
    UIImageView* typeImgV = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.cardView.frame) - 40, 10, 10, 10)];
    typeImgV.image = IMGREADFILE(DynamicPic_card_item);
    [self.headView addSubview:typeImgV];
    
    UILabel* typeL = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(typeImgV.frame), CGRectGetMinY(typeImgV.frame), 20, 10)];
    typeL.font = KQLboldSystemFont(10);
    typeL.textColor = DynamicCardTextColor;
    typeL.textAlignment = NSTextAlignmentLeft;
    self.cardTypeLab = typeL;
    [self.headView addSubview:typeL];
    
    //类型文本
    switch (self.type) {
        case DynamicTypeHave:
            self.cardTypeLab.text = @"我有";
            break;
        case DynamicTypeTogether:
            self.cardTypeLab.text = @"聚聚";
            break;
        case DynamicTypeWant:
            self.cardTypeLab.text = @"我要";
            break;
        case DynamicTypePic:
            self.cardTypeLab.text = @"图文";
            break;
        default:
            break;
    }
    
    [typeImgV release];
    [typeL release];
    
}

//初始化buttom
-(void) initButtom{
    //底部操作条
    UIView* buttomV = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.midView.frame), self.cardView.frame.size.width, DynamicCardHandleBarHeight)];
    buttomV.backgroundColor = [UIColor clearColor];
    self.buttomView = buttomV;
    [self.cardView addSubview:buttomV];
    [buttomV release];
    
    //初始化交互按钮
    UIButton* cBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cBtn.frame = CGRectMake(5, 10, 50, 25);
    [cBtn addTarget:self action:@selector(commonBtnClick) forControlEvents:UIControlEventTouchUpInside];
    cBtn.backgroundColor = [UIColor clearColor];
    cBtn.layer.cornerRadius = 2.0;
    cBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
    cBtn.layer.borderWidth = 0.1;
    [cBtn setTitleColor:BLUECOLOR forState:UIControlStateNormal];
    cBtn.titleLabel.font = KQLboldSystemFont(12);
    
    cBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 25);
    cBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [cBtn setTitle:[NSString stringWithFormat:@"%d",[[_dataDic objectForKey:@"commentSum"] intValue] + [[_dataDic objectForKey:@"zanSum"] intValue] + [[_dataDic objectForKey:@"heheSum"] intValue]] forState:UIControlStateNormal];
    [cBtn setImage:IMGREADFILE(DynamicPic_card_comment) forState:UIControlStateNormal];
    
    [self.buttomView addSubview:cBtn];
    self.commentBtn = cBtn;
    
    UIButton* oBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    oBtn.frame = CGRectMake(CGRectGetMaxX(self.commentBtn.frame) + 15, CGRectGetMinY(self.commentBtn.frame), 50, 25);
    [oBtn addTarget:self action:@selector(optionBtnClick:event:) forControlEvents:UIControlEventTouchUpInside];
    oBtn.backgroundColor = [UIColor clearColor];
    oBtn.layer.cornerRadius = 2.0;
    oBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
    oBtn.layer.borderWidth = 0.1;
    [oBtn setTitleColor:BLUECOLOR forState:UIControlStateNormal];
    oBtn.titleLabel.font = KQLboldSystemFont(12);
    
    oBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 25);
    oBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [oBtn setTitle:[NSString stringWithFormat:@"%d",[[_dataDic objectForKey:@"zanSum"] intValue] + [[_dataDic objectForKey:@"heheSum"] intValue]] forState:UIControlStateNormal];
    [oBtn setImage:IMGREADFILE(DynamicPic_card_top) forState:UIControlStateNormal];
    
    [self.buttomView addSubview:oBtn];
    self.optionBtn = oBtn;
    
    UIButton* dBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    dBtn.frame = CGRectMake(CGRectGetWidth(self.cardView.frame) - 50 - 5, CGRectGetMinY(self.commentBtn.frame), 50, 25);
    [dBtn addTarget:self action:@selector(detailBtnClick) forControlEvents:UIControlEventTouchUpInside];
    dBtn.backgroundColor = [UIColor clearColor];
    dBtn.layer.cornerRadius = 2.0;
    dBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
    dBtn.layer.borderWidth = 0.1;
    [dBtn setImage:IMGREADFILE(DynamicPic_detail_delete) forState:UIControlStateNormal];
    
    self.detailBtn = dBtn;
    
    [self.buttomView addSubview:dBtn];
    
    if (_userId != [[UserModel shareUser].user_id intValue]) {
        self.detailBtn.hidden = YES;
    }
    
    //线
    UIImageView* limgV = [[UIImageView alloc] init];
    limgV.frame = CGRectMake(5, CGRectGetHeight(self.buttomView.frame) + 3, CGRectGetWidth(self.cardView.frame) - 5*2, 0.5);
    limgV.image = IMGREADFILE(DynamicPic_detail_comment_line);
    limgV.alpha = 0.5;
    [self.buttomView addSubview:limgV];
    [limgV release];
    
}

#pragma mark - scrollview
-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int page = scrollView.contentOffset.x/CGRectGetWidth(self.cardView.frame);
    
    _currentPage = page;
    
    self.imgNumLab.text = [NSString stringWithFormat:@"%d/%d",_currentPage + 1,_totalPage];
}

#pragma mark - imageTouch
-(void) midImgTouch:(UIGestureRecognizer*) ges{
    if (_delegate && [_delegate respondsToSelector:@selector(midImageTouch:)]) {
        UIImageView* imageV = (UIImageView*)ges.view;
        [_delegate midImageTouch:imageV];
    }
}

#pragma mark - buttonClick
-(void) commonBtnClick{
    if (_delegate && [_delegate respondsToSelector:@selector(commentButtonClick)]) {
        [_delegate commentButtonClick];
    }
}

-(void) optionBtnClick:(id) sender event:(UIEvent*) event{
    
//    UITouch* touch = [[event allTouches] anyObject];
//    CGPoint point = [touch locationInView:self];
    
    UIView* v = [self.cardView viewWithTag:OPTIONVIEWTAG];
    if (v) {
        [v removeFromSuperview];
        return;
    }
    
    UIButton* senderBtn = (UIButton*)sender;
    
    UIView* view = [[UIView alloc] init];
    view.frame = CGRectMake(CGRectGetMinX(senderBtn.frame), CGRectGetMinY(self.buttomView.frame) - 60, 50, 60);
    view.backgroundColor = [UIColor clearColor];
    
    //呵呵
    UIButton* cBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cBtn.frame = CGRectMake(0, 0, 50, 25);
    [cBtn addTarget:self action:@selector(touchOption:) forControlEvents:UIControlEventTouchUpInside];
    cBtn.backgroundColor = [UIColor whiteColor];
    cBtn.layer.cornerRadius = 2.0;
    cBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
    cBtn.layer.borderWidth = 0.1;
    cBtn.tag = 2;
    [cBtn setTitleColor:BLUECOLOR forState:UIControlStateNormal];
    [cBtn setTitleColor:RGBACOLOR(210, 210, 210, 1) forState:UIControlStateDisabled];
    cBtn.titleLabel.font = KQLboldSystemFont(12);
    
//    cBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 25);
//    cBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [cBtn setTitle:@"呵呵" forState:UIControlStateNormal];
    [cBtn setTitle:@"已呵呵" forState:UIControlStateDisabled];
//    [cBtn setImage:IMGREADFILE(DynamicPic_card_hehe) forState:UIControlStateNormal];
//    [cBtn setImage:IMGREADFILE(DynamicPic_card_hehe_gray) forState:UIControlStateDisabled];
    
    if ([[_dataDic objectForKey:@"hehe"] boolValue]) {
        cBtn.enabled = NO;
    }else{
        cBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 25);
        cBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [cBtn setImage:IMGREADFILE(DynamicPic_card_hehe) forState:UIControlStateNormal];
        [cBtn setImage:IMGREADFILE(DynamicPic_card_hehe_gray) forState:UIControlStateDisabled];
        cBtn.enabled = YES;
    }
    
    [view addSubview:cBtn];
    
    //赞
    UIButton* zBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    zBtn.frame = CGRectMake(0, CGRectGetMaxY(cBtn.frame) + 10, 50, 25);
    [zBtn addTarget:self action:@selector(touchOption:) forControlEvents:UIControlEventTouchUpInside];
    zBtn.backgroundColor = [UIColor whiteColor];
    zBtn.layer.cornerRadius = 2.0;
    zBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
    zBtn.layer.borderWidth = 0.1;
    zBtn.tag = 1;
    [zBtn setTitleColor:BLUECOLOR forState:UIControlStateNormal];
    [zBtn setTitleColor:RGBACOLOR(210, 210, 210, 1) forState:UIControlStateDisabled];
    zBtn.titleLabel.font = KQLboldSystemFont(12);
    
//    zBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 25);
//    zBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [zBtn setTitle:@"赞" forState:UIControlStateNormal];
    [zBtn setTitle:@"已赞" forState:UIControlStateDisabled];
//    [zBtn setImage:IMGREADFILE(DynamicPic_card_top) forState:UIControlStateNormal];
//    [zBtn setImage:IMGREADFILE(DynamicPic_card_top_gray) forState:UIControlStateDisabled];
    
    if ([[_dataDic objectForKey:@"zan"] boolValue]) {
        zBtn.enabled = NO;
    }else{
        zBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 25);
        zBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [zBtn setImage:IMGREADFILE(DynamicPic_card_top) forState:UIControlStateNormal];
        [zBtn setImage:IMGREADFILE(DynamicPic_card_top_gray) forState:UIControlStateDisabled];
        zBtn.enabled = YES;
    }
    
    [view addSubview:zBtn];
    
//    self.optionPopV = [PopoverView showPopoverAtPoint:point inView:self withContentView:view delegate:self];
    
    view.tag = OPTIONVIEWTAG;
    
    [self.cardView addSubview:view];
    
//    [self addWindowLayerWithView:view];
    
    [view release];
    
}

//增加window层覆盖
-(void) addWindowLayerWithView:(UIView*) v{
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [window.rootViewController.view addSubview:view];
    view.tag = OPTIONPLACEVIEWTAG;
    
    CGRect newRect = [v.superview convertRect:v.frame toView:view];
    v.frame = newRect;
    [view addSubview:v];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removePlaceHolderView:)];
    [view addGestureRecognizer:tap];
    [tap release];
    
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(removePlaceHolderView:)];
    [view addGestureRecognizer:pan];
    [pan release];
    
    [view release];
}

//点击移除遮盖view
-(void) removePlaceHolderView:(UIGestureRecognizer*) ges{
    UIView* v = ges.view;
    [v removeFromSuperview];
    
    UIView* opview = [self.buttomView viewWithTag:OPTIONVIEWTAG];
    if (opview) {
        [opview removeFromSuperview];
    }
    
}

-(void) touchOption:(id) sender{
//    [self.optionPopV dismiss];
    
    UIButton* btn = (UIButton*)sender;
    [btn.superview removeFromSuperview];
    
//    UIWindow* window = [UIApplication sharedApplication].keyWindow;
//    UIView* vv = [window.rootViewController.view viewWithTag:OPTIONPLACEVIEWTAG];
//    if (vv) {
//        [vv removeFromSuperview];
//    }
    
    //修改数据库
    if (_delegate && [_delegate respondsToSelector:@selector(optionButtonClickWithType:)]) {
        [_delegate optionButtonClickWithType:btn.tag];
    }
    
    btn.enabled = NO;
    [self.optionBtn setTitle:[NSString stringWithFormat:@"%d",[[_dataDic objectForKey:@"zanSum"] intValue] + [[_dataDic objectForKey:@"heheSum"] intValue] + 1] forState:UIControlStateNormal];
    [self.commentBtn setTitle:[NSString stringWithFormat:@"%d",[[_dataDic objectForKey:@"zanSum"] intValue] + [[_dataDic objectForKey:@"heheSum"] intValue] + [[_dataDic objectForKey:@"commentSum"] intValue] + 1] forState:UIControlStateNormal];
    
    NSMutableDictionary* newDic = [NSMutableDictionary dictionaryWithDictionary:_dataDic];
    
    if (btn.tag == 2) {
        [MobClick event:@"feed_detail_hehe"];
        //hehe
        [newDic setObject:[NSNumber numberWithBool:YES] forKey:@"hehe"];
        [newDic setObject:[NSNumber numberWithInt:[[_dataDic objectForKey:@"heheSum"] intValue] + 1] forKey:@"heheSum"];
    }else if (btn.tag == 1) {
        [MobClick event:@"feed_detail_zan"];
        //zan
        [newDic setObject:[NSNumber numberWithBool:YES] forKey:@"zan"];
        [newDic setObject:[NSNumber numberWithInt:[[_dataDic objectForKey:@"zanSum"] intValue] + 1] forKey:@"heheSum"];
    }
    _dataDic = [newDic copy];
}

-(void) roundBtnClick:(UIButton*) sender{
    if (_delegate && [_delegate respondsToSelector:@selector(roundButtonClickWithType:sender:)]) {
        [_delegate roundButtonClickWithType:_type sender:sender];
    }
}

-(void) detailBtnClick{
    if (_delegate && [_delegate respondsToSelector:@selector(deleteButtonClickWith:)]) {
        [_delegate deleteButtonClickWith:_pId];
    }
}

#pragma mark - headTouch
-(void) headTouch{
    if (_delegate && [_delegate respondsToSelector:@selector(touchHeader)]) {
        [_delegate touchHeader];
    }
}

-(void) writeDataInCell:(NSDictionary *)dic{
    self.pId = [[dic objectForKey:@"id"] intValue];
    self.userId = [[dic objectForKey:@"userId"] intValue];
    self.dataDic = dic;
    
    self.currentPage = 0;
    NSArray* picListArr = [dic objectForKey:@"picList"];
    self.totalPage = picListArr.count;
    
    int type = [[dic objectForKey:@"type"] intValue];
    if (type == 3) {
        self.type = DynamicTypeHave;
    }else if (type == 4) {
        self.type = DynamicTypeWant;
    }else if (type == 8) {
        self.type = DynamicTypeTogether;
    }else{
        self.type = DynamicTypePic;
    }
    
    if (_type == DynamicTypeTogether) {
        long long startTime = [[dic objectForKey:@"startTime"] longLongValue];
        long long endTime = [[dic objectForKey:@"endTime"] longLongValue];
        
        NSString* startStr = [Common makeTime13To10:startTime withFormat:@"YYYY年MM月dd日 HH:mm"];
        NSString* endStr = [Common makeTime13To10:endTime withFormat:@"YYYY年MM月dd日 HH:mm"];
        
        NSString* location = [dic objectForKey:@"location"];
        if (location == nil) {
            location = @"";
        }
        NSString* city = [dic objectForKey:@"city"];
        if (city == nil) {
            city = @"";
        }
        
//        NSString* titleStr = [dic objectForKey:@"title"];
        NSString* titleStr = [dic objectForKey:@"content"];
        
        self.textStr = [NSString stringWithFormat:@"%@ -- %@ ,%@  %@ ,%@",startStr,endStr,city,location,titleStr];
        
    }else{
//        self.textStr = [dic objectForKey:@"title"];
        self.textStr = [dic objectForKey:@"content"];
    }
    
    [self setUp];
    
    self.cardView.frame = CGRectMake(0, DynamicCardSpace, ScreenWidth - 2*DynamicCardEdge, CGRectGetMaxY(self.buttomView.frame) + 5);
    self.frame = CGRectMake(0, 0, CGRectGetWidth(self.cardView.frame), CGRectGetHeight(self.cardView.frame) + DynamicCardSpace + 5);
}

-(void) updateDataWith:(NSDictionary *)dic{
    self.dataDic = [dic copy];
    
    NSString* porStr = [dic objectForKey:@"portrait"];
    if (porStr) {
        [self.headImageV setImageWithURL:[NSURL URLWithString:porStr]];
    }
    
    [self.commentBtn setTitle:[NSString stringWithFormat:@"%d",[[dic objectForKey:@"commentSum"] intValue] + [[_dataDic objectForKey:@"zanSum"] intValue] + [[_dataDic objectForKey:@"heheSum"] intValue]] forState:UIControlStateNormal];
    [self.optionBtn setTitle:[NSString stringWithFormat:@"%d",[[_dataDic objectForKey:@"zanSum"] intValue] + [[_dataDic objectForKey:@"heheSum"] intValue]] forState:UIControlStateNormal];
}

-(void) dealloc{
    [_cardView release];
    [_buttomView release];
    [_optionBtn release];
    [_commentBtn release];
    [_headView release];
    [_headImageV release];
    [_userNameLab release];
    [_timeLab release];
    [_stateLab release];
    [_cardTypeLab release];
    
//    [_optionPopV release];
    
    [_imgNumLab release];
    
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
