#pragma once
#ifndef blender_h__
#define blender_h__

#include <opencv2/opencv.hpp>

// Pure abstract class for blending - used for wallpapers
class Blender
{
public:
   virtual ~Blender() {}
   void init(cv::Mat const& srcImg);
   virtual void updateWallpaper(cv::Mat const& wallpaper) { wallpaper_  = wallpaper.clone(); } // clone in case the wallpaper memory is released externally
   virtual bool blend(cv::Mat const& mask, cv::Mat& dst) = 0;
   virtual void reset();

protected:
   cv::Mat srcImg_;
   cv::Mat wallpaper_;
};


//////////////////////////////////////////////////////////////////////////


class AlphaBlender: public Blender
{
public:
   virtual bool blend(cv::Mat const& mask, cv::Mat& dst);
};


//////////////////////////////////////////////////////////////////////////


class HSVBlender: public Blender
{
public:
   void init(cv::Mat const& srcImg);
   virtual void updateWallpaper(cv::Mat const& wallpaper);
   virtual bool blend(cv::Mat const& mask, cv::Mat& dst);
   virtual void reset();

private:
   float median(cv::Mat const& img);

private:
   std::vector<uchar> pixelVec_;
   float medianSrcV_;
   cv::Mat srcImgV_;
   cv::Mat wallpaperedSrcFull_;
};




#endif // blender_h__
