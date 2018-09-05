#pragma once
#ifndef painter_hsv_mul_h__
#define painter_hsv_mul_h__

#include <opencv2/opencv.hpp>

#include "painter.h"

class HSVMulPainter: public Painter
{
public:
   void init(cv::Mat const& srcImg);         
   virtual void updateColor(cv::Scalar const& color);
   virtual bool paint(cv::Mat const& mask, cv::Mat& dst);

   void preventSaturation(  float& intensityAdjustmentFactor, cv::Mat const& mask );

private:
   enum { SATURATION_GRAY_VAL = 250 };
   void histogramInMask(cv::Mat const& img, cv::Mat const& mask);

private:
   cv::Mat hsvChans_[3]; 
   cv::Scalar colorInHSV_;
   cv::Mat histogram_;
   cv::Mat coloredSrcBGR_;
};


#endif // painter_hsv_mul_h__
