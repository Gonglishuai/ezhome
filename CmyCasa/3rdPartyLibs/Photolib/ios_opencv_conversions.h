
/*M///////////////////////////////////////////////////////////////////////////////////////
//
//  IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.
//
//  By downloading, copying, installing or using the software you agree to this license.
//  If you do not agree to this license, do not download, install,
//  copy or use the software.
//
//
//                          License Agreement
//                For Open Source Computer Vision Library
//
// Copyright (C) 2000-2008, Intel Corporation, all rights reserved.
// Copyright (C) 2009, Willow Garage Inc., all rights reserved.
// Third party copyrights are property of their respective owners.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
//   * Redistribution's of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//
//   * Redistribution's in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//   * The name of the copyright holders may not be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
// This software is provided by the copyright holders and contributors "as is" and
// any express or implied warranties, including, but not limited to, the implied
// warranties of merchantability and fitness for a particular purpose are disclaimed.
// In no event shall the Intel Corporation or contributors be liable for any direct,
// indirect, incidental, special, exemplary, or consequential damages
// (including, but not limited to, procurement of substitute goods or services;
// loss of use, data, or profits; or business interruption) however caused
// and on any theory of liability, whether in contract, strict liability,
// or tort (including negligence or otherwise) arising in any way out of
// the use of this software, even if advised of the possibility of such damage.
//
//M*/

#include <opencv2/opencv.hpp>
#import "opencv2/highgui/cap_ios.h"
#include "scope_exit.h"


inline UIImage* MatToUIImage(const cv::Mat& image)
{
    NSData *data = [NSData dataWithBytes:image.data length:image.elemSize()*image.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (image.elemSize() == 1)
        colorSpace = CGColorSpaceCreateDeviceGray();
    else
        colorSpace = CGColorSpaceCreateDeviceRGB();
    SCOPE_EXIT(CGColorSpaceRelease(colorSpace)); // 'colorSpace' auto-releaser
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    SCOPE_EXIT(CGDataProviderRelease(provider)); // 'provider' auto-releaser

    // Creating CGImage from cv::Mat
    CGBitmapInfo imgInfo;
    
    CGImageRef imageRef;
    if (image.type() == CV_8UC3 || image.type() == CV_8UC1)
        imgInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    else
        imgInfo = kCGImageAlphaLast | kCGBitmapByteOrderDefault;
    
    imageRef = CGImageCreate(image.cols,
                             image.rows,
                             8,
                             8 * image.elemSize(),
                             image.step.p[0],
                             colorSpace,
                             imgInfo,
                             provider,
                             NULL,
                             false,
                             kCGRenderingIntentDefault
                             );
    
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    SCOPE_EXIT(CGImageRelease(imageRef)); // 'imageRef' auto-releaser

    data = nil;

    return img;
}


//////////////////////////////////////////////////////////////////////////



inline void CGImageToMat(CGImage* cgImage, cv::Size const& imgSize, cv::Mat& m, bool preserveAlpha)
{
    // Set up everything.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    SCOPE_EXIT(CGColorSpaceRelease(colorSpace)); // 'colorSpace' auto-releaser
    
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    
    if (0 == CGColorSpaceGetModel(colorSpace))
    {
        m.create(imgSize, CV_8UC1); // 8 bits per component, 1 channel
        bitmapInfo = kCGImageAlphaNone;
    }
    else
    {
        m.create(imgSize, CV_8UC4); // 8 bits per component, 4 channels

        if (preserveAlpha)
            m.setTo(0); // set uninitialized pixels in 'm' to 0
        else
            bitmapInfo = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault; // ignore alpha channel
    }
    
    CGContextRef contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows, 8, m.step[0], colorSpace, bitmapInfo);
    SCOPE_EXIT(CGContextRelease(contextRef)); // 'contextRef' auto-releaser


    // Do the actual work: Render CGImage onto cv::Mat pixel buffer
    CGContextDrawImage(contextRef, CGRectMake(0, 0, imgSize.width, imgSize.height), cgImage);
}


//////////////////////////////////////////////////////////////////////////


inline void UIImageToMat(const UIImage* image, cv::Mat& m, bool preserveAlpha,  int nbChannels = 4)
{
    CGImageToMat(image.CGImage, cv::Size(image.size.width, image.size.height), m, preserveAlpha);
    
    if (1 == nbChannels)
         cv::cvtColor(m, m, CV_RGB2GRAY);
    
    if (3 == nbChannels)
         cv::cvtColor(m, m, CV_BGRA2BGR);
}