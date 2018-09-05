//
// Created by Berenson Sergei on 3/6/14.
// Copyright (c) 2014 Itamar Berger. All rights reserved.
//


#import <Foundation/Foundation.h>

@class RenderProperties;


@interface GraphicRender : NSObject
+ (void)drawRectangle:(CGRect)rect path:(NSArray *)points properties:(RenderProperties *)props;
@end