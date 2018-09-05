//
//  General3DViewController+CubeAccess.m
//  CmyCasa
//
//  Created by Or Sharir on 12/9/12.
//
//

#import "General3DViewController+CubeAccess.h"
#define EPSILON (0.0001f)

@implementation General3DViewController (CubeAccess)
- (BOOL)isWall:(WallSide)wall infrontOfPoint:(CGPoint)screenPoint {
    // Cube's sides
    GLKVector3 floorPoint = [self getVectorForVertex:7];
    GLKVector3 floorNormal = GLKVector3Make(0, 1, 0);
    GLKVector3 ceilingPoint = [self getVectorForVertex:4];
    GLKVector3 ceilingNormal = GLKVector3Make(0, -1, 0);
    GLKVector3 frontPoint = ceilingPoint;
    GLKVector3 frontNormal = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:0], [self getVectorForVertex:4]));
    GLKVector3 leftPoint = ceilingPoint;
    GLKVector3 leftNormal = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:5], [self getVectorForVertex:4]));
    GLKVector3 rightPoint = [self getVectorForVertex:5];
    GLKVector3 rightNormal = GLKVector3Negate(leftNormal);
    
    GLKVector3 planePoint, planeNormal;
    switch (wall) {
        case WallFront:
            planePoint = frontPoint;
            planeNormal = frontNormal;
            break;
        case WallLeft:
            planePoint = leftPoint;
            planeNormal = leftNormal;
            break;
        case WallRight:
            planePoint = rightPoint;
            planeNormal = rightNormal;
            break;
        case WallFloor:
            planePoint = floorPoint;
            planeNormal = floorNormal;
            break;
        case WallCeilling:
            planePoint = ceilingPoint;
            planeNormal = ceilingNormal;
            break;
        default:
            return NO;
            break;
    }
    GLKVector3 point = [self findIntersectionOfPoint:screenPoint
                                    withPlaneAtPoint:planePoint
                                          withNormal:planeNormal];
    bool t = point.z  < 0;
    t = t && GLKVector3DotProduct(GLKVector3Subtract(point, frontPoint), frontNormal) >= -EPSILON; // Before front
    t = t && GLKVector3DotProduct(GLKVector3Subtract(point, leftPoint), leftNormal) >= -EPSILON; // Object is right to the left wall.
    t = t && GLKVector3DotProduct(GLKVector3Subtract(point, rightPoint), rightNormal) >= -EPSILON; // Object is left to tthe right wall.
    t = t && GLKVector3DotProduct(GLKVector3Subtract(point, ceilingPoint), ceilingNormal) >= -EPSILON; // Object is below ceiling
    t = t && GLKVector3DotProduct(GLKVector3Subtract(point, floorPoint), floorNormal) >= -EPSILON; // object is above floor
    return t;
}
-(WallSide)wallAtPosition:(GLKVector3)pos x:(GLKVector3*)xDirection pivot:(GLKVector2*)pivot normal:(GLKVector3*)normal previousWall:(WallSide)previousWall{
    WallSide side = WallNone;
    GLKVector3 alignCubeToScene = GLKVector3Make(0, -[self getVectorForVertex:7].y, 0);
	GLKVector3 v1, v2;
	GLKVector3 a1 = GLKVector3Add([self getVectorForVertex:0], alignCubeToScene);
	GLKVector3 a2 = GLKVector3Add([self getVectorForVertex:4], alignCubeToScene);
	GLKVector3 a3 = GLKVector3Add([self getVectorForVertex:5], alignCubeToScene);
	GLKVector3 a4 = GLKVector3Add([self getVectorForVertex:1], alignCubeToScene);
    
	GLKVector3 up = GLKVector3Make(0, 1, 0);
	GLKVector3 down = GLKVector3Make(0, -1, 0);
	GLKVector3 normLeft = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(a2, a1), up));
    normLeft = GLKVector3Normalize(GLKVector3Subtract(a4, a1));
	GLKVector3 normFront = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(a3, a2), up));
    normFront = GLKVector3Normalize(GLKVector3Subtract(a1, a2));
	GLKVector3 normRight = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(a4, a3), up));
    normRight = GLKVector3Negate(normLeft);
    // Not really a distance because it has a sign which indicate on which side of the plane the point is on.
	float distFromFront = (GLKVector3DotProduct(normFront, GLKVector3Subtract(pos, a2)));
    float distFromRight = (GLKVector3DotProduct(normRight, GLKVector3Subtract(pos, a3)));
    float distFromLeft = (GLKVector3DotProduct(normLeft, GLKVector3Subtract(pos, a2)));
    float distFromCeiling = (GLKVector3DotProduct(down, GLKVector3Subtract(pos, a3)));
    float distFromFloor = (GLKVector3DotProduct(up, GLKVector3Subtract(pos, [self getVectorForVertex:6])));
    
    // if wall current side is 'wallNone' no need to calculate distance from wall
    WallSide currentSide = previousWall;
    if (previousWall == WallNone) {
        currentSide = WallFront;
        float min = fabsf(distFromFront);
        if (min > fabsf(distFromLeft)) {
            min = distFromLeft;
            currentSide = WallLeft;
        }
        if (min > fabsf(distFromRight)) {
            min = distFromRight;
            currentSide = WallRight;
        }
        if (min > fabsf(distFromCeiling)) {
            min = distFromCeiling;
            currentSide = WallCeilling;
        }
        if (min > fabsf(distFromFloor)) {
            min = distFromFloor;
            currentSide = WallFloor;
        }
    }
    
	switch (currentSide) {
		case WallFront:
			if (distFromLeft < MOVEMENT_EPSILON * 0.1f) {
				side = WallLeft;
			} else if (distFromRight < MOVEMENT_EPSILON * 0.1f) {
				side = WallRight;
			} else if (distFromFloor < MOVEMENT_EPSILON * 0.1f) {
				side = WallFloor;
			} else if (distFromCeiling < MOVEMENT_EPSILON * 0.1f) {
				side = WallCeilling;
			} else {
				side = WallFront;
			}
			break;
		case WallLeft:
			if (distFromFront < MOVEMENT_EPSILON * 0.1f) {
				side = WallFront;
			} else if (distFromFloor < MOVEMENT_EPSILON * 0.1f) {
				side = WallFloor;
			} else if (distFromCeiling < MOVEMENT_EPSILON * 0.1f) {
				side = WallCeilling;
			} else {
				side = WallLeft;
			}
			break;
		case WallRight:
			if (distFromFront < MOVEMENT_EPSILON * 0.1f) {
				side = WallFront;
			} else if (distFromFloor < MOVEMENT_EPSILON * 0.1f) {
				side = WallFloor;
			} else if (distFromCeiling < MOVEMENT_EPSILON * 0.1f) {
				side = WallCeilling;
			} else {
				side = WallRight;
			}
			break;
		case WallFloor:
			if (distFromFront < MOVEMENT_EPSILON * 0.1f) {
				side = WallFront;
			} else if (distFromLeft < MOVEMENT_EPSILON * 0.1f) {
				side = WallLeft;
			} else if (distFromRight < MOVEMENT_EPSILON * 0.1f) {
				side = WallRight;
			} else {
				side = WallFloor;
			}
			break;
		case WallCeilling:
            if (distFromFront < MOVEMENT_EPSILON * 0.1f) {
				side = WallFront;
			} else if (distFromLeft < MOVEMENT_EPSILON * 0.1f) {
				side = WallLeft;
			} else if (distFromRight < MOVEMENT_EPSILON * 0.1f) {
				side = WallRight;
			} else {
				side = WallCeilling;
			}
			break;
		default:
			break;
	}
	switch (side) {
		case WallFront:
			v1 = a2;
			v2 = a3;
			*pivot = GLKVector2Make(v1.x, v1.z);
            *normal = normFront;
			break;
		case WallLeft:
			v1 = a1;
			v2 = a2;
			*pivot = GLKVector2Make(v2.x, v2.z);
            *normal = normLeft;
			break;
		case WallRight:
			v1 = a3;
			v2 = a4;
			*pivot = GLKVector2Make(v1.x, v1.z);
            *normal = normRight;
			break;
		case WallFloor:
			v1 = a2;
			v2 = a3;
			*pivot = GLKVector2Make(v1.x, v1.z);
            *normal = up;
			break;
		case WallCeilling:
			v1 = a2;
			v2 = a3;
			*pivot = GLKVector2Make(v1.x, v1.z);
            *normal = down;
			break;
		default:
			break;
	}
	
	*xDirection = GLKVector3Normalize(GLKVector3Subtract(v2, v1));
	return side;
}
-(BOOL)vertexInsideView:(NSUInteger)index {
    return [self.view pointInside:[self getPointForVector:[self getVectorForVertex:index]] withEvent:nil];
}


