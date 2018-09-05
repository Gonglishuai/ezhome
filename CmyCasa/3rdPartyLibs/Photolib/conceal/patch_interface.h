#pragma once

#include <memory>
#include <vector>
#include <opencv2/opencv.hpp>

#include "conceal_defs.h"

class IPatch
{
public:
   enum PatchConfinement { MOVE_FREELY=0, CONFINE_TO_IMAGE=1, CONFINE_TO_WALL=2 };

   typedef std::shared_ptr<IPatch> Handle;

   virtual bool isPtInQuad(cv::Point2f const& pt) const;
   virtual bool selectPatch(cv::Point2f const& touchPt, float proximity = 0.f) = 0;
   virtual bool moveTo( cv::Point2f const& touchPt )   = 0;
   virtual bool nudge( cv::Point const& offset )       = 0;
   virtual bool setPatchSideSize(size_t patchSideSize) = 0;
   virtual Handle clone()                              = 0;
   virtual cv::Point2f center() const                  = 0;
   virtual cv::RotatedRect ellipse() const             = 0;
   virtual bool shrunkenQuad(int shrinkAmountInPixels, Quad2f& quadOut) = 0;
   virtual float radius();

   // Given a point, returns true of the point was within 'snapThresh' of the any of the 2 axis-lines
   // passing through the patch center, and if so, updates 'pt' to the snapped value.
   virtual bool snapToCenterLines(cv::Point2f& pt, float snapThresh) = 0;

   virtual bool intersects(Handle const& rhs);
   virtual void draw(cv::Mat& img, cv::Scalar const& col, int thickness = 1, int lineType=8);

   // Draws the confinement zone polygon to which the patch center belongs.
   // In 2D mode it is simply the image rectangle.
   // In 3D mode it will draw the wall polygon.
   // The function will draw the zone on 'img' with 'color'.
   // If thickness < 0 then, the zone will be filled with 'color' 
   virtual void drawConfinementZone(cv::Mat& img, cv::Scalar const& color, int thickness=1, int lineType=8) const = 0;

   Quad2f const& quad() const { return quad_; }

protected:
   virtual float radiusSqr()  = 0; // return the squared patch radius
   virtual bool touchSelectTest( cv::Point2f const& touchPt, float proximity );

   Quad2f quad_;
};

