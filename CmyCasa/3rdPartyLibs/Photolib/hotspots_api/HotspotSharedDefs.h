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

#ifndef Homestyler_HotspotDefs_h
#define Homestyler_HotspotDefs_h

///////////////////////////////////////////////////////
//              ENUMS AND TYPES                      //
///////////////////////////////////////////////////////

typedef enum hotspots_type_t
{
    HOTSPOT_POINT_TYPE_ABSOLUTE = 0,
    HOTSPOT_POINT_TYPE_RELATIVE_TO_CENTER
} HotspotsType;


// C Struct detailing the information provided by image resizer
// Fields description:
// original_width - The original image width that the hotspot Json was created in (Source: JSON)
// original_height - The original image height that the hotspot Json was created in (Source: JSON)
// pre_crop_resized_img_width - The new image width before any cropping was performed (Source: EXIF)
// pre_crop_resized_img_height - The new image height before any cropping was performed (Source: EXIF)
// smartfit_offset_x - The offset of horizontal smartfit that was applied to the image (Source: EXIF)
// smartfit_offset_y - The offset of vertical smartfit that was applied to the image (Source: EXIF)
//
// NOTE: When using relative-to-center coordinates, the smart fit parameters are ignored as they are
// not necessary for computation.
typedef struct image_resizer_info_t
{
    uint32_t    original_width;
    uint32_t    original_height;
    uint32_t    pre_crop_resized_img_width;
    uint32_t    pre_crop_resized_img_height;
    uint32_t    smartfit_offset_x;
    uint32_t    smartfit_offset_y;
} ImageResizerInfo;

#endif
