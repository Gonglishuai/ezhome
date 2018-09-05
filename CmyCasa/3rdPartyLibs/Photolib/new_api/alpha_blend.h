#pragma once

#include <opencv2/opencv.hpp>

template <class T>
inline T DIVIDE_BY_255(T const& r) { return ((r + 1 + (r >> 8)) >> 8); } // See http://stackoverflow.com/a/8070071/135862 . Correct for any r < 65535

// inline uchar blend8U(uchar const& srcA, uchar const& alpha, uchar const& srcB) 
// {  return srcB + DIVIDE_BY_255(alpha * ( srcA - srcB )); }

/*#define DIVIDE_BY_255(r) (((r) + 1 + ((r) >> 8)) >> 8)*/
#define blend8U(srcA, alpha, srcB) ((srcB) + DIVIDE_BY_255((alpha)*((srcA)-(srcB))))

// Perform alpha blending: dst = srcA*alpha + srcB*(1 - alpha)
// All images must be of the same size and preallocated.
// 'srcA', 'srcB' and 'dst' must be of type 8UC3
// 'alphaMask' must be of type 8UC1 and will be scaled to the [0-1] range
inline bool alpha_blend(cv::Mat const& srcA, cv::Mat const& alphaMask, cv::Mat const& srcB, cv::Mat& dst)
{
   if (srcA.empty() || srcB.empty() || alphaMask.empty())
      return false;

   dst.create(srcA.size(), srcA.type());

   if (srcA.size() != srcB.size() || srcA.size() != alphaMask.size() || srcA.size() != dst.size())
      return false;

   if (CV_8UC3 != srcA.type() || CV_8UC3 != srcB.type() || CV_8UC3 != dst.type() || CV_8UC1 != alphaMask.type())
      return false;

   using namespace cv;

   int cols = srcA.cols;
   int rows = srcA.rows;

   // Optimization for images with pixels without row padding (e.g. no ROIs)
   if (srcA.isContinuous() && srcB.isContinuous() && alphaMask.isContinuous() && dst.isContinuous())
   {
      // If all the images are composed of pixels in contiguous memory (no padding),
      // the we can run the outer loop below just once, and the inner loop will actually loop over all the 
      // pixels of the image, not just over a single row.
      cols *= rows;
      rows = 1;
   }

   for (int r = 0; r < rows; ++r)
   {
      auto pixA  = srcA.ptr<Vec3b>(r,0);
      auto pixB  = srcB.ptr<Vec3b>(r,0);
      auto alpha = alphaMask.ptr<uchar>(r,0);
      auto dstPix = dst.ptr<Vec3b>(r,0);

      auto alphaEnd = alpha + cols; // one-after-last pixel in row

      for (; alpha != alphaEnd; ++alpha, ++pixA, ++pixB, ++dstPix)
      {
         switch (*alpha)
         {
         case 0:
            *dstPix = *pixB;
            continue;

         case 255:
            *dstPix = *pixA;
            continue;
         }
   
         auto alphaComp = 255 - *alpha; // complement

         // We'll use shift instead of division since test show that:
         // 1. It is faster
         // 2. There is at most an error of 1 gray value which is not important here (in about 50% of the possible combinations) 
         // 3. There is no overflow with this calculation, so no need for clamping.
         *dstPix = Vec3b( ((*alpha)*(*pixA)[0] + alphaComp*(*pixB)[0])>>8,
                          ((*alpha)*(*pixA)[1] + alphaComp*(*pixB)[1])>>8,
                          ((*alpha)*(*pixA)[2] + alphaComp*(*pixB)[2])>>8);

//          *dstPix = Vec3b(saturate_cast<uchar>(((*pixA)[0]*alphaRef + (*pixB)[0]*alphaComp)/255),
//                          saturate_cast<uchar>(((*pixA)[1]*alphaRef + (*pixB)[1]*alphaComp)/255),
//                          saturate_cast<uchar>(((*pixA)[2]*alphaRef + (*pixB)[2]*alphaComp)/255));
      }
   }

   return true;
}


//////////////////////////////////////////////////////////////////////////


