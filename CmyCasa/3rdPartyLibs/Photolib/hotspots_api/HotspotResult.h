//  Copyright (c) 2008 by Autodesk, Inc.
//  All rights reserved.
//
//  The information contained herein is confidential and proprietary to
//  Autodesk, Inc., and considered a trade secret as defined under civil
//  and criminal statutes.  Autodesk shall pursue its civil and criminal
//  remedies in the event of unauthorized use or misappropriation of its
//  trade secrets.  Use of this information by anyone other than authorized
//  employees of Autodesk, Inc. is granted only under a written non-
//  disclosure agreement, expressly prescribing the scope and manner of
//  such use.

#ifndef __Homestyler__HotspotResult__
#define __Homestyler__HotspotResult__


#include <iostream>
#include <unordered_map>
#include "BoundingBox.h"
#include "HotspotSharedDefs.h"

///////////////////////////////////////////////////////
//              OpenCV includes                      //
///////////////////////////////////////////////////////

#include <opencv2/opencv.hpp>

using namespace cv;

///////////////////////////////////////////////////////
//              ENUMS AND TYPES                      //
///////////////////////////////////////////////////////

typedef struct hotspot_info_t
{
    Vec2i _coords;
    uint32_t _nbOfVisiblePixels;
} HotspotInfo;

typedef std::unordered_map<std::string, HotspotInfo> HotspotMap;


///////////////////////////////////////////////////////
//                  CLASS                            //
///////////////////////////////////////////////////////

class HotspotResult
{
public:
    /*
     *   Constructor - Generates a Hotspot Result object
     */
    HotspotResult();
    
    ~HotspotResult();
    
    HotspotsType getType();
    
    void setType(HotspotsType type);
    
    void addHotspotToResult(uint32_t index, int16_t hotspot_x, int16_t hotspot_y, uint32_t nbOfVisiblePixels);
    
    void addHotspotToResult(uint32_t index, const Vec2i &hotspot, uint32_t nbOfVisiblePixels);
    
    void addHotspotToResult(std::string key, int16_t hotspot_x, int16_t hotspot_y, uint32_t nbOfVisiblePixels);
    
    HotspotMap& getHotspotsMap();
    
private:
    HotspotsType 	type_;
    HotspotMap 		hotspotMap_;
};


#endif /* defined(__Homestyler__HotspotResult__) */
