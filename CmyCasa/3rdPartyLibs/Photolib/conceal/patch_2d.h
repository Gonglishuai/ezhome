#pragma once

#include "patch_interface.h"

class Patch2D: public IPatch
{
public:

   Patch2D(cv::Size imgSize, cv::Point2f const& center, size_t patchSideSize, size_t minPatchSideSize = 5);

   virtual bool selectPatch(cv::Point2f const& touchPt, float proximity = 0.f);
   virtual bool moveTo( cv::Point2f const& touchPt );
   virtual bool nudge( cv::Point const& offset );   
   virtual bool setPatchSideSize( size_t patchSideSize );
   virtual Handle clone();
   virtual bool intersects( Handle const& rhs );
   virtual cv::Point2f center() const;
   virtual cv::RotatedRect ellipse() const;
   virtual bool snapToCenterLines( cv::Point2f& pt, float snapThresh );
   virtual void drawConfinementZone( cv::Mat& img, cv::Scalar const& color, int thickness=1, int lineType=8 ) const;
   virtual bool shrunkenQuad( int shrinkAmountInPixels, Quad2f& quadOut );
   virtual float radiusSqr();
   virtual float radius();

private:
   void moveQuadInImage( cv::Point2f const& offset );

private:
   cv::Size imgSize_;
   cv::Point2f selectionAnchor_; // stores the selection touch-point coordinates
   size_t minPatchSideSize_;
};

