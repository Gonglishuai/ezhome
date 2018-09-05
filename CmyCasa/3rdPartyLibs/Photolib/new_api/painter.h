#pragma once
#ifndef painter_h__
#define painter_h__

#include <opencv2/opencv.hpp>

// Pure abstract class for painting within a mask with a particular color
class Painter
{
public:
   virtual ~Painter() {}
   void init(cv::Mat const& srcImg);
   virtual void updateColor(cv::Scalar const& color) { color_ = color ; }
   virtual bool paint(cv::Mat const& mask, cv::Mat& dst) = 0;
   virtual void reset();

protected:
   cv::Mat srcImg_;
   cv::Scalar color_;
};


//////////////////////////////////////////////////////////////////////////


class TrivialAlphaPainter: public Painter
{
public:
   virtual bool paint(cv::Mat const& mask, cv::Mat& dst);
};


//////////////////////////////////////////////////////////////////////////




#endif // painter_h__
