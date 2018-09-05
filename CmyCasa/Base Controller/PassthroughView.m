//
//  PassthroughView.m
//  Homestyler
//
//  Created by Berenson Sergei on 2/24/14.
//
//

#import "PassthroughView.h"

@implementation PassthroughView

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if (!view.hidden && view.alpha > 0 && view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event])
            return YES;
    }
    return NO;
}

@end
