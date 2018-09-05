#pragma once

#include "patch_interface.h"
#include "box/box_unfolder.h"

//////////////////////////////////////////////////////////////////////////
// Utility function
template<typename T, int size>
inline int array_size(T(&)[size]){ return size; }
//////////////////////////////////////////////////////////////////////////


class Patch3D: public IPatch
{
public:
   Patch3D(cv::Size imgSize, cv::Point2f const& center, float patchSideSize, BoxUnfolder const& boxUnfolder, PatchConfinement confinement, cv::Point2f const& fixedPointFor3DScale, size_t minPatchSideSize = 15);

   virtual bool selectPatch(cv::Point2f const& touchPt, float proximity = 0.f);
   virtual bool moveTo( cv::Point2f const& touchPt );
   virtual bool nudge( cv::Point const& offset );
   virtual bool setPatchSideSize( size_t patchSideSize );
   virtual Handle clone();
   virtual cv::Point2f center() const                    { return center_;  }
   virtual cv::RotatedRect ellipse() const               { return ellipse_; }
   virtual bool snapToCenterLines( cv::Point2f& pt, float snapThresh );
   virtual void drawConfinementZone(cv::Mat& img, cv::Scalar const& color, int thickness=1, int lineType=8) const;
   virtual bool shrunkenQuad( int shrinkAmountInPixels, Quad2f& quadOut );
   virtual float radiusSqr();

private:
   typedef cv::Rect_<float> Rect2f;
   struct PatchInfo
   {
      cv::Point2f centerImg, centerWall;
      Quad2f quadImg;
      Rect2f rectWall;
      Wall wall;
   };

   bool calcPixelToWorldScale(cv::Point2f const& refImgPoint);
   bool createPatchAroundPoint(cv::Point2f const& center, float patchSideSize, int confinement, PatchInfo& patchInfo_out ) const;
   bool movePatchOnWall( cv::Point2f const& touchPtOnWall );

   bool projectWallRectToImage( Rect2f const& patchRectOnWall, int confinement, Quad2f& quad, cv::Point2f& center, Wall wall ) const;

   // utility function
   void rectToQuad(Rect2f const& rect, Quad2f& quad_out) const;
   void rectToQuad(Rect2f const& rect, cv::Point2f* quad_out) const;
   cv::RotatedRect getPatchEllipse() const;
   void updateFromTemporary();

   bool isPatchTooSmall(Quad2f const& quad);

private:
   PatchConfinement confinement_;
   cv::Size imgSize_;

   BoxUnfolder const& boxUnfolder_;
   std::vector<cv::Size> unfoldedImgSizes_;
   float patchSideSize_;
   float pixelToWorldScale_;

   cv::Point2f center_;
   Wall currentWall_;
   Rect2f patchRectOnWall_;

   cv::Point2f selectionAnchorOnWall_;

   PatchInfo tmpPatchInfo_;
   cv::RotatedRect ellipse_;
   size_t minPatchDiagSquared_;
};

