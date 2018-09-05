
#import "ESModelListCell.h"
#import "UIImageView+WebCache.h"
#import "ESModelTagLabel.h"
#import "ESSampleRoomModel.h"

@interface ESModelListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *modelImageView;
@property (weak, nonatomic) IBOutlet UILabel *modelInformationLabel;
@property (weak, nonatomic) IBOutlet UIView *modelTagsBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *modelNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet ESModelTagLabel *tagRightLabel;
@property (weak, nonatomic) IBOutlet ESModelTagLabel *tagMidLabel;
@property (weak, nonatomic) IBOutlet ESModelTagLabel *tagLeftLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagRightLabelConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagMidLabelConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagLeftLabelConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gradientImageviewHeight;

@end

@implementation ESModelListCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.gradientImageviewHeight.constant = CGRectGetHeight(self.modelImageView.frame)/4.0f;
    
    self.modelImageView.clipsToBounds = YES;
    self.modelImageView.layer.cornerRadius = 2.0f;
    
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = CGRectGetWidth(self.avatarImageView.frame)/2.0f;
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getModelListCellDataWithIndexPath:)])
    {
        ESSampleRoomModel *model = [self.cellDelegate getModelListCellDataWithIndexPath:indexPath];
        self.modelInformationLabel.text = model.caseDescription;
        self.modelNameLabel.text = model.caseName;
        
        self.modelImageView.contentMode = UIViewContentModeCenter;
        WS(weakSelf);
        [self.modelImageView sd_setImageWithURL:[NSURL URLWithString:model.defaultImg]
                               placeholderImage:[UIImage imageNamed:@"image_default"]
                                      completed:^(UIImage * _Nullable image,
                                                  NSError * _Nullable error,
                                                  SDImageCacheType cacheType,
                                                  NSURL * _Nullable imageURL)
        {
            if (!error)
            {
                weakSelf.modelImageView.contentMode = UIViewContentModeScaleAspectFill;
            }
        }];
        
        self.nameLabel.text = model.designerName;

        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.designerAvatar]
                                placeholderImage:[UIImage imageNamed:ICON_HEADER_DEFAULT]];
        
//        self.amountLabel.text = model.pvNum;

        self.tagRightLabel.text = model.rightLabelText;
        self.tagRightLabelConstraint.constant = model.rightLabelWidth;
        self.tagMidLabel.text = model.midLabelText;
        self.tagMidLabelConstraint.constant = model.midLabelWidth;
        self.tagLeftLabel.text = model.leftLabelText;
        self.tagLeftLabelConstraint.constant = model.leftLabelWidth;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
