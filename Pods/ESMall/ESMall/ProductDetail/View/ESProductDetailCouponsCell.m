
#import "ESProductDetailCouponsCell.h"
#import "ESProductDetailCouponsModel.h"

@interface ESProductDetailCouponsCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *discountBackgroundView;

@property (weak, nonatomic) IBOutlet UILabel *firstCouponLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondCouponLabel;
@property (weak, nonatomic) IBOutlet UIView *firstLabelBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *secondLabelBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@end

@implementation ESProductDetailCouponsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    [self.discountBackgroundView addGestureRecognizer:
     [[UITapGestureRecognizer alloc] initWithTarget:self
                                             action:@selector(moreDiscountDidTapped)]];
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getCouponsWithIndexPath:)]
        && [self.cellDelegate respondsToSelector:@selector(getShowBottomViewStatus)])
    {
        BOOL bottomShowStatus = [(id)self.cellDelegate getShowBottomViewStatus];
        self.bottomHeightConstraint.constant = bottomShowStatus?10.0f:0.0f;
        
        NSArray *coupons = [(id)self.cellDelegate getCouponsWithIndexPath:indexPath];
            
        if (coupons
            && [coupons isKindOfClass:[NSArray class]])
        {
            NSString *firstCoupon = [coupons firstObject];
            if ([firstCoupon isKindOfClass:[NSString class]]
                && firstCoupon.length > 0)
            {
                self.firstCouponLabel.text = [NSString stringWithFormat:@"  %@  ", firstCoupon];
            }
            
            NSString *secondCoupon = coupons.count >= 2 ? coupons[1] : @"";
            if ([secondCoupon isKindOfClass:[NSString class]]
                && secondCoupon.length > 0)
            {
                self.secondCouponLabel.text = [NSString stringWithFormat:@"  %@  ", secondCoupon];
            }
            self.secondCouponLabel.hidden = YES;
            
            [self updateBackgroundColor:self.firstLabelBackgroundView];
//            [self updateBackgroundColor:self.secondLabelBackgroundView];
            
            self.arrowImageView.hidden = coupons.count <= 1;
        }
    }
}

#pragma mark - Tap Method
- (void)moreDiscountDidTapped
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(moreCouponsDidTapped)])
    {
        [(id)self.cellDelegate moreCouponsDidTapped];
    }
}

#pragma mark - Methods
- (void)updateBackgroundColor:(UIView *)view
{
    if (!view
        || ![view isKindOfClass:[UIView class]])
    {
        return;
    }
    
    [view layoutIfNeeded];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)[UIColor stec_redLightColor].CGColor, (__bridge id)[UIColor stec_redDeepColor].CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1.0, 0);
    gradientLayer.frame = view.bounds;
    [view.layer insertSublayer:gradientLayer atIndex:0];
    view.clipsToBounds = YES;
    view.layer.cornerRadius = 2.0f;
}

@end