- (BOOL)point:(CGPoint)p directlyIntersectsWall:(WallSide)wall {
    // Cube's sides
    GLKVector3 floorPoint = [self getVectorForVertex:7];
    GLKVector3 floorNormal = GLKVector3Make(0, 1, 0);
    GLKVector3 ceilingPoint = [self getVectorForVertex:4];
    GLKVector3 ceilingNormal = GLKVector3Make(0, -1, 0);
    GLKVector3 frontPoint = ceilingPoint;
    GLKVector3 frontNormal = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:0], [self getVectorForVertex:4]));
    GLKVector3 leftPoint = ceilingPoint;
    GLKVector3 leftNormal = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:5], [self getVectorForVertex:4]));
    GLKVector3 rightPoint = [self getVectorForVertex:5];
    GLKVector3 rightNormal = GLKVector3Negate(leftNormal);
    
    GLKVector3 planePoint, planeNormal;
    switch (wall) {
        case WallFront:
            planePoint = frontPoint;
            planeNormal = frontNormal;
            break;
        case WallLeft:
            planePoint = leftPoint;
            planeNormal = leftNormal;
            break;
        case WallRight:
            planePoint = rightPoint;
            planeNormal = rightNormal;
            break;
        case WallFloor:
            planePoint = floorPoint;
            planeNormal = floorNormal;
            break;
        case WallCeilling:
            planePoint = ceilingPoint;
            planeNormal = ceilingNormal;
            break;
        default:
            return NO;
            break;
    }
    GLKVector3 point = [self findIntersectionOfPoint:p
                                    withPlaneAtPoint:planePoint withNormal:planeNormal];
    bool t = point.z  < 0;
    t = t && GLKVector3DotProduct(GLKVector3Subtract(point, frontPoint), frontNormal) >= -EPSILON; // Before front
    t = t && GLKVector3DotProduct(GLKVector3Subtract(point, leftPoint), leftNormal) >= -EPSILON; // Object is right to the left wall.
    t = t && GLKVector3DotProduct(GLKVector3Subtract(point, rightPoint), rightNormal) >= -EPSILON; // Object is left to the right wall.
    t = t && GLKVector3DotProduct(GLKVector3Subtract(point, ceilingPoint), ceilingNormal) >= -EPSILON; // Object is below ceiling
    t = t && GLKVector3DotProduct(GLKVector3Subtract(point, floorPoint), floorNormal) >= -EPSILON; // object is above floor
    return t;
}

- (WallSide)wallAtIntersectionOfPoint:(CGPoint)p {
    if ([self point:p directlyIntersectsWall:WallFront]) return WallFront;
    if ([self point:p directlyIntersectsWall:WallLeft])  return WallLeft;
    if ([self point:p directlyIntersectsWall:WallRight])  return WallRight;
    if ([self point:p directlyIntersectsWall:WallCeilling])  return WallCeilling;
    if ([self point:p directlyIntersectsWall:WallFloor])  return WallFloor;
    return WallNone;
}

- (GLKVector3)getVectorForVertex:(NSUInteger)index{
    return GLKVector3Make(0, 0, 0);
}

@end
