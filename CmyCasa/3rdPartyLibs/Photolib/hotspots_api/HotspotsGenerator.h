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

#ifndef __Homestyler__HotspotsGenerator__
#define __Homestyler__HotspotsGenerator__

#include <iostream>
#include <unordered_map>

#include "BoundingBox.h"
#include "HotspotResult.h"
#include "HotspotSharedDefs.h"

///////////////////////////////////////////////////////
//              OpenCV includes                      //
///////////////////////////////////////////////////////

#include <opencv2/opencv.hpp>

using namespace cv;

///////////////////////////////////////////////////////
//                  CLASS                            //
///////////////////////////////////////////////////////

class HotspotsGenerator
{
public:
    
    /*
    *   Constructor - Generates a HotspotsGenerator object
    *
    */
    explicit HotspotsGenerator();


    /*
     *  Initialize/Loads the generator with the input image for which hotspots will be produced
     *  Without properly initializing the generator an unexpected behaviour may occur
     *
     *  clearColor - The color index to treat as the clear color (a.k.a background)
     *
     *  type - Hotspot's type which will be generated using this generator
     */
    bool init(const Mat &img, uint8_t clearColor, HotspotsType type);


    /*
    *   Generate the hotspots for the current loaded image
    *
    *   boxPixelExpansion - The margin of pixels to keep from the bounding box of each object
    *
    *   result - An output argument that the generator will fill with the hotspot results
    */
    void generateHotspots(uint16_t boxPixelExpansion, HotspotResult &result);
    
    /*
    *   Destructor
    */
    ~HotspotsGenerator();

private:
    void generateBoundingBoxes();
    Vec2i convertHotspotToType(uint16_t hotspot_x, uint16_t hotspot_y);
private:
    Mat originalImage_;
    uint8_t clearColor_;
    HotspotsType type_;
    std::unordered_map<uint8_t, BoundingBox*> boundingBoxes_;
};

#endif /* defined(__Homestyler__HotspotsGenerator__) */
