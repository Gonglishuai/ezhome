
#import "ESProductInformationCell.h"
#import "ESProductModel.h"

@interface ESProductInformationCell ()

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *oldPriceLabel;
@property (weak, nonatomic) IBOutlet UIView *customizableBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *customizablePriceLabel;

@end

@implementation ESProductInformationCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    // 原价 --一期没有原价, 隐藏
    self.customizableBackgroundView.hidden = YES;
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getProductInfomationAtIndexPath:)])
    {
        // 商品信息
        ESProductModel *model = [(id)self.cellDelegate getProductInfomationAtIndexPath:indexPath];
        if ([model isKindOfClass:[ESProductModel class]])
        {
            NSString *productName = model.name;
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:productName];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineSpacing:10];
            [attributedString addAttribute:NSParagraphStyleAttributeName
                                     value:paragraphStyle
                                     range:NSMakeRange(0, productName.length)];
            self.productNameLabel.attributedText = attributedString;

            NSString *price = [@"¥" stringByAppendingString:model.minPrice];
            if (model.showMinPriceStatus)
            {
                price = [price stringByAppendingString:@"起"];
                NSMutableAttributedString *attributedPrice = [[NSMutableAttributedString alloc] initWithString:price];
                [attributedPrice addAttributes:@{
                                                 NSForegroundColorAttributeName: [UIColor stec_redTextColor],
                                                 NSFontAttributeName: [UIFont stec_mediumPriceFount]
                                                 }
                                         range:NSMakeRange(0, price.length - 1)];
                [attributedPrice addAttributes:@{
                                                 NSForegroundColorAttributeName: [UIColor stec_priceTextColor],
                                                 NSFontAttributeName: [UIFont stec_lightPriceFount]
                                                 }
                                         range:NSMakeRange(price.length - 1, 1)];
                self.priceLabel.attributedText = attributedPrice;
            }
            else
            {
                self.priceLabel.text = price;
            }
            
            self.productNameLabel.text = model.name;
            self.customizableBackgroundView.hidden = !model.isCustomizable;

            if (model.originalPrice
                && [model.originalPrice isKindOfClass:[NSString class]]
                && model.originalPrice.length > 0)
            {
                NSString *originalPrice = [@"¥" stringByAppendingString:model.originalPrice];
                NSDictionary *attributes = @{
                                             NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle|NSUnderlinePatternSolid),
                                             NSStrikethroughColorAttributeName:[UIColor stec_contentTextColor]};
                NSAttributedString *attrStr =
                [[NSAttributedString alloc]initWithString:originalPrice
                                               attributes:attributes];
                self.oldPriceLabel.attributedText = attrStr;
            }
        
            if (model.brandResponseBean
                && [model.brandResponseBean isKindOfClass:[ESProductBrandModel class]]
                && model.brandResponseBean.deposit
                && [model.brandResponseBean.deposit isKindOfClass:[NSArray class]])
            {
                NSString *price = [model.brandResponseBean.deposit firstObject];
                if (price
                    && [price isKindOfClass:[NSString class]])
                {
                    self.customizablePriceLabel.text = [@"¥" stringByAppendingString:price];
                }
            }
        }
    }
}

@end
