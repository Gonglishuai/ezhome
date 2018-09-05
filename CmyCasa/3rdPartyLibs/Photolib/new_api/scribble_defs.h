#pragma once
#ifndef scribble_defs_h__
#define scribble_defs_h__

#include <vector>
#include <opencv2/opencv.hpp>

typedef std::vector<cv::Point> Scribble;
enum ScribbleType { NEGATIVE, POSITIVE, NUM_TYPES };
enum ScribbleGroup { MANUAL_SCRIBBLE, PREDEFINED_MASK_SCRIBBLE, AUTO_FILL_SCRIBBLE, NUM_GROUPS };

#endif // scribble_defs_h__
