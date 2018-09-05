
#import "ESPayWayTitleCell.h"

@interface ESPayWayTitleCell ()

@property (weak, nonatomic) IBOutlet UILabel *payWayTitleLabel;

@end

@implementation ESPayWayTitleCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getPayWayTitleWithIndexPath:)])
    {
        NSDictionary *dict = [(id)self.cellDelegate getPayWayTitleWithIndexPath:indexPath];
        if (dict
            && [dict isKindOfClass:[NSDictionary class]]
            && dict[@"title"]
            && [dict[@"title"] isKindOfClass:[NSString class]])
        {
            self.payWayTitleLabel.text = dict[@"title"];
        }
    }
}

@end
