#pragma once
#ifndef paint_session_h__
#define paint_session_h__

#include <memory>
#include <opencv2/opencv.hpp>

#include "scribble_master.h"
#include "anti_aliaser.h"

class WeightedPainter; // fwd decl
class WeightedBlender; // fwd decl

class PaintSession
{
public:
   PaintSession();

    // Initialize new session.
    // Provide the image to paint on (either directly or via a file).
    // Return true on success.
    bool init(cv::Mat const img);
    bool init(std::string const& imgFileName);
    
    // Check if the paint-session is ready for painting
    // To be ready the class must have been:
    // - init() called
    bool isReady();
    
    // Load predefined masks
    bool loadPredefinedMasks(cv::Mat const img)               { return scribbleMaster_.loadPredefinedMasks(img.clone());         }
    bool loadPredefinedMasks(std::string const& imgFileName)  { return scribbleMaster_.loadPredefinedMasks(imgFileName); }
    bool setImageForAutoFill(cv::Mat const img)               { return scribbleMaster_.setImageForAutoFill(img.clone());         }
    bool setImageForAutoFill(std::string const& imgFileName)  { return scribbleMaster_.setImageForAutoFill(imgFileName); }
    
    // return the image painted with the current mask and the current color/wallpaper.
    cv::Mat const& getPaintedImage()                          { return paintedImg_; }
    
    // Useful for debugging
    cv::Mat const& getCurrentMask()                           { return scribbleMaster_.getPaintMask(); }
    
    //////////////////////////////////////////////////////////////////////////
    // Change/update the color/wallpaper to the current mask.
    // Get the repainted result using getPaintedImage();
    bool updatePaintColor(cv::Scalar const& newColor);
    bool updateWallpaper(cv::Mat const wallpaperImg);

    // Apply ambient occlusion for wallpaper/flooring - this will add a darker faded boundary inside the mask
    void enableAmbientOcclusion(float maxDarkenFactor = 0.3f, int blurKernelSize = 15, float sigma = 5);
    void disableAmbientOcclusion() { withAmbientOcclusion_ = false; }

    //////////////////////////////////////////////////////////////////////////
    // Slider support
    // Brightness: An integer gray-value positive or negative offset applied to the painted or blended region
    void setBrightness(int brightness);
    // Opacity: A float percentage between [0,1] to blend Retinex (e.g. opaque paint) and HSV (e.g. transparent-lacquer)
    void setOpacity(float alpha);
    
    //////////////////////////////////////////////////////////////////////////
    // Update the current mask with a new scribble.
    bool addPredefinedMaskScribble(Scribble const& scribble, ScribbleType scribbleType);
    bool addManualScribble(Scribble const& scribble, ScribbleType scribbleType, int thickness);
    bool addAutoFillScribble(Scribble const& scribble, ScribbleType scribbleType, int thickness);
    
    //////////////////////////////////////////////////////////////////////////
    // Undo/redo related methods:
    bool gotAnythingToUndo(); // Are there any remaning operations to undo()?
    bool undo(); // Undo last scribble
    bool gotAnythingToRedo(); // Are there any operations to redo()?
    bool redo(); // Redo last scribble
    
    // Release any allocated resources.
    // After a call to reset isReady() will be false and init() will have to be called again.
    bool reset();
    
    // Returns the size of the internal and expected image.
    cv::Size imgSize() { return srcImg_.size(); }
    
    bool repaint();
private:
    void applyAmbientOcclusion(cv::Mat mask0);
    
private:
    cv::Mat srcImg_;
    cv::Mat paintedImg_;
    bool wallpaperMode_;
    cv::Mat wallpaperAlpha_;
    ScribbleMaster scribbleMaster_;
    AntiAliaser antialiaser_;

    std::shared_ptr<WeightedPainter> painter_;
    std::shared_ptr<WeightedBlender> blender_;

    bool withAmbientOcclusion_;
    int blurKernelSize_;
    float blurSigma_;
    float maxDarkenFactor_;
};



#endif // paint_session_h__
