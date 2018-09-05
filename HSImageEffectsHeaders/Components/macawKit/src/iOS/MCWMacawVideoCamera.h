//
//  MCWMacawVideoCamera.h
//  macawDemo
//
//  Created by Benjamin Luke on 2013-10-02.
//  Copyright (c) 2013 autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCWImageView.h"
#import "MCWMacawEffect.h"

typedef enum { kMacawVideoOrientationLandscapeLeft, kMacawVideoOrientationLandscapeRight, kMacawVideoOrientationPortrait, kMacawVideoOrientationPortraitUpsidedown } MCWMacawVideoOrientation;

@interface MCWMacawVideoCamera : NSObject

- (MCWMacawVideoCamera *) initWithView:(MCWImageView *)view andEffect:(MCWMacawEffect *)effect;

/*
 The effect that will be applied to the video stream,
 this can be changed between any frame
 */
@property (nonatomic, strong) MCWMacawEffect * effect;

- (void) startProcessingFrames;
- (void) stopProcessingFrames;
- (void) setFrameRate:(NSUInteger)fps;
- (void) switchCameras;
- (void) setOrientation:(MCWMacawVideoOrientation) orientation;

@end
