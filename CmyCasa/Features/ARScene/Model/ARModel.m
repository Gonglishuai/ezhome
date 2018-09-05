//
//  Model.m
//  ardemo
//
//  Created by lvwei on 04/09/2017.
//  Copyright © 2017 juran. All rights reserved.
//

#import "ARModel.h"
#import "Adorner.h"

#import <ModelIO/ModelIO.h>
#import <SceneKit/ModelIO.h>

#define SCALE 0.01f

@implementation ARModel
{
    SCNNode* model;
    SCNNode* box;
    SCNNode* dimension;
    SCNNode* basement;
    
    SCNVector3 minBounds;
    SCNVector3 maxBounds;
}

- (instancetype)initWithObj:(NSString*)url withMaterial:(NSString*)url2 position:(SCNVector3)position
{
    self = [super init];
    
    self.isLocked = YES;

    MDLAsset * asset = [[MDLAsset alloc] initWithURL:[NSURL URLWithString:url]];
    MDLMesh * object = (MDLMesh *)[asset objectAtIndex:0];
    
    if (!object) return nil;
    
    int shadowIndex = -1;
    for (int index = 0; index < object.submeshes.count; index++) {
        if ([[object.submeshes[index].name lowercaseString] containsString:@"shadow"]) {
            shadowIndex = index;
        } else {
            // supposed only two models in obj file, otherwise we have to union other models.
            MDLMesh * mesh = [MDLMesh newSubdividedMesh:object submeshIndex:index subdivisionLevels:1];
            MDLAxisAlignedBoundingBox bounding = mesh.boundingBox;
            minBounds = SCNVector3Make(bounding.minBounds.x, bounding.minBounds.y, bounding.minBounds.z);
            maxBounds = SCNVector3Make(bounding.maxBounds.x, bounding.maxBounds.y, bounding.maxBounds.z);
            
            self.width = maxBounds.x - minBounds.x;
            self.height = maxBounds.z - minBounds.z;
            self.level = maxBounds.y - minBounds.y;
        }
    }
    
    MDLMaterial * material = [[MDLMaterial alloc] initWithName:@"baseMaterial" scatteringFunction:[MDLScatteringFunction new]];
    [material setProperty:[[MDLMaterialProperty alloc] initWithName:@"texture" semantic:MDLMaterialSemanticBaseColor string:url2]];

    SCNMaterial *modelMaterial = [SCNMaterial materialWithMDLMaterial:material];
    modelMaterial.doubleSided = YES;
    SCNMaterial *shadowMaterial = [modelMaterial copy];
    shadowMaterial.shaderModifiers = @{ SCNShaderModifierEntryPointFragment :
                                        @"if (_output.color.a > 0.2)"
                                        @"_output.color.a = _output.color.a+0.05;"
                                        };

    
    model = [SCNNode nodeWithMDLObject:object];
    for (int index = 0; index < object.submeshes.count; index++) {
        if (shadowIndex == index) {
            [model.geometry insertMaterial:shadowMaterial atIndex:index];
        } else {
            [model.geometry insertMaterial:modelMaterial atIndex:index];
        }
    }
    [self addChildNode:model];
    
    dimension = [Adorner buildDimensions:model min:minBounds max:maxBounds];
//    dimension.hidden = YES;
    dimension.opacity = 0.0;
    [self addChildNode:dimension];
    
    basement = [Adorner buildBasement:model min:minBounds max:maxBounds];
    basement.hidden = YES;
    [self addChildNode:basement];
    
    box = [Adorner buildBox:model];
    box.hidden = YES;
    [self addChildNode:box];
    
    //    [Adorner buildMarker:node];
    
    self.position = position;
    self.scale = SCNVector3Make(SCALE, SCALE, SCALE);
    
    return self;
}


- (void)remove
{
    [self removeFromParentNode];
}

- (void)showDimension
{
    [dimension runAction:[SCNAction fadeInWithDuration:1.0]];
}

- (void)hideDimension
{
    [dimension runAction:[SCNAction fadeOutWithDuration:0.5]];
}

- (void)updateDimension
{
    __block int idx = 0;
    NSArray* bounding = @[@(maxBounds.x-minBounds.x), @(maxBounds.z-minBounds.z), @(maxBounds.y-minBounds.y)];
    [dimension enumerateChildNodesUsingBlock:^(SCNNode *child, BOOL *stop) {
        if ([child.geometry isKindOfClass:[SCNText class]] && idx < bounding.count) {
            float distance = [[bounding objectAtIndex:idx++] floatValue] * self.scale.x * 100;
            SCNText *txt = (SCNText *) child.geometry;
            txt.string = [NSString stringWithFormat:@"%.2fcm", distance];
        }
    }];
}

- (void)showBox
{
    if (box.hidden == NO)
        return;
    
    box.scale = SCNVector3Make(0, 0, 0);
    box.hidden = NO;
    
    CGFloat duration = 0.3;
    SCNAction *xzScaleUp = [SCNAction customActionWithDuration:duration actionBlock:^(SCNNode *node, CGFloat elapsedTime){
        CGFloat currentScale = elapsedTime/duration;
        node.scale = SCNVector3Make(currentScale, 0, currentScale);
    }];
    SCNAction *yScaleUp = [SCNAction customActionWithDuration:duration actionBlock:^(SCNNode *node, CGFloat elapsedTime){
        CGFloat currentScale = elapsedTime/duration;
        node.scale = SCNVector3Make(1, currentScale, 1);
    }];
    
    SCNAction *sequence = [SCNAction sequence:@[xzScaleUp, yScaleUp]];
    [box runAction:sequence completionHandler: ^{
//        dimension.hidden = NO;
        dimension.opacity = 1.0;
    }];
}

- (void)hideBox
{
    if (box.hidden == YES)
        return;
    
//    dimension.hidden = YES;
    dimension.opacity = 0.0;
    CGFloat duration = 0.3;
    SCNAction *yScaleDown = [SCNAction customActionWithDuration:duration actionBlock:^(SCNNode *node, CGFloat elapsedTime){
        CGFloat currentScale = 1 - elapsedTime/duration;
        node.scale = SCNVector3Make(1, currentScale, 1);
    }];
    SCNAction *xzScaleDown = [SCNAction customActionWithDuration:duration actionBlock:^(SCNNode *node, CGFloat elapsedTime){
        CGFloat currentScale = 1 - elapsedTime/duration;
        node.scale = SCNVector3Make(currentScale, 0, currentScale);
    }];
    
    SCNAction *sequence = [SCNAction sequence:@[yScaleDown, xzScaleDown]];
    [box runAction:sequence completionHandler:^{
        box.hidden = YES;
    }];
}

- (void)showBasement
{
    if (basement.hidden == NO)
        return;
    
    basement.hidden = NO;
    basement.scale = SCNVector3Make(0, 0, 0);
    
    SCNAction *zoomIn = [SCNAction scaleTo:1.1 duration:0.2];
    SCNAction *zoomOut = [SCNAction scaleTo:1.0 duration:0.1];
    SCNAction *sequence = [SCNAction sequence:@[zoomIn, zoomOut]];
    [basement runAction:sequence];
    
}
- (void)hideBasement
{
    if (basement.hidden == YES)
        return;
    
    SCNAction *zoomIn = [SCNAction scaleTo:1.1 duration:0.1];
    SCNAction *zoomOut = [SCNAction scaleTo:0 duration:0.2];
    SCNAction *sequence = [SCNAction sequence:@[zoomIn, zoomOut]];
    [basement runAction:sequence completionHandler:^{
        basement.hidden = YES;
    }];
}

@end
