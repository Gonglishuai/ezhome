
#import "ESProductDetailPromotionCell.h"
#import "ESCartCommodityPromotion.h"

@interface ESProductDetailPromotionCell ()

@property (weak, nonatomic) IBOutlet UILabel *promotionTagLabel;
@property (weak, nonatomic) IBOutlet UILabel *promotionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *promotionDescLabel;

@property (weak, nonatomic) IBOutlet UIView *topLineView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descTopConstraint;

@end

@implementation ESProductDetailPromotionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.promotionNameLabel.layer.masksToBounds = YES;
    self.promotionNameLabel.layer.cornerRadius = 2.0f;
    self.promotionNameLabel.layer.borderWidth = 1.0f;
    self.promotionNameLabel.layer.borderColor = self.promotionNameLabel.textColor.CGColor;
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        self.promotionTagLabel.hidden = NO;
        self.topLineView.hidden = NO;
        self.topConstraint.constant = 16.0f;
        self.descTopConstraint.constant = 16.0f;
    }
    else
    {
        self.promotionTagLabel.hidden = YES;
        self.topLineView.hidden = YES;
        self.topConstraint.constant = 0.0f;
        self.descTopConstraint.constant = 0.0f;
    }
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getProductPromotionAtIndexPath:)])
    {
        ESCartCommodityPromotion *promotionModel = [(id)self.cellDelegate getProductPromotionAtIndexPath:indexPath];
        if (promotionModel
            && [promotionModel isKindOfClass:[ESCartCommodityPromotion class]])
        {
            self.promotionNameLabel.text = [NSString stringWithFormat:@"  %@  ", promotionModel.tagType];
            self.promotionDescLabel.text = promotionModel.tagName;
        }
    }
}

@end
