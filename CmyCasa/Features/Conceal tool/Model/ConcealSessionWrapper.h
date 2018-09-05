//
// Created by Berenson Sergei on 3/2/14.
// Copyright (c) 2014 SB Tech. All rights reserved.
//


#import <Foundation/Foundation.h>

#include "conceal_session.h"
#include "alpha_blend.h"
#include "conceal_defs.h"

@interface ConcealSessionWrapper : NSObject

@property(nonatomic) BOOL mode3dEnabled;
- (instancetype)initWithInitialImage:(UIImage *)image patchSideSize:(size_t)patchSize json3dCube:(NSData *)jsonStr;
- (BOOL)setupConcealWrapper:(UIImage *)image patchSize:(size_t)patchSize jsonStr:(NSData *)jsonStr;
- (void)startConcealWork;
- (void)stopConcealWork;
- (size_t)getPatchSideSize;
- (void)setPatchSizeSize:(size_t)patchSize;
- (BOOL)moveSelectedPatchTo:(CGPoint)patchTouch ;
- (void)selectPatch:(CGPoint)touchPatch;
- (WhichPatch)getCurrentPatch;
- (void)draw;
- (UIImage*)redraw;
- (void)updateSourceImageForConcealer:(UIImage *)image;
- (UIImage*)applyChangeToSrcImage;
- (UIImage*)getSourceImage;
- (CGPoint)getCenterOfPatchType:(WhichPatch)patchType;
- (PatchTransferMode)getCurrentPatchTransferMode;
- (PatchMode)getCurrentPatchMode;
- (PatchShape)getCurrentPatchShape;
- (Boolean)setPatchMode:(PatchMode)mode;
- (void)setPatchTransferMode:(PatchTransferMode)newmode;
- (void)setPatchShape:(PatchShape)newmode;
- (NSArray*)getPatchCorners:(WhichPatch)patchOption withShrinkSize:(int)size;
- (void)selectSpecificPatch:(WhichPatch)patch;
- (void)nudgeWithPoint:(CGPoint)point;

@end