//
//  SimpleCamera.m
//  Homestyler
//
//  Created by Avihay Assouline on 3/16/14.
//
//

#import "SimpleCamera.h"
#import "HSMath.h"
#import "HSMacros.h"

#define DEFAULT_NEAR_Z          (0.1f)
#define DEFAULT_FAR_Z           (1000.0f)
#define DEFAULT_ASPECT_RATIO    (1024.0f/768.0f)


@interface SimpleCamera ()
@property GLKMatrix3    rotM;
@end

@implementation SimpleCamera

- (id)init
{
    if (self = [super init])
    {
        // Setup default camera rotation
        [self setupWithRotationMatrixAndGravity:GLKMatrix3Identity gravity:GLKVector3Make(0, -1, 0)];
        
        // Setup projection parameters
        self.nearZ = DEFAULT_NEAR_Z;
        self.farZ = DEFAULT_FAR_Z;
        self.aspectRatio = DEFAULT_ASPECT_RATIO;
        self.fovVertical = CAMERA_DEFAULT_VFOV;
        
        // Setup default camera position
        self.position = GLKVector3Make(0.0f, -CAMERA_DEFAULT_HEIGHT, 0.0f);
        
        self.rotM = GLKMatrix3Identity;
    }
    
    return self;
}

- (void)setCameraHeight:(float)height
{
    self.position = GLKVector3Make(self.position.x, height, self.position.z);
}

- (GLKMatrix3)rotationMatrix
{
    
    return self.rotM;
    
//    GLKMatrix3 rotMatrix = GLKMatrix3Identity;
//    
//    // Apply roll, pitch and yaw (Important to keep this order) to create the rotation matrix
//    // See: http://planning.cs.uiuc.edu/node101.html for additional information
//    rotMatrix = GLKMatrix3RotateY(rotMatrix, self.yaw);
//    rotMatrix = GLKMatrix3RotateZ(rotMatrix, self.roll);
//    rotMatrix = GLKMatrix3RotateX(rotMatrix, self.pitch);
//    
//    return rotMatrix;
}

- (GLKMatrix4)projectionMatrix
{
    return GLKMatrix4MakePerspective(GLKMathDegreesToRadians(self.fovVertical), self.aspectRatio, self.nearZ, self.farZ);
}

- (void)setupWithRotationMatrixAndGravity:(GLKMatrix3)matrix gravity:(GLKVector3)gravity
{
    self.rotM = matrix;
    
    // Setup rotation angles according to the right-handed coordinate system of OpenGL
    // i.e. Right -> positive X ; Up -> Positive Y ; Right X Up -> Positive Z
    
    // Rotation around the Y axis
    self.pitch = (float)atan2f(-matrix.m20, sqrtf( powf(matrix.m21, 2) +  powf(matrix.m22, 2)));
    
    // Rotation around the Z axis
    self.yaw = (float)atan2f(matrix.m10, matrix.m00);
    
    // Rotation around the X axis
    self.roll = (float)atan2f(matrix.m21, matrix.m22);

    self.gravity = gravity;
}


- (float)getHeadingDirectionForMatrix:(GLKMatrix3)matrix
{
    // Fix heading -- Use some geometry to find the heading (the angle of the camera direction relative to the plane)
    GLKVector3 xzPlaneNormal = GLKVector3Make(0, 1, 0);
    xzPlaneNormal = GLKMatrix3MultiplyVector3(matrix, xzPlaneNormal);
    
    GLKVector3 yzPlaneNormal = GLKVector3Normalize(GLKVector3Make(self.gravity.y, -self.gravity.x, 0));
    GLKVector3 realFront = GLKVector3Normalize(GLKVector3CrossProduct(xzPlaneNormal, yzPlaneNormal));
    realFront = GLKVector3MultiplyScalar(realFront, SIGN(realFront.z)); // make sure it's really the front and not the back
    
    GLKVector3 rotatedFront = GLKVector3Make(0, 0, 1);
    rotatedFront = GLKVector3Normalize(GLKMatrix3MultiplyVector3(matrix, rotatedFront));
    
    float direction = GLKVector3DotProduct(xzPlaneNormal, GLKVector3CrossProduct(rotatedFront, realFront));
    return acosf(BETWEEN(-1.0f,1.0f,GLKVector3DotProduct(rotatedFront, realFront))) * BIASED_SIGN(direction);
}

