#pragma once
#ifndef box_reconstructor_h__
#define box_reconstructor_h__

#include <opencv2/opencv.hpp>

// Global enums
enum Quantile { TOP_LEFT, TOP_RIGHT, BOTTOM_RIGHT, BOTTOM_LEFT, NUM_QUANTILES };
enum Wall { BACK_WALL, LEFT_WALL, RIGHT_WALL, FLOOR, CEILING, NUM_WALLS };

// Reconstruct axis aligned 3D box and any points on it.
// Assumptions:
//    1. The camera is assumed to be contained within the box;
//    2. The camera Center-of-Projection is at the world origin (0,0,0);
//    3. The box walls are orthogonal and parallel to the world axes; 
//    4. The 2D image/camera coordinates:
//          X: Left -> Right
//          Y: Top  -> Bottom
//    5. The 3D axes are different than 2D image/camera 2D coordinates: Right-hand rule system
//          X: Left -> Right
//          Y: Grows up: Bottom -> Top - This is different than the image Y axis.
//          Z: Grows forward away from the camera. Z grows towards the visible horizon. 
//    6. The height of the camera CoP off the floor sets the global scale.
//     
class BoxReconstructor
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

   // Initialize with camera parameters
   bool init(cv::Matx33f const& K, cv::Matx33f const& R, float verticalDistanceOfCameraFromFloor);

   // Reconstruct the 3D coordinates of the provided backwall corrdinates.
   bool reconstructBackWall(cv::Vec2f const quad2D[NUM_QUANTILES], cv::Vec3f quad3D[NUM_QUANTILES]);

   // Given a 2D image point, find the 3D point lying on the Wall 'wall' 
   // with the camera being at a distance of 'offsetOfCameraFromPlane' from the wall 
   bool reconstruct3DPointOnAxisAlignedPlane(cv::Point2f const& imgPoint, Wall wall, float offsetOfCameraFromWall, cv::Vec3f& out3DPoint)
   { return reconstruct3DPointOnAxisAlignedPlane(imgPoint, boxWallNormals_[wall], offsetOfCameraFromWall, out3DPoint); }

   void reconstruct3DPointOnBox(cv::Point2f const& imgPoint, cv::Vec3f& outPt3D, Wall& wall);

   bool reconstruct3DPointOnWall(cv::Point2f const& imgPoint, cv::Vec3f& outPt3D, Wall wall)
   {  return reconstruct3DPointOnAxisAlignedPlane(imgPoint, wall, cameraDistranceFromWall(wall), outPt3D); }

   // Project 3D point onto image and retirn 2D coordinates
   cv::Vec2f projectToImage(cv::Vec3f const& P3D);

   float cameraDistranceFromWall(Wall w);

private:
   // Given a 2D image point, find the 3D point lying on the plane 
   // with normal 'planeNormal' at distance 'offsetOfCameraFromPlane' from the camera 
   bool reconstruct3DPointOnAxisAlignedPlane(cv::Point2f const& imgPoint, cv::Matx31f const& planeNormal, float offsetOfCameraFromPlane, cv::Vec3f& out3DPoint);


private:
   cv::Matx33f K_, invK_, R_;
   float offsetOfCameraFromFloor_;

   cv::Vec2f backWallQuad2D_[NUM_QUANTILES];
   cv::Vec3f backWallQuad3D_[NUM_QUANTILES];

   cv::Vec3f boxWallNormals_[NUM_WALLS];
};

#endif // box_reconstructor_h__
