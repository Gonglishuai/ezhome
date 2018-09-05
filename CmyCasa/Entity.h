//
//  Encapsulate all the information about a specific entity in the scene.
//  including shape, texture, position, rotation, scale, and identifying key.
//
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "GraphicObject.h"
#import "DrawMode.h"
#import "ModelBoundingBox.h"

#define ENTITY_DRAWING_MODE (@"Entity Drawing Mode")
#define ENTITY_HIGHLIGHT (@"Entity Hightlight")
#define ENTITY_SCALE_LOCKED (@"Entity Scale Locked")
#define ENTITY_OBJECT_BRIGHTNESS (@"Entity Object Brightness")
#define ENTITY_DEFAULT_BRIGHTNESS (1.0)
#define Z_INDEX (@"zIndex")
#define Z_INDEX_DIRECTLY_ON_FLOOR (100)
#define Z_INDEX_LEVITATE_THRESHOLD (200)
#define Z_INDEX_LEVITATE (300)
#define Z_INDEX_ATTACHED_TO_WALL (400)
#define Z_INDEX_ATTACHED_TO_WALL_BOTTOM (410)
#define Z_INDEX_ATTACHED_TO_CEILING (500)
#define CONTOUR_WIDTH (0.025f)
#define CONTOUR_COLOR_RED (1)
#define CONTOUR_COLOR_GREEN (1)
#define CONTOUR_COLOR_BLUE (0)
#define CONTOUR_LOCKED_COLOR_RED (1)
#define CONTOUR_LOCKED_COLOR_GREEN (0)
#define CONTOUR_LOCKED_COLOR_BLUE (0)
#define CONTOUR_COLOR_ALPHA (0.4)


extern NSString* const EntityKeyBrightness;

@interface Entity : NSObject <NSCoding, NSCopying>

@property (strong, nonatomic) GraphicObject* graphicObj;
@property (strong, nonatomic) GLKTextureInfo* texture;
@property (strong, nonatomic) GLKBaseEffect* effect;
@property (strong, nonatomic) NSDictionary* metadata;
@property (strong, nonatomic) UIColor* backgroundColor;
@property (strong, nonatomic) NSNumber * scaleFactor;
@property (strong, atomic) NSNumber* key;
@property (assign, atomic) BOOL isLocked;
@property (assign, atomic) GLKVector3 position;
@property (assign, atomic) GLKVector3 rotation;
@property (assign, nonatomic) GLKVector3 scale;
@property (assign, atomic) GLKMatrix4 modelviewMatrix;
@property (assign, atomic) GLKMatrix4 cameraMatrix;
@property (assign, atomic) GLKMatrix4 projectionMatrix;
@property (assign, atomic) float brightness;
@property (assign) BOOL useShader;
@property (assign) BOOL maskable;
@property (assign) BOOL plantable;
@property (assign) float randomY;
@property (strong, nonatomic) NSString* modelId;
@property (strong , nonatomic) NSString * sceneEntityGUID; //used of identify unique instance of the enitity in scene
@property (nonatomic) float originalScale;
@property (assign, atomic) BOOL shouldApplyFloorplanFix;

+(NSNumber*)keyWithColorCode:(GLKVector4)colorCode;
+(GLKVector4)colorCodeWithKey:(NSNumber*)key;

-(id)initWithGraphicObj:(GraphicObject*)obj
                texture:(GLKTextureInfo*)textureInfo
               metadata:(NSDictionary*)metaDict
             baseEffect:(GLKBaseEffect*)baseEffect
           withPosition:(GLKVector3)position
           withRotation:(GLKVector3)rotation
              withScale:(GLKVector3)scale;

-(void)draw:(NSDictionary*)options renderShadow:(BOOL) renderShadow;
-(void)drawWithKey:(NSDictionary *)options renderShadow:(BOOL)shouldRenderShadow key:(NSNumber*)key;
-(void)drawObjectWithShadow:(BOOL)isShadowVisible;
-(void)updateModelViewMatrixWithCorrectFloor:(BOOL)correctFloor;
-(BOOL)canLevitate;
-(BOOL)canMoveInAir;
-(BOOL)isAttachedToWall;
-(BOOL)isAttachedToWallBottom;
-(BOOL)isAttachedToCeiling;
-(BOOL)isDirectlyOnFloor;
-(BOOL)isAboveFloor;
-(float)widthX;
-(float)widthY;
-(float)widthZ;
-(NSDictionary*)jsonData;
-(void) prepareEffectForNormalRenderMode:(float)aBrightness;

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone *)zone;
+ (Entity*)entityWithJsonDictionary:(NSDictionary*)jsonData;


- (ModelBoundingBox*)getEntityBoundingBox;

///////////////////////////////////////////////////////
// Swappable implementation                          //
///////////////////////////////////////////////////////

@property (strong, nonatomic) NSString *variationId;

///////////////////////////////////////////////////////
// Collection implementation                         //
///////////////////////////////////////////////////////

typedef enum entity_node_type
{
    EntityNodeTypeNone = 0,
    EntityNodeTypeModelView,
    EntityNodeTypeProduct
} EntityNodeType;

- (id)initAsCollection:(GLKVector3)absPosition
          withRotation:(GLKVector3)absRotation
             withScale:(GLKVector3)absScale
withMetadataDictionary:(NSDictionary*)metadataDict;

+ (Entity*)entityWithFloorplanDictionary:(NSDictionary*)jsonData;

- (void)addEntityToCollection:(Entity*)entity;

- (BOOL)isCollection;

- (NSArray*)uniqueModels;

// The nestedEntities and parentEntity define this Entity Node
// tree structure.
@property (strong, nonatomic) NSMutableArray *nestedEntities;
@property (strong, nonatomic) Entity *parentEntity;
@property (nonatomic) EntityNodeType entityType;

///////////////////////////////////////////////////////

- (void)alignModelsAccordingToZIndex;

- (Entity*)cloneEntity;

@end
