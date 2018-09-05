//
//  PatchesView.m
//  photolib_ios_demo
//
//  Created by Berenson Sergei on 3/6/14.
//  Copyright (c) 2014 Itamar Berger. All rights reserved.
//

#import "PatchesView.h"
#import "GraphicRender.h"
#import "RenderProperties.h"

@implementation PatchesView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.backgroundColor = [UIColor clearColor];
     [self setUserInteractionEnabled:NO];
    self.renderer = [GraphicRender new];
    return self;
}

- (instancetype)init
{
    self = [super init];
    self.renderer = [GraphicRender new];
    
    return self;
}

- (void)drawPatch:(CGRect)rect WithPoints:(NSArray *)points innerPoints:(NSArray*)innerPoints properties:(RenderProperties *)props
{
    self.points = points;
    self.innerPoints = innerPoints;
    self.properties = props;
   // [self drawRect:self.frame];
    [self setNeedsDisplay];
}

-(void) drawRect: (CGRect) rect 
{
   // NSLog(@"Points: %@",self.points);

    
    switch (self.properties.rtype) {
        case kRenderCircleSource:
            [GraphicRender drawRectangle:rect path:self.points properties:self.properties ];

            break;
        case kRenderCircleTarget:
            [GraphicRender drawRectangle:rect path:self.points properties:self.properties ];
            

            break;
        case kRenderSquareSource:
            [GraphicRender drawRectangle:rect path:self.points properties:self.properties ];
            

            break;
        case kRenderSquareTarget:
            [GraphicRender drawRectangle:rect path:self.points properties:self.properties ];
            

            break;
        case kRenderLineBetweenPoints:
  

            break;
    }
}

@end
