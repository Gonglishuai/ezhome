//
//  PatchesView.h
//  photolib_ios_demo
//
//  Created by Berenson Sergei on 3/6/14.
//  Copyright (c) 2014 Itamar Berger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphicRender.h"
@class RenderProperties;

@interface PatchesView : UIView


@property(nonatomic, strong) NSArray *points;
@property(nonatomic, strong) NSArray *innerPoints;
@property (nonatomic,strong) GraphicRender *renderer;
@property(nonatomic, strong) RenderProperties *properties;
- (void)drawPatch:(CGRect)rect WithPoints:(NSArray *)points innerPoints:(NSArray*)innerPoints properties:(RenderProperties *)props ;
//- (void)drawPatch:(CGRect)rect WithPoints:(NSArray *)points properties:(RenderProperties *)props;
@end
