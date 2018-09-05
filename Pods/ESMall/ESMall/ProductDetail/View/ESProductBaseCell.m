
#import "ESProductBaseCell.h"

@implementation ESProductBaseCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
