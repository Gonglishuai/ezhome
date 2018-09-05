#pragma once
#ifndef scribble_types_h__
#define scribble_types_h__

#include "scribble_defs.h"

//////////////////////////////////////////////////////////////////////////
// Base class for scribbles
class ScribbleInfo
{
public:
   virtual ~ScribbleInfo() {}
   ScribbleInfo(Scribble const& scribble, ScribbleType type): 
      scribble_(scribble), 
      type_(type) 
   {
      if (1 == scribble_.size())                // handle case of a single point:
         scribble_.push_back(scribble_.back()); // insert the single point as an end-point too
   }

   virtual bool draw(cv::Mat& img, cv::Scalar const& posCol, cv::Scalar const& negCol) = 0;
   virtual ScribbleGroup group() = 0;

protected:
   Scribble scribble_;
   ScribbleType type_;
};


//////////////////////////////////////////////////////////////////////////
// Manual scribble class

class ManualScribble: public ScribbleInfo
{
public:
   ManualScribble(Scribble const& scribble, ScribbleType type, int thickness): 
      ScribbleInfo(scribble, type),
      thickness_(thickness)
   {}

   virtual bool draw(cv::Mat& img, cv::Scalar const& posCol, cv::Scalar const& negCol);
   virtual ScribbleGroup group() { return MANUAL_SCRIBBLE; }

private:
   int thickness_;
};





//////////////////////////////////////////////////////////////////////////
// Predefined mask scribble class
#include "predefined_mask_manager.h"

class PreDefinedMaskScribble: public ScribbleInfo
{
public:
   PreDefinedMaskScribble(Scribble const& scribble, ScribbleType type, PredefinedMaskManager& predefinedMaskManager): 
      ScribbleInfo(scribble, type),
         predefinedMaskManager_(predefinedMaskManager)
      {}

      virtual bool draw(cv::Mat& img, cv::Scalar const& posCol, cv::Scalar const& negCol);
      virtual ScribbleGroup group() { return PREDEFINED_MASK_SCRIBBLE; }

private:
   PredefinedMaskManager& predefinedMaskManager_;
};

#endif // scribble_types_h__
