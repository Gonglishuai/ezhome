

#include <math.h>

#include <opencv2/opencv.hpp>
//#include <highgui.h>

#include "pde_retinex.h"

using namespace cv;


//////////////////////////////////////////////////////////////////////////


// Compute the thresholded Laplacian, taking into account only neighboring
// pixels that differ by more than 'retinexThreshold_' 
void PDERetinex::thresholdedLaplacian( cv::Mat const& srcImg, cv::Mat& laplacianImgOut)
{
   assert(!laplacianImgOut.empty() && !srcImg.empty());
   assert(laplacianImgOut.size() == srcImg.size() && 
          laplacianImgOut.type() == srcImg.type() &&
          CV_32FC1 == laplacianImgOut.type());

   size_t nx = srcImg.cols; 
   size_t ny = srcImg.rows;

   // By not including pixels outside the image in the laplacian calculation
   // we are essentially setting the Neumann-boundary conditions, i.e. the derivative on the boundary is 0.
   // This is equivalent to using cv::Laplacian with cv::BORDER_REPLICATE, hence the replication create a derivative of 0.
   // See e.g. http://hep.physics.indiana.edu/~hgevans/p411-p610/material/10_pde_bound/ft.html
   // "... the derivative of the function is zero on the boundary"
/*
   // pointers to the data and neighboring values 
   // 
   //                 y-1
   //             x-1 ptr x+1
   //                 y+1
   //    <---------------------nx------->

   // Simpler loop with no bounds checking - image contains 1-pixel boundary to 
   // avoid out-of-bounds checks
   size_t stride = srcImg.step / sizeof(float);
   for (size_t y = 0; y < ny; ++y) 
   {
      const float* srcPix   = srcImg.ptr<float>(y,0);
      const float* pixLeft  = srcPix - 1;
      const float* pixRight = srcPix + 1;
      const float* pixAbove = srcPix - stride;
      const float* pixBelow = srcPix + stride;
      float* dstPix = laplacianImgOut.ptr<float>(y,0);

      for (size_t x = 0; x < nx; ++x) 
      {
         *dstPix = 0.;
         updatePixel(srcPix, pixLeft,  dstPix);
         updatePixel(srcPix, pixRight, dstPix);
         updatePixel(srcPix, pixAbove, dstPix);
         updatePixel(srcPix, pixBelow, dstPix);

         ++srcPix;
         ++pixLeft;
         ++pixRight;
         ++pixAbove;
         ++pixBelow;
         ++dstPix;
      }
   }
*/
   // Simpler loop with bounds checking:
   {
      const float* srcPix   = srcImg.ptr<float>(0,0);
      const float* pixLeft  = srcPix - 1;
      const float* pixRight = srcPix + 1;
      const float* pixAbove = srcPix - nx;
      const float* pixBelow = srcPix + nx;
      float* dstPix = laplacianImgOut.ptr<float>(0,0);

      for (size_t y = 0; y < ny; ++y) 
      {
         for (size_t x = 0; x < nx; ++x) 
         {
            *dstPix = 0.;
            // row differences 
            if (0 < x)
               updatePixel(srcPix, pixLeft, dstPix);
            if (x < nx - 1) 
               updatePixel(srcPix, pixRight, dstPix);
            // column differences 
            if (0 < y) 
               updatePixel(srcPix, pixAbove, dstPix);
            if (y < ny - 1) 
               updatePixel(srcPix, pixBelow, dstPix);

            ++srcPix;
            ++pixLeft;
            ++pixRight;
            ++pixAbove;
            ++pixBelow;
            ++dstPix;
         }
      }
   }
}


//////////////////////////////////////////////////////////////////////////


