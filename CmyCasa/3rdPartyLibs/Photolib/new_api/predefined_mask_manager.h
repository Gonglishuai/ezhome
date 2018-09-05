#pragma once
#ifndef predefined_mask_manager_h__
#define predefined_mask_manager_h__


#include <vector>
#include <opencv2/opencv.hpp>

class PredefinedMaskManager
{
public:
   
   bool loadMasks(cv::Mat const& labelImage);
   bool loadMasks(std::string const& labelImageFileName);
      
   // draws the mask of a particular label with the specified color.
   // returns true if there was anything to draw.
   bool drawLabelMask(size_t labelID, cv::Mat& imgToDrawOn, cv::Scalar color);

   // draw the mask of a label corresponding to a particular pixel with the specified color.
   // returns true if there was anything to draw.
   bool drawLabelMask(cv::Point labeledPixel, cv::Mat& imgToDrawOn, cv::Scalar color);

   // release resources and forget all masks.
   void reset();

   // returns the number of distinct labels/masks (including 0)
   size_t size();

   // Returns a single channel label image/map
   cv::Mat const& getLabelImage()  const { return labelImg_; }

private:
   bool extractLabels();
   bool extractColorLabels( cv::Mat const& labelImage );

   // Holds a single range of pixels belonging to the same label, on the same row.
   // With y == row and all x from begin to end-1 being of the same label.
   // This representation allows fast drawing of the mask
   struct RasterRange
   {  size_t row, first, last; }; 

private:
   cv::Mat labelImg_; // This image allows fast lookup of single pixel
   std::vector<std::vector<RasterRange> > labelRasterLines_;
};


#endif // predefined_mask_manager_h__
