#pragma once
#ifndef box_unfolder_h__
#define box_unfolder_h__

#include <vector>
#include <utility>
#include <opencv2/opencv.hpp>

#include "box_reconstructor.h"

class BoxUnfolder
{
public:

   // As a general convention we'll save the back-wall quad (2D and 3D) in this order:
   //
   //         TOP_LEFT (TL)   -->     TOP_RIGHT (TR)
   //                0------------------1
   //                |                  | 
   //                |                  | |
   //                |                  | v
   //                |                  |
   //                3------------------2
   //       BOTTOM_LEFT (BL)  <--   BOTTOM_RIGHT (BR)
   //
   enum Quantile { TOP_LEFT, TOP_RIGHT, BOTTOM_RIGHT, BOTTOM_LEFT, NUM_QUANTILES };

   // Initialize unfolder: generate all the required homographies, but no warping done yet.
   // Returns true on success.
   bool init(cv::Size const& imgSize, cv::Matx33f const R, cv::Matx33f const K, std::vector<cv::Point> backwall2D, std::vector<cv::Point3f> backwall3D, float verticalDistanceOfCameraFromFloor = 1.f);
   bool init(cv::Size const& imgSize, cv::Matx33f const R, float verticalFoV, std::vector<cv::Point3f> backwall3D, float verticalDistanceOfCameraFromFloor = 1.f);

#ifdef WITH_JSON
   bool init(cv::Size const& imgSize, std::string const& jsonFileName, float verticalDistanceOfCameraFromFloor = 1.f);
#endif

   // Given an input image, warp all the walls to be in flat and frontal. 
   // Can be used for both the image and the mask.
   // The results are returned in the 'outUnfoldedWalls' array, indexed by the Wall enum.
   // Non-visible walls return an empty image
   // 
   // If 'removeBlankImages' is true, then if the number of non-zero pixels in the unfolded, single channel, image is 0,
   // the the corresponding element in 'outUnfoldedWalls' will be empty.
   // This is useful for avoiding calling the inpainting when the mask did not overlap a particular wall.
   // The cost of setting this to true is an extra single pass over the image to find non-zero pixels.
   // Returns true on success.
   bool unfold(cv::Mat const& img, std::vector<cv::Mat>& outUnfoldedWalls, bool removeBlankImages = false);
   bool refold(std::vector<cv::Mat> const& unfoldedWalls, cv::Mat& outImg);

   // Given a point in the image, return the corresponding wall-image and the projected point in the wall image coordinates.
   bool projectPointImgToWall(cv::Point2f const& ptInImg, cv::Point2f& ptOnWall_out, Wall& wall_out) const;

   // Given a point on a particular wall image, return the corresponding image-point
   bool projectPointWallToImg(cv::Point2f const& ptOnWall, Wall wall, cv::Point2f& ptInImg_out, bool restrictToImgPolygon = true) const;

   // Returns the scale factor from 3D coordinates to the wall-image pixels
   float wallImageScale(Wall wall) const;

   // returns the size of each of the unfolded/warped images.
   bool getUnfoldedWallImageSizes(std::vector<cv::Size>& warpedImgSizes) const;

   void drawPolygons();

   // Draws the 2D polygon of 'wall' on 'img' with 'color'.
   // If thickness < 0 then, the polygon will be filled with 'color' 
   void drawPolygon(cv::Mat& img, Wall wall, cv::Scalar const& color, int thickness=1, int lineType=8) const;

private:
   void project3DTo2D( std::vector<cv::Point3f> const& pts3d, std::vector<cv::Point2f>& pts2d );

   // Find the 2D polygons on the images coming from each of the box faces
   bool findBoxFacePolygons();

   // find projections of all wall polygons
   bool createWallPolygonHomographies();

   // calculate actual homographies.
   void findHomographies( int wall );

   // Add to box face polygons all edges coming from projections of the box edges. 
   void addBoxEdgesToPolygons();

   // Add the image corners to the appropriate box face polygon. 
   void addImageCornersToPolygons();

   // Find axis aligned bounding box of 3D point set.
   // Returns std::pair<min,max>
   std::pair<cv::Vec3f,cv::Vec3f> boundingBox( std::vector<cv::Vec3f> const& polygon3D );

   // Create a valid K from image size and vertical FoV
   bool generateK(double verticalFoVDeg );

private:
   cv::Size imgSize_;
   cv::Matx33f K_, R_;
   BoxReconstructor boxer_;

   // Note: This member might be removed and exposed through BoxConstructor instead
   std::vector<cv::Point2f> backwall2D_;

   // the image polygon of each wall
   struct BoxFaceInfo
   {
      std::vector<cv::Point> polygon2D;         // in input image coordinate
      std::vector<cv::Vec3f> polygon3D;         // in 3D world coordinates, based on calibration
      std::pair<size_t,size_t> longestPolyEdge; // The vertexes of the longest polygon2D edge (in image pixels)
      float maxEdgeLength;                      // The length is pixels of the longest polygon2D edge
      float imgScale;
      std::pair<cv::Vec3f,cv::Vec3f> boundingBox;
      cv::Point2f srcQuad[NUM_QUANTILES];
      cv::Point2f dstQuad[NUM_QUANTILES];
      cv::Size2f dstSize;
      cv::Mat homography;
   };
   std::vector<BoxFaceInfo> boxFacePolygons_;
};


//////////////////////////////////////////////////////////////////////////

template<typename PixelType> 
inline bool isPtInImg( cv::Point_<PixelType> pt, cv::Size const& sz )
{
   return (0 <= pt.x && pt.x < sz.width && 0 <= pt.y && pt.y < sz.height);
}



#endif // box_unfolder_h__