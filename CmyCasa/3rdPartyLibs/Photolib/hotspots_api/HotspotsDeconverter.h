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

#ifndef __Homestyler__HotspotsDeconverter__
#define __Homestyler__HotspotsDeconverter__

#include <iostream>
#include "HotspotSharedDefs.h"
#include "HotspotResult.h"


///////////////////////////////////////////////////////
//                  CLASS                            //
///////////////////////////////////////////////////////

class HotspotsDeconverter
{
public:
    
    /*
     *   Constructor - Generates a HotspotsDeconverter object
     */
    explicit HotspotsDeconverter();
    
    /*
     *   Initializer
     */
    bool init(uint32_t target_width, uint32_t target_height);
    
    /*
     *   Destructor
     */
    ~HotspotsDeconverter();

    /*
    *   convertHotspotResultUsingImageInfo
    *
    *   info - The information from the image resizer regarding the source and target images
    *   converted_result - An output argument that the generator will fill with the hotspot results
    */
    void convertHotspotResultUsingImageInfo(HotspotResult *result_to_convert, ImageResizerInfo *info);
    
    void convertHotspotUsingImageInfo(HotspotInfo *hotspot, ImageResizerInfo *info, HotspotsType type);
private:
    uint32_t target_width_;
    uint32_t target_height_;
};

#endif /* defined(__Homestyler__HotspotsDeconverted__) */
