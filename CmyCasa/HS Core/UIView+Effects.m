//
//  UIView+Effects.m
//  Homestyler
//
//  Created by Avihay Assouline on 1/12/14.
//
//

#import "QuartzCore/QuartzCore.h"
#import "UIView+Effects.h"

@implementation UIView (Effects)

// Drops a shadow on the borders of this view
- (void)dropShadowWithRadius:(CGFloat)radius opacity:(CGFloat)opacity
{
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = radius;
    self.clipsToBounds = NO;
    self.layer.shadowPath=[UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

// Stroke the border on this view
- (void)strokeWithWidth:(CGFloat)width cornerRadius:(CGFloat)cornerRadius color:(UIColor*)color
{
    self.layer.cornerRadius = cornerRadius; // set as you want.
    self.layer.borderColor = color.CGColor; // set color as you want.
    self.layer.borderWidth = width; // set as you want.
}

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
@end
