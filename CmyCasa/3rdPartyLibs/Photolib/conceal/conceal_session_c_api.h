#pragma once

#ifndef conceal_session_c_api_h__
#define conceal_session_c_api_h__

#include <string>
#include <opencv2/opencv.hpp>

#include "conceal_defs.h"

extern "C"
{ 
   // Initialize new session.
   // Provide the image to conceal.
   // Return true on success.
   bool ConcealSession_init(cv::Mat const& img, size_t initialPatchSideSize);

   // Initialize 3D cube projection data to patches on walls.
   // This MUST be called AFTER init() is called successfully, otherwise it will fail.
   // Returns true on success.
#ifdef WITH_JSON
   // Initialize directly from 3D-analysis json file.
   bool ConcealSession_init3D_withJSONString(std::string const& json, float verticalDistanceOfCameraFromFloor = 1.f);
#endif
   // Initialize directly from 3D and camera data
   bool ConcealSession_init3D(cv::Matx33f const& R, float verticalFoV, std::vector<cv::Point3f> backwall3D, float verticalDistanceOfCameraFromFloor = 1.f);

   // Check if the conceal-session is ready for concealing
   // To be ready the class must have been:
   // - init() called
   bool ConcealSession_isReady();

   // Release any allocated resources.
   // After a call to reset isReady() will be false and init() will have to be called again.
   bool ConcealSession_reset();

   // Get/Set patch size. 
   size_t ConcealSession_getPatchSideSize();
   bool ConcealSession_setPatchSideSize(size_t patchSideSize);

   // Selects between 2D/3D modes
   PatchMode ConcealSession_getPatchMode();
   bool ConcealSession_setPatchMode(PatchMode patchMode);

   // Get/Set patch size. 
   PatchTransferMode ConcealSession_getPatchTransferMode();
   bool ConcealSession_setPatchTransferMode(PatchTransferMode patchTransferMode);

   // Get/Set patch shape. 
   PatchShape ConcealSession_getPatchShape();
   bool ConcealSession_setPatchShape(PatchShape patchShape);

   // Selects patch to move. 
   // This will save the relative offset of the point within the patch to allow natural motion.
   // Returns the selected patch or NONE.
   WhichPatch ConcealSession_selectPatch_withPoint(cv::Point2f const& patchTouchPoint);

   // Select a specified patch
   bool ConcealSession_selectPatch(WhichPatch selectedPatch);

   // Returns the currently selected patch. If no patch currently selected the returns NO_PATCH
   WhichPatch ConcealSession_getSelectedPatch();

   // Moves selected patch to new position
   bool ConcealSession_moveSelectedPatchTo(cv::Point2f const& patchTouch);

   // Returns true is last moveSelectedPatchTo() caused a snap  
   bool ConcealSession_didSnap();

   // Nudges the patch by the specified offset
   bool ConcealSession_nudgeSelectedPatch(cv::Point const& offset);

   // Sets the distance within which the patch will be snapped to the other patch's 
   // alignment line.
   // A value of 0 disables the snapping.
   bool ConcealSession_setSnapLineDistance(size_t distance = 5);

   // Sets the distance from the patch center that would be considered close enough
   // to allow selecting the patch
   bool ConcealSession_setSelectPatchProximityDistance(size_t proximityInPixels = 0);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreturn-type-c-linkage"
   // returns a const ref to the corners of the requested patch
   Quad2f const& ConcealSession_getPatchCorners(WhichPatch whichPatch);
#pragma clang diagnostic pop
    
   // Gets a patch quad that is smaller than the true quad by 'shrinkAmountInPixels' pixels.
   // Quad edges remain parallel to original quad.
   // Negative values will inflate the quad.
   bool ConcealSession_getShrunkenPatchCorners(WhichPatch whichPatch, int shrinkAmountInPixels, Quad2f& shrunkenQuad);

   // Returns parameters for the ellipse bound within the patch
   void ConcealSession_getPatchEllipse(WhichPatch whichPatch, cv::RotatedRect& rotatedRect_out);

   // Returns the center if the patch in image coordinates.
   void ConcealSession_getPatchCenterPoint(WhichPatch whichPatch, cv::Point2f& centerPoint_out);

   // Perform the conceal operation by transferring from source to target patches.
   bool ConcealSession_conceal(cv::Mat const& srcImg, cv::Mat& dstImg);

   // Update source image to a new image.
   bool ConcealSession_updateSrcImg( cv::Mat const &src ); 

   // For debugging
   bool ConcealSession_getSrcImg(cv::Mat& srcImg_out);
}

#endif // conceal_session_c_api_h__
