#pragma once

#ifndef paint_session_c_api_h__
#define paint_session_c_api_h__

#include <string>
#include <opencv2/opencv.hpp>
#include "scribble_defs.h"

extern "C"
{ 
   // Initialize new session.
   // Provide the image to paint on (either directly or via a file).
   // Return true on success.
   bool PaintSession_initFromImage(cv::Mat const& img);
   bool PaintSession_initFromFileName(std::string const& imgFileName);

   // Check if the paint-session is ready for painting
   // To be ready the class must have been:
   // - init() called
   bool PaintSession_isReady();

   // Load predefined masks
   bool PaintSession_loadPredefinedMasksFromImage(cv::Mat const img);
   bool PaintSession_loadPredefinedMasksFromFileName(std::string const& imgFileName);
   bool PaintSession_setImageForAutoFillFromImage(cv::Mat const img);
   bool PaintSession_setImageForAutoFillFromFileName(std::string const& imgFileName);

   // return the image painted with the current mask and the current color/wallpaper.
   void PaintSession_getPaintedImage(cv::Mat& paintedImage);

   // Useful for debugging
   void PaintSession_getCurrentMask(cv::Mat& currentMask);

   // Change/update the color/wallpaper to the current mask.
   // Get the repainted result using getPaintedImage();
   bool PaintSession_updatePaintColor(cv::Scalar const& newColor);
   bool PaintSession_updateWallpaper(cv::Mat const wallpaperImg);

   // Apply ambient occlusion for wallpaper/flooring - this will add a darker faded boundary inside the mask
   void PaintSession_enableAmbientOcclusion(float maxDarkenFactor = 0.3f, int blurKernelSize = 15, float sigma = 5);
   void PaintSession_disableAmbientOcclusion();

   // Slider support
   // Brightness: An integer gray-value positive or negative offset applied to the painted or blended region
   void PaintSession_setBrightness(int brightness);
   // Opacity: A float percentage between [0,1] to blend Retinex (e.g. opaque paint) and HSV (e.g. transparent-lacquer)
   void PaintSession_setOpacity(float alpha);

   // Update the current mask with a new scribble.
   bool PaintSession_addPredefinedMaskScribble(Scribble const& scribble, ScribbleType scribbleType);
   bool PaintSession_addManualScribble(Scribble const& scribble, ScribbleType scribbleType, int thickness);
   bool PaintSession_addAutoFillScribble(Scribble const& scribble, ScribbleType scribbleType, int thickness);

   //////////////////////////////////////////////////////////////////////////
   // Undo/redo related methods:
   bool PaintSession_gotAnythingToUndo(); // Are there any remaning operations to undo()?
   bool PaintSession_undo(); // Undo last scribble
   bool PaintSession_gotAnythingToRedo(); // Are there any operations to redo()? 
   bool PaintSession_redo(); // Redo last scribble

   // Release any allocated resources.
   // After a call to reset isReady() will be false and init() will have to be called again.
   bool PaintSession_reset();

   int PaintSession_imgWidth();
   int PaintSession_imgHeight();
}
#endif // paint_session_c_api_h__
