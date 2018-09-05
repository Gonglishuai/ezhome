
#import "ESPayEnterpriseAgreementCell.h"

@interface ESPayEnterpriseAgreementCell ()

@property (weak, nonatomic) IBOutlet UIButton *selectedButton;
@property (weak, nonatomic) IBOutlet UIButton *agreementButton;

@end

@implementation ESPayEnterpriseAgreementCell
{
    NSIndexPath *_indexPath;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getPayEnterpriseDataWithIndexPath:)])
    {
        NSDictionary *dict = [(id)self.cellDelegate getPayEnterpriseDataWithIndexPath:indexPath];
        if (dict
            && [dict isKindOfClass:[NSDictionary class]]
            && dict[@"selected"])
        {
            self.selectedButton.selected = [dict[@"selected"] boolValue];
        }
    }
}

#pragma mark - Button Method
- (IBAction)selectedButtonDidTapped:(id)sender
{
    self.selectedButton.selected = !self.selectedButton.selected;
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(agreeButtonDidTapped:indexPth:)])
    {
        [(id)self.cellDelegate agreeButtonDidTapped:self.selectedButton.selected
                                           indexPth:_indexPath];
    }
}

- (IBAction)agreementButtonDidTapped:(id)sender
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(agreementButtonDidTapped)])
    {
        [(id)self.cellDelegate agreementButtonDidTapped];
    }
}

@end
