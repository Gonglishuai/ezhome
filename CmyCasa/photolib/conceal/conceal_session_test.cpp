
#include <string>
#include <iostream>
#include <opencv2/opencv.hpp>
#include <highgui.h>

#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

//////////////////////////////////////////////////////////////////////////
// Boost Test Framework
#include <boost/test/unit_test.hpp>

//////////////////////////////////////////////////////////////////////////
// Tested API
#include "conceal_session.h"

//////////////////////////////////////////////////////////////////////////

using namespace std;

BOOST_AUTO_TEST_SUITE(ConcealSession_Tests)


BOOST_AUTO_TEST_CASE(ConcealSession_is_readyness_tests)
{
   ConcealSession session;
   BOOST_CHECK(!session.isReady());
   BOOST_CHECK(session.init(cv::imread("test2.jpg"), 20));
   BOOST_CHECK(session.isReady());
   BOOST_CHECK(session.reset());
   BOOST_CHECK(!session.isReady());

   BOOST_CHECK(session.init(cv::imread("test2.jpg"), 20));
   BOOST_CHECK(session.isReady());
   BOOST_CHECK(session.reset());
   BOOST_CHECK(!session.isReady());
}

BOOST_AUTO_TEST_CASE(ConcealSession_get_set_mode)
{
   ConcealSession session;
   BOOST_CHECK(session.init(cv::imread("test2.jpg"), 20));

   BOOST_CHECK( session.setPatchMode(PATCH_2D));
   BOOST_CHECK_EQUAL(session.getPatchMode(), PATCH_2D);
   BOOST_CHECK(!session.setPatchMode(PATCH_3D));
   BOOST_CHECK_NE(session.getPatchMode(), PATCH_3D);
   BOOST_CHECK_EQUAL(session.getPatchMode(), PATCH_2D);
}

BOOST_AUTO_TEST_CASE(ConcealSession_3D_mode_before_init_fails)
{
   ConcealSession session;
   BOOST_CHECK(!session.setPatchMode(PATCH_3D));
}

BOOST_AUTO_TEST_CASE(ConcealSession_3D_mode_after_init_fails)
{
   ConcealSession session;
   BOOST_CHECK(session.init(cv::imread("test2.jpg"), 20));
   BOOST_CHECK(!session.setPatchMode(PATCH_3D));
}

BOOST_AUTO_TEST_CASE(ConcealSession_3D_mode_after_init3D_ok)
{
   ConcealSession session;
   BOOST_CHECK(session.init(cv::imread("test2.jpg"), 20));
   BOOST_CHECK(session.init3D("test2.jpg.json"));
   BOOST_CHECK(session.setPatchMode(PATCH_3D));
   BOOST_CHECK_EQUAL(session.getPatchMode(), PATCH_3D);
}

BOOST_AUTO_TEST_CASE(ConcealSession_patch_size_setting)
{
   ConcealSession session;
   BOOST_CHECK_EQUAL(0, session.getPatchSideSize());
   BOOST_CHECK(session.init(cv::imread("test2.jpg"), 20));
   BOOST_CHECK_EQUAL(20, session.getPatchSideSize());
   BOOST_CHECK(session.setPatchSideSize(30));
   BOOST_CHECK_EQUAL(30, session.getPatchSideSize());
}


BOOST_AUTO_TEST_CASE(ConcealSession_patch_transfer_mode_works)
{
   ConcealSession session;
   BOOST_CHECK(session.setPatchTransferMode(PATCH_COPY));
   BOOST_CHECK_EQUAL(PATCH_COPY, session.getPatchTransferMode());
   BOOST_CHECK(session.setPatchTransferMode(MIXTURE_MODE));
   BOOST_CHECK_EQUAL(MIXTURE_MODE, session.getPatchTransferMode());
}

BOOST_AUTO_TEST_CASE(ConcealSession_patch_shape_works)
{
   ConcealSession session;
   BOOST_CHECK(session.setPatchShape(SQUARE_PATCH));
   BOOST_CHECK_EQUAL(SQUARE_PATCH, session.getPatchShape());
   BOOST_CHECK(session.setPatchShape(CIRCULAR_PATCH));
   BOOST_CHECK_EQUAL(CIRCULAR_PATCH, session.getPatchShape());
}


