#pragma once

#include <algorithm> // for std::max, std::min
#include <opencv2/opencv.hpp>


//////////////////////////////////////////////////////////////////////////


bool grow( cv::Mat &img, cv::Size const &sz, int imgType )
{
   if (img.empty() || imgType != img.type() || img.cols < sz.width || img.rows < sz.height)
   {
      img.create(cv::Size(std::max(img.cols,sz.width), std::max(img.rows, sz.height)), imgType);
      return true;
   }
   return false;
}


//////////////////////////////////////////////////////////////////////////


struct MatSignature
{
   MatSignature(const cv::Mat& m)
   {
      datastart = m.datastart;
      dataend   = m.dataend;
      flags     = m.flags;
   }
   bool operator == (const MatSignature& s) const { return flags == s.flags && datastart == s.datastart && dataend == s.dataend; }

   void *datastart, *dataend;
   int flags;
};


//////////////////////////////////////////////////////////////////////////


template <typename CallableAction>
class ReallocGuard
{
public:
   ReallocGuard(cv::Mat const& guarded, CallableAction action): 
      guarded_(guarded),
      orgMatSig_(guarded),
      action_(action)
   {}

   ~ReallocGuard()
   {
      if (!(MatSignature(guarded_) == orgMatSig_))
         action_();
   }

private:
   cv::Mat const& guarded_;
   MatSignature orgMatSig_;
   CallableAction action_;
};


template <typename CallableAction>
ReallocGuard<CallableAction> make_realloc_guard(cv::Mat const& guarded, CallableAction action)
{  return ReallocGuard<CallableAction>(guarded, action); }


//////////////////////////////////////////////////////////////////////////

// If the image is smaller than size, then reallocate it.
// Returns a ReallocGuard that will call action if the image is reallocated again after creation and before 
// the guard goes out of scope.
template <typename CallableAction>
ReallocGuard<CallableAction> grow_and_guard( cv::Mat &img, cv::Size const &sz, int imgType, CallableAction action)
{
   grow(img, sz, imgType);
   return make_realloc_guard(img, action); 
}


#define STRING_JOIN2(arg1, arg2) DO_STRING_JOIN2(arg1, arg2)
#define DO_STRING_JOIN2(arg1, arg2) arg1 ## arg2
#define GROW_AND_GUARD(img, sz, imgType, action) \
   auto STRING_JOIN2(realloc_guard_, __LINE__) = grow_and_guard(img, sz, imgType, action)

#define REALLOC_GUARD(img, action) \
   auto STRING_JOIN2(realloc_guard_, __LINE__) = make_realloc_guard(img, action)



