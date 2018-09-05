
#import "ESProductCartLabelCell.h"
#import "ESProductAttributeValueModel.h"

@interface ESProductCartLabelCell ()

@property (weak, nonatomic) IBOutlet UILabel *itemLabel;

@end

@implementation ESProductCartLabelCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    // 需跟ESProductAttributeValueModel模型中计算的font一致
    self.itemLabel.font = [UIFont stec_subTitleFount];
    
    self.itemLabel.clipsToBounds = YES;
    self.itemLabel.layer.cornerRadius = 2.0f;
    self.itemLabel.layer.borderWidth = 0.5f ;
    
    [self updateLabelStatusWithStatus:ESCartLabelStatusEnableDisSelected];
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getCartItemMessageAtIndexPath:)])
    {
        ESProductAttributeValueModel *model = [(id)self.cellDelegate getCartItemMessageAtIndexPath:indexPath];
        if (model)
        {
            self.itemLabel.text = model.value;
            self.userInteractionEnabled = model.couldEdit;
            [self updateLabelStatusWithStatus:model.valueStatus];
        }
    }
}

#pragma mark - Methods
- (void)updateLabelStatusWithStatus:(ESCartLabelStatus)labelStatus
{
    switch (labelStatus)
    {
        case ESCartLabelStatusEnableSelected:
        {
            [self updateItemLabelStatusWithTitleColor:[UIColor stec_blueTextColor]
                                            lineColor:[UIColor stec_blueTextColor]];
            break;
        }
        
        case ESCartLabelStatusEnableDisSelected:
        {
            [self updateItemLabelStatusWithTitleColor:[UIColor stec_subTitleTextColor]
                                            lineColor:[UIColor stec_lineGrayColor]];
            break;
        }
            
        case ESCartLabelStatusDisEnable:
        {
            [self updateItemLabelStatusWithTitleColor:[UIColor stec_lightTextColor]
                                            lineColor:[UIColor stec_lineGrayColor]];
            break;
        }
        default:
            break;
    }
}

- (void)updateItemLabelStatusWithTitleColor:(UIColor *)titleColor
                                  lineColor:(UIColor *)lineColor
{
    self.itemLabel.layer.borderColor = lineColor.CGColor;
    self.itemLabel.textColor = titleColor;
}

@end
