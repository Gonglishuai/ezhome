//
//  Furniture3DViewController.h
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphicObject.h"
#import "Entity.h"
#import "DrawMode.h"
#import "CubeViewController.h"
#import "SavedGyroData.h"
#import "UndoHandler.h"

@protocol Furniture3DViewControllerSelectionDelegate <NSObject>

/*
 this method uses 'isSelectedProduct' to flag if we need to reload product
 info table or just title cell after choosing variation
 */
-(void)activeObjectSelected:(Entity*)entity;
-(void)activeObjectDeselected;
-(void)updateProductInfoButtonForEntity:(Entity*)entity;
-(void)removedEntity:(NSString*)modelId andVariationId:(NSString*)variationId;
-(void)modelLiftEnded;
-(void)activeObjectScaleTryWhenLocked;
-(void)recheckAllModelsAddedToScene;
-(void)updateUndoRedoStates;
@end

@interface Furniture3DViewController : General3DViewController <UIGestureRecognizerDelegate,UndoHandlerDelegate> {
	NSUInteger activeEntityIndex;
    
    // Last state of current active entity
	GLKVector3 position;
    GLfloat rotationY;
    BOOL highlightObject;
	int highlightFrames;
	
    // Relative state of current active entity
    GLKVector3 prevPosition;
	GLKVector3 relativePosition;
	GLfloat relativeScale;
	GLfloat relativeRotateY;
	
	GLKMatrix4 cameraMatrix;
	GLfloat cubeVertsGL[CUBE_VERTS*COORDS];
	bool activeRotation;
	bool activePinch;
}
@property (nonatomic,strong) UndoHandler * undoHandler;
@property (strong, nonatomic) NSMutableDictionary* entitiesDict;
@property (strong, nonatomic) NSMutableArray* entities;
@property (strong, nonatomic) NSMutableArray* entitiesShadows;
@property (strong, nonatomic) Entity* activeEntity;
@property (weak, nonatomic) id <Furniture3DViewControllerSelectionDelegate> selectionDelegate;
@property (assign) float objectBrightness;
@property (strong, atomic) NSArray* cubeVerts;
@property (assign) float contourColorChange;
@property (nonatomic, assign) float scale; //internal use only

#pragma mark Hotspots support

- (UIImage*) snapshot;

#pragma mark General Methods
// Clear all the objects and reset the scene
- (void)clearScene;
// Reset all the current state and relative states (keep objects)
- (void)resetScene;


// Switch to another entity.
- (void)switchToEntity:(Entity*)entity force:(BOOL)forceSwitch;
// Returns where the entity is shown on screen.
- (CGPoint)getEntityPoint:(Entity*)entity;

- (CGPoint)getEntityPoint:(Entity*)entity withOffset: (GLKVector3) offset;

// Remove the given entity by its key
- (void)removeEntity:(NSInteger)key;

//Reset the scale of selected entity
- (void)resetObjectScale:(Entity*)entity;

- (void)adjustObject:(Entity*)entity brightness:(float)val;

// Returns if one of the objects is selected.
- (BOOL)hasActiveObject;

- (void)updateActiveEntity;

#pragma mark GLKViewControllerDelegate
- (void)glkViewControllerUpdate:(GLKViewController *)controller;

#pragma mark GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect;
- (void)render:(DrawMode*)mode highlight:(BOOL)highlight;

#pragma mark TouchEvents
- (void)pinchZoomView:(UIPinchGestureRecognizer *)recognizer;
- (void)rotateView:(UIRotationGestureRecognizer *)recognizer;
- (void)moveView:(UIPanGestureRecognizer *)recognizer;
- (void)levitateView:(UIPanGestureRecognizer *)recognizer;
- (void)selectObject:(UITapGestureRecognizer *)recognizer;


#pragma mark Color Picking
// Find an entity by where it's painted on the screen.
- (void)createUndoStepForEntity:(Entity*)entity;

- (Entity*)findEntityByPoint:(CGPoint)point;
-(void)updateBackgroundColor;
-(void)updateGLOwner;
-(void)pauseRenderer;
-(void)resumeRenderer;
-(void)updateFloor;

///////////////////////////////////////////////////////
// Collection implementation                         //
///////////////////////////////////////////////////////

// Add a new entity to the view.
- (void)addEntity:(NSString*)modelId
      variationId:(NSString*)variationId
          withObj:(GraphicObject*)obj
  withTextureInfo:(GLKTextureInfo*)textureInfo
     withMetadata:(NSDictionary*)metaDict
     withPosition:(GLKVector3)aPosition
     withRotation:(GLKVector3)aRotation
        withScale:(GLKVector3)aScale;

- (void)addEntityFromCollection:(Entity*)collection
                        modelId:(NSString*)modelId
                    variationId:(NSString*)variationId
                        withObj:(GraphicObject*)obj
                withTextureInfo:(GLKTextureInfo*)textureInfo
                   withMetadata:(NSDictionary*)metaDict
                   withPosition:(GLKVector3)aPosition
                   withRotation:(GLKVector3)aRotation
                      withScale:(GLKVector3)aScale;

@end
