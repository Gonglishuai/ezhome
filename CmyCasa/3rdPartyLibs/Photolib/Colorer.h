#pragma once
#include <vector>
#include <opencv2/opencv.hpp>

#define MAX_NUM_OF_AUTOMATIC_SCRIBBLES 16
typedef enum SCRIBBLES_ORDER {FirstS  = 0x0001, SecondS = 0x0002, ThirdS = 0x0004, FourthS = 0x0008, 
   FifthS  = 0x0010, SixthS = 0x0020, SeventhS = 0x0040, EighthS = 0x0080,
   NinethS  = 0x0100, TenthS = 0x0200, EleventhS = 0x0400, TwelvethS = 0x0800,
   ThirteenthS  = 0x1000, FourteenthS = 0x2000, FifteenthS = 0x4000, SixteenthS = 0x8000} SCRIBBLES_ORDER;

namespace photolib 
{
   class Colorer 
   {
   public:
      IplImage* getRecolorMask(const IplImage* const source, IplImage* scribbles, int & numOfScribbles, IplImage* fillMaskOrder = NULL, const IplImage* const sourceNoLight = NULL, int negScribbSdvMargin = 20, int mode=2, int colorFillTol=3) const;

   private:
      int findSmoothingKernelSize(const IplImage* const source, std::vector<CvPoint> pointsVector) const;
      IplImage* fill(const IplImage* const image,const CvScalar& color,  const IplImage*  const scribbles, IplImage* finalMask, IplImage* fillMaskOrder, int & numOfScribbles, std::vector<CvPoint> & posScribbs, int colorFillTol=3) const;
      int PrepareRecolorMask(const IplImage* const source, const CvScalar& color,  IplImage* scribbles, IplImage* maskFinal, IplImage* maskOrderFinal, const IplImage* const sourceNoLight, int & numOfScribbles, int negScribbSdvMargin = 20, float resizeRatio = 1.0, int mode =2, int colorFillTol = 3) const;
      void addAutoNeg(const IplImage* const source, std::vector<CvPoint> posScribbs, IplImage* scribblesImage, int negScribbSdvMargin = 20) const;
      void CorrectMasks(const IplImage* const source, IplImage* const maskFinal, IplImage* const maskOrderFinal) const;

      static const SCRIBBLES_ORDER scribblesOrder[MAX_NUM_OF_AUTOMATIC_SCRIBBLES];
   };
}