#pragma once
#ifndef autofill_scribble_h__
#define autofill_scribble_h__

#include "scribble_types.h"

//////////////////////////////////////////////////////////////////////////
// Auto-fill scribble class

class AutoFillScribble: public ScribbleInfo
{
public:
   AutoFillScribble(Scribble const& scribble, ScribbleType type, int thickness);
   
   virtual bool draw(cv::Mat& img, cv::Scalar const& posCol, cv::Scalar const& negCol);
   virtual ScribbleGroup group() { return AUTO_FILL_SCRIBBLE; }

private:
   int thickness_;
};



#endif // autofill_scribble_h__
