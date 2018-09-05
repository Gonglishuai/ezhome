
#import "ESPayWayCell.h"

@interface ESPayWayCell ()

@property (weak, nonatomic) IBOutlet UIImageView *payImageView;
@property (weak, nonatomic) IBOutlet UILabel *payTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UIView *payBackgroundView;

@end

@implementation ESPayWayCell
{
    NSIndexPath *_indexPath;
    NSString *_title;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    [self.payBackgroundView addGestureRecognizer:
     [[UITapGestureRecognizer alloc]
      initWithTarget:self
      action:@selector(paySelectedDidTapped:)]];
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getPayDataWithIndexPath:)])
    {
        NSDictionary *dict = [(id)self.cellDelegate getPayDataWithIndexPath:indexPath];
        if (dict
            && [dict isKindOfClass:[NSDictionary class]])
        {
            _title = dict[@"title"];
            
            self.payImageView.image = [ESMallAssets bundleImage:dict[@"icon"]];//[UIImage imageNamed:dict[@"icon"]];
            self.payTitleLabel.text = dict[@"title"];
            self.selectedImageView.image = [UIImage imageNamed:dict[@"selectedIcon"]];
        }
    }
}

#pragma mark - Tap Method
- (void)paySelectedDidTapped:(UITapGestureRecognizer *)tap
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(paySelectedDidTapped:title:)])
    {
        [(id)self.cellDelegate paySelectedDidTapped:_indexPath
                                              title:_title];
    }
}

@end
