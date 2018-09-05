
#import "ESPayAmountCell.h"

@interface ESPayAmountCell ()

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ESPayAmountCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getPayAmountDataWithIndexPath:)])
    {
        NSDictionary *dict = [(id)self.cellDelegate getPayAmountDataWithIndexPath:indexPath];
        if (dict
            && [dict isKindOfClass:[NSDictionary class]]
            && dict[@"amount"]
            && [dict[@"amount"] isKindOfClass:[NSString class]]
            && dict[@"title"]
            && [dict[@"title"] isKindOfClass:[NSString class]])
        {
            self.amountLabel.text = dict[@"amount"];
            self.titleLabel.text = dict[@"title"];
        }
    }
}

@end
