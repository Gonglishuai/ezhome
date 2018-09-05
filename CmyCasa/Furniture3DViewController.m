//
//  Furniture3DViewController.m
//  CmyCasa
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "DataManager.h"
//#import "HSFlurry.h"
#import "Furniture3DViewController.h"
#import "AppDelegate.h"
#import "MathMacros.h"
#import "UIImage+OpenCVWrapper.h"
#import "ModelsHandler.h"
#import "UIImage+Buffer.h"
#import "HSMath.h"
#import "CommandItem.h"
#import "ImageBackgroundEffectsViewController.h"
#import "MainViewController.h"
#import "LevitateView.h"

#define SNAPPING_DISTANCE_EPSILON (0.0125f)
#define MOVEMENT_SPEED (2.0f)
#define BLACK_COLOR_PIXEL_VALUE (0)

// wireframe of the cube
static const GLubyte wireframe[] = {
    0,1,
    1,2,
    2,3,
    3,0,
    
    4,5,
    5,6,
    6,7,
    7,4,
    
    0,4,
    1,5,
    2,6,
    3,7,
};

@interface UIGestureRecognizer (CancelGesture)
-(void)cancelGesture;
@end

@implementation UIGestureRecognizer (CancelGesture)

-(void)cancelGesture {
    self.enabled = NO;
    self.enabled = YES;
}

@end

@interface Furniture3DViewController ()
{
    Byte *pngBuffer;
}

@property (strong, nonatomic) UIColor* averageBackgroundColor;
@property (atomic) BOOL updateConstraints;
@property (atomic) BOOL activeProductIsSnapped;
@end

@implementation Furniture3DViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString * designType = [[DataManger sharedInstance] designSource];
    if (designType) {
//        [HSFlurry segmentTrack:@"new design created" withParameters:@{@"design type": designType}];
    }
    
    self.undoHandler = [[UndoHandler alloc] initWithStepsLimit:[[[ConfigManager sharedInstance]toolUndoStepsLimit] integerValue]];
    // Setup gestures:
    UIPinchGestureRecognizer* pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchZoomView:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
    
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveView:)];
    [self.view addGestureRecognizer:pan];
    
    UIPanGestureRecognizer* levitate = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(levitateView:)];
    [levitate setMinimumNumberOfTouches:2];
    [levitate setMaximumNumberOfTouches:2];
    levitate.delegate = self;
    [self.view addGestureRecognizer:levitate];
    
    UIRotationGestureRecognizer* rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    rotate.delegate = self;
    [self.view addGestureRecognizer:rotate];
    
    UITapGestureRecognizer* selectObject = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectObject:)];
    [self.view addGestureRecognizer:selectObject];
    
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    self.objectBrightness = 1;
    
    // Initial state of the object
    self.entities = [[NSMutableArray alloc] init];
    self.entitiesShadows = [[NSMutableArray alloc] init];
    self.entitiesDict = [[NSMutableDictionary alloc] init];
    
    [self resetScene];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateGLOwner];
    [self updateBackgroundColor];
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClearStencil(0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    self.furnitureShader = [[HSFurnitureShader alloc] init];
    [self.furnitureShader loadShaders];
    
    self.alphaCutoffShader = [[AlphaCutOffShader alloc] init];
    [self.alphaCutoffShader loadShaders];
    
    self.updateConstraints = NO;
    self.activeProductIsSnapped = NO;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(void)dealloc
{
    NSLog(@"dealloc - Furniture3DViewController");
    if (NULL != pngBuffer)
        free(pngBuffer);
}

#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)clearScene {
    @synchronized(self) {
        [self resetScene];
        self.activeEntity = nil;
        [self.entities removeAllObjects];
        [self.entitiesShadows removeAllObjects];
        [self.entitiesDict removeAllObjects];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)resetScene {
    @synchronized(self) {
        position = GLKVector3Make(0.0f, 0.0f, 0.0f);
        rotationY = 0.0f;
        relativePosition = GLKVector3Make(0.0f, 0.0f, 0.0f);
        relativeRotateY = 0.0f;
        relativeScale = 1.0f;
        highlightObject = YES;
        self.activeEntity = nil;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(GLKVector3)getVectorForVertex:(NSUInteger)index {
    return GLKVector3Make([(NSNumber*)[self.cubeVerts objectAtIndex:index * COORDS + X] floatValue],
                          [(NSNumber*)[self.cubeVerts objectAtIndex:index * COORDS + Y] floatValue],
                          [(NSNumber*)[self.cubeVerts objectAtIndex:index * COORDS + Z] floatValue]);
}

////////////////////////////////////////////////////////////////////////////////////////////////////




////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)resetObjectState
{
    [self.activeEntity updateModelViewMatrixWithCorrectFloor:YES];
    if (self.gyroData == nil) {
        position = GLKVector3Make(0,self.activeEntity.position.y,-3.0f);
    } else if ([self.activeEntity isAttachedToCeiling]) {
        
        float dist = 0.03f;
        float widthFactor, heightFactor;
        switch ([[DesignsManager sharedInstance] workingDesign].Orientation) {
            case UIImageOrientationUp:
                widthFactor = 0.5f;
                heightFactor = 0.03f;
                break;
            case UIImageOrientationDown:
                widthFactor = 0.5f;
                heightFactor = 1-dist;
                break;
            case UIImageOrientationLeft:
                widthFactor = 1-dist;
                heightFactor = 0.5f;
                break;
            case UIImageOrientationRight:
                widthFactor = dist;
                heightFactor = 0.5f;
                break;
            default:
                widthFactor = 0.5f;
                heightFactor = 0.5f;
                break;
        }
        CGPoint middleHighPoint = CGPointMake(self.view.bounds.size.width * widthFactor, self.view.bounds.size.height * heightFactor);
        
        if (self.cubeVerts != nil && ([self vertexInView:4] || [self vertexInView:5])) {
            position = [self findIntersectionOfPoint:middleHighPoint withPlaneAtPoint:[self getVectorForVertex:4] withNormal:GLKVector3Make(0, 1, 0)];
            position = GLKVector3Subtract(position, GLKVector3Make(0, self.activeEntity.widthY, 0));
        } else {
            position = [self findVectorForRay:middleHighPoint atDepth:10.0f];
            position = GLKVector3Subtract(position, GLKVector3Make(0, self.activeEntity.widthY, 0));
        }
    } else if (self.cubeVerts == nil || [self.activeEntity isAttachedToWall] == NO) { //position the object in the lower half of the screen.
        GLKVector2 p = GLKVector2Make(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height / 2.0f);
        
        p = GLKVector2Add(p, GLKVector2Rotate(GLKVector2Make(0,  self.view.bounds.size.width / 4.0f), [self.camera angleOfScreenRotation]));
        position = [self findIntersectionOfPoint:pointFromVec(p) withPlaneAtPoint:GLKVector3Make(0, 0, 0) withNormal:GLKVector3Make(0, 1, 0)];
        if (self.cubeVerts != nil) {
            rotationY = angleBetween3DVectors(GLKVector3Subtract([self getVectorForVertex:0], [self getVectorForVertex:4]), GLKVector3Make(0, 0, 1));
        } else {
            rotationY = M_PI_4;
        }
    } else { // Position objects that are attached to walls on one of the visible corners
        GLKVector3 xDir;
        if ([self vertexInView:7] == YES && [self vertexInView:6] == NO) {
            GLKVector3 base = [self getVectorForVertex:7];
            base.y = 0;
            position = GLKVector3Add(base, GLKVector3DivideScalar(GLKVector3Subtract([self getVectorForVertex:4], [self getVectorForVertex:7]), 2.0f));
            xDir = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:5], [self getVectorForVertex:4]));
        } else if ([self vertexInView:6] == YES) {
            GLKVector3 base = [self getVectorForVertex:6];
            base.y = 0;
            position = GLKVector3Add(base, GLKVector3DivideScalar(GLKVector3Subtract([self getVectorForVertex:5], [self getVectorForVertex:6]), 2.0f));
            xDir = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:4], [self getVectorForVertex:5]));
        } else {
            GLKVector3 base = [self getVectorForVertex:7];
            base.y = 0;
            position = GLKVector3Add(base, GLKVector3DivideScalar(GLKVector3Subtract([self getVectorForVertex:4], [self getVectorForVertex:7]), 2.0f));
            base = [self getVectorForVertex:6];
            base.y = 0;
            position = GLKVector3Add(position, GLKVector3Add(base, GLKVector3DivideScalar(GLKVector3Subtract([self getVectorForVertex:4], [self getVectorForVertex:7]), 2.0f)));
            position = GLKVector3DivideScalar(position, 2);
            
            xDir = GLKVector3Make(0, 0, 0);
            
        }
        position = GLKVector3Add(position, GLKVector3MultiplyScalar(xDir, MOVEMENT_EPSILON));
        
        if ([self.activeEntity isAttachedToWallBottom])
        {
            GLKVector3 vecTwoToVecThree = GLKVector3Subtract([self getVectorForVertex:3], [self getVectorForVertex:2]);
            GLKVector3 vecTwoToVecSix = GLKVector3Subtract([self getVectorForVertex:6], [self getVectorForVertex:2]);
            
            GLKVector3 floorNormal = [self getNormalOfPlane:vecTwoToVecSix
                                                 leftVector:vecTwoToVecThree];
            
            /*
             * To compute the current distance to the floor we must perform the move
             * of the object to the new location, check the distance and restore the current location
             */
            GLKVector3 currentPosition = self.activeEntity.position;
            self.activeEntity.position = position;
            [self.activeEntity updateModelViewMatrixWithCorrectFloor:YES];
            
            float distanceToFloor = [self distanceOfEntity:self.activeEntity
                                           fromWallAtPoint:[self getVectorForVertex:3]
                                                withNormal:floorNormal];
            
            self.activeEntity.position = currentPosition;
            [self.activeEntity updateModelViewMatrixWithCorrectFloor:YES];
            
            position = GLKVector3Make(position.x,
                                      position.y - distanceToFloor,
                                      position.z);
        }
        
        GLKVector3 v1 = [self getVectorForVertex:4];
        GLKVector3 v2 = [self getVectorForVertex:5];
        GLKVector3 up = GLKVector3Make(0, 1, 0);
        GLKVector3 front = GLKVector3Make(0, 0, 1);
        GLKVector3 norm = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(v2, v1), up));
        
        float direction = GLKVector3DotProduct(up, GLKVector3CrossProduct(front, norm));
        float angle = BIASED_SIGN(direction) * acosf(GLKVector3DotProduct(norm, front));
        rotationY = angle;
    }
    
    relativePosition = GLKVector3Make(0, 0, 0);
    relativeRotateY = 0;
    relativeScale = 1.0f;
    
    [self resumeRenderer];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

