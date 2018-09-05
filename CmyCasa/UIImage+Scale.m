//
//  UIImage+Scale.m
//  CmyCasa
//
//

#import "UIImage+Scale.h"
#import <QuartzCore/QuartzCore.h>
@implementation UIImage (Scale)
-(UIImage*)scaleToFitLargestSide:(float)largestSide {
	CGSize oldSize = self.size;
	float side = MAX(oldSize.width, oldSize.height);
	if (side <= largestSide) return self;
	return [self scaleByFactor:largestSide / side];
}

-(UIImage*)scaleToFitLargestSideWithScaleFactor:(float)largestSide scaleFactor:(float)scale supportUpscale:(bool) upscale{
	CGSize oldSize = self.size;
	float side = MAX(oldSize.width * scale, oldSize.height * scale);
	if (!upscale && side <= largestSide) return self;
	return [self scaleByFactor:(largestSide / side) * scale];
}


-(UIImage*)scaleByFactor:(float)factor {
	CGSize oldSize = self.size;
	CGSize newSize = CGSizeMake(oldSize.width*factor, oldSize.height*factor);
	return [self scaleToSize:newSize];
}
-(UIImage*)scaleToSize:(CGSize)size
{
	// Create a bitmap graphics context
	// This will also set it as the current context
	UIGraphicsBeginImageContext(size);
	
	// Draw the scaled image in the current context
	[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
	
	// Create a new image from current context
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// Pop the current context from the stack
	UIGraphicsEndImageContext();
	
	// Return our new scaled image
	return scaledImage;
}
-(UIImage*)scaleToFitLargestSide2:(float)largestSide {
	CGSize oldSize = self.size;
	float side = MAX(oldSize.width, oldSize.height);
	if (side <= largestSide) return self;
	return [self scaleByFactor2:largestSide / side];
}


- (UIImage*)scalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage*)scaleImageTo1024
{
	UIImage* temp = [UIImage imageWithCGImage:self.CGImage scale:1.0f orientation:UIImageOrientationUp];
	CGSize newSize = CGSizeMake(1024, 768);
    return [UIImage imageWithCGImage:[temp scaleToSize2:newSize].CGImage scale:1  orientation:self.imageOrientation];
}

-(UIImage*)scaleImageTo800
{
    UIImage* temp = [UIImage imageWithCGImage:self.CGImage scale:1.0f orientation:UIImageOrientationUp];
    CGSize newSize = CGSizeMake(800, 600);
    return [UIImage imageWithCGImage:[temp scaleToSize2:newSize].CGImage scale:1  orientation:self.imageOrientation];
}


#pragma mark Convert Image To Grayscale
- (UIImage*)grayScaleImage
{
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, self.size.width, self.size.height, 8, 0, colorSpace, 0);
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [self CGImage]);
    // Create bitmap image info from pixel data in current context
    CGImageRef grayImage = CGBitmapContextCreateImage(context);
    // release the colorspace and graphics context
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
//    
//    // make a new alpha-only graphics context
//    context = CGBitmapContextCreate(nil,
//                                    self.size.width,
//                                    self.size.height,
//                                    8,
//                                    0,
//                                    CGColorSpaceCreateDeviceGray(),
//                                    kCGImageAlphaNone);
//    // draw image into context with no colorspace
//    CGContextDrawImage(context, imageRect, [self CGImage]);
//    
//    // create alpha bitmap mask from current context
//    CGImageRef mask = CGBitmapContextCreateImage(context);
//    // release graphics context
//    CGContextRelease(context);
    // make UIImage from grayscale image with alpha mask
//    CGImageRef grayScale = CGImageCreateWithMask(grayImage, mask);
    UIImage *grayScaleImage = [UIImage imageWithCGImage:grayImage
                                                  scale:self.scale
                                            orientation:self.imageOrientation];
    // release the CG images
//    CGImageRelease(grayScale);
    CGImageRelease(grayImage);
//    CGImageRelease(mask);
    // return the new grayscale image
    return grayScaleImage;
}


-(UIImage*)scaleByFactor2:(float)factor {
	UIImage* temp = [UIImage imageWithCGImage:self.CGImage scale:1.0f orientation:UIImageOrientationUp];
	CGSize oldSize = temp.size;
	CGSize newSize = CGSizeMake(oldSize.width*factor, oldSize.height*factor);
    return [UIImage imageWithCGImage:[temp scaleToSize2:newSize].CGImage scale:1 orientation:self.imageOrientation];
}
-(UIImage*)scaleToSize2:(CGSize)size
{
	UIImage* temp = [UIImage imageWithCGImage:self.CGImage scale:1.0f orientation:UIImageOrientationUp];
	// Create a bitmap graphics context
	// This will also set it as the current context
	UIGraphicsBeginImageContext(size);
	
	// Draw the scaled image in the current context
	[temp drawInRect:CGRectMake(0, 0, size.width, size.height)];
	
	// Create a new image from current context
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// Pop the current context from the stack
	UIGraphicsEndImageContext();
	
	// Return our new scaled image
	return [UIImage imageWithCGImage:scaledImage.CGImage scale:1.0f orientation:self.imageOrientation];
}


-(void)addRoundedCornersWithRadious:(CGFloat)radious andBorderColor:(UIColor*)bordercolor forUIImageView:(UIImageView*)imview{
    
    
    imview.layer.cornerRadius = radious;
    imview.layer.masksToBounds = YES;
    imview.layer.borderColor = bordercolor.CGColor;
    imview.layer.borderWidth = 1.0;
    
    
}

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


- (CGRect) aspectFittedRect:(CGRect)maxRect
{
    CGRect inRect = CGRectMake(0, 0, self.size.width, self.size.height);
    
	float originalAspectRatio = inRect.size.width / inRect.size.height;
	float maxAspectRatio = maxRect.size.width / maxRect.size.height;
    
	CGRect newRect = maxRect;
	if (originalAspectRatio > maxAspectRatio) { // scale by width
		newRect.size.height = maxRect.size.height * inRect.size.height / inRect.size.width;
		newRect.origin.y += (maxRect.size.height - newRect.size.height)/2.0;
	} else {
		newRect.size.width = maxRect.size.height  * inRect.size.width / inRect.size.height;
		newRect.origin.x += (maxRect.size.width - newRect.size.width)/2.0;
	}
    
	return CGRectIntegral(newRect);
}

- (UIImage*)imageWithShadow {
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef shadowContext = CGBitmapContextCreate(NULL, self.size.width + 10, self.size.height, CGImageGetBitsPerComponent(self.CGImage), 0,
                                                       colourSpace, (int)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    CGContextSetShadowWithColor(shadowContext, CGSizeMake(-5, 0), 5, [UIColor colorWithWhite:0.2 alpha:0.5].CGColor);
    CGContextDrawImage(shadowContext, CGRectMake(10, 0, self.size.width, self.size.height), self.CGImage);
    
    CGImageRef shadowedCGImage = CGBitmapContextCreateImage(shadowContext);
    CGContextRelease(shadowContext);
    
    UIImage * shadowedImage = [UIImage imageWithCGImage:shadowedCGImage];
    CGImageRelease(shadowedCGImage);
    
    return shadowedImage;
}


@end
