//
//  General3DViewController+CubeAccess.h
//  CmyCasa
//
//  Created by Or Sharir on 12/9/12.
//
//

#import "General3DViewController.h"
#import "PaintProtocols.h"

#define MOVEMENT_EPSILON (0.00001f)

@interface General3DViewController (CubeAccess)
- (BOOL)vertexInsideView:(NSUInteger)index;
- (BOOL)isWall:(WallSide)wall infrontOfPoint:(CGPoint)screenPoint;
- (GLKVector3)getVectorForVertex:(NSUInteger)index;
- (WallSide)wallAtPosition:(GLKVector3)pos x:(GLKVector3*)xDirection pivot:(GLKVector2*)pivot normal:(GLKVector3*)normal previousWall:(WallSide)previousWall;
- (WallSide)wallAtIntersectionOfPoint:(CGPoint)p;
@end
