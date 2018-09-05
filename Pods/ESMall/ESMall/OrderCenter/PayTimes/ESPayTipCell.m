
#import "ESPayTipCell.h"

@interface ESPayTipCell ()

@property (weak, nonatomic) IBOutlet UILabel *tipMessageLabel;

@end

@implementation ESPayTipCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getPayTipMessageWithIndexPath:)])
    {
        NSDictionary *dict = [(id)self.cellDelegate getPayTipMessageWithIndexPath:indexPath];
        if (dict
            && [dict isKindOfClass:[NSDictionary class]]
            && dict[@"message"]
            && [dict[@"message"] isKindOfClass:[NSString class]])
        {
            self.tipMessageLabel.text = dict[@"message"];
        }
    }
}

@end
