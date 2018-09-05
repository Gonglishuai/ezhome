//
//  UIView+Border.m
//  Homestyler
//
//  Created by Eric Dong on 02/04/18.
//
//

#import "UIView+Border.h"

@implementation UIView (Border)
// Note: cannot use synthesize in a Category

-(void)setBorderColor:(UIColor *)color
{
    self.layer.borderColor = color.CGColor;
}

-(void)setBorderWidth:(CGFloat)width
{
    self.layer.borderWidth = width;
}

-(void)setCornerRadius:(CGFloat)radius
{
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = radius > 0;
}

@end
