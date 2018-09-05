//
//  UIImage+UIImage_Buffer.h
//  Homestyler
//
//  Created by Avihay Assouline on 3/10/14.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Buffer)

// Generates a UIImage from an 8-bit single channel buffer
// The buffer size should be: sizeof(char) * width * height otherwise an unexpected
// behaviour may occur
+ (UIImage*) imageFromSingleChannelBuffer:(Byte*)buffer width:(int)width height:(int)height;

@end
