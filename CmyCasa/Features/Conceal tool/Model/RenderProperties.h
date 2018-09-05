//
// Created by Berenson Sergei on 3/6/14.
// Copyright (c) 2014 Itamar Berger. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef enum RenderTypes
{
    kRenderCircleSource,
    kRenderCircleTarget,
    kRenderSquareSource,
    kRenderSquareTarget,
    kRenderLineBetweenPoints
    
}RenderType;

@interface RenderProperties : NSObject
@property(nonatomic, strong) UIColor *fillColor;
@property(nonatomic) CGFloat  lineWidth;
@property (nonatomic) RenderType rtype;
@property (nonatomic) RenderType lineType;
@property (nonatomic, strong) NSArray * sourcePoints;
@property (nonatomic, strong) NSArray * targetPoints;



@end