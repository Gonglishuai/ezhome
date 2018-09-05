#pragma once
#ifndef effects_composer_h__
#define effects_composer_h__

#include <string>
#include <vector>
#include <opencv2/opencv.hpp>


class EffectsComposer
{
public:
   // Currently support 2 types of effects:
   // LUT - Remap R, G, B channels to new curves
   // MAP - Replace each pixel color with color from a 256-entry LUT indexed by on mean(R,G,B)
   enum EffectType { LUT, MAP };

   // Adds new filter effect.
   // Return false on error: 
   //  - empty name string.
   //  - LUT must be 256x1 of type CV_8UC3.
   bool addColorEffect(cv::Mat const& lutImage, std::string const& effectName, EffectType effectType)
   {
      if (lutImage.empty()                   || 
          lutImage.type() != CV_8UC3         ||
          lutImage.size() != cv::Size(256,1) )
         return false;

      if (effectName.empty())
         return false;

      effects_.push_back(Effect(lutImage, effectName, effectType));
      return true;
   }

   bool addColorEffectLUT(cv::Mat const& lutImage, std::string const& effectName) { return addColorEffect(lutImage, effectName, LUT); }
   bool addColorEffectMap(cv::Mat const& mapImage, std::string const& effectName) { return addColorEffect(mapImage, effectName, MAP); } 
   int getNumberOfAvailableEffects() { return effects_.size(); }
   
   //////////////////////////////////////////////////////////////////////////
   // Apply effect
   //    Ver. 1: Must allocate result, errors reported by returning empty image
   cv::Mat const& applyEffect(int effectIndex, cv::Mat const& inImg, float blendFactor = 1);
   //    Ver. 2: Returns false on error, takes, possibly pre-allocated) result image
   bool applyEffect(int effectIndex, cv::Mat const& inImg, cv::Mat& result, float blendFactor = 1);

   // Returns empty string if index is out of bounds.
   std::string getEffectNameAtIndex(int effectIndex)
   {
      if (effectIndex < 0 || int(effects_.size()) <= effectIndex)
         return std::string();
      return effects_[effectIndex].name;
   }

   // Create a set of thumbnails by resizing 'inImg' and applying all filters with indices in [beginIndex, endIndex)
   // Default is all filters. 
   // 'endIndex' is one AFTER the last, a value of -1 means all the way to the last filter.
   //bool createThumbnails(cv::Mat const& inImg, cv::Size const& thumbSize, std::vector<cv::Mat>& thumbnails, int beginIndex = 0, int endIndex = -1);

   // Blend 2 images with a blend factor between [0,1]
   void blend(cv::Mat const img1, cv::Mat const img2, cv::Mat& result, float blendFactor)
   {  cv::addWeighted(img1, 1.0f-blendFactor, img2, blendFactor, 0, result); }
    
    // Perform gamma correction for an input image
    static bool gammaCorrection(cv::Mat const &inImg, cv::Mat &result ,float gamma = 0.0);


private:
   struct Effect
   {
      // Simple ctor
      Effect(cv::Mat const& lutImage, std::string const& effectName, EffectType effectType):
         lut(lutImage.clone()),
         type(effectType),
         name(effectName)
      {}

      cv::Mat lut;
      EffectType type;
      std::string name;
   };

   std::vector<Effect> effects_; 
   cv::Mat resultImg_;
};

#endif // effects_composer_h__
    