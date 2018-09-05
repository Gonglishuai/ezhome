//
//  PaintProtocols.h
//  Homestyler
//
//  Created by Avihay Assouline on 2/10/14.
//
//

#import <Foundation/Foundation.h>

///////////////////////////////////////////////////////
//                  ENUMS & TYPEDEFS                 //
///////////////////////////////////////////////////////

typedef enum PaintMode
{
    ePaintModeColor = 0,
    ePaintModeWallpaper = 1,
    ePaintModeFloor = 2
} PaintMode;

typedef enum PaintItemTypes
{
    ePaintFill = 0,
    ePaintLine = 1,
    ePaintFreeLine =  2
} PaintItemType;

typedef enum WallSide
{
	WallNone = 0,
	WallLeft = 1,
	WallFront = 2,
	WallRight = 3,
	WallFloor = 4,
	WallCeilling = 5,
    WallAll = 6
} WallSide;

