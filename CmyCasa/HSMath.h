//
//  HSMath.h
//  Homestyler
//
//  Created by Avihay Assouline on 3/31/14.
//
//

#ifndef Homestyler_HSMath_h
#define Homestyler_HSMath_h

#import <GLKit/GLKit.h>

GLKVector2 vecFromPoint(CGPoint p);
CGPoint pointFromVec(GLKVector2 v);
CGPoint pointFromVec3(GLKVector3 v);
CGPoint pointAverage(CGPoint p1, CGPoint p2);
GLKVector3 vectorAverage(GLKVector3 p1, GLKVector3 p2);
CGPoint pointWeightedAverage(CGPoint p1, float w1, CGPoint p2, float w2);
GLKVector3 vectorWeightedAverage(GLKVector3 p1, float w1, GLKVector3 p2, float w2);
float angleBetween3DVectorsWithDirection(GLKVector3 v1, GLKVector3 v2, GLKVector3 up);
float angleBetween3DVectors(GLKVector3 v1, GLKVector3 v2);
float angleBetween2DVectors(GLKVector2 v1_in, GLKVector2 v2_in);
GLKVector2 GLKVector2Rotate(GLKVector2 vec, float radians);
float distanceBetweenPointAndLine(GLKVector3 point, GLKVector3 lineStart, GLKVector3 lineEnd);

#endif
