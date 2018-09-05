#pragma once
#include <algorithm>
#include <memory>
#include "painter.h"


class WeightedPainter: public Painter
{
public:
   WeightedPainter() : alpha_(1), brightness_(0) {}
   typedef std::shared_ptr<Painter> PainterHandle;

   // Will blend the results of 2 painters with a weighted factor: alpha * painterA + (1-alpha) * painterB
   bool init(std::shared_ptr<Painter> painterA, std::shared_ptr<Painter> painterB, float initialAlpha = 1);
   virtual void updateColor(cv::Scalar const& color);
   virtual bool paint(cv::Mat const& mask, cv::Mat& dst);
   virtual void reset();

   void setBrightness(int brightness) { brightness_ = brightness; }
   void setAlpha(float alpha) { alpha_ = std::max(0.f, std::min(1.f, alpha)); }

private:
   bool alphaPaint( cv::Mat const& mask, cv::Mat& dst );

private:
   PainterHandle painterA_, painterB_;
   float alpha_;
   int brightness_;
};

