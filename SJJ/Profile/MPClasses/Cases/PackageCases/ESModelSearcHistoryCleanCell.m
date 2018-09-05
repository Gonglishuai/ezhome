
#import "ESModelSearcHistoryCleanCell.h"

@interface ESModelSearcHistoryCleanCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ESModelSearcHistoryCleanCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getSearchHistoryTipTextWithIndexPath:)])
    {
        NSString *title = [self.cellDelegate getSearchHistoryTipTextWithIndexPath:indexPath];
        if (title
            && [title isKindOfClass:[NSString class]])
        {
            self.titleLabel.text = title;
        }
    }
}

#pragma mark - Button Tapped
- (IBAction)clearButtonDidTapped:(id)sender
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(cleanButtonDidTapped)])
    {
        [self.cellDelegate cleanButtonDidTapped];
    }
}

@end
