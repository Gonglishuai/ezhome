
#import "ESProductDetailParametersCell.h"
#import "ESProductAttributeSelectedValueModel.h"

@interface ESProductDetailParametersCell ()

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *keyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyLabelBottomConstraint;

@end

@implementation ESProductDetailParametersCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getProductDetailParametersAtIndex:)])
    {
        ESProductAttributeSelectedValueModel *model = [(id)self.cellDelegate getProductDetailParametersAtIndex:indexPath.row];
        if ([model isKindOfClass:[ESProductAttributeSelectedValueModel class]])
        {
            self.keyLabel.text = model.name;
            self.valueLabel.text = model.value;
        }
        
        if ([self.cellDelegate respondsToSelector:@selector(getParametersBottomConstraintShowStatusWithIndex:)])
        {
            BOOL showBottomConstraint = [(id)self.cellDelegate getParametersBottomConstraintShowStatusWithIndex:indexPath.row];
            CGFloat keyBottomConstant = 0.0f;
            CGFloat valueBottomConstant = 0.0f;
            CGFloat heightDifference = model.nameSize.height - model.valueSize.height;
            if (showBottomConstraint)
            {
                if (heightDifference > 0)
                {
                    valueBottomConstant = heightDifference + 16.0f;
                    keyBottomConstant = 16.0f;
                }
                else
                {
                    keyBottomConstant = -heightDifference + 16.0f;
                    valueBottomConstant = 16.0f;
                }
            }
            else
            {
                if (heightDifference > 0)
                {
                    valueBottomConstant = heightDifference;
                    keyBottomConstant = 0.0f;
                }
                else
                {
                    keyBottomConstant = -heightDifference;
                    valueBottomConstant = 0.0f;
                }
            }
            
            self.keyLabelBottomConstraint.constant = keyBottomConstant;
            self.bottomConstraint.constant = valueBottomConstant;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
