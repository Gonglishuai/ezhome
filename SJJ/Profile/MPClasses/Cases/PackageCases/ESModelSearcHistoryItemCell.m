
#import "ESModelSearcHistoryItemCell.h"

@interface ESModelSearcHistoryItemCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ESModelSearcHistoryItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getSearchHistoryItemTextWithIndexPath:)])
    {
        NSString *title = [self.cellDelegate getSearchHistoryItemTextWithIndexPath:indexPath];
        if (title
            && [title isKindOfClass:[NSString class]])
        {
            self.titleLabel.text = title;
        }
    }
}

@end