bool PDERetinex::extractLighting( cv::Mat const& srcImg, float retinexThreshold )
{
   if (srcImg.empty())
      return false;

   retinexThreshold_ = retinexThreshold;

   cv::Rect srcROI(0, 0, srcImg.cols, srcImg.rows);

   PoissonNeumannSolver<>::makeOptimalPaddedImage(srcImg, paddedImg_);
   assert(PoissonNeumannSolver<>::isOptimalSize(paddedImg_.size()));

   paddedImg_.convertTo(paddedImg32F_, CV_MAKE_TYPE(CV_32F, srcImg.channels()));
   // Split image to separate channels
   std::vector<cv::Mat> paddedChannels(paddedImg32F_.channels());
   split(paddedImg32F_, paddedChannels);

   std::vector<cv::Mat> subImgs(paddedImg32F_.channels());

   for (int c = 0; c < paddedImg_.channels(); ++c) 
   {
      laplacianImg32FC1_.create(paddedImg32F_.size(), CV_32FC1);
      thresholdedLaplacian(paddedChannels[c], laplacianImg32FC1_); // Retinex Laplacian
//       cv::Laplacian(paddedChannels[c](optimalROI), laplacianImg32FC1_(optimalROI), CV_32F, 1, 1, 0, BORDER_REPLICATE); // "Regular" Laplacian

      if (!poissonSolver_.solve(laplacianImg32FC1_, solvedImg_))
         return false;

      // Results has an arbitrary gray-value offset.
      // Shift it back to proper values
      double srcMinVal, recMinVal;
      //double srcMaxVal, recMaxVal;
      minMaxLoc(paddedChannels[c], &srcMinVal/*, &srcMaxVal*/);
      minMaxLoc(solvedImg_, &recMinVal/*, &recMaxVal*/);
      solvedImg_ += srcMinVal - recMinVal; 

/*
      // Alternative re-normalization
      reconstructedImg_ -= recMinVal; 
      reconstructedImg_ *= srcMaxVal / (recMaxVal - recMinVal);
*/
          
//       cv::imshow("paddedChannels[c]", paddedChannels[c]/255);
//       cv::imshow("laplacianImg32FC1_", laplacianImg32FC1_/255/2+0.5);
//       cv::imshow("reconstructedImg_", solvedImg_/255);
//       cv::waitKey();

      solvedImg_(srcROI).copyTo(subImgs[c]); // copy just image without padding
   }

   merge(subImgs, reconstructedImg_);

   illumination_ = paddedImg32F_(srcROI) - reconstructedImg_;

   //////////////////////////////////////////////////////////////////////////
   // Desaturated illumination if above MAX_SATURATION (percent of [0,1])
   // 
   // Conversion to HSV of float images can only be done for value between [0,1]
   // but illumination is around [-255,+255] (possibly more).
   // We'll divide by 255 to get [-1,1] and then divide by 2 and shift by half to get [0,1]
   // All this should hopefully not affect the saturation too much. 
   cv::Mat hsvIllumination;
   cv::Mat illu_0_1 = (illumination_/255 + 1)/2; 
   cvtColor(illu_0_1, hsvIllumination, CV_BGR2HSV);
   double MAX_SATURATION = 0.03; 
   cv::Mat chan[3];
   cv::split(hsvIllumination, chan);
   //cv::imshow("satu", chan[1] >= MAX_SATURATION);
   cv::threshold(chan[1], chan[1], MAX_SATURATION, MAX_SATURATION, CV_THRESH_TRUNC); // truncate saturation to MAX_SATURATION
   cv::merge(chan, 3, hsvIllumination);
   cvtColor(hsvIllumination, illu_0_1, CV_HSV2BGR);
   illumination_ = (illu_0_1*2 -1)*255;
   //////////////////////////////////////////////////////////////////////////


//   cv::blur(illumination_, illumination_, cv::Size(7,7));

//    cv::imshow("illumination_", illumination_/255/2+0.5);
//    cv::waitKey();

   return true;
}


//////////////////////////////////////////////////////////////////////////


void PDERetinex::getDeLightedImage( cv::Mat& imgOut )
{
   reconstructedImg_.convertTo(imgOut, CV_8UC3);
}


//////////////////////////////////////////////////////////////////////////


bool PDERetinex::applyLightingToNewImage( cv::Mat const& srcImg, cv::Mat& dstImg, cv::Mat const& mask)
{
   if (srcImg.size() != illumination_.size() ||
      srcImg.channels() != illumination_.channels())
      return false;

   cv::Mat relighted;
   srcImg.convertTo(relighted, CV_32F); 

   relighted += illumination_;

   cv::Mat grey;
   cv::cvtColor(relighted, grey, CV_BGR2GRAY);
   double mx;
   cv::minMaxLoc(grey, nullptr, &mx, nullptr, nullptr, mask);
   // If mx would oversaturate, i.e. 255 < mx, then re-map mx to 255
   // Under-saturation does not seem to be a real problem
   if (mx <= 255)
      relighted.convertTo(dstImg, CV_8U);
   else
      relighted.convertTo(dstImg, CV_8U, 255.0/(mx*1.05));

   return true;
}


//////////////////////////////////////////////////////////////////////////
