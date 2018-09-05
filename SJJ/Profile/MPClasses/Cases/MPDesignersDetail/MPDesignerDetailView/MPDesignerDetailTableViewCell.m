
#import "MPDesignerDetailTableViewCell.h"
#import "MPCaseModel.h"
#import "UIImageView+WebCache.h"
#import "MP3DCaseModel.h"
#import "ESDesignCaseList.h"

@interface MPDesignerDetailTableViewCell ()

/// case image.
@property (weak, nonatomic) IBOutlet UIImageView *caseImageView;
/// case title.
@property (weak, nonatomic) IBOutlet UILabel *caseTitleLabel;
/// case detail information.
@property (weak, nonatomic) IBOutlet UILabel *deatilInfoLabel;

@property (weak, nonatomic) IBOutlet UILabel *numLikes;
@property (strong, nonatomic) ESDesignCaseList *myModel;
@end

@implementation MPDesignerDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    self.caseTitleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
}

- (void)updateCellForIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(getDesignerDetailModelAtIndex:)]) {
        ESDesignCaseList *model = [self.delegate getDesignerDetailModelAtIndex:index];

        self.caseTitleLabel.text = [NSString stringWithFormat:@"%@  %@  %@",(model.style == nil)?NSLocalizedString(@"暂无数据", nil):model.style,(model.roomType == nil)?NSLocalizedString(@"暂无数据", nil):model.roomType,(model.area == nil)?NSLocalizedString(@"暂无数据", nil):model.area];
        self.numLikes.text = [NSString stringWithFormat:@"%@",(model.favoriteCount == nil)?@"0":model.favoriteCount];
        
        [_caseImageView sd_setImageWithURL:[NSURL URLWithString:model.designCover] placeholderImage:[UIImage imageNamed:HOUSE_DEFAULT_IMAGE]];
    }
}

- (void)setModel:(ESDesignCaseList *)model {
    _myModel = model;
    
    self.caseTitleLabel.text = [NSString stringWithFormat:@"%@  %@  %@㎡",(model.style == nil)?NSLocalizedString(@"暂无数据", nil):model.style,(model.roomType == nil)?NSLocalizedString(@"暂无数据", nil):model.roomType,(model.area == nil)?NSLocalizedString(@"暂无数据", nil):model.area];
    self.numLikes.text = [NSString stringWithFormat:@"%@",(model.favoriteCount == nil)?@"0":model.favoriteCount];
    
    [_caseImageView sd_setImageWithURL:[NSURL URLWithString:model.designCover] placeholderImage:[UIImage imageNamed:HOUSE_DEFAULT_IMAGE]];

}
@end
