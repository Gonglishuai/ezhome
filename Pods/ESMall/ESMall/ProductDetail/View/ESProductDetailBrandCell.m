
#import "ESProductDetailBrandCell.h"
#import "UIImageView+WebCache.h"
#import "ESProductBrandModel.h"

@interface ESProductDetailBrandCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation ESProductDetailBrandCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.iconImageView.clipsToBounds = YES;
    self.iconImageView.layer.cornerRadius = 2.0f;
    self.iconImageView.layer.borderColor = [UIColor stec_viewBackgroundColor].CGColor;
    self.iconImageView.layer.borderWidth = 0.5f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath
{
    self.iconImageView.image = [UIImage imageNamed:@"search_case_logo"];
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getBrandInformationAtIndexPath:)])
    {
        // 品牌信息
        ESProductBrandModel *model = [(id)self.cellDelegate getBrandInformationAtIndexPath:indexPath];
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.logo]
                              placeholderImage:[UIImage imageNamed:@"search_case_logo"]];
        self.nameLabel.text = model.brandName;
        self.descriptionLabel.text = model.desc.length?model.desc:@"";
    }
}

#pragma mark - Button Method
- (IBAction)chatButtonDidTapped:(id)sender
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(chatButtonDidTapped)])
    {
        [(id)self.cellDelegate chatButtonDidTapped];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
