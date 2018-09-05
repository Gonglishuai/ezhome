//
//  CubeViewController.h
//  CmyCasa
//

#import <UIKit/UIKit.h>
#import "General3DViewController.h"
#import "General3DViewController+CubeAccess.h"
#import "SavedDesign.h"

#define CUBE_VERTS (8)
#define COORDS (3)
#define TEX_COORDS (2)
#define X (0)
#define Y (1)
#define Z (2)
@interface GeneralCubeViewController : General3DViewController
{
    @private
    GLfloat cubeVerts[CUBE_VERTS*COORDS];
}

@property (assign) BOOL wireframeHidden;
@property (assign) BOOL cubeWallsHidden;
@property (assign) BOOL useMipmapping;
@property (strong, nonatomic) SavedDesign* currentDesign;
@property (strong, nonatomic) UIImage* textureImage;
@property (assign) float cubeTextureScale;
@property (assign) float wallsTransparency;
@property (nonatomic) NSArray* cubeNSArray;
-(void)setupSceneFromCurrentDesign;
-(void)reloadCube;
// Get where the vertex of the cube is poisitioned on the window
- (CGPoint)getPointForVertex:(int)vertex;
// project wrappers
- (GLKVector3)projectPointForVertex:(int)vertex;
// Returns the position of the vertex as a vector.
- (GLKVector3)getVectorForVertex:(int)vertex;
// Sets the vertex with the given vector
- (void)setVector:(GLKVector3)vector forVertex:(int)vertex;
// Translate the given vertex by adding the given vector to it.
-(void)translateVertex:(int)vertex withVector:(GLKVector3)diff;
-(void)updateSurfaceTex;
-(void)setWallSide:(WallSide)side;
-(void)rotateSurfaceXZ:(float)angle;
-(void)refreshGLView;
-(void)glkViewLogic;
@property GLfloat floorRotatingAngle;
@property GLfloat floorHeightDelta;
@property GLfloat floorWidthDelta;

// Retrieves the current active rendered wall masks
// The wall mask stores the information on which wall side
// is currently rendered. Wall masks are only taken into account
// When the painting mode is for floors
+ (int)getActiveWallMask;

// Sets the current active rendered wall masks
+ (void)setActiveWallMask:(int)wallMask;

// Clears the current active rendered wall masks
+ (void)clearWallMasks;

// Activate the rendering of a specific wall
+ (void)activateWall:(WallSide)wallside;

@end
