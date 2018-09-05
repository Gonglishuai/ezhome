#pragma once

#include "blender.h"
#include "poisson_neumann_solver.h"

class PoissonBlender: public Blender
{
public:
   void init(cv::Mat const& srcImg);
   virtual void updateWallpaper(cv::Mat const& wallpaper);
   virtual bool blend(cv::Mat const& mask, cv::Mat& dst);
   virtual void reset();

private:
   void calcGradients(cv::Mat const& srcImg32F, cv::Mat& gxImg, cv::Mat& gyImg );
   void calcLaplacian( cv::Mat const& gxImg, cv::Mat const& gyImg, cv::Mat& laplacianImg );

private:
   cv::Size srcSize_;
   double srcMinVal_/*, srcMaxVal_*/;
   PoissonNeumannSolver<float> poissonSolver_;
   enum { DX = 0, DY = 1, GRADS_NUM = 2, CHANNELS = 3 };
   cv::Mat srcGradient_[CHANNELS][GRADS_NUM];
   cv::Mat wallpaperGradient_[CHANNELS][GRADS_NUM];
   cv::Mat fusedGradients_[GRADS_NUM];
   cv::Mat laplacian_;
   cv::Mat blendedImg_[CHANNELS];
};

