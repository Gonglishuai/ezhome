
#import "ESModelFilterCell.h"
#import "ESSampleRoomTagFilterModel.h"

@interface ESModelFilterCell ()

@property (weak, nonatomic) IBOutlet UILabel *filterLabel;

@end

@implementation ESModelFilterCell
{
    NSIndexPath *_indexPath;
    BOOL _selectedStatus;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.filterLabel.backgroundColor = [UIColor yellowColor];
    self.filterLabel.clipsToBounds = YES;
    self.filterLabel.layer.cornerRadius = 2.0f;
    
    self.filterLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemDidTapped)];
    [self.filterLabel addGestureRecognizer:tap];
}

- (void)updateFilterCellWithIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getFilterDataWithIndexPath:)])
    {
        ESSampleRoomTagFilterModel *model = [self.cellDelegate getFilterDataWithIndexPath:indexPath];
        self.filterLabel.text = model.tagName;
        
        _selectedStatus = model.currentSelectedStatus;
        [self updateFilterLabelStatus];
    }
}

- (void)updateFilterLabelStatus
{
    UIColor *backgroundColor = nil;
    UIColor *textColor = nil;
    
    if (_selectedStatus)
    {
        backgroundColor = [UIColor stec_itemSelectedTextColor];
        textColor = [UIColor whiteColor];
    }
    else
    {
        backgroundColor = [UIColor stec_viewBackgroundColor];
        textColor = [UIColor stec_subTitleTextColor];
    }
    
    self.filterLabel.backgroundColor = backgroundColor;
    self.filterLabel.textColor = textColor;
}

#pragma mark - Tap Methods
- (void)itemDidTapped
{
    _selectedStatus = !_selectedStatus;
    
    [self updateFilterLabelStatus];
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(itemDidTappedWithIndexPath:)])
    {
        [self.cellDelegate itemDidTappedWithIndexPath:_indexPath];
    }
}

@end
