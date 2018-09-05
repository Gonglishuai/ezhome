
#import "ESProductDetailDiscountCell.h"

@interface ESProductDetailDiscountCell ()

@property (weak, nonatomic) IBOutlet UILabel *discountTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *discountMessageLabel;

@end

@implementation ESProductDetailDiscountCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.discountTitleLabel.layer.masksToBounds = YES;
    self.discountTitleLabel.layer.cornerRadius = 2.0f;
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getProductDiscountAtIndexPath:)])
    {
        NSArray *discount = [(id)self.cellDelegate getProductDiscountAtIndexPath:indexPath];
        if (discount
            && [discount isKindOfClass:[NSArray class]])
        {
            NSString *message = @"";
            for (NSString *str in discount)
            {
                if ([str isKindOfClass:[NSString class]])
                {
                    message = [NSString stringWithFormat:@"%@/%@", message, str];
                }
            }
            if (message.length > 0)
            {
                message = [message substringFromIndex:1];
            }
            
            self.discountMessageLabel.text = message;
        }
    }
}

@end
