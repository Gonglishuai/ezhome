
#import "ESProductCouponItemView.h"
#import <ESFoundation/UIFont+Stec.h>
#import <ESFoundation/UIColor+Stec.h>

@implementation ESProductCouponItemView

- (instancetype)initWithFrame:(CGRect)frame
                     itemName:(NSString *)name
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self createItemView:name];
    }
    return self;
}

- (void)createItemView:(NSString *)name
{
    if (!name
        || ![name isKindOfClass:[NSString class]])
    {
        name = @"";
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont stec_remarkTextFount];
    label.text = name;
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
    [self updateBackgroundColor];
}

- (void)updateBackgroundColor
{
    [self layoutIfNeeded];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)[UIColor stec_redLightColor].CGColor, (__bridge id)[UIColor stec_redDeepColor].CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1.0, 0);
    gradientLayer.frame = self.bounds;
    [self.layer insertSublayer:gradientLayer atIndex:0];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 2.0f;
}

@end
