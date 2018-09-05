//
//  UIImage+Masking.m
//  CmyCasa
//
//  Created by Or Sharir on 12/6/12.
//
//

#import "UIImage+Masking.h"
#import "UIImage+OpenCVWrapper.h"
CGImageRef CopyImageAndAddAlphaChannel(CGImageRef sourceImage) {
    CGImageRef retVal = NULL;
    
    size_t width = CGImageGetWidth(sourceImage);
    size_t height = CGImageGetHeight(sourceImage);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL, width, height,
                                                          8, 0, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
    if (offscreenContext != NULL) {
        CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), sourceImage);
        
        retVal = CGBitmapContextCreateImage(offscreenContext);
        CGContextRelease(offscreenContext);
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return retVal;
}


@implementation UIImage (Masking)
- (UIImage*)imageByMaskingUsingImage:(UIImage *)maskImage {
    NSString *reqSysVer = @"7";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        return [self maskImageWith:maskImage];
    }
    
    CGImageRef maskRef = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef source = [self CGImage];
    
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(source);
    if ( alphaInfo == kCGImageAlphaNone || alphaInfo == kCGImageAlphaNoneSkipLast || alphaInfo == kCGImageAlphaNoneSkipFirst ) {
        source = CopyImageAndAddAlphaChannel(source);
    }
    
    CGImageRef masked = CGImageCreateWithMask(source, mask);
    CGImageRelease(mask);
    
    if ( source != [self CGImage] ) {
        CGImageRelease(source);
    }
    
    UIImage *result = nil;
    if (masked && [UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)] ) {
        result = [UIImage imageWithCGImage:masked scale:self.scale orientation:self.imageOrientation];
    } else if (masked) {
        result = [UIImage imageWithCGImage:masked];
    }
    
    CGImageRelease(masked);
    
    return result;
}

@end