BOOST_AUTO_TEST_CASE(ConcealSession_patch_selection)
{
   auto img = cv::imread("test2.jpg");
   ConcealSession session;
   BOOST_CHECK(session.init(img, 20));
   BOOST_CHECK_EQUAL(NO_PATCH, session.getSelectedPatch());
   BOOST_CHECK_EQUAL(NO_PATCH, session.selectPatch(cv::Point(0,0)));
   BOOST_CHECK_EQUAL(TARGET_PATCH, session.selectPatch(cv::Point(  img.cols/3, img.rows/2)));
   BOOST_CHECK_EQUAL(TARGET_PATCH, session.selectPatch(cv::Point(  img.cols/3, img.rows/2) - cv::Point( 2, 2)));
   BOOST_CHECK_EQUAL(TARGET_PATCH, session.getSelectedPatch());
   BOOST_CHECK_EQUAL(NO_PATCH,         session.selectPatch(cv::Point(  img.cols/3, img.rows/2) - cv::Point(11,11)));
   BOOST_CHECK_EQUAL(SOURCE_PATCH, session.selectPatch(cv::Point(2*img.cols/3, img.rows/2)));
   BOOST_CHECK_EQUAL(SOURCE_PATCH, session.selectPatch(cv::Point(2*img.cols/3, img.rows/2) + cv::Point( 2, 2)));
   BOOST_CHECK_EQUAL(SOURCE_PATCH, session.getSelectedPatch());
   BOOST_CHECK_EQUAL(NO_PATCH,         session.selectPatch(cv::Point(2*img.cols/3, img.rows/2) + cv::Point(11,11)));
   BOOST_CHECK_EQUAL(NO_PATCH, session.getSelectedPatch());
}

BOOST_AUTO_TEST_CASE(ConcealSession_3D_mode_can_move_quad_near_boundary_after_aborted_move)
{
   // Set up: create image with 3D and change to 3D patch mode
   auto img = cv::imread("test2.jpg");
   ConcealSession session;
   BOOST_CHECK(session.init(img, 20));
   BOOST_CHECK(session.init3D("test2.jpg.json"));
   BOOST_CHECK(session.setPatchMode(PATCH_3D));
   BOOST_CHECK_EQUAL(session.getPatchMode(), PATCH_3D);

   // select src patch
   BOOST_CHECK_EQUAL(SOURCE_PATCH, session.selectPatch(cv::Point(2*img.cols/3, img.rows/2)));
   BOOST_CHECK(session.moveSelectedPatchTo(cv::Point(2*img.cols/3, int(img.rows/2) - 1 ))); // move up one
//   BOOST_CHECK(!session.moveSelectedPatchTo(cv::Point(689, 244))); // move patch to partially cross top boundary 
   BOOST_CHECK(session.moveSelectedPatchTo(cv::Point(689, 200)));  // move beyond from back-wall to ceiling
}

BOOST_AUTO_TEST_CASE(ConcealSession_3D_mode_can_be_initialized_with_3D_data_directly)
{
   auto img = cv::imread("test2.jpg");
   ConcealSession session;
   BOOST_CHECK(session.init(img, 20));

   {
      // parse JSON to get 3D data
      using namespace boost::property_tree;

      // Create an empty property tree object
      ptree pt;
      read_json("test2.jpg.json", pt);

      float verticalFoVDeg = pt.get<float>("Vertical-FOV");

      cv::Matx33f R(3,3,CV_32FC1);
      int elem = 0;
      ptree& pos = pt.get_child("Rotation-Matrix");
      std::for_each(std::begin(pos), std::end(pos), [&R, &elem](ptree::value_type& kv) 
      {  R.val[elem++] = kv.second.get<float>("");});

      std::vector<cv::Point3f> backwall3D(4);
      backwall3D[TOP_LEFT]     = cv::Point3f(pt.get<float>("Back-Wall-3D-Top-Left.x" ), pt.get<float>("Back-Wall-3D-Top-Left.y" ), pt.get<float>("Back-Wall-3D-Top-Left.z" ));
      backwall3D[TOP_RIGHT]    = cv::Point3f(pt.get<float>("Back-Wall-3D-Top-Right.x"), pt.get<float>("Back-Wall-3D-Top-Right.y"), pt.get<float>("Back-Wall-3D-Top-Right.z"));
      backwall3D[BOTTOM_RIGHT] = cv::Point3f(pt.get<float>("Back-Wall-3D-Bot-Right.x"), pt.get<float>("Back-Wall-3D-Bot-Right.y"), pt.get<float>("Back-Wall-3D-Bot-Right.z"));
      backwall3D[BOTTOM_LEFT]  = cv::Point3f(pt.get<float>("Back-Wall-3D-Bot-Left.x" ), pt.get<float>("Back-Wall-3D-Bot-Left.y" ), pt.get<float>("Back-Wall-3D-Bot-Left.z" ));

      BOOST_CHECK(session.init3D(R, verticalFoVDeg, backwall3D));
   }
}

