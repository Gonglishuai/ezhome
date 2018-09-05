
#import "ESPeoductDetailAddressAnnotationView.h"
#import <QuartzCore/QuartzCore.h>

@interface ESPeoductDetailAddressAnnotationView ()

@property (nonatomic, strong) CALayer *pointLayer;
@property (nonatomic, strong) CALayer *nimbusLayer;
@property (nonatomic, readwrite) CGSize pointSize;

@end

@implementation ESPeoductDetailAddressAnnotationView

@synthesize annotation = _annotation;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])
    {
        self.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.calloutOffset = CGPointMake(0, 4);
        self.bounds = CGRectMake(0, 0, 23, 23);
        self.pointSize = CGSizeMake(16, 16);
        self.pulseDuration = 1;
        self.delayBetweenPulse = 1;
        self.annotationShowColor = [UIColor colorWithRed:0.082 green:0.369 blue:0.918 alpha:1];
    }
    return self;
}

- (void)rebuildLayers
{
    [_nimbusLayer removeFromSuperlayer];
    _nimbusLayer = nil;
    
    [_pointLayer removeFromSuperlayer];
    _pointLayer = nil;
    
    [self.layer addSublayer:self.nimbusLayer];
    [self.layer addSublayer:self.pointLayer];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if(newSuperview)
    {
        [self rebuildLayers];
    }
}

#pragma mark - Setters
- (void)setAnnotationShowColor:(UIColor *)annotationShowColor
{
    if(CGColorGetNumberOfComponents(annotationShowColor.CGColor) == 2)
    {
        float white = CGColorGetComponents(annotationShowColor.CGColor)[0];
        float alpha = CGColorGetComponents(annotationShowColor.CGColor)[1];
        annotationShowColor = [UIColor colorWithRed:white green:white blue:white alpha:alpha];
    }
    _annotationShowColor = annotationShowColor;
    
    if(self.superview)
    {
        [self rebuildLayers];
    }
}

- (void)setDelayBetweenPulse:(NSTimeInterval)delayBetweenPulse
{
    _delayBetweenPulse = delayBetweenPulse;
    
    if(self.superview)
    {
        [self rebuildLayers];
    }
}

- (void)setPulseDuration:(NSTimeInterval)pulseDuration
{
    _pulseDuration = pulseDuration;
    
    if(self.superview)
    {
        [self rebuildLayers];
    }
}

#pragma mark - Getters
- (CALayer *)pointLayer
{
    if(!_pointLayer)
    {
        _pointLayer = [CALayer layer];
        _pointLayer.bounds = self.bounds;
        _pointLayer.contents = (id)[self pointAnnotationImage].CGImage;
        _pointLayer.position = CGPointMake(self.bounds.size.width/2+0.5, self.bounds.size.height/2+0.5);
        _pointLayer.contentsGravity = kCAGravityCenter;
        _pointLayer.contentsScale = [UIScreen mainScreen].scale;
    }
    return _pointLayer;
}

- (CALayer *)nimbusLayer
{
    if(!_nimbusLayer)
    {
        _nimbusLayer = [CALayer layer];
        _nimbusLayer.bounds = CGRectMake(0, 0, 60, 60);
        _nimbusLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        _nimbusLayer.contentsScale = [UIScreen mainScreen].scale;

        CAMediaTimingFunction *linear = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        CAMediaTimingFunction *easeIn = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        CAMediaTimingFunction *easeOut = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.duration = self.pulseDuration + self.delayBetweenPulse;
        animationGroup.repeatCount = INFINITY;
        animationGroup.timingFunction = linear;
        
        CAKeyframeAnimation *imageAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
        imageAnimation.values = @[
                                  (id)[[self nimbusImageWithRadius:20] CGImage],
                                  (id)[[self nimbusImageWithRadius:35] CGImage],
                                  (id)[[self nimbusImageWithRadius:50] CGImage]
                                  ];
        imageAnimation.duration = self.pulseDuration;
        imageAnimation.calculationMode = kCAAnimationDiscrete;
        
        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
        pulseAnimation.fromValue = @0.0;
        pulseAnimation.toValue = @1.0;
        pulseAnimation.duration = self.pulseDuration;
        pulseAnimation.timingFunction = easeOut;
        
        CABasicAnimation *fadeOutAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeOutAnim.fromValue = @1.0;
        fadeOutAnim.toValue = @0.0;
        fadeOutAnim.duration = self.pulseDuration;
        fadeOutAnim.timingFunction = easeIn;
        fadeOutAnim.removedOnCompletion = NO;
        fadeOutAnim.fillMode = kCAFillModeForwards;
        
        animationGroup.animations = @[imageAnimation, pulseAnimation, fadeOutAnim];
        
        [_nimbusLayer addAnimation:animationGroup forKey:@"pulse"];
    }
    return _nimbusLayer;
}

#pragma mark - CG Drawing

