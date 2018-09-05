//
//  UIImage+OpenCVWrapper.m
//  Homestyler
//
//  Created by Or Sharir on 3/6/13.
//  Modified on 18/3/2014 by Avihay Assouline to replace IplImage with cv::Mat
//
//

#import "UIImage+OpenCVWrapper.h"
#import "ios_opencv_conversions.h"

@implementation UIImage (OpenCVWrapper)

-(UIColor*)findAverageColor
{
    float topPortion = 0.75;
    
    cv::Mat img;
    ::UIImageToMat(self, img, true, 3);
    
    // create ROI on top part of image
    cv::Rect roi = cv::Rect(0, 0, img.size().width, (int)(topPortion*img.size().height) );
    
    // set ROI on image
    cv::Mat imgInROI = img(roi);
    
    // calc avg in ROI
    cv::Scalar avg = cv::mean(imgInROI);
    
    // original normalization code - keeps relative brightness by normalizing with 255 (max value per channel)
    // norm of avg - |avg| <= 1
    return [UIColor colorWithRed:avg.val[0]/255.0 green:avg.val[1]/255.0 blue:avg.val[2]/255.0 alpha:1];
}

-(UIImage*)resizeImageByFactor:(float)factor
{
    cv::Mat img;
    ::UIImageToMat(self, img, true);
    
    cv::Size s = img.size();
    cv::Size newSize = cv::Size(round(s.width*factor), round(s.height*factor));
    
    cv::Mat resizedImage;
    cv::resize(img, resizedImage, newSize, 0, 0, CV_INTER_AREA);

    UIImage* result = MatToUIImage(resizedImage);
    return result;
}

-(UIImage*)crop:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage* cropped = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return cropped;
}

-(UIImage*)maskImageWith:(UIImage*)mask
{
    std::vector<cv::Mat> channels;
    
    cv::Mat alphaChannel;
    ::UIImageToMat(mask, alphaChannel, false, 1);

    cv::Mat srcImgMat;
    ::UIImageToMat(self, srcImgMat, true, 3);
    
    cv::split(srcImgMat, channels);

    channels.push_back(alphaChannel);
    
    cv::Mat dst;
    cv::merge(channels, dst);
    
    UIImage* result = MatToUIImage(dst);
    return result;
}

-(UIImage*)transformPortraitToLandscape:(UIColor*)backColor withMaxWidth:(CGFloat)maxWidth
{
    // Check for degenerate images (alloced not inited)
    if (!self.CGImage)
        return nil;
    
    cv::Mat portIm;
    ::UIImageToMat(self, portIm, true, 3);
    
    // Compute the border size to fit the image when the proportions are rotated
    float rescaleFactor = (portIm.cols / (float)portIm.rows);
    
    // Get the destination image with the background color
    CGFloat r,g,b,a;
    [backColor getRed:&r green:&g blue:&b alpha:&a];
    
    // Resize and paste the image in the center of the destination image
    cv::Size newSize = cv::Size(portIm.size());
    if (self.size.width <= self.size.height)
    {
        newSize = cv::Size(portIm.cols * rescaleFactor, portIm.cols );
        cv::resize(portIm, portIm, newSize);
    }
    
    int borderTotalSize = maxWidth - newSize.width;
    
    cv::Mat dstImg;
    cv::copyMakeBorder(portIm,
                       dstImg,
                       0,                   // No top border
                       0,                   // No bottom border
                       borderTotalSize / 2, // Left border
                       borderTotalSize / 2, // Right border
                       cv::BORDER_CONSTANT,
                       cv::Scalar(r * 255,g * 255,b * 255,a * 255));
    
    UIImage* result = MatToUIImage(dstImg);
    return result;
}

@end
