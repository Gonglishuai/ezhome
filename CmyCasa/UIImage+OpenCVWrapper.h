//
//  UIImage+OpenCVWrapper.h
//  Homestyler
//
//  Created by Or Sharir on 3/6/13.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (OpenCVWrapper)
-(UIColor*)findAverageColor;
-(UIImage*)resizeImageByFactor:(float)factor;
-(UIImage*)crop:(CGRect)rect;
-(UIImage*)maskImageWith:(UIImage*)mask;
-(UIImage*)transformPortraitToLandscape:(UIColor*)backColor withMaxWidth:(CGFloat)maxWidth;

@end
