
#include <string>
#include <highgui.h>


//////////////////////////////////////////////////////////////////////////
// Boost Test Framework
#include <boost/test/unit_test.hpp>

//////////////////////////////////////////////////////////////////////////
// Tested API
#include "rect_utils.h"

//////////////////////////////////////////////////////////////////////////


using namespace cv;
using namespace rect_utils;

BOOST_AUTO_TEST_SUITE(Rect_utils_Tests)


BOOST_AUTO_TEST_CASE(Rect_creation_tests)
{
   {
      auto r = createAroundCenter(Point(5,5),10);
      BOOST_CHECK_EQUAL(0 , r.x);
      BOOST_CHECK_EQUAL(0 , r.y);
      BOOST_CHECK_EQUAL(10 , r.width);
      BOOST_CHECK_EQUAL(10 , r.height);
   }
   {
      auto r = createAroundCenter(Point2f(5,5),20);
      BOOST_CHECK_EQUAL(-5 , r.x);
      BOOST_CHECK_EQUAL(-5 , r.y);
      BOOST_CHECK_EQUAL(20 , r.width);
      BOOST_CHECK_EQUAL(20 , r.height);
   }
   {
      auto r = createAroundCenter(Point2f(5,5), Size(10,20));
      BOOST_CHECK_EQUAL(0 , r.x);
      BOOST_CHECK_EQUAL(-5 , r.y);
      BOOST_CHECK_EQUAL(10 , r.width);
      BOOST_CHECK_EQUAL(20 , r.height);
   }
}

BOOST_AUTO_TEST_CASE(Rect_center_tests)
{
   {
      Point c0(0,0);
      auto r = createAroundCenter(c0, Size(10,4));
      BOOST_CHECK_EQUAL(c0 , center(r));
   }
   {
      Point c0(0,0);
      auto r = createAroundCenter(c0, Size(5,11));
      BOOST_CHECK_EQUAL(c0 , center(r));
   }
   {
      Point2f c0(0,0);
      auto r = createAroundCenter(c0, Size(10,4));
      BOOST_CHECK_EQUAL(c0 , center(r));
   }
   {
      Point2f c0(0,0);
      auto r = createAroundCenter(c0, Size(5,11));
      BOOST_CHECK_EQUAL(c0 , center(r));
   }
   {
      Point2f c0(0,0);
      auto r = createAroundCenter(c0, Size(-5,-11));
      BOOST_CHECK_EQUAL(c0 , center(r));
   }
   {
      Point c0(0,0);
      auto r = createAroundCenter(c0, Size_<float>(5,11));
      BOOST_CHECK_EQUAL(c0 , center(r));
   }
}