// Perform alpha blending with a single color: dst = color*alpha + srcB*(1 - alpha)
inline bool alpha_blend(cv::Scalar const& color, cv::Mat const& alphaMask, cv::Mat const& srcB, cv::Mat& dst)
{
   if (srcB.empty() || alphaMask.empty() || dst.empty())
      return false;

   if (srcB.size() != alphaMask.size() || srcB.size() != dst.size())
      return false;

   if (CV_8UC3 != srcB.type() || CV_8UC3 != dst.type() || CV_8UC1 != alphaMask.type())
      return false;

   using namespace cv;

   int cols = alphaMask.cols;
   int rows = alphaMask.rows;

   // Optimization for images with pixels without row padding (e.g. no ROIs)
   if (srcB.isContinuous() && alphaMask.isContinuous() && dst.isContinuous())
   {
      // If all the images are composed of pixels in contiguous memory (no padding),
      // the we can run the outer loop below just once, and the inner loop will actually loop over all the 
      // pixels of the image, not just over a single row.
      cols *= rows;
      rows = 1;
   }

   auto b = saturate_cast<uchar>(color.val[0]); 
   auto g = saturate_cast<uchar>(color.val[1]); 
   auto r = saturate_cast<uchar>(color.val[2]); 

   Vec3b col(b,g,r);

   int preMulTableR[256];
   int preMulTableG[256];
   int preMulTableB[256];

   for (int i=0; i<256; ++i)
   {
      preMulTableR[i] = i*r; 
      preMulTableG[i] = i*g; 
      preMulTableB[i] = i*b; 
   }

   for (int r = 0; r < rows; ++r)
   {
      auto pixB  = srcB.ptr<Vec3b>(r,0);
      auto alpha = alphaMask.ptr<uchar>(r,0);
      auto dstPix = dst.ptr<Vec3b>(r,0);

      auto alphaEnd = alpha + cols; // one-after-last pixel in row

      for (; alpha != alphaEnd; ++alpha, ++pixB, ++dstPix)
      {
         switch (*alpha)
         {
         case 0:
            *dstPix = *pixB;
            continue;

         case 255:
            *dstPix = col;
            continue;
         }
						   
      auto alphaComp = 255 - *alpha; // complement

      // Shift right by 8 instead of division by 255.
      // approximation is good enough for our usage as error is at most 1 gray-value and it's much faster
      *dstPix = Vec3b((preMulTableB[*alpha] + (*pixB)[0]*alphaComp)>>8,
                      (preMulTableG[*alpha] + (*pixB)[1]*alphaComp)>>8,
                      (preMulTableR[*alpha] + (*pixB)[2]*alphaComp)>>8);
      }
   }

   return true;
}


//////////////////////////////////////////////////////////////////////////


// Blend a 4-channel image onto a background image.
// Can be used in-place when 'background' and 'dst' are the same image. 
inline bool alpha_blend(cv::Mat const& srcWithAlphaChannel, cv::Mat const& background, cv::Mat& dst, float globalOpacity = 1)
{
   if (srcWithAlphaChannel.empty() || background.empty() || dst.empty())
      return false;

   if (srcWithAlphaChannel.size() != background.size() || srcWithAlphaChannel.size() != dst.size())
      return false;

   if (CV_8UC4 != srcWithAlphaChannel.type() || CV_8UC3 != background.type() || CV_8UC3 != dst.type())
      return false;

   using namespace cv;

   MatConstIterator_<Vec4b> itA        = srcWithAlphaChannel.begin<Vec4b>(), itA_end = srcWithAlphaChannel.end<Vec4b>();
   MatConstIterator_<Vec3b> itB        = background.begin<Vec3b>();
   MatIterator_<Vec3b> itDst           = dst.begin<Vec3b>();

   if (1 == globalOpacity)
   {
      // This can be further optimized, e.g.by
      // 1. Using a*s1 + (1-a)*s2 == a*s1 + s2 - a*s2 == a*(s1-s2) + s2
      // 2. Avoid division by 255 by using >> 8 (approximate by 256). 
      //    Corner case of 255 is never reached sue to switch().
      for( ; itA != itA_end; ++itA, ++itB, ++itDst )
      {
         Vec4b const& pixA = *itA;
         Vec3b const& pixB = *itB;
         switch (pixA[3])
         {
         case 0:
            *itDst = pixB;
            continue;
         case 255:
            *itDst = Vec3b(pixA[0], pixA[1], pixA[2]);
            continue;
         }
         int alpha = pixA[3];     
         int alphaComp = 255 - alpha; // complement
         *itDst = Vec3b(saturate_cast<uchar>((pixA[0]*alpha + pixB[0]*alphaComp)/255),
            saturate_cast<uchar>((pixA[1]*alpha + pixB[1]*alphaComp)/255),
            saturate_cast<uchar>((pixA[2]*alpha + pixB[2]*alphaComp)/255));
      }
   }
   else
   {
      // global opacity is in percent, so we can calculate it out of 128 instead of 100
      // and then shift-right 7 instead of dividing.
      int opacity = int(globalOpacity*(1<<7));
      // This could probably be optimized even more
      for( ; itA != itA_end; ++itA, ++itB, ++itDst )
      {
         Vec4b const& pixA = *itA;
         Vec3b const& pixB = *itB;
         if(0 == pixA[3])
         {
            *itDst = pixB;
            continue;
         }

         int alpha = (pixA[3]*opacity) >> 7; // divide by 128     
         int alphaComp = 255 - alpha; // complement
         *itDst = Vec3b(saturate_cast<uchar>((pixA[0]*alpha + pixB[0]*alphaComp)/255),
            saturate_cast<uchar>((pixA[1]*alpha + pixB[1]*alphaComp)/255),
            saturate_cast<uchar>((pixA[2]*alpha + pixB[2]*alphaComp)/255));
      }
   }
   return true;
}