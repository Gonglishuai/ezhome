//
//  UIView+Effects.h
//  Homestyler
//
//  Created by Avihay Assouline on 1/12/14.
//
//

#import <Foundation/Foundation.h>

@interface UIView (Effects)

// Drops a shadow on the borders of this view
- (void)dropShadowWithRadius:(CGFloat)radius opacity:(CGFloat)opacity;

// Stroke the border on this view
- (void)strokeWithWidth:(CGFloat)width cornerRadius:(CGFloat)cornerRadius color:(UIColor*)color;


+ (UIImage *) imageWithView:(UIView *)view;

@end
