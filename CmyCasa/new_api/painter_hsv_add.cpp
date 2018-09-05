#include "painter_hsv_add.h"
#include "alpha_blend.h"
#include "convert_color.h"


//////////////////////////////////////////////////////////////////////////


void HSVAddPainter::init( cv::Mat const& srcImg )
{
   Painter::init(srcImg);
   cv::Mat srcHSV;
   cv::cvtColor(srcImg_, srcHSV, cv::COLOR_BGR2HSV);
   cv::split(srcHSV, hsvChans_);
}


//////////////////////////////////////////////////////////////////////////


void HSVAddPainter::updateColor( cv::Scalar const& color )
{
   // convert input color to HSV
   convertColor(color, colorInHSV_, cv::COLOR_BGR2HSV);

   // Set HS channels to input color HS.
   hsvChans_[0].setTo(cv::Scalar::all(colorInHSV_.val[0]));
   hsvChans_[1].setTo(cv::Scalar::all(colorInHSV_.val[1]));
   
   cv::Mat mergedHSV;
   cv::merge(hsvChans_, 3, mergedHSV);
   cv::cvtColor(mergedHSV, coloredSrcBGR_, cv::COLOR_HSV2BGR);
}


//////////////////////////////////////////////////////////////////////////


bool HSVAddPainter::paint( cv::Mat const& mask, cv::Mat& dst )
{
   using namespace std;

   assert(1 == mask.channels());

   float avgImgIntensityInMask = cv::mean(hsvChans_[2], mask).val[0];

   float intensityAdjustmentOffset = (avgImgIntensityInMask > 0 ? colorInHSV_.val[2] - avgImgIntensityInMask : 1); // additive

   // If we need to brighten the image, then 'intensityAdjustmentOffset' is positive and we need
   // to prevent saturation. Otherwise, skip this step.
   if (0 < intensityAdjustmentOffset)
      preventSaturation(intensityAdjustmentOffset, mask);

   // In the case of completely black - map saturated pixels to gray-value 50, just 
   // to get some visibility.
//    if (intensityAdjustmentOffset < 1e-9)
//       intensityAdjustmentOffset = 50.0 / float(SATURATION_GRAY_VAL);

   return alpha_blend(coloredSrcBGR_ + cv::Scalar::all(intensityAdjustmentOffset), mask, srcImg_, dst);
}


//////////////////////////////////////////////////////////////////////////


void HSVAddPainter::histogramInMask( cv::Mat const& img, cv::Mat const& mask )
{
   assert(CV_8UC1 == img.type());
   int bins = 1<<8;
   const float range[] = { 0, float(bins) } ;
   const float* histRange[] = { range };
   int zero = 0;
   cv::calcHist(&img, 1, &zero, mask, histogram_, 1, &bins, histRange);
}



//////////////////////////////////////////////////////////////////////////


void HSVAddPainter::preventSaturation( float& intensityAdjustmentOffset, cv::Mat const& mask )
{
   // Build histogram of src in mask
   histogramInMask(hsvChans_[2], mask);

   // update histogram to contain accumulated pixel counts in descending gray-value order to determine saturation.
   for (int i=254; 0 <= i; --i)
      histogram_.at<float>(i) += histogram_.at<float>(i+1);

   // We want to avoid over-saturation. Thus, if intensity readjustment will cause over saturation
   // we do change the adjustment factor to avoid saturation.

   // Find how many flushed (over-saturated) pixels in source
   int srcSaturatedCount = histogram_.at<float>(SATURATION_GRAY_VAL+1);

   // After readjustment, saturated pixels will be mapped above 'adjustedFlushedGrayVal' 
   int adjustedFlushedGrayVal = ( 1e-9 < intensityAdjustmentOffset ? SATURATION_GRAY_VAL - intensityAdjustmentOffset : 256);

   // Find how many pixels will flush in source AFTER adjustment
   int srcAdjustedSaturatedCount = (254 < adjustedFlushedGrayVal ? 0 : histogram_.at<float>(adjustedFlushedGrayVal+1));

   // adjustment will flush - avoid it
   if (srcSaturatedCount < srcAdjustedSaturatedCount)
   {
      int newSatThresh = 254;
      for (; 0 <= newSatThresh; --newSatThresh)
         if (srcSaturatedCount < histogram_.at<float>(newSatThresh) )
            break;

      ++newSatThresh; // increment to get last one that was smaller
      intensityAdjustmentOffset = float(SATURATION_GRAY_VAL) - newSatThresh;
   }	
}


