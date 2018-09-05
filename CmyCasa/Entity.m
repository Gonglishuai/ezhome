//
//  Entity.m
//
//
// Edit by Sergei on 2/20/14 - Enabled all objects to levitate

#import "Entity.h"
#import "NSString+Contains.h"
#import "ServerUtils.h"

static long lastID = 0;
#define RUG_Y (-0.1f)

NSString* const EntityKeyModelId = @"productId";
NSString* const EntityKeyVariationId = @"variationId";
NSString* const EntityKeyPositionX = @"x";
NSString* const EntityKeyPositionY = @"y";
NSString* const EntityKeyPositionZ = @"z";
NSString* const EntityKeyRotationY = @"yRot";
NSString* const EntityKeyScale = @"scale";
NSString* const EntityKeyIsLocked = @"isLocked";
NSString* const EntityKeyBrightness = @"brightness";
NSString* const EntityKeyZIndex = @"zIndex";

NSString* const FPEntityKeyModelId = @"id";
NSString* const FPEntityKeyMetaField = @"meta";
NSString* const FPEntityKeyPositionX = @"x";
NSString* const FPEntityKeyPositionY = @"y";
NSString* const FPEntityKeyPositionZ = @"z";
NSString* const FPEntityKeyRotationY = @"rotation";
NSString* const FPEntityKeyPositionContainer = @"position";

@interface Entity ()
@property NSArray* subObjectsOrder;
@end

