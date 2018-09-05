//
//  UIImage+SafeFileLoading.h
//  Homestyler
//
//  Created by Or Sharir on 5/30/13.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (SafeFileLoading)
+(UIImage*)safeImageWithContentsOfFile:(NSString*)file;
+ (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2;

@end
