//
//  NSObject wrapper for an enum representing different drawing modes
//
//  DrawMode.h
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

enum DrawModeType {
	DM_NORMAL = 0,
	DM_PICKING = 1,
	};

@interface DrawMode : NSObject
@property (assign, atomic) enum DrawModeType mode;

+(DrawMode*)normalDrawMode; // Normal drawing mode.
+(DrawMode*)pickingDrawMode; // Color picking mode.
-(id)initWithMode:(enum DrawModeType)type;
-(bool)isNormalRenderMode;
-(bool)isPickingRenderMode;
@end
