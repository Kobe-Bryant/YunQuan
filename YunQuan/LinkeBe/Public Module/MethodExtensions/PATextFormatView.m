//
//  PATextView.m
//  PAEBank_iPad
//
//  Created by Kyle Yang on 12-1-11.
//  Copyright (c) 2012年 pingan. All rights reserved.
//

#import "PATextFormatView.h"

@implementation PATextFormatView
@synthesize formatText,font,textColor,formatViews;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    NSArray *_rowArray = [formatText componentsSeparatedByString:@"\n"];
    CGFloat _rowSpace = 21;
    CGFloat _posY = 0;
    int currentSubViewIndex = 0;
    if (!font) {
        self.font = [UIFont systemFontOfSize:15];
    }
    if (!textColor) {
        self.textColor = [UIColor colorWithRed:68/255.0 green:60/255.0 blue:40/255.0 alpha:1];;
    }
    for (int i=0; i<[_rowArray count]; i++) {
        NSArray *_colArray = [[_rowArray objectAtIndex:i] componentsSeparatedByString:@"$$$"];
        CGFloat _colX = 0;
        for (int j=0; j<[_colArray count]; j++) {
            NSString *_colText = [_colArray objectAtIndex:j];
            CGFloat _colWidth = [_colText sizeWithFont:font].width;
            UILabel *_colLabel = [[UILabel alloc] initWithFrame:CGRectMake(_colX, _posY, _colWidth, 21)];
            _colLabel.backgroundColor = [UIColor clearColor];
            _colLabel.textColor = textColor;
            _colLabel.font = self.font;
            _colLabel.text = _colText;
            [self addSubview:_colLabel];
            [_colLabel release];
            _colX += _colWidth + 1;
            if (j<[_colArray count]-1) {
                UIView *_colView = [formatViews objectAtIndex:currentSubViewIndex];
                currentSubViewIndex++;
                NSString *_colViewText = nil;
                CGFloat _colViewWidth = 0;
                if ([_colView isKindOfClass:[UILabel class]]) {
                    _colViewText = [(UILabel*)_colView text];
                }else if ([_colView isKindOfClass:[UIButton class]]) {
                    _colViewText = [(UIButton*)_colView titleLabel].text;
                }
                if (_colViewText&&[_colViewText length]>0) {
                    _colViewWidth = [_colViewText sizeWithFont:font].width;
                }else{
                    _colViewWidth = _colView.frame.size.width;
                }
                _colView.frame = CGRectMake(_colX, _posY, _colViewWidth, 21);
                [self addSubview:_colView];
                _colX += _colViewWidth +1;
            }
        }
        _posY += _rowSpace;
    }
    self.contentSize = CGSizeMake(self.frame.size.width, _posY - _rowSpace);
}

- (void)dealloc {
    [formatViews release];
	[formatText release];
	[font release];
    [textColor release];
    [super dealloc];
}
@end
