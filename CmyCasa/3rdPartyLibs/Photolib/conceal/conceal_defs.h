#pragma once

#include <vector>
#include <opencv2/opencv.hpp>

//////////////////////////////////////////////////////////////////////////
// enums

enum WhichPatch         { SOURCE_PATCH, TARGET_PATCH, NO_PATCH };
enum PatchMode          { PATCH_2D, PATCH_3D };
enum PatchTransferMode  { PATCH_COPY, SEAMLESS_CLONE, MIXTURE_MODE };
enum PatchShape         { SQUARE_PATCH, CIRCULAR_PATCH };

//////////////////////////////////////////////////////////////////////////
// typdefs

typedef std::vector<cv::Point2f> Quad2f;

