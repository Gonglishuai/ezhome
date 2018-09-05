#pragma once

inline void convertColor(cv::Scalar const& src, cv::Scalar& dst, int code)
{
   cv::Scalar_<unsigned char> src8u(cv::saturate_cast<uchar>(src.val[0]), 
                                    cv::saturate_cast<uchar>(src.val[1]), 
                                    cv::saturate_cast<uchar>(src.val[2]), 
                                    cv::saturate_cast<uchar>(src.val[3]));
   cv::Mat srcColorMat(cv::Size(1,1), CV_8UC3, src8u.val);

   cv::Scalar_<unsigned char> dst8u;
   cv::Mat dstColorMat(1,1,CV_8UC3, dst8u.val);
   cv::cvtColor(srcColorMat, dstColorMat, code);
   dst = dst8u;
}