BOOST_AUTO_TEST_CASE(Rect_clip_tests)
{
   {
      // clipping with itself returns self
      Rect r1(Point(0,0), Size(10,10));
      auto r2 = r1;
      BOOST_CHECK(clip(r1, r1));
      BOOST_CHECK_EQUAL(r1, r2);
   }
   {
      // clipping with large size returns self
      Rect r1(Point(0,0), Size(10,10));
      auto r2 = r1;
      BOOST_CHECK(clip(r1, Size(100,100)));
      BOOST_CHECK_EQUAL(r1, r2);
   }
   {
      // clipping with large size returns self
      Rect r1(Point(90,90), Size(10,10));
      auto r2 = r1;
      BOOST_CHECK(clip(r1, Size(100,100)));
      BOOST_CHECK_EQUAL(r1, r2);
   }

   {
      // clipping with outside fails 
      Rect r0(Point(0,0), Size(10,10));
      {
         auto r1 = r0;
         BOOST_CHECK(!clip(r1, Rect(10,0,100,100)));
      }
      {
         auto r1 = r0;
         BOOST_CHECK(!clip(r1, Rect(0,10,100,100)));
      }
      r0.x = 90;
      r0.y = 90;
      {
         auto r1 = r0;
         BOOST_CHECK(!clip(r1, Rect(0,0,90,100)));
      }
      {
         auto r1 = r0;
         BOOST_CHECK(!clip(r1, Rect(0,0,100,90)));
      }
   }
   {
      // clipping large rect with small returns small
      Rect big(Point(0,0), Size(10,10));
      Rect small(Point(0,0), Size(1,1));
      BOOST_CHECK(clip(big, small));
      BOOST_CHECK_EQUAL(big, small);
   }
   {
      // clipping small rect with big returns small
      Rect big(Point(0,0), Size(10,10));
      Rect small(Point(0,0), Size(1,1));
      auto smallOrg = small;
      BOOST_CHECK(clip(small, big));
      BOOST_CHECK_EQUAL(small, smallOrg);
   }
   {
      // clipping works as expect
      Rect r1(-5,-5,10,10);
      Size sz(10,10);
      BOOST_CHECK(clip(r1, sz));
      BOOST_CHECK_EQUAL(r1.tl(), Point(0,0));
      BOOST_CHECK_EQUAL(r1.size(), Size(5,5));
   }
   {
      // clipping works as expect
      Rect r1(5,5,10,10);
      Size sz(10,10);
      BOOST_CHECK(clip(r1, sz));
      BOOST_CHECK_EQUAL(r1.tl(), Point(5,5));
      BOOST_CHECK_EQUAL(r1.size(), Size(5,5));
   }
}


BOOST_AUTO_TEST_CASE(Rect_confine_tests)
{
   {
      // confine to itself returns self
      Rect r1(Point(0,0), Size(10,10));
      auto r2 = r1;
      BOOST_CHECK(confine(r1, r1));
      BOOST_CHECK_EQUAL(r1, r2);
   }
   {
      // confine to large size returns self
      Rect r1(Point(0,0), Size(10,10));
      auto r2 = r1;
      BOOST_CHECK(confine(r1, Size(100,100)));
      BOOST_CHECK_EQUAL(r1, r2);
   }
   {
      // confine to large size returns self
      Rect r1(Point(90,90), Size(10,10));
      auto r2 = r1;
      BOOST_CHECK(confine(r1, Size(100,100)));
      BOOST_CHECK_EQUAL(r1, r2);
   }
   {
      // confine to rect too small fails
      Rect r1(Point(0,0), Size(10,10));
      Rect r2(Point(0,0), Size(10,9));
      BOOST_CHECK(!confine(r1, r2));
   }
   {
      // confine to rect too small fails
      Rect r1(Point(0,0), Size(10,10));
      Rect r2(Point(0,0), Size(9,10));
      BOOST_CHECK(!confine(r1, r2));
   }

   {
      // confine works
      Rect r0(Point(0,0), Size(10,10));
      auto r1 = r0;
      Rect r2(Point(100,100), Size(100,100));
      BOOST_CHECK(confine(r1, r2));
      BOOST_CHECK_EQUAL(r1.tl(), r2.tl());
      BOOST_CHECK_EQUAL(r1.size(), r0.size());
   }
   {
      // confine works
      Rect r0(Point(200,200), Size(10,10));
      auto r1 = r0;
      Rect r2(Point(0,0), Size(100,100));
      BOOST_CHECK(confine(r1, r2));
      BOOST_CHECK_EQUAL(r1.br(), r2.br());
      BOOST_CHECK_EQUAL(r1.size(), r0.size());
   }
   {
      // confine works with size too
      Rect r0(Point(0,0), Size(10,10));
      auto r1 = r0;
      Size sz(Size(100,100));
      BOOST_CHECK(confine(r1, sz));
      BOOST_CHECK_EQUAL(r1.tl(), r0.tl());
      BOOST_CHECK_EQUAL(r1.size(), r0.size());
   }


}




//////////////////////////////////////////////////////////////////////////

BOOST_AUTO_TEST_SUITE_END()

