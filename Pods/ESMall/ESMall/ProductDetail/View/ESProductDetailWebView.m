
#import "ESProductDetailWebView.h"

@implementation ESProductDetailWebView

// default returns YES if point is in bounds
- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event
{
    if (point.y >= CGRectGetHeight(self.frame)/4.0 * 3.0)
    {
        return NO;
    }
    
    return YES;
}

@end
