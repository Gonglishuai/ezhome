//
//  HSAnimatingView.m
//  Homestyler
//
//  Created by Ma'ayan on 10/24/13.
//
//

#import "HSAnimatingView.h"

#import <QuartzCore/QuartzCore.h>

@interface HSAnimatingView ()
{
    CGFloat fAnimationHeight;
}

@end

@implementation HSAnimatingView

- (id)initWithFrame:(CGRect)frame andAnimationHeight:(CGFloat)height
{
    self = [super initWithFrame:frame];
    if (self)
    {
        fAnimationHeight = height;
    }
    return self;
}

- (void) animate
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        float animDefaultHeight = 200;
        if (fAnimationHeight == 0)
        {
            fAnimationHeight = animDefaultHeight;
        }

        float animHeightDiameter = 200;
        float countHeight = 0;
        double fadeDuration = ((double) (0.3)) * ((double) fAnimationHeight / (double) animDefaultHeight);
        double pathDuration = ((double) (0.8)) * ((double) fAnimationHeight / (double) animDefaultHeight);
        animHeightDiameter = animHeightDiameter * ((double) fAnimationHeight / (double) animDefaultHeight);
        
        //opacity animation
        CABasicAnimation *fadeAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeAnim.fromValue=[NSNumber numberWithDouble:1.0];
        fadeAnim.toValue=[NSNumber numberWithDouble:0.0];
        fadeAnim.removedOnCompletion = NO;
        fadeAnim.duration = fadeDuration;
        fadeAnim.delegate = self;
        fadeAnim.fillMode = kCAFillModeForwards;
        fadeAnim.beginTime = CACurrentMediaTime() + (pathDuration - fadeDuration);
        [self.layer addAnimation:fadeAnim forKey:@"opacity"];
        
        //position animation
        CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        pathAnimation.calculationMode = kCAAnimationPaced;
        pathAnimation.fillMode = kCAFillModeForwards;
        pathAnimation.removedOnCompletion = NO;
        pathAnimation.delegate = self;
        pathAnimation.duration = pathDuration;
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, self.center.x, self.center.y - countHeight);
        CGPathAddLineToPoint(path, nil, self.center.x, self.center.y - fAnimationHeight);
        /*while (countHeight < fAnimationHeight)
        {
            CGPathMoveToPoint(path, nil, self.center.x, self.center.y - countHeight);
            CGPathAddQuadCurveToPoint(path, nil,
                                      self.center.x - animWidthDiameter/2, self.center.y - countHeight - animHeightDiameter/4,
                                      self.center.x, self.center.y - countHeight - 2 * animHeightDiameter/4);
            CGPathMoveToPoint(path, nil, self.center.x, self.center.y - countHeight - 2 * animHeightDiameter/4);
            CGPathAddQuadCurveToPoint(path, nil,
                                      self.center.x + animWidthDiameter/2, self.center.y - countHeight - 3 * animHeightDiameter/4,
                                      self.center.x, self.center.y - countHeight - 4 * animHeightDiameter/4);
            
            countHeight += animHeightDiameter;
            
            animHeightDiameter -= animHeightDecayRate;
            if (animHeightDiameter < 10)
            {
                animHeightDiameter = 10;
            }
        }*/
        
        pathAnimation.path = path;
        [self.layer addAnimation:pathAnimation forKey:@"position"];
    });
}

- (void)reset
{
    [self.layer removeAnimationForKey:@"opacity"];
    [self.layer removeAnimationForKey:@"position"];
    self.alpha = 0;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if (self)
    {
        //self.alpha = 0;
        self.layer.opacity = 0;
        [self removeFromSuperview];
    }
    
}

- (void)animationDidStart:(CAAnimation *)theAnimation
{
    
}

@end
