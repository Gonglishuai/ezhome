#pragma once
#ifndef PDE_RETINEX_LIB_H__
#define PDE_RETINEX_LIB_H__

#include <opencv2/opencv.hpp>



// This class implements the Retinex algorithm described in:
//    Retinex Poisson Equation: a Model for Color Perception
//    Nicolas Limare, Ana Belén Petro, Catalina Sbert, Jean-Michel Morel
//    http://www.ipol.im/pub/art/2011/lmps_rpe/

class PDERetinex
{
public:
   // Extract the lighting component of the image using the Retinex algorithm.
   bool extractLighting(cv::Mat const& img, float retinexThreshold);

   // Get the image with the lighting component found with extractLighting() removed.
   void getDeLightedImage(cv::Mat& imgOut);

   // Apply the extracted lighting to a new image of the same size
   bool applyLightingToNewImage(cv::Mat const& srcImg, cv::Mat& dstImg, cv::Mat const& mask);

   // Release resources.
   // Must call extractLighting() again to resume usage.
   void reset();

private:
   void thresholdedLaplacian(cv::Mat const& srcImg, cv::Mat& laplacianImgOut);
   inline void updatePixel(const float*& srcPix, const float*& neighborPix, float*& dstPix);

private:
   cv::Mat reconstructedImg_, illumination_;
   float retinexThreshold_;
};


//////////////////////////////////////////////////////////////////////////


void PDERetinex::updatePixel( const float*& srcPix, const float*& neighborPix, float*& dstPix )
{
   float diff = *neighborPix - *srcPix;
   if (retinexThreshold_ < fabs(diff))
      *dstPix += diff;
}



#endif // PDE_RETINEX_LIB_H__