// Is the given vertex visible in the view
-(BOOL)vertexInView:(int)idx {
    GLKVector3 v = [self getVectorForVertex:idx];
    GLKVector3 p = [self projectPointForVector:v];
    return p.x >= 0 && p.x < self.view.bounds.size.width && p.y >= 0 && p.y < self.view.bounds.size.height;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(GLKVector3)getNormalOfPlane:(GLKVector3)upVector leftVector:(GLKVector3)leftVector
{
    GLKVector3 crossProduct = GLKVector3CrossProduct(upVector,leftVector);
    return GLKVector3Normalize(crossProduct);
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(float)distanceOfEntity:(Entity*)entity
         fromWallAtPoint:(GLKVector3)point
              withNormal:(GLKVector3)normal
{
    ModelBoundingBox *entityBoundingBox = [entity getEntityBoundingBox];
    
    // Compute bounding box points in object coordinate system
    GLKVector3 tlVertex = GLKVector3Make(entityBoundingBox.minX,
                                         entityBoundingBox.minY,
                                         entityBoundingBox.maxZ);
    
    GLKVector3 trVertex = GLKVector3Make(entityBoundingBox.maxX,
                                         entityBoundingBox.minY,
                                         entityBoundingBox.maxZ);
    
    GLKVector3 blVertex = GLKVector3Make(entityBoundingBox.minX,
                                         entityBoundingBox.minY,
                                         entityBoundingBox.minZ);
    
    GLKVector3 brVertex = GLKVector3Make(entityBoundingBox.maxX,
                                         entityBoundingBox.minY,
                                         entityBoundingBox.minZ);
    
    // Compute bounding box points in object coordinate system
    GLKVector3 tlVertexTop = GLKVector3Make(entityBoundingBox.minX,
                                            entityBoundingBox.maxY,
                                            entityBoundingBox.maxZ);
    
    GLKVector3 trVertexTop = GLKVector3Make(entityBoundingBox.maxX,
                                            entityBoundingBox.maxY,
                                            entityBoundingBox.maxZ);
    
    GLKVector3 blVertexTop = GLKVector3Make(entityBoundingBox.minX,
                                            entityBoundingBox.maxY,
                                            entityBoundingBox.minZ);
    
    GLKVector3 brVertexTop = GLKVector3Make(entityBoundingBox.maxX,
                                            entityBoundingBox.maxY,
                                            entityBoundingBox.minZ);
    
    // Compute bounding box points in world coordinate system
    tlVertex = GLKMatrix4MultiplyVector3WithTranslation(entity.modelviewMatrix, tlVertex);
    trVertex = GLKMatrix4MultiplyVector3WithTranslation(entity.modelviewMatrix, trVertex);
    blVertex = GLKMatrix4MultiplyVector3WithTranslation(entity.modelviewMatrix, blVertex);
    brVertex = GLKMatrix4MultiplyVector3WithTranslation(entity.modelviewMatrix, brVertex);
    
    tlVertexTop = GLKMatrix4MultiplyVector3WithTranslation(entity.modelviewMatrix, tlVertexTop);
    trVertexTop = GLKMatrix4MultiplyVector3WithTranslation(entity.modelviewMatrix, trVertexTop);
    blVertexTop = GLKMatrix4MultiplyVector3WithTranslation(entity.modelviewMatrix, blVertexTop);
    brVertexTop = GLKMatrix4MultiplyVector3WithTranslation(entity.modelviewMatrix, brVertexTop);
    
    // Compute distance of each point from the wall at point 'point' with normal 'normal'
    float tlVertexDist = GLKVector3DotProduct(normal, GLKVector3Subtract(tlVertex, point));
    float trVertexDist = GLKVector3DotProduct(normal, GLKVector3Subtract(trVertex, point));
    float blVertexDist = GLKVector3DotProduct(normal, GLKVector3Subtract(blVertex, point));
    float brVertexDist = GLKVector3DotProduct(normal, GLKVector3Subtract(brVertex, point));
    
    float tlVertexDistTop = GLKVector3DotProduct(normal, GLKVector3Subtract(tlVertexTop, point));
    float trVertexDistTop = GLKVector3DotProduct(normal, GLKVector3Subtract(trVertexTop, point));
    float blVertexDistTop = GLKVector3DotProduct(normal, GLKVector3Subtract(blVertexTop, point));
    float brVertexDistTop = GLKVector3DotProduct(normal, GLKVector3Subtract(brVertexTop, point));
    
    float minDistance = MAXFLOAT;
    
    if (tlVertexDist < minDistance)
        minDistance = tlVertexDist;
    if (trVertexDist < minDistance)
        minDistance = trVertexDist;
    if (blVertexDist < minDistance)
        minDistance = blVertexDist;
    if (brVertexDist < minDistance)
        minDistance = brVertexDist;
    
    if (tlVertexDistTop < minDistance)
        minDistance = tlVertexDistTop;
    if (trVertexDistTop < minDistance)
        minDistance = trVertexDistTop;
    if (blVertexDistTop < minDistance)
        minDistance = blVertexDistTop;
    if (brVertexDistTop < minDistance)
        minDistance = brVertexDistTop;
    
    return minDistance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (GLKVector3)getNormalForWall:(WallSide)wall
{
    // Finished setting up the active's entity properties -> Now we take care of snapping
    GLKVector3 vecSevenToVecFour = GLKVector3Subtract([self getVectorForVertex:4], [self getVectorForVertex:7]);
    GLKVector3 vecSevenToVecThree = GLKVector3Subtract([self getVectorForVertex:3], [self getVectorForVertex:7]);
    
    GLKVector3 vecSixToVecFive = GLKVector3Subtract([self getVectorForVertex:5], [self getVectorForVertex:6]);
    GLKVector3 vecSixToVecSeven = GLKVector3Subtract([self getVectorForVertex:7], [self getVectorForVertex:6]);
    
    GLKVector3 vecTwoToVecOne = GLKVector3Subtract([self getVectorForVertex:1], [self getVectorForVertex:2]);
    GLKVector3 vecTwoToVecSix = GLKVector3Subtract([self getVectorForVertex:6], [self getVectorForVertex:2]);
    
    GLKVector3 vecTwoToVecThree = GLKVector3Subtract([self getVectorForVertex:3], [self getVectorForVertex:2]);
    
    GLKVector3 floorNormal = [self getNormalOfPlane:vecTwoToVecSix
                                         leftVector:vecTwoToVecThree];
    
    GLKVector3 leftWallNormal = [self getNormalOfPlane:vecSevenToVecFour
                                            leftVector:vecSevenToVecThree];
    
    GLKVector3 frontWallNormal = [self getNormalOfPlane:vecSixToVecFive
                                             leftVector:vecSixToVecSeven];
    
    GLKVector3 rightWallNormal = [self getNormalOfPlane:vecTwoToVecOne
                                             leftVector:vecTwoToVecSix];
    
    switch (wall)
    {
        case WallFloor: return floorNormal; break;
        case WallCeilling: return GLKVector3MultiplyScalar(floorNormal, -1); break;
        case WallRight: return rightWallNormal; break;
        case WallLeft: return leftWallNormal; break;
        case WallFront: return frontWallNormal; break;
            
        case WallAll:
        case WallNone:
        default: return GLKVector3Make(0, 0, 0); break;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (GLfloat)distanceOfEntity:(Entity*)entity FromWall:(WallSide)wall
{
    switch (wall)
    {
        case WallFloor:
        {
            return [self distanceOfEntity:entity
                          fromWallAtPoint:[self getVectorForVertex:3]
                               withNormal:[self getNormalForWall:WallFloor]];
        } break;
            
        case WallCeilling:
        {
            return [self distanceOfEntity:entity
                          fromWallAtPoint:[self getVectorForVertex:0]
                               withNormal:[self getNormalForWall:WallCeilling]];
        } break;
            
        case WallRight:
        {
            return [self distanceOfEntity:entity
                          fromWallAtPoint:[self getVectorForVertex:5]
                               withNormal:[self getNormalForWall:WallRight]];
        } break;
            
        case WallLeft:
        {
            return [self distanceOfEntity:entity
                          fromWallAtPoint:[self getVectorForVertex:4]
                               withNormal:[self getNormalForWall:WallLeft]];
        } break;
            
        case WallFront:
        {
            return [self distanceOfEntity:entity
                          fromWallAtPoint:[self getVectorForVertex:4]
                               withNormal:[self getNormalForWall:WallFront]];
        } break;
            
        case WallAll:
        case WallNone:
        default:
        {
            return -MAXFLOAT;
        } break;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)snapEntityToWalls:(Entity*)entity
{
    float distanceToLeftWall = [self distanceOfEntity:entity FromWall:WallLeft];
    float distanceToFrontWall = [self distanceOfEntity:entity FromWall:WallFront];
    float distanceToRightWall = [self distanceOfEntity:entity FromWall:WallRight];
    float distanceToFloor = [self distanceOfEntity:entity FromWall:WallFloor];
    float distanceToCeiling = [self distanceOfEntity:entity FromWall:WallCeilling];
    //    NSLog(@"distanceToLeftWall %f", distanceToLeftWall);
    //    NSLog(@"distanceToFrontWall %f", distanceToFrontWall);
    //    NSLog(@"distanceToRightWall %f", distanceToRightWall);
    //    NSLog(@"distanceToFloor %f", distanceToFloor);
    //    NSLog(@"distanceToCeiling %f", distanceToCeiling);
    
    GLKVector3 newPosition = entity.position;
    
    float worldScale = [[DesignsManager sharedInstance] workingDesign].GlobalScale;
    
    if (fabsf(distanceToLeftWall) < SNAPPING_DISTANCE_EPSILON / worldScale)
    {
        GLKVector3 nLeftWallNormal = GLKVector3Negate([self getNormalForWall:WallLeft]);
        newPosition = GLKVector3Add(newPosition, GLKVector3MultiplyScalar(nLeftWallNormal, distanceToLeftWall));
    }
    
    if (fabsf(distanceToFrontWall) < SNAPPING_DISTANCE_EPSILON / worldScale)
    {
        GLKVector3 nFrontWallNormal = GLKVector3Negate([self getNormalForWall:WallFront]);
        newPosition = GLKVector3Add(newPosition, GLKVector3MultiplyScalar(nFrontWallNormal, distanceToFrontWall));
    }
    
    if (fabsf(distanceToRightWall) < SNAPPING_DISTANCE_EPSILON / worldScale)
    {
        GLKVector3 nRightWallNormal = GLKVector3Negate([self getNormalForWall:WallRight]);
        newPosition = GLKVector3Add(newPosition, GLKVector3MultiplyScalar(nRightWallNormal, distanceToRightWall));
    }
    
    if (fabsf(distanceToFloor) < SNAPPING_DISTANCE_EPSILON / worldScale && (![self.activeEntity isDirectlyOnFloor] &&
                                                                            ![self.activeEntity canMoveInAir] &&
                                                                            ![self.activeEntity isAboveFloor]))
    {
        GLKVector3 nFloorNormal = GLKVector3Negate([self getNormalForWall:WallFloor]);
        newPosition = GLKVector3Add(newPosition, GLKVector3MultiplyScalar(nFloorNormal, distanceToFloor));
    }
    
    if (fabsf(distanceToCeiling) < SNAPPING_DISTANCE_EPSILON / worldScale && ![self.activeEntity isAttachedToCeiling])
    {
        newPosition = GLKVector3Add(newPosition, GLKVector3MultiplyScalar([self getNormalForWall:WallFloor], distanceToCeiling));
    }
    
    float totalDistanceChanged = fabsf(GLKVector3Length(GLKVector3Subtract(newPosition, entity.position)));
    
    if (totalDistanceChanged > 0.0001f)
    {
        NSLog(@"activeProductIsSnapped");
        self.activeProductIsSnapped = YES;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

// Update the active entity with the changes affecting its state
- (void)updateActiveEntity
{
    @synchronized(self)
    {
        if (self.activeEntity)
        {
            self.activeEntity.position = GLKVector3Add(position, relativePosition);
            //NSLog(@"Active Entitiy: X:%f Y:%f Z:%f",position.x, position.y, position.z);
            
            self.activeEntity.rotation = GLKVector3Make(0, rotationY - relativeRotateY, 0);
            GLfloat actualScale = self.scale * relativeScale;
            self.activeEntity.scale = GLKVector3Make(actualScale, actualScale, actualScale);
            
            //TBD
            [self.activeEntity updateModelViewMatrixWithCorrectFloor:YES];
            
            /*
             * Updating the constraints should occur in response to an action
             * Enable this atmoic boolean when it is needed for rendering and setting final
             * position.
             */
            if (self.updateConstraints)
            {
                self.activeProductIsSnapped = NO;
                
                if ([ConfigManager isProductSnappingToWallActive] && [UserSettingsPreferences isParamEnabledWithKey:kUserPreferenceGridOptionsSnapToGrid])
                    [self snapEntityToWalls:self.activeEntity];
            }
            
            [self.entities sortUsingComparator:^NSComparisonResult(Entity* obj1, Entity* obj2) {
                if (obj1.maskable){return -1;}
                if (obj2.maskable){return 1;}
                
                return [@(obj1.position.z) compare:@(obj2.position.z)];
            }];
            
            [self.entitiesShadows sortUsingComparator:^NSComparisonResult(Entity* obj1, Entity* obj2) {
                return [@(obj1.position.y) compare:@(obj2.position.y)];
            }];
            
            activeEntityIndex = [self.entities indexOfObject:self.activeEntity];
            
            [self.selectionDelegate updateProductInfoButtonForEntity:self.activeEntity];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

// Switch the focus to another entity
- (void)switchToEntity:(Entity*)entity force:(BOOL)forceSwitch
{
    if ([(MainViewController *)self.parentViewController productTagBaseView].isProductReplacedFromFamily == YES)
    {
        return;
    }
    
    [self resumeRenderer];
    
    if (entity == nil && forceSwitch == NO)
        return;
    
    if (entity == self.activeEntity)
        return;
    
    @synchronized(self) {
        [self updateActiveEntity];
        [self resetScene];
        
        // Notify about selection to delegate
        if (entity) {
            [self.selectionDelegate activeObjectSelected:entity];
            highlightObject = YES;
        } else {
            [self.selectionDelegate activeObjectDeselected];
            highlightObject = NO;
        }
        
        self.activeEntity = entity;
        
        if (entity) {
            activeEntityIndex = [self.entities indexOfObject:self.activeEntity];
            position = entity.position;
            self.scale = entity.scale.x;
            rotationY = entity.rotation.y;
        } else {
            activeEntityIndex = NSNotFound;
            [(MainViewController *)self.parentViewController stopEditing];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark GLKViewControllerDelegate
- (void)glkViewControllerUpdate:(GLKViewController *)controller
{
    @synchronized(self)
    {
        // Update cube verts array
        if (self.cubeVerts != nil) {
            int i = 0;
            for (NSNumber* num in self.cubeVerts) {
                cubeVertsGL[i++] = [num floatValue];
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    @synchronized (self)
    {
        [self updateActiveEntity];
        
        for (Entity* entity in self.entities)
        {
            if (entity.isCollection)
            {
                NSArray *arrayCopy = [NSArray arrayWithArray:[entity nestedEntities]];
                for (Entity *en in arrayCopy)
                {
                    en.cameraMatrix = [self.camera cameraMatrix];
                    en.projectionMatrix = [self.camera projectionMatrix];
                    en.backgroundColor = self.averageBackgroundColor;
                    [en updateModelViewMatrixWithCorrectFloor:YES];
                }
            }
            else
            {
                entity.cameraMatrix = [self.camera cameraMatrix];
                entity.projectionMatrix = [self.camera projectionMatrix];
                entity.backgroundColor = self.averageBackgroundColor;
                [entity updateModelViewMatrixWithCorrectFloor:YES];
            }
        }

        [self render:[DrawMode normalDrawMode] highlight:highlightObject];
        [self pauseRenderer];
    }
}

- (void)render:(DrawMode*)mode highlight:(BOOL)highlight
{
    @try
    {
        if (self.entities.count > 0)
        {
            Entity* tempEntity = self.entities[0];
            [tempEntity.effect prepareToDraw];
        }
        else
        {
            [self.effect prepareToDraw];
        }
        
        
        NSDictionary *activeArgs = [NSDictionary dictionaryWithObjectsAndKeys:
                                    mode, ENTITY_DRAWING_MODE,
                                    [NSNumber numberWithFloat:self.objectBrightness], ENTITY_OBJECT_BRIGHTNESS,
                                    [NSNumber numberWithBool:highlight], ENTITY_HIGHLIGHT,
                                    [NSNumber numberWithBool:self.contourColorChange], ENTITY_SCALE_LOCKED,
                                    nil];
        NSDictionary *nonActiveArgs = [NSDictionary dictionaryWithObjectsAndKeys:
                                       mode, ENTITY_DRAWING_MODE,
                                       [NSNumber numberWithFloat:self.objectBrightness], ENTITY_OBJECT_BRIGHTNESS,
                                       [NSNumber numberWithBool:NO], ENTITY_HIGHLIGHT,
                                       [NSNumber numberWithBool:NO], ENTITY_SCALE_LOCKED,
                                       nil];
        
        glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        glClearStencil(0);
        glEnable(GL_DEPTH_TEST);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
        
        // Draw Wireframe
        if ([UserSettingsPreferences isParamEnabledWithKey:kUserPreferenceGridOptionsSnapToGrid] &&
            self.activeProductIsSnapped &&
            self.cubeVerts != nil &&
            [mode isNormalRenderMode])
        {
            // Set the color of the wireframe.
            self.effect.texture2d0.enabled = GL_FALSE;
            self.effect.useConstantColor = GL_TRUE;
            self.effect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 0.75f);
            CGFloat oldCameraHeight = self.cameraHeight;
            self.cameraHeight = CAMERA_DEFAULT_HEIGHT;
            self.effect.transform.modelviewMatrix = [self.camera cameraMatrix];
            self.cameraHeight = oldCameraHeight;
            [self.effect prepareToDraw];
            glDisable(GL_DEPTH_TEST);
            glEnable(GL_BLEND);
            glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
            glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
            
            glEnableVertexAttribArray(GLKVertexAttribPosition);
            glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, cubeVertsGL);
            
            glLineWidth(5.0);
            glDrawElements(GL_LINES, 24, GL_UNSIGNED_BYTE, wireframe);
            
            glDisableVertexAttribArray(GLKVertexAttribPosition);
            glEnable(GL_DEPTH_TEST);
        }
        
        if (self.activeEntity)
        {
            for (Entity *nEntity in [self.activeEntity uniqueModels])
            {
                [nEntity draw:activeArgs renderShadow:NO];
            }
        }
        
        // Draw entities without shadows
        NSArray * copyArray = [NSArray arrayWithArray:self.entities];
        for (Entity* entity in copyArray)
        {
            for (Entity *nEntity in [entity uniqueModels])
            {
                if (mode.isNormalRenderMode && self.alphaCutoffShader && [nEntity plantable])
                {
                    [self.alphaCutoffShader draw:nEntity];
                }
                else
                {
                    if (mode.isNormalRenderMode)
                    {
                        [self.furnitureShader draw:nEntity highlighted:NO];
                    }
                    else
                    {
                        [nEntity draw:nonActiveArgs renderShadow:NO];
                    }
                }
            }
        }
        
        // Draw shadows only
        NSArray * copyEntitiesShadows = [NSArray arrayWithArray:self.entitiesShadows];
        for (Entity* entity in copyEntitiesShadows)
        {
            for (Entity *nEntity in [entity uniqueModels])
            {
                [nEntity draw:nonActiveArgs renderShadow:YES];
            }
        }
        
    }
    @catch (NSException *exception)
    {
        HSMDebugLog(@"Render Exception: %@", exception);
        
    }
    @finally {
        //
    }
    
    // At the end of drawing, resume the renderer to display results
    [self resumeRenderer];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark TouchEvents
// Needed to allow for rotate and pinch to play togather more nicely.
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
        if (activePinch)
            return NO;
        else
            return YES;
    } else if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        if (activeRotation)
            return NO;
        else
            return YES;
    }
    
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)pinchZoomView:(UIPinchGestureRecognizer *)recognizer
{
    NSLog(@"pinchZoomView");
    [self resumeRenderer];
    
    if (!self.activeEntity)
        return;
    
    if (activeRotation)
        [recognizer cancelGesture];
    
    if (recognizer.state == UIGestureRecognizerStateFailed) {
        activePinch = NO;
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        activePinch = NO;
        
        CGPoint tap = [recognizer locationInView:self.view];
        Entity* entity = [self findEntityByPoint:tap];
        if (entity) {
            [self switchToEntity:entity force:NO];
        }
        
        if (!self.activeEntity)
            return;
        
        [[DesignsManager sharedInstance] workingDesign].dirty = YES;
        
        if (![[[DesignsManager sharedInstance] workingDesign] isScalingLocked]) {
            [self createUndoStepForActiveEntity];
        }
    }
    
    if (activePinch && [[[DesignsManager sharedInstance] workingDesign] isScalingLocked]) {
        
//        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_UNLOCK_REAL_SCALE_DIALOG withParameters:@{EVENT_PARAM_UNLOCK_TRIGGER:EVENT_PARAM_VAL_PINCH}];
        
        if (self.selectionDelegate) {
            [self.selectionDelegate activeObjectScaleTryWhenLocked];
        }
        
        return;
    }
    
    if (!activePinch && (recognizer.scale > 1.2 || recognizer.scale < 0.8)){
        activePinch = YES;
        [recognizer setScale:1];
    }
    
    if (activePinch){
        relativeScale = recognizer.scale;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.scale *= relativeScale;
        relativeScale = 1.0f;
        activePinch = NO;
    }
    
    if (recognizer.state == UIGestureRecognizerStateCancelled) {
        relativeScale = 1.0f;
        activePinch = NO;
        [self discardLastUndoStep];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)rotateView:(UIRotationGestureRecognizer *)recognizer
{
    NSLog(@"rotateView");
    [self resumeRenderer];
    
    if (activePinch || self.activeEntity == nil)
        return;
    
    if (recognizer.state == UIGestureRecognizerStateFailed) {
        activeRotation = false;
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        activeRotation = true;
        if (self.activeEntity == nil) {
            CGPoint tap = [recognizer locationInView:self.view];
            Entity* entity = [self findEntityByPoint:tap];
            [self switchToEntity:entity force:NO];
            if (self.activeEntity == nil) return;
        }
        
        [[DesignsManager sharedInstance] workingDesign].dirty = YES;
        [self createUndoStepForActiveEntity];
    }
    
    relativeRotateY = 2.0 * [recognizer rotation];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        rotationY -= relativeRotateY;
        relativeRotateY = 0.0f;
        activeRotation = false;
        
    }
    if (recognizer.state == UIGestureRecognizerStateCancelled) {
        relativeRotateY= 0.0f;
        activeRotation = false;
        [self discardLastUndoStep];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

static WallSide sideStart = WallNone;

static float ellipseRadius(float theta, float width, float height) {
    return (width * height) / sqrtf(powf(height * cosf(theta), 2.0f) + powf(width * sinf(theta), 2.0f));
}

-(void)doAttachToWallLogic:(UIPanGestureRecognizer *)recognizer{
    [self resumeRenderer];
    
    static GLKVector3 initialPos;
    static WallSide sideStart = WallNone;
    static GLKVector3 wallNormal;
    static GLKVector2 pivotStart;
    GLKVector3 xDirection, tempWallNormal;
    GLKVector2 pivotEnd;
    self.updateConstraints = YES;
    
    if (recognizer.state == UIGestureRecognizerStateFailed)
        return;
    
    if (recognizer.state == UIGestureRecognizerStateBegan || sideStart == WallNone)
    {
        if (!self.activeEntity) {
            CGPoint tap = [recognizer locationInView:self.view];
            Entity* entity = [self findEntityByPoint:tap];
            [self switchToEntity:entity force:NO];
            
            RETURN_VOID_ON_NIL(self.activeEntity);
        }
        
        [[DesignsManager sharedInstance] workingDesign].dirty = YES;
        
        [self createUndoStepForActiveEntity];
  
        sideStart = [self wallAtPosition:position
                                       x:&xDirection
                                   pivot:&pivotStart
                                  normal:&wallNormal
                            previousWall:WallNone];
        
        WallSide tempSide = [self wallAtPosition:position
                                               x:&xDirection
                                           pivot:&pivotStart
                                          normal:&wallNormal
                                    previousWall:sideStart];
        
        if (tempSide != sideStart)
            sideStart = tempSide;
        
        initialPos = [self findIntersectionOfPoint:[recognizer locationInView:self.view]
                                  withPlaneAtPoint:position
                                        withNormal:wallNormal];
    }
    
    GLKVector3 newPos = [self findIntersectionOfPoint:[recognizer locationInView:self.view]
                                     withPlaneAtPoint:position withNormal:wallNormal];
    
    GLKVector3 oldRelativePosition = relativePosition;
    relativePosition = GLKVector3Subtract(newPos, initialPos);
    
    /*
     * To compute the current distance to the floor we must perform the move
     * of the object to the new location, check the distance and restore the current location
     */
    GLKVector3 currentPosition = self.activeEntity.position;
    self.activeEntity.position = GLKVector3Add(position, relativePosition);
    [self.activeEntity updateModelViewMatrixWithCorrectFloor:YES];
    
    float distanceToFloor = [self distanceOfEntity:self.activeEntity
                                          FromWall:WallFloor];
    
    float distanceToCeilling = [self distanceOfEntity:self.activeEntity
                                             FromWall:WallCeilling];
    
    self.activeEntity.position = currentPosition;
    [self.activeEntity updateModelViewMatrixWithCorrectFloor:YES];
    
    // If the distance to the floor is smaller than epsilon, do not allow
    // to make the move to the new position and restore to the previous
    // relative position
    if (distanceToFloor < MOVEMENT_EPSILON) {
        relativePosition.y = oldRelativePosition.y;
    }
    
    if (distanceToCeilling < MOVEMENT_EPSILON) {
        relativePosition.y = oldRelativePosition.y;
    }
    
    GLKVector3 nextPosition = GLKVector3Add(position, relativePosition);
    
    WallSide sideEnd = [self wallAtPosition:nextPosition
                                          x:&xDirection
                                      pivot:&pivotEnd
                                     normal:&tempWallNormal
                               previousWall:sideStart];
    
    if (sideStart != sideEnd)
    {
        if (sideEnd != WallFloor && sideEnd != WallCeilling)
        {
            if (sideStart == WallLeft && sideEnd == WallFront) {
                position = GLKVector3Make(pivotStart.x, nextPosition.y, pivotStart.y);
                position = GLKVector3Add(position, GLKVector3MultiplyScalar(xDirection, MOVEMENT_EPSILON));
            } else if (sideStart == WallFront && sideEnd == WallLeft) {
                position = GLKVector3Make(pivotEnd.x, nextPosition.y, pivotEnd.y);
                position = GLKVector3Add(position, GLKVector3MultiplyScalar(xDirection, -MOVEMENT_EPSILON));
            } else if (sideStart == WallFront && sideEnd == WallRight) {
                position = GLKVector3Make(pivotEnd.x, nextPosition.y, pivotEnd.y);
                position = GLKVector3Add(position, GLKVector3MultiplyScalar(xDirection, MOVEMENT_EPSILON));
            } else if (sideStart == WallRight && sideEnd == WallFront) {
                position = GLKVector3Make(pivotStart.x, nextPosition.y, pivotStart.y);
                position = GLKVector3Add(position, GLKVector3MultiplyScalar(xDirection, -MOVEMENT_EPSILON));
            }
            
            initialPos = [self findIntersectionOfPoint:[recognizer locationInView:self.view] withPlaneAtPoint:position withNormal:tempWallNormal];
            
            // Fix rotation of the art -- should face away from the wall
            GLKVector3 up = GLKVector3Make(0, 1, 0);
            GLKVector3 front = GLKVector3Make(0,0,1);
            GLKVector3 norm = GLKVector3Normalize(GLKVector3CrossProduct(xDirection, up));
            float direction = GLKVector3DotProduct(up, GLKVector3CrossProduct(front, norm));
            float angle = BIASED_SIGN(direction) * acosf(GLKVector3DotProduct(front, norm));
            rotationY = angle;
            relativeRotateY = 0.0f;
            relativePosition = GLKVector3Make(0, 0, 0);
            sideStart = sideEnd;
            wallNormal = tempWallNormal;
            pivotStart = pivotEnd;
        }
    }
    
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        position = GLKVector3Add(position, relativePosition);
        [self resetEntityMovment];
    }
    
    if (recognizer.state == UIGestureRecognizerStateCancelled) {
        [self resetEntityMovment];
        [self discardLastUndoStep];
    }
}

-(void)doNotAttachToWallLogic:(UIPanGestureRecognizer *)recognizer{
    
    if (self.activeEntity) {
        
        [self resumeRenderer];
        
        self.updateConstraints = YES;
        
        if (recognizer.state == UIGestureRecognizerStateFailed)
            return;
        
        if (recognizer.state == UIGestureRecognizerStateBegan)
        {
            [[DesignsManager sharedInstance] workingDesign].dirty = YES;
            [self createUndoStepForActiveEntity];
        }
        
        GLKVector3 oldRelativePosition = relativePosition;
        
        CGPoint translation = [recognizer translationInView:self.view];
        
        GLKVector2 actualYdir = GLKVector2Normalize(GLKVector2Make([self.camera gravityVectorForDevice].x, -[self.camera gravityVectorForDevice].y));
        GLKVector2 actualXdir = GLKVector2Make(actualYdir.y, -actualYdir.x);
        GLKVector2 transV = vecFromPoint(translation);
        GLKVector2 xMove = GLKVector2Project(transV, actualXdir);
        GLKVector2 yMove = GLKVector2Project(transV, actualYdir);

        float direction = GLKVector3DotProduct(GLKVector3Make(0, 0, 1), GLKVector3CrossProduct(GLKVector3Make(1, 0, 0), GLKVector3Make(actualXdir.x, actualXdir.y, 0)));
        float angle = acosf(GLKVector2DotProduct(actualXdir, GLKVector2Make(1, 0))) * BIASED_SIGN(direction);
        float xFactor = 2 * ellipseRadius(angle, self.view.bounds.size.width, self.view.bounds.size.height);
        float yFactor = 2 * ellipseRadius(angle + M_PI_2, self.view.bounds.size.width, self.view.bounds.size.height);
        float pitchFactor = 1.0f - 0.5f * fabsf([self.camera gravityVectorForDevice].z);
        float actualXMove = SIGN(GLKVector2DotProduct(xMove, actualXdir)) * GLKVector2Length(xMove) / xFactor;
        float actualYMove = SIGN(GLKVector2DotProduct(yMove, actualYdir)) * GLKVector2Length(yMove) / yFactor;
        
        relativePosition.x = 4.0f * MOVEMENT_SPEED * pitchFactor * actualXMove * MAX(1, (fabsf(position.z) / 5.0f));
        relativePosition.z = 8.0f * MOVEMENT_SPEED * pitchFactor * actualYMove * MAX(1, (fabsf(position.z) / 5.0f));
        
//        relativePosition.x += translation.x * pitchFactor/ (self.view.bounds.size.width * 2.8);
//        relativePosition.z += translation.y * pitchFactor / (self.view.bounds.size.height * 2.8);
        
        /*
         * To compute the current distance to the floor we must perform the move
         * of the object to the new location, check the distance and restore the current location
         */
        GLKVector3 currentPosition = self.activeEntity.position;
        self.activeEntity.position = GLKVector3Add(position, relativePosition);
        [self.activeEntity updateModelViewMatrixWithCorrectFloor:YES];
        
        float distanceToFloor = [self distanceOfEntity:self.activeEntity
                                              FromWall:WallFloor];
        
        float distanceToCeilling = [self distanceOfEntity:self.activeEntity
                                                 FromWall:WallCeilling];
        
        float distanceToLeft = [self distanceOfEntity:self.activeEntity
                                             FromWall:WallLeft];
        
        float distanceToRight = [self distanceOfEntity:self.activeEntity
                                              FromWall:WallRight];
        
        float distanceToFront = [self distanceOfEntity:self.activeEntity
                                              FromWall:WallFront];
        
        //NSLog(@"F %f C %f L %f R %f FR %f", distanceToFloor, distanceToCeilling, distanceToLeft, distanceToRight, distanceToFront);
        
        self.activeEntity.position = currentPosition;
        [self.activeEntity updateModelViewMatrixWithCorrectFloor:YES];
        
        
        if (distanceToFloor < MOVEMENT_EPSILON) {
            relativePosition.y = oldRelativePosition.y;
        }
        
        if (distanceToCeilling < MOVEMENT_EPSILON) {
            relativePosition.y = oldRelativePosition.y;
        }
        
        if ([ConfigManager isStopOnWallActive]) {
            
            if (distanceToLeft < MOVEMENT_EPSILON) {
                NSLog(@"Tought Left");
                relativePosition.x = oldRelativePosition.x;
                if (oldRelativePosition.z != relativePosition.z) {
                    //relativePosition.x -= distanceToLeft;
                }
            }
            
            if (distanceToRight < MOVEMENT_EPSILON) {
                NSLog(@"Tought right");
                relativePosition.x = oldRelativePosition.x;
                
                if (oldRelativePosition.z != relativePosition.z) {
                    //relativePosition.x += distanceToRight;
                }
            }
            
            if (distanceToFront < MOVEMENT_EPSILON) {
                NSLog(@"Tought front");
                relativePosition.z = oldRelativePosition.z;
                
                if (oldRelativePosition.x != relativePosition.x) {
                    //relativePosition.z -= distanceToFront;
                }
            }
        }
        
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            position = GLKVector3Add(position, relativePosition);
            [self resetEntityMovment];
        }
        
        if (recognizer.state == UIGestureRecognizerStateCancelled) {
            [self resetEntityMovment];
            [self discardLastUndoStep];
        }
    }
}

static BOOL isLevitateActive = NO;

- (void)moveView:(UIPanGestureRecognizer *)recognizer
{
    LevitateView * levitateButton = (LevitateView*)[self.view viewWithTag:10];

    if (recognizer.state == UIGestureRecognizerStateBegan ||
        recognizer.state == UIGestureRecognizerStateChanged){
        
        CGPoint point = [recognizer locationInView:self.view];
        //NSLog(@"point X:%f, Y:%f", point.x, point.y);

        CGPoint localPoint = [levitateButton convertPoint:point fromView:self.view];
        //NSLog(@"LP X:%f, Y:%f", localPoint.x, localPoint.y);

        if (CGRectContainsPoint(levitateButton.bounds, localPoint)) {
           // NSLog(@"touch in");
            [levitateButton touchUp];
            
            if (!isLevitateActive) {
                isLevitateActive = YES;
            }
        }else{
            //NSLog(@"touch out");
        }
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded){
        //NSLog(@"finish");
        if (isLevitateActive) {
            [self levitateView:recognizer];
            isLevitateActive = NO;
            [levitateButton touchDown];
            return;
        }
    }
    
    if (isLevitateActive) {
        [self levitateView:recognizer];
    }else{
        if ([self.activeEntity isAttachedToWall]) {
            //NSLog(@"attach to wall");
            [self doAttachToWallLogic:recognizer];
        }else{
            //NSLog(@"not attach to wall");
            [self doNotAttachToWallLogic:recognizer];
        }
    }
}

-(void)resetEntityMovment{
    relativePosition = GLKVector3Make(0, 0, 0);
    sideStart = WallNone;
    self.updateConstraints = NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)levitateView:(UIPanGestureRecognizer *)recognizer
{
    //NSLog(@"levitateView");
    [self resumeRenderer];
    
    RETURN_VOID_ON_NIL(self.activeEntity);
    
    if (![self.activeEntity canLevitate])
        return;
    
    if (recognizer.state == UIGestureRecognizerStateFailed)
        return;
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [[DesignsManager sharedInstance] workingDesign].dirty = YES;
        [self createUndoStepForActiveEntity];
    }
    
    GLKVector3 oldRelativePosition = relativePosition;
    GLKVector3 currentPosition = self.activeEntity.position;
    
    float yView = [recognizer translationInView:self.view].y / (self.view.bounds.size.height);
    float xView = [recognizer translationInView:self.view].x / (self.view.bounds.size.width);
    
    relativePosition.y = 2.0f * (-yView + xView);
    //NSLog(@"x:%f y:%f relativePosition.y:%f", [recognizer translationInView:self.view].x,[recognizer translationInView:self.view].y, relativePosition.y);

    self.activeEntity.position = GLKVector3Add(position, relativePosition);
    [self.activeEntity updateModelViewMatrixWithCorrectFloor:YES];
    
    float distanceToFloor = [self distanceOfEntity:self.activeEntity
                                          FromWall:WallFloor];
    //NSLog(@"distanceToFloor %f", distanceToFloor);
    
    float distanceToCeilling = [self distanceOfEntity:self.activeEntity
                                             FromWall:WallCeilling];
    //NSLog(@"distanceToCeilling %f", distanceToCeilling);
    
    self.activeEntity.position = currentPosition;
    [self.activeEntity updateModelViewMatrixWithCorrectFloor:YES];
    
    if (distanceToFloor < MOVEMENT_EPSILON) {
        relativePosition.y = oldRelativePosition.y;
    }
    
    if (distanceToCeilling < MOVEMENT_EPSILON) {
        relativePosition.y = oldRelativePosition.y;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        position.y += relativePosition.y;
        relativePosition.y = 0.0f;
        
        if ([self.selectionDelegate respondsToSelector:@selector(modelLiftEnded)]) {
            [self.selectionDelegate modelLiftEnded];
        }
    }
    
    if (recognizer.state == UIGestureRecognizerStateCancelled) {
        [self resetEntityMovment];
        [self discardLastUndoStep];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

// Change the focus to another object
- (void)selectObject:(UITapGestureRecognizer *)recognizer {
    [[(MainViewController *)self.parentViewController productTagBaseView] setIsProductReplacedFromFamily:NO];
    
    if (recognizer.state == UIGestureRecognizerStateFailed)
        return;
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint tap = [recognizer locationInView:self.view];
        Entity* entity = [self findEntityByPoint:tap];
        [self switchToEntity:entity force:YES];

        if (!entity ) {
            [self.selectionDelegate activeObjectDeselected];
            self.activeProductIsSnapped = NO;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark Color Picking
- (Entity*)findEntityByPoint:(CGPoint)point
{
    Entity* foundEntity;
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    @synchronized(self)
    {
        [appDelegate glkVC].paused = YES;
        NSInteger height = [appDelegate glkView].drawableHeight;
        NSInteger width = [appDelegate glkView].drawableWidth;
        Byte pixelColor[4] = {0};
        
        // Creates a separate framebuffer, so we won't change what's presented to the user.
        GLuint colorRenderbuffer;
        GLuint depthRenderbuffer;
        GLuint framebuffer;
        GLint originalFBO;
        
        glGetIntegerv(GL_FRAMEBUFFER_BINDING, &originalFBO);
        
        glGenFramebuffers(1, &framebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
        
        // create the texture
        
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, (int32_t)width, (int32_t)height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        
        glGenRenderbuffers(1, &depthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8_OES, (int32_t)width, (int32_t)height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (status != GL_FRAMEBUFFER_COMPLETE) {
            HSMDebugLog(@"Framebuffer status: %x", (int)status);
            foundEntity = nil;
        } else {
            
            [self render:[DrawMode pickingDrawMode] highlight:NO];
            
            // Read the color of the pixel at the point.
            CGFloat screenScale = [appDelegate glkView].contentScaleFactor;
            glReadPixels(point.x * screenScale, (height - (point.y * screenScale)), 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, pixelColor);
            
            // Convert the color array to a color vector
            GLKVector4 colorCode = GLKVector4Make(pixelColor[0]/255.0, pixelColor[1]/255.0, pixelColor[2]/255.0, pixelColor[3]/255.0);
            
            // Return any matching entity by the key defined by the color code.
            // nil is returned if nothing is found.
            foundEntity = [self.entitiesDict objectForKey:[Entity keyWithColorCode:colorCode]];
            
            glClearColor(0, 0, 0, 0);
            glClear(GL_COLOR_BUFFER_BIT);
        }
        
        glBindFramebuffer(GL_FRAMEBUFFER, originalFBO);
        [appDelegate.glkView bindDrawable];
        
        glDeleteRenderbuffers(1, &depthRenderbuffer);
        glDeleteRenderbuffers(1, &colorRenderbuffer);
        glDeleteFramebuffers(1, &framebuffer);
        
        
        [appDelegate glkVC].paused = NO;
    }
    return foundEntity;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (CGPoint)getEntityPoint:(Entity*)entity
{
    if (entity == nil)
        return CGPointZero;
    
    [entity updateModelViewMatrixWithCorrectFloor:YES];
    int viewport[4] = {self.view.bounds.origin.x,
        self.view.bounds.origin.y,
        self.view.bounds.size.width,
        self.view.bounds.size.height};
    
    GLKVector3 p = GLKMathProject(entity.position,
                                  self.camera.cameraMatrix,
                                  self.effect.transform.projectionMatrix,
                                  viewport);
    
    return CGPointMake(p.x, self.view.bounds.size.height - p.y);
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (CGPoint)getEntityPoint:(Entity*)entity withOffset:(GLKVector3)offset
{
    if (entity == nil)
        return CGPointZero;
    
    [entity updateModelViewMatrixWithCorrectFloor:YES];
    int viewport[4] = {self.view.bounds.origin.x,
        self.view.bounds.origin.y,
        self.view.bounds.size.width,
        self.view.bounds.size.height};
    
    GLKVector3 p = GLKMathProject(GLKVector3Add(entity.position, offset),
                                  self.camera.cameraMatrix,
                                  self.effect.transform.projectionMatrix,
                                  viewport);
    
    return CGPointMake(p.x, self.view.bounds.size.height - p.y);
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)removeEntity:(NSInteger)key
{
    [self resumeRenderer];
    Entity* entity = [self.entitiesDict objectForKey:[NSNumber numberWithInteger:key]];
    if (entity) {
        if (self.activeEntity == entity) {
            [self switchToEntity:nil force:YES];
        }
        [self.entitiesDict removeObjectForKey:[NSNumber numberWithInteger:key]];
        [self.entities removeObject:entity];
        [self.entitiesShadows removeObject:entity];
        
        if (self.activeEntity) {
            activeEntityIndex = [self.entities indexOfObject:self.activeEntity];
        }
        
        [self.selectionDelegate removedEntity:entity.modelId
                               andVariationId:entity.variationId];
        
        //remove undo/redo actions
        [self removeUndoHistoryForEntity:entity];
        self.activeProductIsSnapped = NO;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (UIImage*) snapshot
{
    //hold varable state
    BOOL oldHightlightObject = highlightObject;
    BOOL oldActiveProductIsSnapped = self.activeProductIsSnapped;
    
    //remove snap and highlight
    highlightObject = NO;
    self.activeProductIsSnapped = NO;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [[appDelegate glkView] display];
    UIImage* screenshot = [[appDelegate glkView] snapshot];
    
    //restore variables
    highlightObject = oldHightlightObject;
    self.activeProductIsSnapped = oldActiveProductIsSnapped;
    return screenshot;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)resetObjectScale:(Entity*)entity
{
    [self createUndoStepForEntity:entity];
    entity.scale = GLKVector3Make(1.0f, 1.0f, 1.0f);
    self.scale = 1.0f;
    [self resumeRenderer];
}

- (void)adjustObject:(Entity*)entity brightness:(float)val
{
    entity.brightness = val;
    [self resumeRenderer];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)hasActiveObject {
    return self.activeEntity != nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)updateBackgroundColor
{
    UIImage* background = [[[DesignsManager sharedInstance] workingDesign] image];
    
    if (background)
        self.averageBackgroundColor = [background findAverageColor];
}



////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Undo/Redo Methods

- (void)createUndoStepForActiveEntity
{
    [self createUndoStepForEntity:self.activeEntity];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)createUndoStepForEntity:(Entity*)entity
{
    [self.undoHandler clearCommandByType:kCommandRedo];
    CommandItem * state = [[CommandItem alloc]initWithPosition:entity.position rotation:entity.rotation andScale:entity.scale forItemID:entity.sceneEntityGUID];
    
    [self.undoHandler addUndoCommand:state];
    
    if (self.selectionDelegate && [self.selectionDelegate respondsToSelector:@selector(updateUndoRedoStates)])
    {
        [self.selectionDelegate updateUndoRedoStates];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)discardLastUndoStep
{
    [self.undoHandler getUndoCommand];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(Entity*)findEntityByID:(NSString*)itemID{
    
    for (Entity *en in self.entities) {
        if ([en.sceneEntityGUID isEqualToString:itemID]) {
            return en;
        }
    }
    return nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)canUndo
{
    return [self.undoHandler canPerformCommand:kCommandUndo];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)canRedo
{
    return [self.undoHandler canPerformCommand:kCommandRedo];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)applyUndoStep
{
    
    CommandItem * step = [self.undoHandler getUndoCommand];
    Entity * entity = [self findEntityByID:step.itemID];
    
    
    if (entity)
    {
        CommandItem * currentState = [[CommandItem alloc]initWithPosition:entity.position rotation:entity.rotation andScale:entity.scale forItemID:entity.sceneEntityGUID];
        
        [self.undoHandler addRedoCommand:currentState];
        
        
        
        [self updateEntityPresentationAfterUndoRedo:step entity:entity];
        
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)applyRedoStep
{
    CommandItem * step = [self.undoHandler getRedoCommand];
    Entity * entity = [self findEntityByID:step.itemID];
    
    if (entity)
    {
        CommandItem * currentState = [[CommandItem alloc]initWithPosition:entity.position rotation:entity.rotation andScale:entity.scale forItemID:entity.sceneEntityGUID];
        
        [self.undoHandler addUndoCommand:currentState];
        
        [self updateEntityPresentationAfterUndoRedo:step entity:entity];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)removeUndoHistoryForEntity:(Entity*)entity
{
    [self.undoHandler removeCommandsForCommandID:entity.sceneEntityGUID];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updateFloor
{
    if ([[ConfigManager getTenantIdName] isEqualToString:@"ezhome"]) {
        return;
    }
    
    float newFloor = (self.cubeVerts == nil) ? 0 : [self getVectorForVertex:3].y;
    NSString* formatVersion = [[DesignsManager sharedInstance] workingDesign].FormatVersion;
    
    if ([formatVersion isEqualToString:@"1.2"] && [[DesignsManager sharedInstance] workingDesign].supportsFullConcealAPI)
    {
        self.cameraHeight = CAMERA_DEFAULT_HEIGHT - newFloor;
    }
    else
    {
        self.cameraHeight = CAMERA_DEFAULT_HEIGHT;
    }
}

- (void)updateEntityPresentationAfterUndoRedo:(CommandItem *)step entity:(Entity *)entity {
    // we must set the active entity otherwise the effect will be done on different object
    [self switchToEntity:entity force:YES];
    
    entity.position = step.position;
    entity.rotation = step.rotation;
    entity.scale = step.scale;
    //we must update these local variables otherwise there is not effect when calling update Active Entity
    position = entity.position;
    self.scale = entity.scale.x;
    rotationY = entity.rotation.y;
    [self updateActiveEntity];
}

- (void)addEntity:(NSString*)modelId
      variationId:(NSString*)variationId
          withObj:(GraphicObject*)obj
  withTextureInfo:(GLKTextureInfo*)textureInfo
     withMetadata:(NSDictionary*)metaDict
     withPosition:(GLKVector3)aPosition
     withRotation:(GLKVector3)aRotation
        withScale:(GLKVector3)aScale
{
    @synchronized(self)
    {
        Entity* entity = [[Entity alloc] initWithGraphicObj:obj
                                                    texture:textureInfo
                                                   metadata:metaDict
                                                 baseEffect:self.effect
                                               withPosition:aPosition
                                               withRotation:aRotation
                                                  withScale:aScale];
        
        if (entity) {
            entity.modelId = modelId;
            entity.variationId = variationId;
            
            NSNumber *brightness = [metaDict objectForKey:EntityKeyBrightness];
            entity.brightness = ENTITY_DEFAULT_BRIGHTNESS;
            if (brightness)
                entity.brightness = [brightness floatValue];
            
            if (!textureInfo) {
                entity.useShader = YES;
            }
            
            [self resetScene];
            
            self.activeEntity = entity;
            
            BOOL addedItemFromSaveDesign = NO;
            if(self.activeEntity.position.x != 0 || self.activeEntity.position.y != 0 || self.activeEntity.position.z != 0) {
                addedItemFromSaveDesign = YES;
            }
            
            if(self.activeEntity.rotation.y != 0) {
                addedItemFromSaveDesign = YES;
            }
            
            if (!addedItemFromSaveDesign) {
                [self.selectionDelegate activeObjectSelected:self.activeEntity];
            }
            
            // Put the new entity ordered by the Y coordinate: needed for shadows drawing (ordering by the y coordinates)
            NSUInteger idx = [self.entities indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                if ([(Entity*)obj position].y >= entity.position.y) {
                    *stop = YES;
                    return YES;
                }
                return NO;
            }];
            
            if (idx == NSNotFound)
                idx = [self.entities count];
            
            [self.entities insertObject:entity atIndex:idx];
            [self.entitiesShadows insertObject:entity atIndex:idx];
            [self.entitiesDict setObject:entity forKey:entity.key];
            activeEntityIndex = idx;
            [self resetObjectState];
            BOOL externalObject = NO;
            
            if(aPosition.x != 0 || aPosition.y != 0 || aPosition.z != 0) {
                position = entity.position;
                externalObject = YES;
            }
            
            if( aRotation.y != 0 ) {
                rotationY = aRotation.y;
                externalObject = YES;
            }
            
            self.scale = 1.0f;
            if(aScale.y != 1) {
                self.scale = aScale.y;
                externalObject = YES;
            }
            
            // Fix for old designs that used the wrong value for floor:
            NSString* formatVersion = [[[DesignsManager sharedInstance] workingDesign] FormatVersion];
            if (externalObject == YES && [formatVersion isEqualToString:@"1"] == YES && self.cubeVerts != nil && [entity canLevitate] == YES) {
                float oldUseOfFloor = [self getVectorForVertex:3].y;
                position = GLKVector3Add(position, GLKVector3Make(0, -oldUseOfFloor, 0));
            }
            
            activeEntityIndex = [self.entities indexOfObject:self.activeEntity];
        }
    }
}
///////////////////////////////////////////////////////
// Collection implementation                         //
///////////////////////////////////////////////////////

- (void)addEntityFromCollection:(Entity*)collection
                        modelId:(NSString*)modelId
                    variationId:(NSString*)variationId
                        withObj:(GraphicObject*)obj
                withTextureInfo:(GLKTextureInfo*)textureInfo
                   withMetadata:(NSDictionary*)metaDict
                   withPosition:(GLKVector3)aPosition
                   withRotation:(GLKVector3)aRotation
                      withScale:(GLKVector3)aScale
{
    @synchronized(self)
    {
        /*
         *  Collections may be extracted from two different sources:
         *  (1) A floorplan JSON
         *  (2) A saved JSON which was saved in HSM format
         *
         *  The location fix should be applied only if we extracted a floorplan JSON
         */
        if ([collection shouldApplyFloorplanFix])
        {
            aPosition = GLKVector3Make(aPosition.x - [[obj getBoundingBox] centerOfBox].x,
                                       aPosition.y - [obj getBoundingBox].minY,
                                       aPosition.z - [[obj getBoundingBox] centerOfBox].z);
        }
        
        Entity* entity = [[Entity alloc] initWithGraphicObj:obj
                                                    texture:textureInfo
                                                   metadata:metaDict
                                                 baseEffect:self.effect
                                               withPosition:aPosition
                                               withRotation:aRotation
                                                  withScale:aScale];
        if (entity){
        
            [collection.nestedEntities removeObjectAtIndex:0];
            [collection.nestedEntities addObject:entity];
            [self.entitiesDict setObject:collection forKey:entity.key];
            entity.parentEntity = collection;
            entity.modelId = modelId;
            entity.variationId = variationId;
            entity.entityType = EntityNodeTypeProduct;
            NSNumber *brightness = [metaDict objectForKey:EntityKeyBrightness];
            entity.brightness = ENTITY_DEFAULT_BRIGHTNESS;
            if (brightness)
                entity.brightness = [brightness floatValue];
            
            if (textureInfo==NULL) {
                entity.useShader=YES;
            }
            
            [self resetScene];
            
            self.scale = 1.0f;
            entity.scale = GLKVector3Make(self.scale, self.scale, self.scale);
            
            if( aRotation.y != 0 ) {
                rotationY = aRotation.y;
            }
            
            if(aScale.y != 1) {
                self.scale = aScale.y;
            }
            
            BOOL addedItemFromSaveDesign = NO;
            if(collection.position.x != 0 || collection.position.y != 0 || collection.position.z != 0) {
                position = collection.position;
                addedItemFromSaveDesign = YES;
            }
            
            if(collection.rotation.y != 0) {
                rotationY = collection.rotation.y;
                addedItemFromSaveDesign = YES;
            }
            
            // Set the collection as active only when loading from catalog
            if (!addedItemFromSaveDesign)
            {
                self.activeEntity = collection;
                [self updateActiveEntity];
                [self.selectionDelegate activeObjectSelected:self.activeEntity];
            }
            
            // reset object only if we are not replacing the product
            if (![[(MainViewController *)self.parentViewController productTagBaseView] isProductReplacedFromFamily])
            {
                [self resetObjectState];
            }
        }
    }
}

-(void)updateGLOwner{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [appDelegate setDrawableMultisample];
    
    [[appDelegate glkView] removeFromSuperview];
    [self.view addSubview:[appDelegate glkView]];
    [appDelegate glkView].delegate = self;
    [appDelegate glkVC].delegate = self;
    [appDelegate glkView].frame = self.view.bounds;
    [self.view sendSubviewToBack:[appDelegate glkView]];
    [[appDelegate glkView] bindDrawable];
    
    [appDelegate glkView].drawableDepthFormat = GLKViewDrawableDepthFormat24;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)pauseRenderer
{
    @synchronized(self)
    {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate.glkVC setPaused:YES];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)resumeRenderer
{
    @synchronized(self)
    {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state != UIApplicationStateBackground && state != UIApplicationStateInactive)
        {
            [appDelegate.glkVC setPaused:NO];
        }
    }
}

@end
