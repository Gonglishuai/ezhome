//
// Created by Berenson Sergei on 3/6/14.
// Copyright (c) 2014 Itamar Berger. All rights reserved.
//


#import "GraphicRender.h"
#import "RenderProperties.h"


@implementation GraphicRender {

}


+ (void)drawRectangle:(CGRect)rect path:(NSArray *)points properties:(RenderProperties *)props {

    
    CGContextRef context = UIGraphicsGetCurrentContext();

    
    if (!context) {
        return;
    }
    UIColor * fillColor = [props fillColor];
    CGFloat lineWidth = [props lineWidth];

    //CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextSetStrokeColorWithColor(context, fillColor.CGColor);
    
    CGContextSetLineCap(context, kCGLineCapRound);

    CGContextSetLineWidth(context, lineWidth);

    CGContextSetAllowsAntialiasing(context, YES);

    CGContextBeginPath(context);

   for (int i=0;i<points.count;i++)
   {
       NSValue *val = [points objectAtIndex:i];
       CGPoint p = [val CGPointValue];
       NSValue *val2 = [points objectAtIndex:(i+1)%4];

        CGPoint pF = [val2 CGPointValue];
        CGContextMoveToPoint(context, p.x, p.y);
        CGContextAddLineToPoint(context, pF.x, pF.y);
        CGContextStrokePath(context);
        CGContextFillPath(context);
    }
}

- (void)drawCyrc
{
    UIColor * color = [UIColor colorWithRed:1 green:0.144 blue:0.114 alpha:1];
    UIBezierPath * ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(102.5, 33.5,41,41)];
    [[UIColor clearColor]setFill];
    [ovalPath fill];
    [[UIColor blackColor]setStroke];
    ovalPath.lineWidth = 2;
    [ovalPath stroke];
    
    
    UIBezierPath * ovalPath2 = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(105.5, 36.5,35,35)];
    [color setStroke];
    ovalPath2.lineWidth = 1;
    CGFloat ovalPattern2[] = {5, 5, 5, 5};
    [ovalPath2 setLineDash: ovalPattern2 count:4 phase: 0];
    [ovalPath2 stroke];
    
}
@end