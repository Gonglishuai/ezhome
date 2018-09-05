
#import "ESSaleAgreementCell.h"

@interface ESSaleAgreementCell ()

@property (weak, nonatomic) IBOutlet UILabel *approvedLabel;

@end

@implementation ESSaleAgreementCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)updateSaleAgreementCellWithIndex:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getSaleAgreementStatus:)])
    {
        BOOL hasApproved = [self.cellDelegate getSaleAgreementStatus:indexPath];
        self.approvedLabel.hidden = !hasApproved;
    }
}

@end
