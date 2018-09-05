//
//  SavedGyroData.h
//  CmyCasa
//
// 	A custom class for saving the gravity and rotation matrix from the device's motion.

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <CoreMotion/CMAttitude.h>
#import <CoreMotion/CMDeviceMotion.h>

@interface SavedGyroData : NSObject <NSCoding, NSCopying>

@property (assign, atomic) GLKMatrix3 gyroRotationMatrix;
@property (assign, atomic) GLKVector3 gravity;

-(id)initWithRotationMatrix:(GLKMatrix3)matrix withModMatrix:(GLKMatrix4)modMatrix;
-(id)initWithCameraMatrix:(GLKMatrix3)matrix;

-(GLKMatrix3)matrixForAnalysiswithModMatrix:(GLKMatrix4)modMatrix;
-(UIImageOrientation)imageOrientation;

- (id)copyWithZone:(NSZone *)zone;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToData:(SavedGyroData *)data;

- (NSUInteger)hash;
@end