BOOST_AUTO_TEST_CASE(ConcealSession_get_patch_position)
{
   // Set up: create image with 3D and change to 3D patch mode
   auto img = cv::imread("test2.jpg");
   ConcealSession session;
   BOOST_CHECK(session.init(img, 20));
   BOOST_CHECK(session.init3D("test2.jpg.json"));

   auto defaultSrcPos = cv::Point2f(2.f*img.cols/3.f, img.rows/2.f);
   BOOST_CHECK_EQUAL(session.getPatchCenterPoint(SOURCE_PATCH), defaultSrcPos);
   BOOST_CHECK_EQUAL(session.getPatchEllipse(SOURCE_PATCH).center, defaultSrcPos);
   auto quad = session.getPatchCorners(SOURCE_PATCH);
   cv::Point2f centerOfGravity = (quad[0] + quad[1] + quad[2] + quad[3]) * 0.25f;
   BOOST_CHECK_EQUAL(centerOfGravity, defaultSrcPos);
}

BOOST_AUTO_TEST_CASE(ConcealSession_fails_gracefully_on_non_3_channel_init_image)
{
   cv::Mat img4c(100,100,CV_8UC4);
   ConcealSession session;
   BOOST_REQUIRE(!session.init(img4c, 20));
}

// Verify that moving a patch to its current location is idempotent
BOOST_AUTO_TEST_CASE(ConcealSession_move_to_patch_center_leaves_patch_center_unchanged)
{
   auto img = cv::imread("test2.jpg");
   ConcealSession session;
   BOOST_CHECK(session.init(img, 70));
   BOOST_CHECK(session.setSnapLineDistance(0)); // disable snapping

   {
      // In 2D mode
      BOOST_CHECK(session.setPatchMode(PATCH_2D));
      auto srcCenter = session.getPatchCenterPoint(SOURCE_PATCH);
      BOOST_CHECK_EQUAL(SOURCE_PATCH, session.selectPatch(srcCenter));
      BOOST_CHECK(session.moveSelectedPatchTo(srcCenter));
      auto srcCenterAfterMove = session.getPatchCenterPoint(SOURCE_PATCH);
      BOOST_CHECK_EQUAL(srcCenter, srcCenterAfterMove);
   }

   {
      // In 3D mode
      BOOST_REQUIRE(session.init3D("test2.jpg.json"));
      BOOST_CHECK(session.setPatchMode(PATCH_3D));
      auto srcCenter = session.getPatchCenterPoint(SOURCE_PATCH);
      BOOST_CHECK_EQUAL(SOURCE_PATCH, session.selectPatch(srcCenter));
      BOOST_CHECK(session.moveSelectedPatchTo(srcCenter));
      auto srcCenterAfterMove = session.getPatchCenterPoint(SOURCE_PATCH);
      BOOST_CHECK_EQUAL(srcCenter, srcCenterAfterMove);
   }
}


