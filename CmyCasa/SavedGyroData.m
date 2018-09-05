//
//  SavedGyroData.m
//  CmyCasa
//
//

#import "SavedGyroData.h"
#import "HSMacros.h"

@implementation SavedGyroData

@synthesize gravity, gyroRotationMatrix;


// Occurs on 3D Analysis
-(id)initWithRotationMatrix:(GLKMatrix3)matrix withModMatrix:(GLKMatrix4)modMatrix
{
	if (self = [super init])
    {
        GLKMatrix3 xFlip = GLKMatrix3Make(-1, 0, 0,
										  0, 1, 0,
										  0, 0, 1);
		matrix = GLKMatrix3Multiply(xFlip, GLKMatrix3Multiply(matrix, xFlip));
        
        self.gravity = GLKMatrix3MultiplyVector3(matrix, GLKVector3Make(0, -1, 0));
        self.gravity = GLKMatrix4MultiplyVector3(GLKMatrix4Transpose(modMatrix), self.gravity);
		matrix = GLKMatrix3Multiply(matrix, GLKMatrix4GetMatrix3(modMatrix));
        
		self.gyroRotationMatrix = matrix;
	}
	return self;
}

-(GLKMatrix3)matrixForAnalysiswithModMatrix:(GLKMatrix4)modMatrix
{
    GLKMatrix3 matrix = self.gyroRotationMatrix;
    matrix = GLKMatrix3Transpose(GLKMatrix3RotateX(GLKMatrix3Transpose(matrix), M_PI_2));
    matrix = GLKMatrix3Multiply(matrix, GLKMatrix4GetMatrix3(modMatrix));
    GLKMatrix3 xFlip = GLKMatrix3Make(-1, 0, 0,
                                      0, 1, 0,
                                      0, 0, 1);
    matrix = GLKMatrix3Multiply(xFlip, GLKMatrix3Multiply(matrix, xFlip));
    return matrix;
}

// Load from saved designs
-(id)initWithCameraMatrix:(GLKMatrix3)matrix
{
    if (self = [super init])
    {
        self.gravity = GLKMatrix3MultiplyVector3(matrix, GLKVector3Make(0, -1, 0));
        self.gyroRotationMatrix = GLKMatrix3Transpose(matrix);
    }
    return self;
}

-(UIImageOrientation)imageOrientation
{
    SavedGyroData* devicePosition = self;
    float vec_size = devicePosition.gravity.x * devicePosition.gravity.x + devicePosition.gravity.y * devicePosition.gravity.y;
    vec_size = sqrtf(vec_size);

    float angle = 0;
    if (vec_size > 0) angle = acosf(devicePosition.gravity.x / vec_size);
    if (devicePosition.gravity.y < 0) angle = 2.0 * M_PI - angle;
    angle += M_PI_4;
    while (angle < 0) angle += 2.0 * M_PI;
    while (angle >= 2*M_PI) angle -= 2.0 * M_PI;
    
    if (0 <= angle && angle < M_PI_2) {
        return UIImageOrientationDown;
    } else if (M_PI_2 <= angle && angle < M_PI) {
        return UIImageOrientationLeft;
    } else if (M_PI <= angle && angle < 3.0 * M_PI_2) {
        return UIImageOrientationUp;
    } else {
        return UIImageOrientationRight;
    }
}



#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeBytes:(const uint8_t *)&gyroRotationMatrix length:sizeof(gyroRotationMatrix) forKey:@"gyroRotationMatrix"];
    [coder encodeBytes:(const uint8_t *)&gravity length:sizeof(gravity) forKey:@"gravity"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init])
    {
        const uint8_t *bytes = [coder decodeBytesForKey:@"gyroRotationMatrix" returnedLength:NULL];
        CHECK_C_NULL_RETURN_NIL(bytes);
        memcpy(&gyroRotationMatrix, bytes, sizeof(gyroRotationMatrix));
        
        bytes = [coder decodeBytesForKey:@"gravity" returnedLength:NULL];
        CHECK_C_NULL_RETURN_NIL(bytes);
        memcpy(&gravity, bytes, sizeof(gravity));
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    SavedGyroData *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil)
    {
        copy.gravity = self.gravity;
        copy.gyroRotationMatrix = self.gyroRotationMatrix;
    }

    return copy;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToData:other];
}

- (BOOL)isEqualToData:(SavedGyroData *)data {
    if (self == data)
        return YES;
    if (data == nil)
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = 31u;
    return hash;
}


@end
