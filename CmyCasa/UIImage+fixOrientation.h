//
//  UIImage+fixOrientation.h
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (fixOrientation)
- (UIImage*)flipImage;
- (UIImage *)normalizedImage;
- (UIImage *)fixOrientation:(UIImageOrientation)o;
@end
