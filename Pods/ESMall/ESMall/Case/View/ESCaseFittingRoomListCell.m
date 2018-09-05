
#import "ESCaseFittingRoomListCell.h"
#import "ESCaseFittingModelTagLabel.h"
#import "UIImageView+WebCache.h"
#import "ESFittingSampleRoomModel.h"

@interface ESCaseFittingRoomListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *caseImageView;
@property (weak, nonatomic) IBOutlet UILabel *caseInformationLabel;
@property (weak, nonatomic) IBOutlet UILabel *caseNameLabel;
@property (weak, nonatomic) IBOutlet ESCaseFittingModelTagLabel *tagLeftLabel;
@property (weak, nonatomic) IBOutlet ESCaseFittingModelTagLabel *tagMidLabel;
@property (weak, nonatomic) IBOutlet ESCaseFittingModelTagLabel *tagRightLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gradientImageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagRightLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagMidLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagLeftLabelWidth;

@end

@implementation ESCaseFittingRoomListCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.gradientImageViewHeight.constant = CGRectGetHeight(self.caseImageView.frame)/4.0f;
    
    self.caseImageView.clipsToBounds = YES;
    self.caseImageView.layer.cornerRadius = 2.0f;
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getFittingRoomListCellDataWithIndex:)])
    {
        ESFittingSampleRoomModel *model = [self.cellDelegate getFittingRoomListCellDataWithIndex:indexPath];
        self.caseNameLabel.text = model.caseName;
        self.caseInformationLabel.text = model.caseDescription;
        [self.caseImageView sd_setImageWithURL:[NSURL URLWithString:model.defaultImg]
                               placeholderImage:[UIImage imageNamed:@"HouseDefaultImage"]];
        
        self.tagRightLabel.text = model.rightLabelText;
        self.tagRightLabelWidth.constant = model.rightLabelWidth;
        self.tagMidLabel.text = model.midLabelText;
        self.tagMidLabelWidth.constant = model.midLabelWidth;
        self.tagLeftLabel.text = model.leftLabelText;
        self.tagLeftLabelWidth.constant = model.leftLabelWidth;
    }
}

@end
