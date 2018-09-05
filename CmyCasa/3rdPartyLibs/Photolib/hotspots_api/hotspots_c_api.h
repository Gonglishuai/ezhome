#pragma once

#ifndef Homestyler_hotspots_c_api_h
#define Homestyler_hotspots_c_api_h

#include <string>
#include <opencv2/opencv.hpp>
#include "HotspotSharedDefs.h"
#include "HotspotResult.h"


extern "C"
{
    ////////////////////////////////////////////////////////////////////////
    //////////////////// Hotspots Generator C API //////////////////////////
    ////////////////////////////////////////////////////////////////////////
    
    bool HotspotsGenerator_init(cv::Mat const& img, uint8_t clearColor, HotspotsType type);
    
    void HotspotsGenerator_generateHotspots(uint16_t boxPixelExpansion, HotspotResult &result);
    
    ////////////////////////////////////////////////////////////////////////
    //////////////////// Hotspots Deconverter C API ////////////////////////
    ////////////////////////////////////////////////////////////////////////
    
    bool HotspotsDeconverter_init(uint32_t target_width, uint32_t target_height);
    
    void HotspotsDeconverter_convertHotspotResultUsingImageInfo(HotspotResult *result_to_convert, ImageResizerInfo *info);
    
    void HotspotsDeconverter_convertHotspotUsingImageInfo(HotspotInfo *hotspot, ImageResizerInfo *info, HotspotsType type);
}


#endif
