#pragma once

#include <vector>
#include <type_traits>
#include <cassert>

#include <opencv2/opencv.hpp>

//////////////////////////////////////////////////////////////////////////
// Integrating 2D Laplacian field using Poisson Solver with Neumann boundary conditions
template <typename DepthType = double>
class PoissonNeumannSolver
{
public:
   typedef DepthType depth_type;

   // Only support double and float
   static_assert(std::is_same<depth_type, double>::value || std::is_same<depth_type, float>::value, "PoissonNeumannSolver<> only supports double and float types.");

   // Result type will be a single channel image with depth like the template parameter
   enum { RESULT_TYPE = CV_MAKETYPE(cv::DataType<depth_type>::type,1) };

   // Get optimal size for arbitrary image size
   static cv::Size getOptimalSize(cv::Size const& srcSize);

   // Returns the closest optimal size containing srcSize for optimal 
   // DCT operation
   static bool isOptimalSize(cv::Size const& srcSize);

   // Returns false is DCT calculation will fail on an image of this size
   // Otherwise the calculation will be performed but maybe not with optimal efficiency
   static bool isValidSize(cv::Size const& srcSize);

   // Helper static method to copy image into a 0-padded image if needed.
   // If 'img' is already optimal then 'paddedImg' will just be a reference to 'img'
   // This method can also operate on multi-channel images (even though PoissonNeumannSolver can't).
   static void makeOptimalPaddedImage(cv::Mat img, cv::Mat& paddedImgOut);

   // Find solution. 
   // isValidSize(laplacian.size())  must be true.
   // Result will be stored in 'resImg'.
   // 'resImg' will be a single channel image with depth like the template parameter 
   // if needed it will be reallocated internally, so an empty input image is a valid parameter.
   // Returns false on bad laplacian image size or type.
   bool solve( cv::Mat const& laplacian, cv::Mat& resImg );

   // Release all internal memory
   void clear();

private:
   void createEigenValues( cv::Size const& imgSize );

private:
   std::vector<depth_type> cosTableW_, cosTableH_;
   cv::Mat denomImg_;
   cv::Mat dctImg_;
};


//////////////////////////////////////////////////////////////////////////


template <typename DepthType>
void PoissonNeumannSolver<DepthType>::makeOptimalPaddedImage( cv::Mat img, cv::Mat& paddedImgOut)
{
   if (isOptimalSize(img.size()))
   {
      paddedImgOut = img;
      return;
   }

   // Copy 'img' into a properly padded image.
   cv::Size optimalSize = PoissonNeumannSolver<>::getOptimalSize(img.size());
   cv::copyMakeBorder(img, 
                      paddedImgOut, 
                      0, optimalSize.height - img.rows, 
                      0, optimalSize.width  - img.cols, 
                      cv::BORDER_CONSTANT);
}


//////////////////////////////////////////////////////////////////////////


template <typename DepthType>
inline bool PoissonNeumannSolver<DepthType>::isValidSize( cv::Size const& srcSize )
{
   if (0 == srcSize.width || 0 == srcSize.height) // can't have 0 size
      return false;

   // Both width and height must be even. Odd sizes not supported.
   return 0 == (srcSize.width % 2 || srcSize.height % 2);
}


//////////////////////////////////////////////////////////////////////////


template <typename DepthType>
inline bool PoissonNeumannSolver<DepthType>::isOptimalSize( cv::Size const& srcSize )
{
   return getOptimalSize(srcSize) == srcSize;
}


//////////////////////////////////////////////////////////////////////////


template <typename DepthType>
inline cv::Size PoissonNeumannSolver<DepthType>::getOptimalSize( cv::Size const& srcSize )
{  
   return cv::Size(2*cv::getOptimalDFTSize((srcSize.width+1)/2), 
                   2*cv::getOptimalDFTSize((srcSize.height+1)/2));
}


//////////////////////////////////////////////////////////////////////////


template <typename DepthType>
void PoissonNeumannSolver<DepthType>::clear()
{
   // release cosine table vectors
   cosTableW_.clear();
   cosTableH_.clear();
   denomImg_.release();
   dctImg_.release();
}


//////////////////////////////////////////////////////////////////////////


template <typename DepthType>
bool PoissonNeumannSolver<DepthType>::solve( cv::Mat const& laplacian, cv::Mat& resImg )
{
   if (!isValidSize(laplacian.size()))
      return false;

   // Laplacian image must be a single channel image with depth like the template parameter
   if(RESULT_TYPE != laplacian.type())
      return false;

   // Create FFT eigen values image.
   createEigenValues(laplacian.size());

   // Allocate DCT image (if needed) with requested depth type
   dctImg_.create(laplacian.size(), laplacian.type());

   //////////////////////////////////////////////////////////////////////////
   // Solve Poisson equation by integrating Laplacian image 
   // This is the heart of the code. This is where the magic happens :-)
   // 1. Transform Laplacian to DCT (real-FFT) space
   // 2. Divide by "eigen values"
   // 3. Convert back to image/pixel space - this is the reconstructed image up to 
   //    an unknown global gray-value offset.
   cv::dct(laplacian, dctImg_);              // Calculate DCT
   cv::divide(dctImg_, denomImg_, dctImg_);  // Divide by DCT eigenvalues to get FFT of solution (division by 0 will assign 0, which is what we want.)
   cv::idct(dctImg_, resImg);                // Inverse DCT
   return true;
}


//////////////////////////////////////////////////////////////////////////


template <typename DepthType>
void PoissonNeumannSolver<DepthType>::createEigenValues( cv::Size const& imgSize )
{
   if (denomImg_.size() == imgSize) // Nothing to do, already initialized to correct size.
      return;

   int H = imgSize.height;
   int W = imgSize.width;

   // Initialize cosine tables
   cosTableW_.resize(W);
   for(size_t j=0; j<cosTableW_.size(); ++j)
      cosTableW_[j] = (depth_type)(2*cos(CV_PI*j/( (depth_type) W)) - 2);

   cosTableH_.resize(H);
   for(size_t i=0; i<cosTableH_.size(); ++i)
      cosTableH_[i] = (depth_type)(2*cos(CV_PI*i/( (depth_type) H)) - 2);

   denomImg_.create(cv::Size(W,H), RESULT_TYPE);
   depth_type* denom = reinterpret_cast<depth_type*>(denomImg_.data);
   // Compute the eigen values of the Laplacian matrix
   // denom = (2*cos(pi*x/W)-2) + (2*cos(pi*y/(H)) - 2);
   for(int ii = 0 ; ii < H;ii++)
   {
      for(int jj = 0 ; jj < W; jj++)
      {
         int idx = ii*W + jj;
         denom[idx] = cosTableW_[jj] + cosTableH_[ii];
      }
   }
}


//////////////////////////////////////////////////////////////////////////