// Returnes a rotation matrix that aligns the current rotation matrix to the center of the scene using to the gravity vector
- (GLKMatrix3)getAlignmentRotationMatrixForMatrix:(GLKMatrix3)matrix andGravity:(GLKVector3)gravity
{
    // Get XZ plane normal with respect to current camera matrix rotation
    GLKVector3 xzPlaneNormal = GLKVector3Make(0, 1, 0);
    xzPlaneNormal = GLKMatrix3MultiplyVector3(matrix, xzPlaneNormal);
    
    float heading = [self getHeadingDirectionForMatrix:matrix];
    return GLKMatrix3MakeRotation(heading, xzPlaneNormal.x, xzPlaneNormal.y, xzPlaneNormal.z);

}

// Aligning the camera rotation matrix to display correctly with respect to the floor
// This code is used to build the camera matrix. All incoming data uses this method (3D analysis + Saved designs)
-(GLKMatrix3)sceneAlignedCameraRotationMatrix
{
    GLKMatrix3 rot = GLKMatrix3Transpose(self.rotM);
    GLKMatrix3 fixRotation = [self getAlignmentRotationMatrixForMatrix:rot andGravity:self.gravity];
    rot = GLKMatrix3Multiply(fixRotation, rot);
    rot = GLKMatrix3Multiply(GLKMatrix3Identity, rot);
    return rot;
}

// Compute heading of an input matrix
- (GLKMatrix3)headingMatrix
{
    GLKMatrix3 rot = GLKMatrix3Transpose(self.rotM);
	float heading = [self getHeadingDirectionForMatrix:rot];
	return GLKMatrix3MakeRotation(-heading, 0, 1, 0);
}

-(GLKVector3)gravityVectorForDevice
{
    // Fix gravity from unifed representation to IOS represention on device
    GLKVector3 v = self.gravity;
    GLKMatrix3 m = GLKMatrix3MakeRotation(M_PI_2, 0, 0, 1);
    return GLKMatrix3MultiplyVector3(m, v);
}

- (GLKMatrix4)cameraMatrix
{
    GLKMatrix4 modelview = GLKMatrix4Identity;
    
    // Fix camera from unifed representation to IOS represention on device
    GLKMatrix3 tt = GLKMatrix3MakeRotation(M_PI_2, 0, 0, 1);
    GLKMatrix3 rotM = GLKMatrix3Multiply(tt, [self sceneAlignedCameraRotationMatrix]);
    
    // Convert rotation matrix from 3x3 to 4x4 to support translation (a.k.a modelview)
    modelview = GLKMatrix4Make(rotM.m00, rotM.m01, rotM.m02, 0,
                               rotM.m10, rotM.m11, rotM.m12, 0,
                               rotM.m20, rotM.m21, rotM.m22, 0,
                               0, 0, 0, 1);
    
    // Set camera height and return to the user
    return GLKMatrix4Translate(modelview, self.position.x, self.position.y, self.position.x);
}

-(float)angleOfScreenRotation
{
    return angleBetween2DVectors(GLKVector2Make(self.gravityVectorForDevice.x, self.gravityVectorForDevice.y), GLKVector2Make(0, -1));
}

-(float)horizonalFOV:(GLfloat)ratio
{
    return GLKMathRadiansToDegrees(2 * atanf(tanf(GLKMathDegreesToRadians(self.fovVertical / 2)) * ratio));
}

- (NSDictionary*)JSONFormat
{
    return [self JSONFormatWithScale:1.0];
}

