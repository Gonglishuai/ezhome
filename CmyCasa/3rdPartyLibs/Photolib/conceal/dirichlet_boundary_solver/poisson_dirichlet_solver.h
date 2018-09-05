#pragma once

#include <vector>
#include <type_traits>
#include <cassert>

#include <opencv2/opencv.hpp>

#include "dst.h"

//////////////////////////////////////////////////////////////////////////
// Integrating 2D Laplacian field using Poisson Solver with Dirichlet boundary conditions
template <typename DepthType = double>
class PoissonDirichletSolver
{
public:
   typedef DepthType depth_type;

   // Only support double and float
   static_assert(std::is_same<depth_type, double>::value || std::is_same<depth_type, float>::value, "PoissonDirichletSolver<> only supports double and float types.");

   // Result type will be a single channel image with depth like the template parameter
   enum { RESULT_TYPE = CV_MAKETYPE(cv::DataType<depth_type>::type, 1) };

   // Generate image gradients
   bool getGradient(cv::Mat const& img, cv::Mat& gx, cv::Mat& gy);

   // Generate Laplacian image from the gradient
   bool getLaplacian(cv::Mat const& gx, cv::Mat const& gy, cv::Mat& laplacian);
   // Generate Laplacian image directly from the image
   bool getLaplacian(cv::Mat const& img, cv::Mat& laplacian);


   // Find solution. 
   // Result will be stored in 'resImg'.
   // 'boundaryImg contains the pixel values along the image boundary. This image will be
   // changed as part of the computation.
   // 'resImg' will be a single channel image with depth like the template parameter 
   // if needed it will be reallocated internally, so an empty input image is a valid parameter.
   // Returns false on bad laplacian image size or type.
   bool solve(cv::Mat const& laplacian, cv::Mat& boundaryImg, cv::Mat& resImg );

   // Release all internal memory
   void clear();

private:
   void createEigenValues( cv::Size const& imgSize );

private:
   std::vector<depth_type> cosTableW_, cosTableH_;
   cv::Mat denomImg_;
   cv::Mat dstImg_;
};


//////////////////////////////////////////////////////////////////////////


template <typename DepthType /*= double*/>
bool PoissonDirichletSolver<DepthType>::getGradient( cv::Mat const& img, cv::Mat& gx, cv::Mat& gy )
{
   int h = img.rows;
   int w = img.cols;

   if (h < 2 || w < 2)
      return false;

   gx = cv::Mat::zeros(h, w, img.type()); 
   gy = cv::Mat::zeros(h, w, img.type()); 

   cv::Range rowSubImgRange(0,h-1); 
   cv::Range colSubImgRange(0,w-1);

   gx(rowSubImgRange,colSubImgRange) = img(rowSubImgRange,colSubImgRange+1) - img(rowSubImgRange,colSubImgRange); 
   gy(rowSubImgRange,colSubImgRange) = img(rowSubImgRange+1,colSubImgRange) - img(rowSubImgRange,colSubImgRange);
   return true;
}


//////////////////////////////////////////////////////////////////////////


template <typename DepthType /*= double*/>
bool PoissonDirichletSolver<DepthType>::getLaplacian( cv::Mat const& gx, cv::Mat const& gy, cv::Mat& laplacian )
{
   int h = gx.rows;
   int w = gx.cols;

   if (h < 2 || w < 2)
      return false;

   laplacian = cv::Mat::zeros(h, w, gx.type()); 

   cv::Range rowSubRange(0,h-1); 
   cv::Range colSubRange(0,w-1);

   //  Laplacian
   laplacian(rowSubRange+1,colSubRange)  = gy(rowSubRange+1,colSubRange) - gy(rowSubRange,colSubRange); 
   laplacian(rowSubRange,colSubRange+1) += gx(rowSubRange,colSubRange+1) - gx(rowSubRange,colSubRange);
   return true;
}


//////////////////////////////////////////////////////////////////////////


template <typename DepthType /*= double*/>
bool PoissonDirichletSolver<DepthType>::getLaplacian( cv::Mat const& img, cv::Mat& laplacian )
{
   if (img.rows < 2 || img.cols < 2)
      return false;

//    cv::Mat gx, gy;
//    getGradient(img, gx, gy);
//    getLaplacian(gx, gy, laplacian);
   cv::Laplacian(img, laplacian, cv::DataType<DepthType>::depth, 1, 1, 0, cv::BORDER_REPLICATE);

   return true;
}



//////////////////////////////////////////////////////////////////////////


