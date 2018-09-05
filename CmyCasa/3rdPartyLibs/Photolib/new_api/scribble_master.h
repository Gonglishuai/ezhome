#pragma once
#ifndef scribble_master_h__
#define scribble_master_h__

#include <assert.h>
#include <vector>
#include <memory>
#include <opencv2/opencv.hpp>

#include "predefined_mask_manager.h"
#include "scribble_types.h"
#include "autofill_scribble.h"


class ScribbleMaster
{
public:

   ScribbleMaster(): isReady_(false) {}

   // Initialize to new scribble set.
   // init() will automatically reset() the session.
   bool init(cv::Size const& imgSize);

   // Load predefined masks
   bool loadPredefinedMasks(cv::Mat const img);
   bool loadPredefinedMasks(std::string const& imgFileName) {  return loadPredefinedMasks(cv::imread(imgFileName)); }
   bool setImageForAutoFill(cv::Mat const img);
   bool setImageForAutoFill(std::string const& imgFileName) {  return setImageForAutoFill(cv::imread(imgFileName));  }

   // Add new positive or negative scribble.
   // Specify thickness and whether the scribble rendering should be anti-aliased.
   bool addScribble(Scribble const& scribble, ScribbleType scribbleType, ScribbleGroup scribbleGroup, int thickness, bool antialias);

   // Undo last scribble
   // This operation is slower than addScribble() since it has to rebuild the entire scribble process up-to 
   // one step before. This trades time for memory.
   bool undo();

   // Are there any remaning operations to undo()?
   bool gotAnythingToUndo()
   {  return 0 < scribbles_.size(); }

   // Redo last scribble
   // This operation is available only when:
   // - A successful undo() was called
   // - addScribble() was not called after the undo() 
   bool redo();

   // Are there any operations to redo()?
   bool gotAnythingToRedo()
   {  return 0 < redoScribbles_.size(); }

   // return the current number of scribbles
   size_t count() { return scribbles_.size(); }

   cv::Mat const& getPaintMask()
   {  return paintMask_; }

   // Check the state of the object.
   // Will be false before init() and after reset()
   bool isReady();

   // release resources and forget all scribbles.
   void reset();

private: 
   bool fullRedraw();
   bool incrementalDraw();
   void updateAutoFillMask(cv::Mat& mask);

private:
   bool isReady_;
   cv::Size imgSize_;
   cv::Mat autoFillInputImage_, paintMask_, unusedFillOrderMask_;

   typedef std::shared_ptr<ScribbleInfo> ScribbleInfoHandle;
   std::vector<ScribbleInfoHandle> scribbles_;
   std::vector<ScribbleInfoHandle> redoScribbles_;
   PredefinedMaskManager predefinedMaskManager_;

   cv::Mat currentScribbleBunchImage_, incrementalMask_, autoFillBaseMask_;
   cv::Mat cachedUndoMask_;
   bool cachedUndoMaskGood_;
   int firstBunchScribble_;
};

#endif // scribble_master_h__
