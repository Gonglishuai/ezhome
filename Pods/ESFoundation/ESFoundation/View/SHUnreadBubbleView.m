//
//  SHUnreadBubble.m
//  Consumer
//
//  Created by Arnav Jain on 28/11/16.
//  Copyright © 2016 Autodesk. All rights reserved.
//

#import "SHUnreadBubbleView.h"
#import <ESBasic/ESDevice.h>
#import "UIColor+Stec.h"
#import "UIFont+Stec.h"

@interface SHUnreadBubbleView ()
{
    CGFloat _defaultWidth;
    CGFloat _expandedWidth;
    CGFloat _maxWidth;

    CGFloat _fontSize;
}

@property (weak, nonatomic) IBOutlet UILabel *unreadCountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@end

@implementation SHUnreadBubbleView

- (void)awakeFromNib
{
    [super awakeFromNib];

    _defaultWidth = 16.0f;
    _expandedWidth = 22.0f;
    _maxWidth = 28.0f;
    _fontSize = 12.0f;
}

- (void)setLabelFont
{
    self.unreadCountLabel.font = [UIFont stec_remarkTextFount];
}

- (void)setupLabelCorners
{
    self.unreadCountLabel.layer.cornerRadius = self.heightConstraint.constant / 2.0f;
}

- (void)setCount:(NSUInteger)count
{
    [self setLabelFont];
    [self setupLabelCorners];

    NSString *text = nil;
    CGFloat width = 0;

    if (count < 10)
    {
        text = [@(count) stringValue];
        width = _defaultWidth;
    }
    else if (count >= 10 && count <= 99)
    {
        text = [@(count) stringValue];
        width = _expandedWidth;
    }
    else if (count > 99)
    {
        text = @"99+";
        width = _maxWidth;
    }

    self.unreadCountLabel.text = text;
    self.widthConstraint.constant = width;
}

@end
