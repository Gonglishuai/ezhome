
#import "ESReturnApplyWayCell.h"

@interface ESReturnApplyWayCell ()

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *applyGoodsAndMoneyButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *applyMoneyButton;

@end

@implementation ESReturnApplyWayCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getReturnWayStatus)])
    {
        NSInteger returnWay = [self.cellDelegate getReturnWayStatus];
        self.applyGoodsAndMoneyButton.selected = returnWay == 0;
        self.applyMoneyButton.selected = returnWay != 0;
    }
}

#pragma mark - Button Methods
- (IBAction)applyGoodsAndMoneyButtonDidTapped:(id)sender
{
    if (self.applyGoodsAndMoneyButton.selected)
    {
        return;
    }
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(applyGoodsWithMoneyDidTapped)])
    {
        self.applyGoodsAndMoneyButton.selected = !self.applyGoodsAndMoneyButton.selected;
        [self.cellDelegate applyGoodsWithMoneyDidTapped];
    }
}

- (IBAction)applyMoneyButtonDidTapped:(id)sender
{
    if (self.applyMoneyButton.selected)
    {
        return;
    }
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(applyMoneyDidTapped)])
    {
        self.applyMoneyButton.selected = !self.applyMoneyButton.selected;
        [self.cellDelegate applyMoneyDidTapped];
    }
}

@end
