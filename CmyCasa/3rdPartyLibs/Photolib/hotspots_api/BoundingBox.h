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

#ifndef __Homestyler__BoundingBox__
#define __Homestyler__BoundingBox__

#include <iostream>

class BoundingBox
{
public:
    /*
     *  Constructor - creates a bounding box
     *  
     *  init_x - X-coordinate of initial point that is added to the box
     *  init_y - Y-coordinate of initial point that is added to the box
     */
    BoundingBox(int init_x, int init_y);
    
    /*
     *  Destructor
     */
    ~BoundingBox() {};
    
    /*
     *  Adds a valid point to the current bounding box
     */
    void addPoint(int x, int y);
    
private:
    int x_min_;
    int y_min_;
    int x_max_;
    int y_max_;
    uint32_t _nb_of_visible_pixels;
    
private:
    friend class HotspotsGenerator;
};

#endif /* defined(__Homestyler__BoundingBox__) */