BOOST_AUTO_TEST_CASE(ConcealSession_snap_test)
{
   auto img = cv::imread("test2.jpg");
   ConcealSession session;
   BOOST_CHECK(session.init(img, 70));
   BOOST_CHECK(session.setPatchMode(PATCH_2D));

   auto srcCenter = session.getPatchCenterPoint(SOURCE_PATCH);
   auto tgtCenter = session.getPatchCenterPoint(TARGET_PATCH);

   BOOST_REQUIRE_EQUAL(tgtCenter.y, srcCenter.y); // by default both patched are initially at the same height

   {
      // First, disable snapping.
      // Move patch by 1 pixel down and back up again. Verify all works as expected.
      BOOST_CHECK(session.setSnapLineDistance(0)); // disable snapping
      BOOST_CHECK_EQUAL(SOURCE_PATCH, session.selectPatch(srcCenter));
      BOOST_CHECK(session.moveSelectedPatchTo(srcCenter + cv::Point2f(0,1)));
      auto srcCenterAfterMove = session.getPatchCenterPoint(SOURCE_PATCH);
      BOOST_CHECK_EQUAL(srcCenter.x, srcCenterAfterMove.x);
      BOOST_CHECK_EQUAL(srcCenter.y + 1, srcCenterAfterMove.y);
      BOOST_CHECK(session.moveSelectedPatchTo(srcCenter ));
      srcCenterAfterMove = session.getPatchCenterPoint(SOURCE_PATCH);
      BOOST_CHECK_EQUAL(srcCenter, srcCenterAfterMove);
      BOOST_CHECK_EQUAL(tgtCenter.y, srcCenterAfterMove.y);
   }

   {
      // Enable snapping
      BOOST_CHECK(session.setSnapLineDistance(5));
      BOOST_CHECK_EQUAL(SOURCE_PATCH, session.selectPatch(srcCenter));
      BOOST_CHECK(session.moveSelectedPatchTo(srcCenter + cv::Point2f(0,1)));
      auto srcCenterAfterMove = session.getPatchCenterPoint(SOURCE_PATCH);
      BOOST_CHECK_EQUAL(srcCenter.x, srcCenterAfterMove.x);
      BOOST_CHECK_EQUAL(srcCenter.y, srcCenterAfterMove.y);
      BOOST_CHECK_EQUAL(tgtCenter.y, srcCenterAfterMove.y);
   }

   {
      BOOST_CHECK(session.setSnapLineDistance(5));
      BOOST_CHECK_EQUAL(SOURCE_PATCH, session.selectPatch(srcCenter));
      BOOST_CHECK(session.moveSelectedPatchTo(srcCenter + cv::Point2f(0,5))); // move by 5, this should snap
      auto srcCenterAfterMove = session.getPatchCenterPoint(SOURCE_PATCH);
      BOOST_CHECK_EQUAL(srcCenter.x, srcCenterAfterMove.x);
      BOOST_CHECK_EQUAL(srcCenter.y, srcCenterAfterMove.y);
      BOOST_CHECK_EQUAL(tgtCenter.y, srcCenterAfterMove.y);

      BOOST_CHECK(session.moveSelectedPatchTo(srcCenter + cv::Point2f(0,6))); // move by 6, this should NOT snap
      srcCenterAfterMove = session.getPatchCenterPoint(SOURCE_PATCH);
      BOOST_CHECK_EQUAL(srcCenter.x, srcCenterAfterMove.x);
      BOOST_CHECK_EQUAL(srcCenter.y + 6, srcCenterAfterMove.y);
      BOOST_CHECK_EQUAL(tgtCenter.y + 6, srcCenterAfterMove.y);
   }

//    {
//       auto img0 = img.clone();
//       session.conceal(img, img0);
//       session.draw(img0);
//       imshow("ttt", img0);
//       cv::waitKey();
//    }
}

BOOST_AUTO_TEST_CASE(ConcealSession_updateSrcImg_works_as_expected)
{
   auto img = cv::imread("test2.jpg");
   ConcealSession session;
   BOOST_CHECK(session.init(img, 70));
   cv::Mat outImg;
   BOOST_CHECK(session.getSrcImg(outImg));
   cv::Mat diff;
   cv::absdiff(img, outImg, diff);
   BOOST_CHECK_EQUAL(cv::Scalar::all(0), cv::sum(diff));
//    imshow("outImg", outImg);
//    cv::waitKey(1);

   cv::Mat dst;
   img.copyTo(dst);
   session.conceal(dst, dst);
   BOOST_CHECK(session.updateSrcImg(dst));
   BOOST_CHECK(session.getSrcImg(outImg));
   cv::absdiff(img, outImg, diff);
   BOOST_CHECK_NE(cv::Scalar::all(0), cv::sum(diff));
//    imshow("out1", outImg);
//    cv::waitKey();
}