template <typename DepthType>
void PoissonDirichletSolver<DepthType>::clear()
{
   // release cosine table vectors
   cosTableW_.swap(std::vector<depth_type>());
   cosTableH_.swap(std::vector<depth_type>());
   denomImg_.release();
   dstImg_.release();
}


//////////////////////////////////////////////////////////////////////////


template <typename DepthType>
bool PoissonDirichletSolver<DepthType>::solve( cv::Mat const& laplacian, cv::Mat& boundaryImg, cv::Mat& resImg )
{
   // Laplacian image must be a single channel image with depth like the template parameter
   if(RESULT_TYPE != laplacian.type())
      return false;

   if(RESULT_TYPE != boundaryImg.type())
      return false;

   int H = boundaryImg.rows;
   int W = boundaryImg.cols;

   // Solving Poisson Equation Using DST
   cv::Range rowSubImgRange(1,H-1); 
   cv::Range colSubImgRange(1,W-1); 

   //  boundary image contains image intensities at boundaries

   //////////////////////////////////////////////////////////////////////////
   // OPTIMIZE: work only along boundaries not on full image
   boundaryImg(rowSubImgRange,colSubImgRange).setTo(0); 
   cv::Mat boundaryLaplacian(cv::Mat::zeros(H,W, boundaryImg.type())); 
   boundaryLaplacian(rowSubImgRange,colSubImgRange) = -4*boundaryImg(rowSubImgRange, colSubImgRange) + boundaryImg(rowSubImgRange, colSubImgRange+1) + boundaryImg(rowSubImgRange, colSubImgRange-1) + boundaryImg(rowSubImgRange-1,colSubImgRange) + boundaryImg(rowSubImgRange+1,colSubImgRange);
   //////////////////////////////////////////////////////////////////////////

   laplacian -= boundaryLaplacian;//  subtract boundary points contribution

   //  DST over sub-image excluding boundary.
   dstImg_ = laplacian(rowSubImgRange,colSubImgRange);

   createEigenValues(dstImg_.size());

   boundaryImg.copyTo(resImg); // preserve/copy boundary pixels to result // OPTIMIZE: copy only boundary pixels

   // compute 2D sine transform using 2 calls to 1D column DST
   if (!dst(dstImg_, dstImg_) || !dst(dstImg_.t(),dstImg_))
      return false;

   dstImg_ = dstImg_.t(); 

   cv::divide(dstImg_, denomImg_, dstImg_);  // Divide by DST2 eigenvalues to get DST of solution

   // compute Inverse Sine Transform
   if (!idst(dstImg_, dstImg_) || !idst(dstImg_.t(), dstImg_))
      return false;

   resImg(rowSubImgRange, colSubImgRange) = dstImg_.t();

   return true;
}


//////////////////////////////////////////////////////////////////////////


template <typename DepthType>
void PoissonDirichletSolver<DepthType>::createEigenValues( cv::Size const& imgSize )
{
   if (denomImg_.size() == imgSize) // Nothing to do, already initialized to correct size.
      return;

   int H = imgSize.height;
   int W = imgSize.width;

   // Initialize cosine tables
   cosTableW_.resize(W);
   for(size_t j=0; j<cosTableW_.size(); ++j)
      cosTableW_[j] = static_cast<depth_type>((2.0*cos(CV_PI*(j+1)/((double)W+1)) - 2)); // the "+1" is the difference from Neumann Boundary Condition using DCT

   cosTableH_.resize(H);
   for(size_t i=0; i<cosTableH_.size(); ++i)
      cosTableH_[i] = static_cast<depth_type>((2.0*cos(CV_PI*(i+1)/( (double)H+1)) - 2));

   denomImg_.create(cv::Size(W,H), cv::DataType<DepthType>::type); // create denomImg_ with the proper depth
   DepthType* denom = reinterpret_cast<DepthType*>(denomImg_.data);
   // Compute the eigen values of the Laplacian matrix
   // denom = (2*cos(pi*x/(W  ))-2) + (2*cos(pi*y/(H  )) - 2);
   // denom = (2*cos(pi*x/(W-1))-2) + (2*cos(pi*y/(H-1)) - 2) ;
   for(int ii = 0 ; ii < H;ii++)
   {
      for(int jj = 0 ; jj < W; jj++)
      {
         int idx = ii*W + jj;
         denom[idx] = static_cast<DepthType>(cosTableW_[jj] + cosTableH_[ii]);
      }
   }
}


//////////////////////////////////////////////////////////////////////////

