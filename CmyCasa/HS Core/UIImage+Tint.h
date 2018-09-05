//
//  UIImage+Tint.h
//  Homestyler
//
//  Created by Eric Dong on 5/10/18.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Tint)

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor;
- (UIImage *)tintedGradientImageWithColor:(UIColor *)tintColor;
- (UIImage *)tintedImageWithColor:(UIColor *)tintColor blendingMode:(CGBlendMode)blendMode;

@end
