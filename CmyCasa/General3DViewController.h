//
//  General3DViewController.h
//  CmyCasa
//
//  Created by Or Sharir on 11/11/12.
//
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "SavedGyroData.h"
#import "Entity.h"
#import "HSFurnitureShader.h"
#import "AlphaCutOffShader.h"
#import "SimpleCamera.h"
#import "HSMath.h"

typedef enum
{
    ScreenEdgeLeft = 0,
    ScreenEdgeRight = 1,
    ScreenEdgeTop = 2,
    ScreenEdgeBottom = 3,
} ScreenEdge;

@interface General3DViewController : UIViewController <GLKViewControllerDelegate, GLKViewDelegate>

@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) HSFurnitureShader *furnitureShader;
@property (strong, nonatomic) AlphaCutOffShader *alphaCutoffShader;
@property (strong, nonatomic) SimpleCamera *camera;
@property (strong, nonatomic) SavedGyroData* gyroData;
@property (assign, nonatomic) float cameraHeight;
@property (assign) float worldScale;

-(void)updateCamera;
-(void)updateProjection;
-(void)updateProjectionWithRatio:(GLfloat) ratio;

- (void)toggleBottomBarVisibility:(UIView*)bottomBar;
- (BOOL)isBottomBarVisible;

#pragma marks Helpers
// Get where the general vector is positioned on the window
- (CGPoint)getPointForVector:(GLKVector3)vector;
- (GLKVector2)getVector2ProjectionOfVector:(GLKVector3)vector;
// Wrappers for the un/project method (projects a point for 3d world to window)
- (GLKVector3)projectPointForVector:(GLKVector3)vector;
- (GLKVector3)unprojectPoint:(CGPoint)point withDepth:(float)z;
- (GLKVector3)unprojectVector:(GLKVector3)point;
// Unproject a point from the window (where the button is poisitioned) to the 3d world.
- (GLKVector3)findIntersectionOfPoint:(CGPoint)point withPlaneAtPoint:(GLKVector3)v0 withNormal:(GLKVector3)n;
- (GLKVector3)findIntersectionPlaneOfEntity:(Entity*)entity withPoint:(CGPoint)point;
- (GLKVector3)findVectorForRay:(CGPoint)point atDepth:(float)s;
- (GLKVector3)findEdgeOfLineStartingAt:(GLKVector3)start end:(GLKVector3)end withScreen:(ScreenEdge)screenEdge;

@end
