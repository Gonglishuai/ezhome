//
//  DrawMode.m
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import "DrawMode.h"

@implementation DrawMode

@synthesize mode;
+(DrawMode*)normalDrawMode {
	static DrawMode* normalDrawMode;
	if (normalDrawMode == nil) normalDrawMode = [[DrawMode alloc] initWithMode:DM_NORMAL];
	return normalDrawMode;
}

+(DrawMode*)pickingDrawMode {
	static DrawMode* pickingDrawMode;
	if (pickingDrawMode == nil) pickingDrawMode = [[DrawMode alloc] initWithMode:DM_PICKING];
	return pickingDrawMode;
}

-(id)initWithMode:(enum DrawModeType)type {
	if (self = [super init]) {
		self.mode = type;
	}
	return self;
}
-(bool)isNormalRenderMode {
	return self.mode == DM_NORMAL;
}

-(bool)isPickingRenderMode {
	return self.mode == DM_PICKING;
}

@end
