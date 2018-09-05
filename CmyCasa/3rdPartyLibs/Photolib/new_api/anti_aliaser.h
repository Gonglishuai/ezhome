#pragma once
#ifndef anti_aliaser_h__
#define anti_aliaser_h__

#include <opencv2/opencv.hpp>

class AntiAliaser
{
public:
   cv::Mat const& antialias(cv::Mat const& binaryImage);
   void antialias(cv::Mat const& binaryImage, cv::Mat& dstAntiAliasedImage, cv::Scalar const& fillColor, bool setDstToZero);
   cv::Mat const& getAntiAliasedImage() { return antiAliasedImage_; }
   void reset();

private:
   cv::Mat largerImage_, antiAliasedImage_;
};


#endif // anti_aliaser_h__