- (UIImage*)nimbusImageWithRadius:(CGFloat)radius
{
    CGFloat glowRadius = radius/6;
    CGFloat ringThickness = radius/24;
    CGPoint center = CGPointMake(glowRadius+radius, glowRadius+radius);
    CGRect imageBounds = CGRectMake(0, 0, center.x*2, center.y*2);
    CGRect ringFrame = CGRectMake(glowRadius, glowRadius, radius*2, radius*2);
    
    UIGraphicsBeginImageContextWithOptions(imageBounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor* ringColor = [UIColor whiteColor];
    [ringColor setFill];
    
    UIBezierPath *ringPath = [UIBezierPath bezierPathWithOvalInRect:ringFrame];
    [ringPath appendPath:[UIBezierPath bezierPathWithOvalInRect:CGRectInset(ringFrame, ringThickness, ringThickness)]];
    ringPath.usesEvenOddFillRule = YES;
    
    for(float i=1.3; i>0.3; i-=0.18)
    {
        CGFloat blurRadius = MIN(1, i)*glowRadius;
        CGContextSetShadowWithColor(context, CGSizeZero, blurRadius, self.annotationShowColor.CGColor);
        [ringPath fill];
    }
    
    UIImage *ringImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return ringImage;
}


- (UIImage*)pointAnnotationImage
{
    UIGraphicsBeginImageContextWithOptions(self.pointSize, NO, 0);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint origin = CGPointMake(0, 0);
    
    UIColor* fillColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    CGFloat routeColorRGBA[4];
    [self.annotationShowColor getRed: &routeColorRGBA[0] green: &routeColorRGBA[1] blue: &routeColorRGBA[2] alpha: &routeColorRGBA[3]];
    
    UIColor* strokeColor = [UIColor colorWithRed: (routeColorRGBA[0] * 0.9) green: (routeColorRGBA[1] * 0.9) blue: (routeColorRGBA[2] * 0.9) alpha: (routeColorRGBA[3] * 0.9 + 0.1)];
    UIColor* outerShadowColor = [self.annotationShowColor colorWithAlphaComponent: 0.5];
    UIColor* transparentColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0];
    
    NSArray* glossGradientColors = [NSArray arrayWithObjects:
                                    (id)fillColor.CGColor,
                                    (id)[UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.5].CGColor,
                                    (id)transparentColor.CGColor, nil];
    CGFloat glossGradientLocations[] = {0, 0.49, 1};
    CGGradientRef glossGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)glossGradientColors, glossGradientLocations);
    
    UIColor* innerShadow = fillColor;
    CGSize innerShadowOffset = CGSizeMake(-1.1, -2.1);
    CGFloat innerShadowBlurRadius = 2;
    UIColor* outerShadow = outerShadowColor;
    CGSize outerShadowOffset = CGSizeMake(0.5, 0.5);
    CGFloat outerShadowBlurRadius = 1.5;
    
    UIBezierPath* dropShadowPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+0.5, origin.y+0.5, 14, 14)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, outerShadowOffset, outerShadowBlurRadius, outerShadow.CGColor);
    [strokeColor setFill];
    [dropShadowPath fill];
    CGContextRestoreGState(context);
    
    UIBezierPath* fillPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+0.5, origin.y+0.5, 14, 14)];
    [self.annotationShowColor setFill];
    [fillPath fill];
    
    {
        CGContextSaveGState(context);
        CGContextSetAlpha(context, 0.5);
        CGContextSetBlendMode(context, kCGBlendModeOverlay);
        CGContextBeginTransparencyLayer(context, NULL);
        
        UIBezierPath* mask3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+0.5, origin.y+0.5, 14, 14)];
        [mask3Path addClip];
        
        UIBezierPath* bottomInnerLightPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+3, origin.y+3, 14, 14)];
        CGContextSaveGState(context);
        [bottomInnerLightPath addClip];
        CGContextDrawRadialGradient(context, glossGradient,
                                    CGPointMake(origin.x+10, origin.y+10), 0.54,
                                    CGPointMake(origin.x+10, origin.y+10), 5.93,
                                    kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
        CGContextRestoreGState(context);
        
        
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
    }
    
    {
        CGContextSaveGState(context);
        CGContextSetBlendMode(context, kCGBlendModeOverlay);
        CGContextBeginTransparencyLayer(context, NULL);
        
        UIBezierPath* mask4Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+0.5, origin.y+0.5, 14, 14)];
        [mask4Path addClip];
        
        UIBezierPath* bottomCircleInnerLight2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x-1.5, origin.y-0.5, 16, 16)];
        [transparentColor setFill];
        [bottomCircleInnerLight2Path fill];
        
        CGRect bottomCircleInnerLight2BorderRect = CGRectInset([bottomCircleInnerLight2Path bounds], -innerShadowBlurRadius, -innerShadowBlurRadius);
        bottomCircleInnerLight2BorderRect = CGRectOffset(bottomCircleInnerLight2BorderRect, -innerShadowOffset.width, -innerShadowOffset.height);
        bottomCircleInnerLight2BorderRect = CGRectInset(CGRectUnion(bottomCircleInnerLight2BorderRect, [bottomCircleInnerLight2Path bounds]), -1, -1);
        
        UIBezierPath* bottomCircleInnerLight2NegativePath = [UIBezierPath bezierPathWithRect: bottomCircleInnerLight2BorderRect];
        [bottomCircleInnerLight2NegativePath appendPath: bottomCircleInnerLight2Path];
        bottomCircleInnerLight2NegativePath.usesEvenOddFillRule = YES;
        
        CGContextSaveGState(context);
        {
            CGFloat xOffset = innerShadowOffset.width + round(bottomCircleInnerLight2BorderRect.size.width);
            CGFloat yOffset = innerShadowOffset.height;
            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                        innerShadowBlurRadius,
                                        innerShadow.CGColor);
            
            [bottomCircleInnerLight2Path addClip];
            CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(bottomCircleInnerLight2BorderRect.size.width), 0);
            [bottomCircleInnerLight2NegativePath applyTransform: transform];
            [[UIColor grayColor] setFill];
            [bottomCircleInnerLight2NegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
    }
    
    {
        CGContextSaveGState(context);
        CGContextSetBlendMode(context, kCGBlendModeOverlay);
        CGContextBeginTransparencyLayer(context, NULL);
        
        UIBezierPath* mask2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+0.5, origin.y+0.5, 14, 14)];
        [mask2Path addClip];
        
        UIBezierPath* bottomCircleInnerLight4Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x-1.5, origin.y-0.5, 16, 16)];
        [transparentColor setFill];
        [bottomCircleInnerLight4Path fill];
        
        CGRect bottomCircleInnerLight4BorderRect = CGRectInset([bottomCircleInnerLight4Path bounds], -innerShadowBlurRadius, -innerShadowBlurRadius);
        bottomCircleInnerLight4BorderRect = CGRectOffset(bottomCircleInnerLight4BorderRect, -innerShadowOffset.width, -innerShadowOffset.height);
        bottomCircleInnerLight4BorderRect = CGRectInset(CGRectUnion(bottomCircleInnerLight4BorderRect, [bottomCircleInnerLight4Path bounds]), -1, -1);
        
        UIBezierPath* bottomCircleInnerLight4NegativePath = [UIBezierPath bezierPathWithRect: bottomCircleInnerLight4BorderRect];
        [bottomCircleInnerLight4NegativePath appendPath: bottomCircleInnerLight4Path];
        bottomCircleInnerLight4NegativePath.usesEvenOddFillRule = YES;
        
        CGContextSaveGState(context);
        {
            CGFloat xOffset = innerShadowOffset.width + round(bottomCircleInnerLight4BorderRect.size.width);
            CGFloat yOffset = innerShadowOffset.height;
            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                        innerShadowBlurRadius,
                                        innerShadow.CGColor);
            
            [bottomCircleInnerLight4Path addClip];
            CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(bottomCircleInnerLight4BorderRect.size.width), 0);
            [bottomCircleInnerLight4NegativePath applyTransform: transform];
            [[UIColor grayColor] setFill];
            [bottomCircleInnerLight4NegativePath fill];
        }
        CGContextRestoreGState(context);
        
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
    }

    {
        CGContextSaveGState(context);
        CGContextSetBlendMode(context, kCGBlendModeOverlay);
        CGContextBeginTransparencyLayer(context, NULL);
        
        UIBezierPath* maskPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+0.5, origin.y+0.5, 14, 14)];
        [maskPath addClip];
        
        UIBezierPath* whiteGlossGlow2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+1.5, origin.y+0.5, 7.5, 7.5)];
        CGContextSaveGState(context);
        [whiteGlossGlow2Path addClip];
        CGContextDrawRadialGradient(context, glossGradient,
                                    CGPointMake(origin.x+5.25, origin.y+4.25), 0.68,
                                    CGPointMake(origin.x+5.25, origin.y+4.25), 2.68,
                                    kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
        CGContextRestoreGState(context);
        
        UIBezierPath* whiteGlossGlow1Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+1.5, origin.y+0.5, 7.5, 7.5)];
        CGContextSaveGState(context);
        [whiteGlossGlow1Path addClip];
        CGContextDrawRadialGradient(context, glossGradient,
                                    CGPointMake(origin.x+5.25, origin.y+4.25), 0.68,
                                    CGPointMake(origin.x+5.25, origin.y+4.25), 1.93,
                                    kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
        CGContextRestoreGState(context);
        
        
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
    }
    
    UIBezierPath* whiteGlossPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+2, origin.y+1, 6.5, 6.5)];
    CGContextSaveGState(context);
    [whiteGlossPath addClip];
    CGContextDrawRadialGradient(context, glossGradient,
                                CGPointMake(origin.x+5.25, origin.y+4.25), 0.5,
                                CGPointMake(origin.x+5.25, origin.y+4.25), 1.47,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);
    
    UIBezierPath* strokePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(origin.x+0.5, origin.y+0.5, 14, 14)];
    [strokeColor setStroke];
    strokePath.lineWidth = 1;
    [strokePath stroke];
    
    UIImage *pointImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
        
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(colorSpace);
    
    return pointImage;
}

@end
