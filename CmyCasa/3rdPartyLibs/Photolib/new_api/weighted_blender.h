#pragma once
#include <algorithm>
#include <memory>
#include "blender.h"


class WeightedBlender: public Blender
{
public:
   WeightedBlender() : alpha_(1), brightness_(0) {}
   typedef std::shared_ptr<Blender> BlenderHandle;

   // Will blend the results of 2 blenders with a weighted factor: alpha * blenderA + (1-alpha) * blenderB
   bool init(std::shared_ptr<Blender> blenderA, std::shared_ptr<Blender> blenderB, float initialAlpha = 1);
   virtual void updateWallpaper(cv::Mat const& wallpaper);
   virtual bool blend(cv::Mat const& mask, cv::Mat& dst);
   virtual void reset();

   void setBrightness(int brightness) { brightness_ = brightness; }
   void setAlpha(float alpha) { alpha_ = std::max(0.f, std::min(1.f, alpha)); }

private:
   bool alphaBlend( cv::Mat const& mask, cv::Mat& dst );

private:
   BlenderHandle blenderA_, blenderB_;
   float alpha_;
   int brightness_;
};

