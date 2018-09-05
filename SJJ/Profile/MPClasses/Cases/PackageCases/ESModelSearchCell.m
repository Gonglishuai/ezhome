
#import "ESModelSearchCell.h"

@interface ESModelSearchCell ()

@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@end

@implementation ESModelSearchCell
{
    NSIndexPath *_indexPath;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.searchButton.layer.masksToBounds = YES;
    self.searchButton.layer.cornerRadius = 3.0f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)updateSearchCellWithIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getSearchTipTextWithIndexPath:)])
    {
        NSString *title = [self.cellDelegate getSearchTipTextWithIndexPath:indexPath];
        if (title
            && [title isKindOfClass:[NSString class]])
        {
            [self.searchButton setTitle:title
                               forState:UIControlStateNormal];
        }
    }
}

@end
