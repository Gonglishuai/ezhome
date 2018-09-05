#include <cassert>
#include "poisson_blender.h"


void PoissonBlender::init( cv::Mat const& srcImg )
{
   assert(!srcImg.empty() && srcImg.rows && srcImg.cols && CHANNELS == srcImg.channels());
   //Blender::init(srcImg);
   srcSize_ = srcImg.size();
   cv::Mat paddedImg;
   PoissonNeumannSolver<float>::makeOptimalPaddedImage(srcImg, paddedImg);
   cv::Mat img32F;
   paddedImg.convertTo(img32F, CV_32FC3);
   std::vector<cv::Mat> chans;
   cv::split(img32F, chans);
   for (int c=0; c<CHANNELS; ++c)
      calcGradients(chans[c], srcGradient_[c][DX], srcGradient_[c][DY]);

   minMaxLoc(paddedImg, &srcMinVal_/*, &srcMaxVal_*/);
}


//////////////////////////////////////////////////////////////////////////


void PoissonBlender::updateWallpaper( cv::Mat const& wallpaper )
{
   assert(!wallpaper.empty() && wallpaper.size() == srcSize_ && CV_8UC3 == wallpaper.type());
   // Blender::updateWallpaper(wallpaper);
   cv::Mat paddedImg;
   PoissonNeumannSolver<float>::makeOptimalPaddedImage(wallpaper, paddedImg);
   cv::Mat img32F;
   paddedImg.convertTo(img32F, CV_32FC3);
   std::vector<cv::Mat> chans;
   cv::split(img32F, chans);
   for (int c=0; c<CHANNELS; ++c)
      calcGradients(chans[c], wallpaperGradient_[c][DX], wallpaperGradient_[c][DY]);
}


//////////////////////////////////////////////////////////////////////////


bool PoissonBlender::blend( cv::Mat const& mask, cv::Mat& dst )
{
   cv::Rect srcROI(0,0,srcSize_.width, srcSize_.height);
   for (int c=0; c<CHANNELS; ++c)
   {
      for (int d=0; d<GRADS_NUM; ++d)
      {
         srcGradient_[c][d].copyTo(fusedGradients_[d]);  // copy src gradients 
         wallpaperGradient_[c][d](srcROI).copyTo(fusedGradients_[d](srcROI), mask); // overwrite with wallpaper grads inside mask
      }
      calcLaplacian(fusedGradients_[DX], fusedGradients_[DY], laplacian_);
      if (!poissonSolver_.solve(laplacian_, blendedImg_[c]))
         return false;

      // Find minimum value of source image for later properly off-setting the result.
      double blendedMinVal;
      minMaxLoc(blendedImg_[c], &blendedMinVal);
      blendedImg_[c] += srcMinVal_ - blendedMinVal; // Offset minimum value to correct position.

//       double blendedMinVal, blendedMaxVal;
//       minMaxLoc(blendedImg_[c], &blendedMinVal, &blendedMaxVal);
//       blendedImg_[c] -= blendedMinVal; 
//       blendedImg_[c] *= srcMaxVal_ / (blendedMaxVal - blendedMinVal);
   }
   cv::Mat res32;
   cv::merge(blendedImg_, 3, res32);
   res32.convertTo(dst, CV_8UC3);
   return true;
}


//////////////////////////////////////////////////////////////////////////


void PoissonBlender::reset()
{
   poissonSolver_.clear();
   Blender::reset();
}


//////////////////////////////////////////////////////////////////////////


void PoissonBlender::calcGradients( cv::Mat const& srcImg32F, cv::Mat& gxImg, cv::Mat& gyImg )
{
   assert(CV_32FC1 == srcImg32F.type() && !srcImg32F.empty());
   assert(srcImg32F.rows && srcImg32F.cols);

   gxImg.create(srcImg32F.size(), srcImg32F.type());
   gyImg.create(srcImg32F.size(), srcImg32F.type());

   int H = gxImg.rows;
   int W = gxImg.cols;

   float* f = reinterpret_cast<float*>(srcImg32F.data);
   float *gx = reinterpret_cast<float*>(gxImg.data);
   float *gy = reinterpret_cast<float*>(gyImg.data);

   // obtain gradients
   for(int ii = 0; ii < H * W; ii++)
   {
      gx[ii] = 0;
      gy[ii] = 0;
   }

   //gx
   for(int ii = 0; ii < H; ii++)
   {
      for(int jj = 0; jj < W-1; jj++)
      {
         int idx = ii*W + jj;
         gx[idx] = f[idx+1] - f[idx];
      }
   }

   //gy
   for(int ii = 0; ii < H-1; ii++)
   {
      for(int jj = 0; jj < W; jj++)
      {
         int idx = ii*W + jj;
         gy[idx] = f[idx+W] - f[idx];
      }
   }
}

void PoissonBlender::calcLaplacian( cv::Mat const& gxImg, cv::Mat const& gyImg, cv::Mat& laplacianImg )
{
   assert(CV_32FC1 == gxImg.type() && !gxImg.empty());
   assert(CV_32FC1 == gyImg.type() && !gyImg.empty());
   assert(gxImg.rows && gxImg.cols && gxImg.size() == gyImg.size());

   laplacianImg.create(gxImg.size(), gxImg.type());

   int H = gxImg.rows;
   int W = gxImg.cols;

   float *gx         = reinterpret_cast<float*>(gxImg.data);
   float *gy         = reinterpret_cast<float*>(gyImg.data);
   float* laplacian  = reinterpret_cast<float*>(laplacianImg.data);

   laplacianImg.setTo(0);

   // last col of gx is made 0
   for(int ii = 0 ; ii < H;ii++)
   {
      int idx = ii*W + (W-1);
      gx[idx] = 0;
   }

   // last row of gy is made 0
   for(int jj = 0 ; jj < W; jj++)
   {
      int idx = (H-1)*W + jj;
      gy[idx] = 0;
   }

   // calculate f ; top row of gy (ii = 0)
   for(int jj = 0 ; jj < W; jj++) 
   {
      laplacian[jj] += gy[jj] ;
   }

   // rest of the rows of gy
   for(int ii = 1 ; ii < H;ii++)
   {
      for(int jj = 0 ; jj < W; jj++)
      {
         int idx = ii*W + jj;
         laplacian[idx] +=  gy[idx] - gy[idx-W];
      }
   }


   // first col of gx (jj = 0)
   for(int ii = 0 ; ii < H;ii++)
   {
      int idx = ii*W;
      laplacian[idx] += gx[idx];
   }	

   //rest cols of gx
   for(int ii = 0 ; ii < H;ii++)
   {
      for(int jj = 1 ; jj < W; jj++)
      {
         int idx = ii*W + jj;
         laplacian[idx] += gx[idx] - gx[idx-1];
      }
   }
}