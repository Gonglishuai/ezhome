//
//  HSMath.m
//  Homestyler
//
//  Created by Avihay Assouline on 3/31/14.
//
//

#include "HSMath.h"

#pragma mark C Helpers

GLKVector2 vecFromPoint(CGPoint p) {
	return GLKVector2Make(p.x, p.y);
}
CGPoint pointFromVec(GLKVector2 v) {
	return CGPointMake(v.x, v.y);
}

//Returns the point that's in the middle between two points.
CGPoint pointAverage(CGPoint p1, CGPoint p2) {
	return CGPointMake((p1.x + p2.x) / 2.0f, (p1.y + p2.y) / 2.0f);
}

// Returns the point that's on the line between two points, calculated as the weigted average.
CGPoint pointWeightedAverage(CGPoint p1, float w1, CGPoint p2, float w2) {
	return CGPointMake((p1.x * w1 + p2.x * w2) / (w1 + w2), (p1.y * w1 + p2.y * w2) / (w1 + w2));
}
// Same as above for vectors.
GLKVector3 vectorWeightedAverage(GLKVector3 p1, float w1, GLKVector3 p2, float w2) {
	return GLKVector3DivideScalar(GLKVector3Add(GLKVector3MultiplyScalar(p1, w1), GLKVector3MultiplyScalar(p2, w2)),
								  w1 + w2);
}

GLKVector3 vectorAverage(GLKVector3 p1, GLKVector3 p2) {
	return GLKVector3DivideScalar(GLKVector3Add(p1, p2), 2.0f);
}

// Returns the angle between to vectors, with direction of angle relative to up (right hand rule)
float angleBetween3DVectorsWithDirection(GLKVector3 v1, GLKVector3 v2, GLKVector3 up) {
	float direction = GLKVector3DotProduct(up, GLKVector3CrossProduct(v1, v2));
	return SIGN(direction) * acosf(GLKVector3DotProduct(GLKVector3Normalize(v1), GLKVector3Normalize(v2)));
}
// Use (0,1,0) or close alternative for reference
float angleBetween3DVectors(GLKVector3 v1, GLKVector3 v2) {
	GLKVector3 up = GLKVector3Make(0, 1, 0);
	float angle = angleBetween3DVectorsWithDirection(v1, v2, up);
	if (angle == 0) {
		up = GLKVector3Make(0.1, 1, 0);
		return angleBetween3DVectorsWithDirection(v1, v2, up);
	}
	return angle;
}


// Calculate the angle between two vectors.
float angleBetween2DVectors(GLKVector2 v1_in, GLKVector2 v2_in)
{
	const GLKVector3 up = GLKVector3Make(0, 0, 1);
	GLKVector3 v1 = GLKVector3Make(v1_in.x, v1_in.y, 0);
	GLKVector3 v2 = GLKVector3Make(v2_in.x, v2_in.y, 0);
	
	return  angleBetween3DVectorsWithDirection(v1, v2, up);
}

GLKVector2 GLKVector2Rotate(GLKVector2 vec, float radians) {
    return GLKVector2Make(vec.x * cosf(radians) - vec.y * sinf(radians), vec.x * sinf(radians) + vec.y * cosf(radians));
}

float distanceBetweenPointAndLine(GLKVector3 point, GLKVector3 lineStart, GLKVector3 lineEnd) {
    GLKVector3 pointRelativeToLine = GLKVector3Subtract(point, lineStart);
    return GLKVector3Distance(pointRelativeToLine, GLKVector3Project(pointRelativeToLine, GLKVector3Subtract(lineEnd, lineStart)));
}
CGPoint pointFromVec3(GLKVector3 v) {
    return CGPointMake(v.x, v.y);
}