- (NSDictionary*)JSONFormatWithScale:(float)scale
{
    return @{ @"xPos" :     @(self.position.x * scale),
              @"yPos" :     @(self.position.y * scale),
              @"zPos" :     @(self.position.z * scale),
              @"xTar" :     @(self.target.x * scale),
              @"yTar" :     @(self.target.y * scale),
              @"zTar" :     @(self.target.z * scale),
              @"yaw" :      @(self.yaw),
              @"pitch" :    @(self.pitch),
              @"roll" :     @(self.roll)};
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeBytes:(const uint8_t *)&_rotM length:sizeof(_rotM) forKey:@"rotM"];
    [coder encodeBytes:(const uint8_t *)&_position length:sizeof(_position) forKey:@"position"];
    [coder encodeBytes:(const uint8_t *)&_target length:sizeof(_target) forKey:@"target"];
    [coder encodeBytes:(const uint8_t *)&_viewport length:sizeof(_viewport) forKey:@"viewport"];
    [coder encodeBytes:(const uint8_t *)&_aspectRatio length:sizeof(_aspectRatio) forKey:@"aspectRatio"];
    [coder encodeBytes:(const uint8_t *)&_fovVertical length:sizeof(_fovVertical) forKey:@"fovVertical"];
    [coder encodeBytes:(const uint8_t *)&_nearZ length:sizeof(_nearZ) forKey:@"nearZ"];
    [coder encodeBytes:(const uint8_t *)&_farZ length:sizeof(_farZ) forKey:@"farZ"];
    [coder encodeBytes:(const uint8_t *)&_yaw length:sizeof(_yaw) forKey:@"yaw"];
    [coder encodeBytes:(const uint8_t *)&_roll length:sizeof(_roll) forKey:@"roll"];
    [coder encodeBytes:(const uint8_t *)&_pitch length:sizeof(_pitch) forKey:@"pitch"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init])
    {
        const uint8_t *bytes = [coder decodeBytesForKey:@"rotM" returnedLength:NULL];
        CHECK_C_NULL_RETURN_NIL(bytes);
        memcpy(&_rotM, bytes, sizeof(_rotM));
        
        bytes = [coder decodeBytesForKey:@"position" returnedLength:NULL];
        CHECK_C_NULL_RETURN_NIL(bytes);
        memcpy(&_position, bytes, sizeof(_position));
        
        bytes = [coder decodeBytesForKey:@"target" returnedLength:NULL];
        CHECK_C_NULL_RETURN_NIL(bytes);
        memcpy(&_target, bytes, sizeof(_target));
        
        bytes = [coder decodeBytesForKey:@"viewport" returnedLength:NULL];
        CHECK_C_NULL_RETURN_NIL(bytes);
        memcpy(&_viewport, bytes, sizeof(_viewport));
        
        bytes = [coder decodeBytesForKey:@"aspectRatio" returnedLength:NULL];
        CHECK_C_NULL_RETURN_NIL(bytes);
        memcpy(&_aspectRatio, bytes, sizeof(_aspectRatio));
        
        bytes = [coder decodeBytesForKey:@"fovVertical" returnedLength:NULL];
        CHECK_C_NULL_RETURN_NIL(bytes);
        memcpy(&_fovVertical, bytes, sizeof(_fovVertical));
        
        bytes = [coder decodeBytesForKey:@"nearZ" returnedLength:NULL];
        CHECK_C_NULL_RETURN_NIL(bytes);
        memcpy(&_nearZ, bytes, sizeof(_nearZ));
        
        bytes = [coder decodeBytesForKey:@"farZ" returnedLength:NULL];
        CHECK_C_NULL_RETURN_NIL(bytes);
        memcpy(&_farZ, bytes, sizeof(_farZ));
        
        bytes = [coder decodeBytesForKey:@"yaw" returnedLength:NULL];
        CHECK_C_NULL_RETURN_NIL(bytes);
        memcpy(&_yaw, bytes, sizeof(_yaw));
        
        bytes = [coder decodeBytesForKey:@"roll" returnedLength:NULL];
        CHECK_C_NULL_RETURN_NIL(bytes);
        memcpy(&_roll, bytes, sizeof(_roll));
        
        bytes = [coder decodeBytesForKey:@"pitch" returnedLength:NULL];
        CHECK_C_NULL_RETURN_NIL(bytes);
        memcpy(&_pitch, bytes, sizeof(_pitch));
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    SimpleCamera *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy != nil)
    {
        copy.position = self.position;
        copy.target = self.target;
        copy.viewport = self.viewport;
        copy.aspectRatio = self.aspectRatio;
        copy.fovVertical = self.fovVertical;
        copy.nearZ = self.nearZ;
        copy.farZ = self.farZ;
        copy.yaw = self.yaw;
        copy.roll = self.roll;
        copy.pitch = self.pitch;
        copy.rotM = self.rotM;
    }
    
    return copy;
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;
    
    return [self isEqualToData:other];
}

- (BOOL)isEqualToData:(SimpleCamera*)data
{
    if (self == data)
        return YES;
    if (data == nil)
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger hash = 31u ;
    return hash;
}


@end
