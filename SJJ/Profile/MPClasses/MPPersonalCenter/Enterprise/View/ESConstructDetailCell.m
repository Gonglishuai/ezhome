
#import "ESConstructDetailCell.h"

@interface ESConstructDetailCell ()

@property (weak, nonatomic) IBOutlet UILabel *keyLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueLabelRightConstraint;

@end

@implementation ESConstructDetailCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getDetailDataWithIndexPath:)])
    {
        NSDictionary *dict = [self.cellDelegate getDetailDataWithIndexPath:indexPath];
        self.bottomLine.hidden = ![dict[@"showLine"] boolValue];
        self.keyLabel.text = dict[@"key"];
        
        if ([dict[@"showArrow"] boolValue])
        {
            self.arrowImageView.hidden = NO;
            self.valueLabelRightConstraint.constant = 25.0f;
        }
        else
        {
            self.arrowImageView.hidden = YES;
            self.valueLabelRightConstraint.constant = 15.0f;
        }
        
        if ([dict[@"alertRed"] boolValue])
        {
            self.valueLabel.text = nil;
            NSString *value = dict[@"value"];
            if (value.length >= 3)
            {
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:value];
                [str addAttribute:NSForegroundColorAttributeName value:[UIColor stec_subTitleTextColor] range:NSMakeRange(0,1)];
                [str addAttribute:NSForegroundColorAttributeName value:[UIColor stec_redTextColor] range:NSMakeRange(1,value.length - 1)];
                self.valueLabel.attributedText = str;
            }
        }
        else
        {
            self.valueLabel.attributedText = nil;
            self.valueLabel.text = dict[@"value"];
        }
    }
}

@end
