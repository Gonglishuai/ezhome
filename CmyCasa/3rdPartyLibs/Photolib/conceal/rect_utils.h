#pragma once

#include <opencv2/opencv.hpp>


namespace rect_utils
{
   //////////////////////////////////////////////////////////////////////////
   // Move 'innerRect' so that it is completely enclosed within 'outerRect'
   // Returns false if innerRect is too big to be fully enclosed
   template <typename T>
   inline bool confine( cv::Rect_<T>& innerRect, cv::Rect_<T> const& outerRect )
   {
      if (outerRect.width < innerRect.width || outerRect.height < innerRect.height)
         return false;

      innerRect.x = std::max(innerRect.x, outerRect.x);
      innerRect.y = std::max(innerRect.y, outerRect.y);

      innerRect.x -= std::max(static_cast<T>(0), (innerRect.x + innerRect.width ) - (outerRect.x + outerRect.width ));
      innerRect.y -= std::max(static_cast<T>(0), (innerRect.y + innerRect.height) - (outerRect.y + outerRect.height));
      return true;
   }


   //////////////////////////////////////////////////////////////////////////


   // Move 'rect' so that it is enclosed within a given size 'sz'
   // Returns false if innerRect is too big to be fully enclosed
   template <typename T, typename U>
   inline bool confine( cv::Rect_<T>& rect, cv::Size_<U> const& sz )
   {  
      return confine(rect, cv::Rect_<T>(static_cast<T>(0), static_cast<T>(0), static_cast<T>(sz.width), static_cast<T>(sz.height)));
   }


   //////////////////////////////////////////////////////////////////////////
   // Clip 'innerRect' so that the remainder is completely enclosed within 'outerRect'
   // Returns false if the clipped rect is empty
   template <typename T>
   inline bool clip( cv::Rect_<T>& innerRect, cv::Rect_<T> const& outerRect )
   {
      innerRect &= outerRect;
      return (0 < innerRect.width) && (0 < innerRect.height);
   }


   //////////////////////////////////////////////////////////////////////////

   // Clip 'innerRect' so that the remainder is completely enclosed within Size 'sz'
   // Returns false if the clipped rect is empty
   template <typename T>
   inline bool clip( cv::Rect_<T>& rect, cv::Size const& sz )
   {  
      return clip(rect, cv::Rect_<T>(static_cast<T>(0), static_cast<T>(0), static_cast<T>(sz.width), static_cast<T>(sz.height)));
   }


   //////////////////////////////////////////////////////////////////////////

   // Get center point of a rect.
   template <typename T>
   inline cv::Point_<T> center(cv::Rect_<T> const& rect)
   {
      return cv::Point_<T>(rect.x + rect.width/2, rect.y + rect.height/2);
   }


   //////////////////////////////////////////////////////////////////////////


   // Create a rect around a center point with size 'sz'
   template <typename T, typename U>
   inline cv::Rect_<T> createAroundCenter(cv::Point_<T> const& center, cv::Size_<U> const& sz)
   {
      return cv::Rect_<T>(center.x - static_cast<T>(sz.width )/2, 
         center.y - static_cast<T>(sz.height)/2, 
         static_cast<T>(sz.width), 
         static_cast<T>(sz.height));
   }


   //////////////////////////////////////////////////////////////////////////


   // Create a 'side' x 'side' rect around the center point 'center'.
   template <typename T, typename U>
   inline cv::Rect_<T> createAroundCenter(cv::Point_<T> const& center, U const& side)
   {
      return createAroundCenter(center, cv::Size_<U>(side, side));
   }

}
