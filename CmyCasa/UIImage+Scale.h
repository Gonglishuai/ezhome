//
//  UIImage+Scale.h
//  CmyCasa
// A few scaling functions for images
//

#import <UIKit/UIKit.h>

@interface UIImage (Scale)
-(UIImage*)scaleToSize:(CGSize)size;
-(UIImage*)scaleByFactor:(float)factor;
-(UIImage*)scaleToFitLargestSide:(float)largestSide;

-(UIImage*)scaleToFitLargestSideWithScaleFactor:(float)largestSide scaleFactor:(float)factor supportUpscale:(bool) upscale;
// temporartly duplicated due to slight changes
-(UIImage*)scaleToSize2:(CGSize)size;
-(UIImage*)scaleByFactor2:(float)factor;
-(UIImage*)scaleToFitLargestSide2:(float)largestSide;

-(UIImage*)scalingAndCroppingForSize:(CGSize)targetSize;

//hack
-(UIImage*)scaleImageTo1024;
-(UIImage*)scaleImageTo800;
+ (UIImage *) imageWithView:(UIView *)view;

-(void)addRoundedCornersWithRadious:(CGFloat)radious andBorderColor:(UIColor*)bordercolor forUIImageView:(UIImageView*)imview;

- (CGRect) aspectFittedRect:(CGRect)maxRect;

- (UIImage*)imageWithShadow;

- (UIImage*)grayScaleImage;

@end
