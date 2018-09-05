//
//  UIImage+UIImage_Buffer.m
//  Homestyler
//
//  Created by Avihay Assouline on 3/10/14.
//
//

#import "UIImage+Buffer.h"

@implementation UIImage (Buffer)

+ (UIImage*)imageFromSingleChannelBuffer:(Byte*)buffer width:(int)width height:(int)height
{
    // make data provider from buffer
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, (width * height * sizeof(Byte)), NULL);
    
    // set up for CGImage creation
    int bitsPerComponent = 8;
    int bitsPerPixel = 8;
    int bytesPerRow = width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    return [UIImage imageWithCGImage:imageRef];
}

@end