//////////////////////////////////////////////////////////////////////////

#define NO_MANUAL_TESTS

#ifndef NO_MANUAL_TESTS
#include <iostream>
#include <algorithm>

ConcealSession concealSession;
cv::Mat srcImg;
std::string winname = "Image";
size_t patchSide = 70;

using namespace std;


void redraw()
{
   auto img = srcImg.clone();
   concealSession.conceal(srcImg, img);
   concealSession.draw(img);
   imshow(winname, img);
   cv::waitKey(1);
}


void mouseCallback(int event, int x, int y, int flags, void* userdata)
{
   if (!concealSession.isReady())
      return;

   x = std::max(0, std::min(srcImg.cols - 1, int(short(x))));
   y = std::max(0, std::min(srcImg.rows - 1, int(short(y))));

   switch(event)
   {
   case cv::EVENT_LBUTTONDOWN:
      concealSession.selectPatch(cv::Point(x,y));
      //redraw();
      break;

   case cv::EVENT_MOUSEMOVE:
      if (flags & (cv::EVENT_FLAG_LBUTTON | cv::EVENT_FLAG_RBUTTON) )
      {
         concealSession.moveSelectedPatchTo(cv::Point(x,y));
         redraw();      
      }
      break;
   }
}


BOOST_AUTO_TEST_CASE(Manual_test)
{
   std::string img_name;
   img_name = "C:/Users/adishavit/Work/Images/AppImages/tests/2.jpg";
   //img_name = "c:/Users/adishavit/Work/src/Photolib/tests/data/test2.jpg";
   //img_name = "C:/Users/adishavit/Work/src/Photolib/ios_demo/opencv_demo/subletting-cosy-room-finchley-road-mai-july-d8ad75d88d64b69800e869f5a6b8d06b.jpg";
   
   srcImg = cv::imread(img_name);
   BOOST_CHECK(concealSession.init(srcImg, patchSide));
   BOOST_CHECK(concealSession.init3D(img_name + ".json"));

   auto img = srcImg.clone();
   concealSession.draw(img);
   cv::imshow(winname, img);
   cv::setMouseCallback(winname, mouseCallback);

   int key;
   bool stop = false;
   while (!stop)
   {
      key = cv::waitKey();

      switch(key)
      {
      case 27: // ESC
      case 'Q': case 'q':// Quit
         stop = true;
         break;

      case '+':
      case '=':
         patchSide += 5; 
         if (!concealSession.setPatchSideSize(patchSide))
            patchSide -= 5;
         redraw();
         break;

      case '-':
         patchSide -= 5; 
         if (!concealSession.setPatchSideSize(patchSide))
            patchSide += 5;
         redraw();
         break;

      case ' ':
         concealSession.conceal(srcImg, srcImg);
         concealSession.updateSrcImg(srcImg);
         redraw();
         break;

      case '2':
         concealSession.setPatchMode(PATCH_2D);
         redraw();
         break;

      case '3':
         concealSession.setPatchMode(PATCH_3D);
         redraw();
         break;

      case 'c':
      case 'C':
         cout << "Clone mode." << endl;
         concealSession.setPatchTransferMode(PATCH_COPY);
         redraw();
         break;

      case 'p':
      case 'P':
         cout << "Poisson/Seamless-clone mode." << endl;
         concealSession.setPatchTransferMode(SEAMLESS_CLONE);
         redraw();
         break;

      case 'm':
      case 'M':
         cout << "Mixture mode." << endl;
         concealSession.setPatchTransferMode(MIXTURE_MODE);
         redraw();
         break;


      case 's':
      case 'S':
         if (CIRCULAR_PATCH == concealSession.getPatchShape())
         {
            cout << "Square patches" << endl;
            concealSession.setPatchShape(SQUARE_PATCH);
         }
         else
         {
            cout << "Circle patches" << endl;
            concealSession.setPatchShape(CIRCULAR_PATCH);
         }
         redraw();
         break;

      }
   }
   cv::destroyAllWindows();
}

#endif
//////////////////////////////////////////////////////////////////////////

BOOST_AUTO_TEST_SUITE_END()