@implementation Entity
@synthesize position, rotation, cameraMatrix, modelviewMatrix, effect, texture, metadata,projectionMatrix,maskable,plantable;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(id)initWithGraphicObj:(GraphicObject*)obj
                texture:(GLKTextureInfo*)textureInfo
               metadata:(NSDictionary*)metaDict
             baseEffect:(GLKBaseEffect*)baseEffect
           withPosition:(GLKVector3)aPosition
           withRotation:(GLKVector3)aRotation
              withScale:(GLKVector3)aScale
{
	if (self = [super init]) {
		if (obj == nil || obj.numberOfObjects == 0 || baseEffect == nil) {
            return nil;
        };
		self.graphicObj = obj;
		
        self.sceneEntityGUID = [[ServerUtils sharedInstance] generateGuid];
        if (textureInfo != nil) {
			if ([self.graphicObj texCoordOfObject:0] == NULL) {
                return nil;
            };
			self.texture = textureInfo;
		} else {
			self.texture = nil;
		}
		
		self.metadata = metaDict;
		self.effect = baseEffect;
		
		self.cameraMatrix = GLKMatrix4Identity;
		self.key = [NSNumber numberWithLong:++lastID];
		self.randomY = RUG_Y * ((float)rand() / RAND_MAX) / 3.0f;
        self.isLocked = NO;
        self.position = aPosition;
        self.rotation = aRotation;
        self.scale = aScale;
        self.scaleFactor=[NSNumber numberWithFloat:aScale.x];
        self.brightness = 1;
        [self updateModelViewMatrixWithCorrectFloor:YES];
        
        NSMutableArray* order = [NSMutableArray arrayWithCapacity:self.graphicObj.numberOfObjects];
        for (int i = 0; i < self.graphicObj.numberOfObjects; i++) {
            [order addObject:@{@"name": [self.graphicObj nameOfObject:i], @"index": @(i)}];
        }
        [order sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
            if ([obj1[@"name"] contains:@"shadow" options:NSCaseInsensitiveSearch]) {
                if ([obj2[@"name"] contains:@"shadow" options:NSCaseInsensitiveSearch]) {
                    return [obj1[@"index"] compare:obj2[@"index"]];
                }
                return NSOrderedDescending;
            }
            if ([obj2[@"name"] contains:@"shadow" options:NSCaseInsensitiveSearch]) {
                return NSOrderedAscending;
            }
            
            return [obj1[@"index"] compare:obj2[@"index"]];
        }];
        self.subObjectsOrder = [order copy];

        self.maskable = [self isMask];
        self.plantable = [self isPlant];
        self.entityType = EntityNodeTypeProduct;
        self.shouldApplyFloorplanFix = NO;
	}
	return self;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)updateModelViewMatrixWithCorrectFloor:(BOOL)correctFloor
{
	if (correctFloor && !self.parentEntity && [self isDirectlyOnFloor]) {
			position.y = RUG_Y;
	}
	
	modelviewMatrix = GLKMatrix4Identity;
    
    if (self.parentEntity)
    {
        modelviewMatrix = GLKMatrix4Translate(modelviewMatrix,
                                              self.parentEntity.position.x,
                                              self.parentEntity.position.y,
                                              self.parentEntity.position.z);
        
        modelviewMatrix = GLKMatrix4Scale(modelviewMatrix,
                                          self.parentEntity.scale.x,
                                          self.parentEntity.scale.y,
                                          self.parentEntity.scale.z);
        
        modelviewMatrix = GLKMatrix4RotateY(modelviewMatrix, self.parentEntity.rotation.y);
    }
    
    modelviewMatrix = GLKMatrix4Translate(modelviewMatrix, position.x, position.y, position.z);
    modelviewMatrix = GLKMatrix4Scale(modelviewMatrix, _scale.x, _scale.y, _scale.z);
    modelviewMatrix = GLKMatrix4RotateY(modelviewMatrix, rotation.y);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)drawWithKey:(NSDictionary *)options renderShadow:(BOOL)shouldRenderShadow key:(NSNumber*)key
{
	DrawMode* mode = [options objectForKey:ENTITY_DRAWING_MODE];
    
	if (mode.isNormalRenderMode)
    {
        [self prepareEffectForNormalRenderMode:self.brightness];
	}
    else if (mode.isPickingRenderMode)
    {
        [self prepareEffectForPickingRenderModeWithKey:key];
	}
    
    BOOL highlight = [(NSNumber*)[options objectForKey:ENTITY_HIGHLIGHT] boolValue];
    
	if (mode.isNormalRenderMode && highlight) {
        BOOL lockedOperation = [(NSNumber*)[options objectForKey:ENTITY_SCALE_LOCKED] boolValue];
        [self renderEntityHighlight :lockedOperation];
    } else {
        [self renderEntity: shouldRenderShadow];
    }
    
	glDisable(GL_BLEND);
	glDisable(GL_CULL_FACE);
	glDisable(GL_STENCIL_TEST);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)draw:(NSDictionary *)options renderShadow:(BOOL)shouldRenderShadow
{
	[self drawWithKey:options renderShadow:shouldRenderShadow key:self.key];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) renderEntity: (BOOL) renderShadow
{
    [effect prepareToDraw];
    
    glDisable(GL_STENCIL_TEST);
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    
    [self drawObjectWithShadow:renderShadow];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

// For color picking -- paint the object with the color code matching its key.
- (void) prepareEffectForPickingRenderModeWithKey:(NSNumber*)key
{
    effect.transform.modelviewMatrix = GLKMatrix4Multiply(self.cameraMatrix, modelviewMatrix);
    effect.colorMaterialEnabled = GL_FALSE;
    effect.light0.enabled = GL_FALSE;
    effect.texture2d0.enabled = GL_FALSE;
    effect.useConstantColor = GL_TRUE;
    effect.constantColor = [Entity colorCodeWithKey:key];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (GLKVector3) calculateHighlightScaleFactor {
    float contourScaleX, contourScaleY, contourScaleZ;
    if (self.graphicObj.widthX > 0) {
        contourScaleX = (self.graphicObj.widthX + CONTOUR_WIDTH) / self.graphicObj.widthX;
    } else {
        contourScaleX = 1;
    }
    if (self.graphicObj.widthY > 0) {
        contourScaleY = (self.graphicObj.widthY + CONTOUR_WIDTH) / self.graphicObj.widthY;
    } else {
        contourScaleY = 1;
    }
    if (self.graphicObj.widthZ > 0) {
        contourScaleZ = (self.graphicObj.widthZ + CONTOUR_WIDTH) / self.graphicObj.widthZ;
    } else {
        contourScaleZ = 1;
    }
    return GLKVector3Make(contourScaleX, contourScaleY, contourScaleZ);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) prepareEffectForNormalRenderMode:(float)aBrightness
{
    effect.colorMaterialEnabled = GL_FALSE;
    effect.transform.modelviewMatrix = GLKMatrix4Multiply(self.cameraMatrix, modelviewMatrix);
    
    GLKVector3 color = GLKVector3Make(1, 1, 1);
    if (self.backgroundColor) {
        CGFloat red, green, blue, alpha;
        [self.backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
        color = GLKVector3Make(red, green, blue);
    }
    float factor = MAX(color.x, MAX(color.y, color.z));
    if (factor <= 0) color = GLKVector3Make(1, 1, 1);
    color = GLKVector3DivideScalar(color, factor);
    color = GLKVector3MultiplyScalar(color, aBrightness);
    float strength = [[ConfigManager sharedInstance] backgroundColorFactor];
    color = GLKVector3Lerp(GLKVector3Make(aBrightness, aBrightness, aBrightness), color, strength);
    effect.useConstantColor = GL_TRUE;
    effect.constantColor = GLKVector4MakeWithVector3(color, 1);//GLKVector4Make(aBrightness, aBrightness, aBrightness, 1.0f);
    // Lighting must be always off for offscreen buffer (for picking) to work. No idea why, but that seems to be the case.
    effect.light0.enabled = GL_FALSE;
    if (self.texture != nil) {
        effect.texture2d0.enabled = GL_TRUE;
        effect.texture2d0.target = GLKTextureTarget2D;
        effect.texture2d0.name = texture.name;
        effect.texture2d0.envMode = GLKTextureEnvModeModulate;
        
    } else {
        effect.texture2d0.enabled = GL_FALSE;
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) renderEntityHighlight :(BOOL)locked
{
    effect.texture2d0.enabled = GL_FALSE;
    effect.useConstantColor = GL_TRUE;
    GLKVector4 oldColor = effect.constantColor;
    effect.constantColor = GLKVector4Make(0, 0, 0, 0);
    [effect prepareToDraw];
    
    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_FALSE);
    glEnable(GL_STENCIL_TEST);
    glStencilFunc(GL_ALWAYS, 1, ~0);
    glStencilOp(GL_KEEP, GL_REPLACE, GL_REPLACE);
    
    [self drawObjectWithShadow:NO];
    
    effect.constantColor = GLKVector4Make(CONTOUR_COLOR_RED,
                                          CONTOUR_COLOR_GREEN,
                                          CONTOUR_COLOR_BLUE,
                                          CONTOUR_COLOR_ALPHA);
    
    if (locked)
    {
        effect.constantColor = GLKVector4Make(CONTOUR_LOCKED_COLOR_RED,
                                              CONTOUR_LOCKED_COLOR_GREEN,
                                              CONTOUR_LOCKED_COLOR_BLUE,
                                              CONTOUR_COLOR_ALPHA);
    }
    
    GLKVector3 highlightScaleFactor = [self calculateHighlightScaleFactor];
    GLKVector3 oldScale = _scale;
    GLKVector3 oldPos = position;
    _scale = GLKVector3Multiply(_scale, highlightScaleFactor);
    float changedInHeight = 0.01f * (_scale.y * self.graphicObj.widthY - oldScale.y * self.graphicObj.widthY);
    position = GLKVector3Subtract(position, GLKVector3Make(0, changedInHeight / 2.0f, 0));
    [self updateModelViewMatrixWithCorrectFloor:NO];
    effect.transform.modelviewMatrix = GLKMatrix4Multiply(self.cameraMatrix, modelviewMatrix);
    
    [effect prepareToDraw];
    
    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_TRUE);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glStencilFunc(GL_NOTEQUAL, 1, ~0);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    
    [self drawObjectWithShadow:NO];
    
    position = oldPos;
    
    self.scale = GLKVector3Multiply(oldScale, GLKVector3AddScalar(GLKVector3Negate(highlightScaleFactor),2));
    changedInHeight = 0.01f * (oldScale.y * self.graphicObj.widthY - _scale.y * self.graphicObj.widthY);
    [self updateModelViewMatrixWithCorrectFloor:NO];
    effect.transform.modelviewMatrix = GLKMatrix4Multiply(self.cameraMatrix, modelviewMatrix);
   
    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_TRUE);
    
    if (self.texture != nil)
        effect.texture2d0.enabled = GL_TRUE;
    
    effect.constantColor = oldColor;
    position = oldPos;
    _scale = oldScale;
    [self updateModelViewMatrixWithCorrectFloor:YES];
    effect.transform.modelviewMatrix = GLKMatrix4Multiply(self.cameraMatrix, modelviewMatrix);
    
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

+(NSNumber*)keyWithColorCode:(GLKVector4)colorCode {
	int red = colorCode.x * 255;
	int green = colorCode.y * 255;
	int blue = colorCode.z * 255;
	return [NSNumber numberWithLong:(red + (green << 8) + (blue << 16))];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

+(GLKVector4)colorCodeWithKey:(NSNumber*)key {
	long temp = [key longValue];
	float red = (temp % 256) / 255.0;
	float green = ((temp >> 8) % 256) / 255.0;
	float blue = ((temp >> 16) % 256) / 255.0;
	return GLKVector4Make(red, green, blue, 1.0f);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)canLevitate
{
    return YES;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)canMoveInAir {
	RETURN_ON_NIL(self.metadata, NO);
	return [(NSNumber*)[metadata valueForKey:Z_INDEX] integerValue] == Z_INDEX_LEVITATE;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)isAttachedToWall {
	RETURN_ON_NIL(self.metadata, NO);
	return ([(NSNumber*)[metadata valueForKey:Z_INDEX] integerValue] == Z_INDEX_ATTACHED_TO_WALL ||
            [(NSNumber*)[metadata valueForKey:Z_INDEX] integerValue] == Z_INDEX_ATTACHED_TO_WALL_BOTTOM);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)isAttachedToWallBottom {
    RETURN_ON_NIL(self.metadata, NO);
    return [(NSNumber*)[metadata valueForKey:Z_INDEX] integerValue] == Z_INDEX_ATTACHED_TO_WALL_BOTTOM;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)isAttachedToCeiling {
	RETURN_ON_NIL(self.metadata, NO);
	return [(NSNumber*)[metadata valueForKey:Z_INDEX] integerValue] == Z_INDEX_ATTACHED_TO_CEILING;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)isDirectlyOnFloor {
	RETURN_ON_NIL(self.metadata, NO);
	return [(NSNumber*)[metadata valueForKey:Z_INDEX] integerValue] == Z_INDEX_DIRECTLY_ON_FLOOR;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)isAboveFloor {
    RETURN_ON_NIL(self.metadata, NO);
    return [(NSNumber*)[metadata valueForKey:Z_INDEX] integerValue] == Z_INDEX_LEVITATE_THRESHOLD;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)drawObjectWithShadow:(BOOL)isShadowVisible
{
    if (self.isCollection)
    {
        NSArray * copyArray = [NSArray arrayWithArray:self.nestedEntities];
        for (Entity *nestedEntity in copyArray)
        {
            [nestedEntity drawObjectWithShadow:YES];
        }
        
        return;
    }
    
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
	
	if (self.graphicObj.numberOfObjects == 1)
    {
		glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, [self.graphicObj vertsOfObject:0]);
		if ([self.graphicObj texCoordOfObject:0] != NULL) {
			glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, [self.graphicObj texCoordOfObject:0]);
		}
		
		glDrawArrays(GL_TRIANGLES, 0, [self.graphicObj numVertsOfObject:0]);
	}
    else
    {
        BOOL drawAtLeastOnce = NO;
        for (NSDictionary* o in self.subObjectsOrder) {
            if (drawAtLeastOnce && !isShadowVisible && [self isShadowObject:o]) {
                break;
            }
            
            if (isShadowVisible && ![self isShadowObject:o]){
                continue;
            }
            
            drawAtLeastOnce = YES;
            int i = [o[@"index"] intValue];
			glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, [self.graphicObj vertsOfObject:i]);
			if ([self.graphicObj texCoordOfObject:i] != NULL) {
				glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, [self.graphicObj texCoordOfObject:i]);
			}
			
			glDrawArrays(GL_TRIANGLES, 0, [self.graphicObj numVertsOfObject:i]);
		}
	}
	
	glDisableVertexAttribArray(GLKVertexAttribPosition);
	glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)isShadowObject:(NSDictionary*)o {
    return [o[@"name"] contains:@"shadow" options:NSCaseInsensitiveSearch];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(float)widthX {
    return self.graphicObj.widthX * self.scale.x;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(float)widthY {
    return self.graphicObj.widthY * self.scale.y;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(float)widthZ {
    return self.graphicObj.widthZ * self.scale.z;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSDictionary*)jsonData
{
    NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionaryWithDictionary:
            @{
                 EntityKeyModelId : self.modelId,
                 EntityKeyScale: @(self.scale.x),
                 EntityKeyRotationY: @(self.rotation.y),
                 EntityKeyPositionX: @(self.position.x),
                 EntityKeyPositionY: @(self.position.y),
                 EntityKeyPositionZ: @(self.position.z),
                 EntityKeyIsLocked: @(self.isLocked),
                 EntityKeyBrightness: @(self.brightness)
             }];
    
    // Variation Id is non mandatory for a saved object
    if (self.variationId)
        [jsonDictionary setObject:self.variationId forKey:EntityKeyVariationId];
    
    // Add Z-Index information in case it exists
    if (self.metadata && [metadata valueForKey:Z_INDEX])
        [jsonDictionary setObject:(NSNumber*)[metadata valueForKey:Z_INDEX] forKey:EntityKeyZIndex];
    
    // If the current entity is not an assembly, return the single entity JSON
    if (!self.nestedEntities || [self.nestedEntities count] == 0)
        return jsonDictionary;
    
    // Add all nested entities as sub-models to the saved JSON
    NSMutableArray *nestedEntitiesJsonArray = [NSMutableArray new];
    NSArray * copyArray = [NSArray arrayWithArray:self.nestedEntities];
    for (Entity *nestedEntity in copyArray)
    {
        [nestedEntitiesJsonArray addObject:[nestedEntity jsonData]];
    }
    
    [jsonDictionary setObject:nestedEntitiesJsonArray forKey:SavedDesignKeyModels];
    
    return jsonDictionary;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

+(Entity*)entityWithFloorplanDictionary:(NSDictionary*)jsonData
{
    Entity* entity = [[Entity alloc] init];
    
    if (entity)
    {
        entity.sceneEntityGUID = [[ServerUtils sharedInstance] generateGuid];
        entity.modelId = jsonData[FPEntityKeyModelId];
        entity.variationId = jsonData[EntityKeyVariationId];
        
        if (!entity.variationId)
            entity.variationId = entity.modelId;
        
        NSDictionary *jsonPosition= jsonData[FPEntityKeyPositionContainer];
        entity.position = GLKVector3Make([jsonPosition[FPEntityKeyPositionX] floatValue] / 100,
                                         [jsonPosition[FPEntityKeyPositionZ] floatValue] / 100,
                                         -[jsonPosition[FPEntityKeyPositionY] floatValue] / 100);
        
        float scale = 1;
        entity.scale = GLKVector3Make(scale, scale, scale);
        entity.rotation = GLKVector3Make(0,  -GLKMathDegreesToRadians([jsonData[FPEntityKeyRotationY] floatValue]), 0);
        entity.isLocked = NO;
        entity.brightness = 1.0;
        entity.entityType = EntityNodeTypeProduct;
    }
    
    return entity;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

+(Entity*)entityWithJsonDictionary:(NSDictionary*)jsonData
{
    Entity* entity = [[Entity alloc] init];
    
    /*
     *  (1) Create a single entity from JSON.
     *  even if it is an assembly, we create it and this entity will serve as it's parent node
     */
    if (entity)
    {
        entity.sceneEntityGUID = [[ServerUtils sharedInstance] generateGuid];
        entity.modelId = jsonData[EntityKeyModelId];
        entity.variationId = jsonData[EntityKeyVariationId];
        
        if (!entity.variationId)
            entity.variationId = entity.modelId;
        
        entity.position = GLKVector3Make([jsonData[EntityKeyPositionX] floatValue],
                                         [jsonData[EntityKeyPositionY] floatValue],
                                         [jsonData[EntityKeyPositionZ] floatValue]);
        float scale = [jsonData[EntityKeyScale] floatValue];
        entity.scale = GLKVector3Make(scale, scale, scale);
        entity.rotation = GLKVector3Make(0, [jsonData[EntityKeyRotationY] floatValue], 0);
        entity.isLocked = [jsonData[EntityKeyIsLocked] boolValue];
        
        if (jsonData[EntityKeyZIndex])
            entity.metadata = @{Z_INDEX : (NSNumber*)jsonData[EntityKeyZIndex]};
        
        if (jsonData[EntityKeyBrightness])
            entity.brightness = [jsonData[EntityKeyBrightness] floatValue];
        else
            entity.brightness = 1.0;
        
        entity.nestedEntities = [NSMutableArray new];
    }
    
    /*
     *  If the design is NOT an assembly, the JSON represents a regular entity
     *  so we mark it as regular and return. The key used here is SavedDesignKeyModels
     *  to be consistent with the saved design json structure where each assembly
     *  is a scene
     */
    if (!jsonData[SavedDesignKeyModels])
    {
        entity.entityType = EntityNodeTypeProduct;
        return entity;
    }
    
    /*
     *  Reaching here marks that the design is an assembly.
     *  We mark it as one and add it's decendants to it recursively. This allows nested assemblies.
     */
    entity.entityType = EntityNodeTypeModelView;
    entity.key = [NSNumber numberWithLong:++lastID];
    for (NSDictionary *nestedDictionary in jsonData[SavedDesignKeyModels])
    {
        Entity *nestedEntity = [Entity entityWithJsonDictionary:nestedDictionary];
        
        if (nestedEntity)
        {
            [entity addEntityToCollection:nestedEntity];
        }
    }
    
    return entity;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setScale:(GLKVector3)sscale{

    if (_scale.x!=sscale.x || _scale.y!=sscale.y || _scale.z!=sscale.z) {
      self.scaleFactor = [NSNumber numberWithFloat:sscale.x];
    }
    _scale = sscale;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)isPlant {
    return [self.graphicObj hasObjectNamed:@"plant"];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)isMask {
    return [self.graphicObj hasObjectNamed:@"mask"];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    
    if (!self)
        return nil;
    
    self.backgroundColor = [coder decodeObjectForKey:@"self.backgroundColor"];
    self.scaleFactor = [coder decodeObjectForKey:@"self.scaleFactor"];
    self.key = [coder decodeObjectForKey:@"self.key"];
    self.isLocked = [coder decodeBoolForKey:@"self.isLocked"];
    self.useShader = [coder decodeBoolForKey:@"self.useShader"];
    self.randomY = [coder decodeFloatForKey:@"self.randomY"];
    self.modelId = [coder decodeObjectForKey:@"self.modelId"];
    self.sceneEntityGUID = [coder decodeObjectForKey:@"self.sceneEntityGUID"];
    self.originalScale = [coder decodeFloatForKey:@"self.originalScale"];
    self.subObjectsOrder = [coder decodeObjectForKey:@"self.subObjectsOrder"];
    self.metadata = [coder decodeObjectForKey:@"self.metadata"];
    self.maskable = [coder decodeBoolForKey:@"self.maskable"];
    self.plantable = [coder decodeBoolForKey:@"self.plantable"];

    const uint8_t *bytes = [coder decodeBytesForKey:@"self.position" returnedLength:NULL];
    memcpy(&position, bytes, sizeof(position));
    const uint8_t *bytes2 = [coder decodeBytesForKey:@"self.rotation" returnedLength:NULL];
    memcpy(&rotation, bytes2, sizeof(rotation));
    const uint8_t *bytes3 = [coder decodeBytesForKey:@"self.scale" returnedLength:NULL];
    memcpy(&_scale, bytes3, sizeof(_scale));

    const uint8_t *bytes4 = [coder decodeBytesForKey:@"self.modelviewMatrix" returnedLength:NULL];
    memcpy(&modelviewMatrix, bytes4, sizeof(modelviewMatrix));
    const uint8_t *bytes5 = [coder decodeBytesForKey:@"self.projectionMatrix" returnedLength:NULL];
    memcpy(&projectionMatrix, bytes5, sizeof(projectionMatrix));
    const uint8_t *bytes6 = [coder decodeBytesForKey:@"self.cameraMatrix" returnedLength:NULL];
    memcpy(&cameraMatrix, bytes6, sizeof(cameraMatrix));
    
    self.brightness = [coder decodeFloatForKey:@"self.brightness"];
    self.variationId = [coder decodeObjectForKey:@"self.variationId"];
    self.entityType = [coder decodeIntForKey:@"self.entityType"];
    self.nestedEntities = [coder decodeObjectForKey:@"self.nestedEntities"];
    self.parentEntity = [coder decodeObjectForKey:@"self.parentEntity"];
    
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.backgroundColor forKey:@"self.backgroundColor"];
    [coder encodeObject:self.scaleFactor forKey:@"self.scaleFactor"];
    [coder encodeObject:self.key forKey:@"self.key"];
    [coder encodeBool:self.isLocked forKey:@"self.isLocked"];
    [coder encodeBool:self.useShader forKey:@"self.useShader"];
    [coder encodeFloat:self.randomY forKey:@"self.randomY"];
    [coder encodeObject:self.modelId forKey:@"self.modelId"];
    [coder encodeObject:self.sceneEntityGUID forKey:@"self.sceneEntityGUID"];
    [coder encodeFloat:self.originalScale forKey:@"self.originalScale"];
    [coder encodeObject:self.subObjectsOrder forKey:@"self.subObjectsOrder"];
    [coder encodeObject:self.metadata forKey:@"self.metadata"];
    [coder encodeBool:self.maskable forKey:@"self.maskable"];
    [coder encodeBool:self.plantable forKey:@"self.plantable"];
    [coder encodeBytes:(const uint8_t *)&position length:sizeof(self.position) forKey:@"self.position"];
    [coder encodeBytes:(const uint8_t *)&rotation length:sizeof(self.rotation) forKey:@"self.rotation"];
    [coder encodeBytes:(const uint8_t *)&_scale length:sizeof(_scale) forKey:@"self.scale"];
    [coder encodeBytes:(const uint8_t *)&modelviewMatrix length:sizeof(self.modelviewMatrix) forKey:@"self.modelviewMatrix"];
    [coder encodeBytes:(const uint8_t *)&projectionMatrix length:sizeof(self.projectionMatrix) forKey:@"self.projectionMatrix"];
    [coder encodeBytes:(const uint8_t *)&cameraMatrix length:sizeof(self.cameraMatrix) forKey:@"self.cameraMatrix"];
    [coder encodeFloat:self.brightness forKey:@"self.brightness"];
    [coder encodeObject:self.variationId forKey:@"self.variationId"];
    [coder encodeInt:self.entityType forKey:@"self.entityType"];
    [coder encodeObject:[self.nestedEntities mutableCopy] forKey:@"self.nestedEntities"];
    [coder encodeObject:self.parentEntity forKey:@"self.parentEntity"];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id)copyWithZone:(NSZone *)zone
{
    Entity *copy = [[[self class] allocWithZone:zone] init];
    
    if (!copy)
        return nil;
    
    copy.graphicObj = [self.graphicObj copy];
    copy.backgroundColor = [self.backgroundColor copy];
    copy.scaleFactor = [self.scaleFactor copy];
    copy.key = [self.key copy];
    copy.isLocked = self.isLocked;
    copy.useShader = self.useShader;
    copy.randomY = self.randomY;
    copy.modelId = [self.modelId copy];
    copy.originalScale = self.originalScale;
    copy.subObjectsOrder = [self.subObjectsOrder copy];
    copy.position = self.position;
    copy.scale = self.scale;
    copy.rotation = self.rotation;
    copy.cameraMatrix = self.cameraMatrix;
    copy.modelviewMatrix = self.modelviewMatrix;
    copy.effect = self.effect;
    copy.texture = [self.texture copy];
    copy.metadata = [self.metadata copy];
    copy.projectionMatrix = self.projectionMatrix;
    copy.maskable = self.maskable;
    copy.plantable = self.plantable;
    copy.sceneEntityGUID = [self.sceneEntityGUID copy];
    copy.brightness = self.brightness;
    copy.nestedEntities = [self.nestedEntities mutableCopy];
	copy.variationId = self.variationId;
    copy.entityType = self.entityType;
    copy.parentEntity = self.parentEntity;

    return copy;
}

///////////////////////////////////////////////////////
// Collection implementation                         //
///////////////////////////////////////////////////////

- (id)initAsCollection:(GLKVector3)absPosition
          withRotation:(GLKVector3)absRotation
             withScale:(GLKVector3)absScale
withMetadataDictionary:(NSDictionary*)metadataDict
{
    if (self = [super init])
    {
        self.sceneEntityGUID = [[ServerUtils sharedInstance] generateGuid];
        self.cameraMatrix = GLKMatrix4Identity;
        self.key = [NSNumber numberWithLong:++lastID];
        self.randomY = RUG_Y * ((float)rand() / RAND_MAX) / 3.0f;
        self.isLocked = NO;
        self.position = absPosition;
        self.rotation = absRotation;
        self.scale = absScale;
        self.scaleFactor=[NSNumber numberWithFloat:absScale.x];
        self.brightness = 1;
        self.maskable = NO;
        self.plantable = NO;
        self.nestedEntities = [NSMutableArray new];
        self.entityType = EntityNodeTypeModelView;
        self.metadata = metadataDict;
        [self updateModelViewMatrixWithCorrectFloor:YES];
    }
    
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)addEntityToCollection:(Entity*)entity
{
    if (!entity)
        return;
    
    [self.nestedEntities addObject:entity];
    entity.parentEntity = self;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)isCollection
{
    return (EntityNodeTypeModelView == self.entityType);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSArray*)uniqueModels
{
    NSMutableArray *uniqueModels = [NSMutableArray new];
    
    if (![self isCollection])
    {
        [uniqueModels addObject:self];
    }
    else
    {
        NSArray * copyArray = [NSArray arrayWithArray:self.nestedEntities];
        for (Entity *nestedEntity in copyArray)
            [uniqueModels addObject:nestedEntity];
    }
    
    return [uniqueModels copy];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (ModelBoundingBox*)getEntityBoundingBox
{
    // If an item is not a collection the bounding box is of
    // The entity itself
    if (![self isCollection])
        return [self.graphicObj getBoundingBox];
    
    float mnx = MAXFLOAT;
    float mxx = -MAXFLOAT;
    float mny = MAXFLOAT;
    float mxy = -MAXFLOAT;
    float mnz = MAXFLOAT;
    float mxz = -MAXFLOAT;
    
    NSArray * copyArray = [NSArray arrayWithArray:self.nestedEntities];

    for (Entity *nestedEntity in copyArray)
    {
        mnx = MIN([nestedEntity.graphicObj getBoundingBox].minX + nestedEntity.position.x, mnx);
        mny = MIN([nestedEntity.graphicObj getBoundingBox].minY + nestedEntity.position.y, mny);
        mnz = MIN([nestedEntity.graphicObj getBoundingBox].minZ + nestedEntity.position.z, mnz);
        mxx = MAX([nestedEntity.graphicObj getBoundingBox].maxX + nestedEntity.position.x, mxx);
        mxy = MAX([nestedEntity.graphicObj getBoundingBox].maxY + nestedEntity.position.y, mxy);
        mxz = MAX([nestedEntity.graphicObj getBoundingBox].maxZ + nestedEntity.position.z, mxz);
    }
    
    return [[ModelBoundingBox alloc] initWithMaxX:mxx
                                             maxY:mxy
                                             maxZ:mxz
                                             minX:mnx
                                             minY:mny
                                             minZ:mnz];
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)alignModelsAccordingToZIndex
{
    RETURN_VOID_ON_NIL(self.metadata);
    RETURN_VOID_ON_NIL([self.metadata objectForKey:Z_INDEX]); // Object must have a Z-Index to apply a fix
    
    // Alignment of models according to their Z Index is only a fix
    // for collections
    if (![self isCollection])
        return;
    
    // The only fix currently is for an attached to wall assembly
    if (![self isAttachedToWall])
        return;
    
    // Save the current minimal Z before entering the loop
    // that may change the bounding box
    float boxMinZ = [self getEntityBoundingBox].minZ;
    
    NSArray * copyArray = [NSArray arrayWithArray:self.nestedEntities];
    for (Entity *nestedEntity in copyArray)
    {
        nestedEntity.position =  GLKVector3Make(nestedEntity.position.x,
                                                nestedEntity.position.y,
                                                nestedEntity.position.z - boxMinZ);
    }
    
    return;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (Entity*)cloneEntity
{
    Entity *duplicate = [self copy];
    duplicate.sceneEntityGUID = [[ServerUtils sharedInstance] generateGuid];
    duplicate.key = [NSNumber numberWithLong:++lastID];
    
    [duplicate.nestedEntities removeAllObjects];

    NSArray * copyArray = [NSArray arrayWithArray:self.nestedEntities];
    for (Entity *nested in copyArray)
    {
        [duplicate.nestedEntities addObject:[nested copy]];
    }
    
    return duplicate;
}


@end
