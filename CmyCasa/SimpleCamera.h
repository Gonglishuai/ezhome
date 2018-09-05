//
//  SimpleCamera.h
//  Homestyler
//
//  Created by Avihay Assouline on 3/16/14.
//
//
#import <GLKit/GLKit.h>
#import <Foundation/Foundation.h>

#define CAMERA_DEFAULT_VFOV     (62.70671f)
#define CAMERA_DEFAULT_HEIGHT   (1.5f)

// The simple camera model is a Right-Handed coordinates camera
// that is consistent with OpenGL's camera (Negative Z is forward)
@interface SimpleCamera : NSObject

#pragma mark - Alter camera
- (void)setCameraHeight:(float)height;

#pragma mark - Export to JSON
- (NSDictionary*)JSONFormatWithScale:(float)scale;

// TMP: TO REMOVE
- (GLKMatrix3)sceneAlignedCameraRotationMatrix;
- (void)setupWithRotationMatrixAndGravity:(GLKMatrix3)matrix gravity:(GLKVector3)gravity;
- (float)angleOfScreenRotation;
- (GLKMatrix3)headingMatrix;
- (float)horizonalFOV:(GLfloat)ratio;
- (GLKVector3)gravityVectorForDevice;

// END OF: TO REMOVE

#pragma mark - Graphics matrices required for rendering
- (GLKMatrix4)cameraMatrix;
- (GLKMatrix4)projectionMatrix;
- (GLKMatrix3)rotationMatrix;

#pragma mark - Camera world properties
@property GLKVector3    position;
@property GLKVector3    target;
@property GLKVector4    viewport;   // Currently not supported in camera. A part of the view controller.
@property GLKVector3    gravity;



#pragma mark - Field of view properties
@property float         aspectRatio;
@property float         fovVertical;
@property float         nearZ;
@property float         farZ;

#pragma mark - Rotation properties
@property float         yaw;    // Rotation around the Z axis (Positive angle goes from positive X axis to positive Y axis)
@property float         roll;   // Rotation around the X axis (Positive angle goes from positive Y axis to positive Z axis)
@property float         pitch;  // Rotation around the Y axis (Positive angle goes from positive Z axis to positive X axis)

@end
