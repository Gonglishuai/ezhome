//
//  UIImage+Masking.h
//  CmyCasa
//
//  Created by Or Sharir on 12/6/12.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Masking)
// Mask image must be
- (UIImage*)imageByMaskingUsingImage:(UIImage *)maskImage;
@end
