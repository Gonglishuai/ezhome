#pragma once

#include <string>
#include <vector>
#include <array>
#include <memory>

#include <opencv2/opencv.hpp>

#include "dirichlet_boundary_solver/poisson_dirichlet_solver.h"
#include "patch_interface.h"
#include "box/box_unfolder.h"
#include "conceal_defs.h"

class ConcealSession
{
public:
   ConcealSession();

   // Initialize new session.
   // Provide the image to conceal.
   // Return true on success.
   bool init(cv::Mat const& img, size_t initialPatchSideSize);

   // Initialize 3D cube projection data to patches on walls.
   // This MUST be called AFTER init() is called successfully, otherwise it will fail.
   // Returns true on success.
#ifdef WITH_JSON
   // Initialize directly from 3D-analysis json file.
   bool init3D(std::string const& json, float verticalDistanceOfCameraFromFloor = 1.f);
#endif
   // Initialize directly from 3D and camera data
   bool init3D(cv::Matx33f const& R, float verticalFoV, std::vector<cv::Point3f> backwall3D, float verticalDistanceOfCameraFromFloor = 1.f);

   // Check if the conceal-session is ready for concealing
   // To be ready the class must have been:
   // - init() called
   bool isReady() const; 

   // Release any allocated resources.
   // After a call to reset isReady() will be false and init() will have to be called again.
   bool reset();

   // Get/Set patch size. 
   size_t getPatchSideSize();
   bool setPatchSideSize(size_t patchSideSize);

   // Selects between 2D/3D modes
   PatchMode getPatchMode();
   bool setPatchMode(PatchMode patchMode);
    
   // Get/Set patch size. 
   PatchTransferMode getPatchTransferMode() { return transferMode_; }
   bool setPatchTransferMode(PatchTransferMode patchTransferMode);

   // Get/Set patch shape. 
   PatchShape getPatchShape() { return patchShape_; }
   bool setPatchShape(PatchShape patchShape);

   // Selects patch to move. 
   // This will save the relative offset of the point within the patch to allow natural motion.
   // Returns the selected patch or NONE.
   WhichPatch selectPatch(cv::Point2f const& patchTouchPoint);

   // Returns the currently selected patch. If no patch currently selected the returns NO_PATCH
   WhichPatch getSelectedPatch();

   // Select a particular patch
   bool selectPatch(WhichPatch selectedPatch);

   // Moves selected patch to new position
   bool moveSelectedPatchTo(cv::Point2f const& patchTouch);

   // Returns true is last moveSelectedPatchTo() caused a snap  
   bool didSnap() { return didSnap_; }

   // Nudges the patch by the specified offset
   bool nudgeSelectedPatch(cv::Point const& offset);

   // Sets the distance within which the patch will be snapped to the other patch's 
   // alignment line.
   // A value of 0 disables the snapping.
   bool setSnapLineDistance(size_t distance = 5);

   // Sets the distance from the patch center that would be considered close enough
   // to allow selecting the patch
   bool setSelectPatchProximityDistance(size_t proximityInPixels = 0);

   // returns a const ref to the corners of the requested patch
   Quad2f const& getPatchCorners(WhichPatch whichPatch) const;
   bool getShrunkenPatchCorners(WhichPatch whichPatch, int shrinkAmountInPixels, Quad2f& shrunkenQuad) const;
   cv::RotatedRect getPatchEllipse(WhichPatch whichPatch) const;
   cv::Point2f getPatchCenterPoint(WhichPatch whichPatch) const;

   void draw(cv::Mat& img);
   bool conceal(cv::Mat const& srcImg, cv::Mat& dstImg);
   bool updateSrcImg( cv::Mat const &src ); 

   // For debugging
   bool drawCube(cv::Mat& imgToDrawOn, cv::Scalar const& color, int thickness=1, int lineType=8);
   bool getSrcImg(cv::Mat& srcImg_out) const;

private:
   void transfer( cv::Mat const& srcImg, IPatch const& srcPatch, cv::Mat& dstImg, IPatch const& dstPatch );
   void prepareWarpedPatchImg( IPatch const &srcPatch, IPatch const &dstPatch, cv::Mat const &srcImg, cv::Rect& dstRoi );
   void seamlessClone(cv::Rect const& dstRoi, cv::Mat& dstImg);
   void mixtureClone(cv::Rect const& dstRoi, cv::Mat& dstImg);
   bool initSeamlessCloneMembers(cv::Mat const& img);

   cv::Point2f getBackwallCenterImgPoint();

private:
   cv::Size imgSize_;
   PatchMode patchMode_;
   WhichPatch whichPatch_;
   PatchShape patchShape_;
   size_t patchSideSize_;
   
   std::shared_ptr<IPatch> patches_[2];
   std::shared_ptr<IPatch> refPatchForAutoAlign_;

   bool enable3DMode_;
   BoxUnfolder boxUnfolder_;

   PatchTransferMode transferMode_;
   cv::Mat warpedPatchImg_, warpedPatchMask_;
   cv::Mat warpedPixelsMask_, srcPatchPixelsMask_;

   //////////////////////////////////////////////////////////////////////////
   // Seamless clone members
   cv::Mat srcImg32f_, patchImg32f_, dstImg32f_;
   std::vector<cv::Mat> patchRoiChans32f_, dstRoiChans32f_;
   std::vector<cv::Mat> srcChans32f_, patchChans32f_, dstChans32f_;
   std::vector<cv::Mat> gradX_, gradY_;
   cv::Mat gradientMask_, patchGradX_, patchGradY_, lap_;
   PoissonDirichletSolver<float> solver_;

   cv::Mat blendMask_;

   float snapLineThreshold_;
   bool didSnap_;

   float proximityInPixels_;
};

