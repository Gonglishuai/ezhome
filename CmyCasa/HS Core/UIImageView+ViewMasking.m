//
//  UIImageView+ViewMasking.m
//  Homestyler
//
//  Created by Avihay Assouline on 4/16/14.
//
//

#import "UIImageView+ViewMasking.h"

@implementation UIImageView (ViewMasking)

- (void)setMaskToCircleWithBorderWidth:(float)borderWidth andColor:(UIColor*)color
{
    self.clipsToBounds = YES;
    self.layer.cornerRadius = MIN(self.frame.size.width, self.frame.size.height) / 2;
    self.layer.borderColor = [color CGColor];
    self.layer.borderWidth = borderWidth;
}

@end
