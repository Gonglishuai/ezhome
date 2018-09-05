//
//  JRBaseButton.m
//  Consumer
//
//  Created by 姜云锋 on 17/4/21.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JRBaseButton.h"

@implementation JRBaseButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect bounds = self.bounds;
    CGFloat widthDelta = MAX(44.0 - bounds.size.width, 0);
    CGFloat heightDelta = MAX(44.0 - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}
@end
