
#import "UIImageView+WebCache.h"
#import "MPHomeViewCell.h"
#import "MPCaseModel.h"
#import "MP3DCaseModel.h"

@interface MPHomeViewCell()

/// case imageView.
@property (weak, nonatomic) IBOutlet UIImageView *caseImageView;

/// designer avator.
@property (weak, nonatomic) IBOutlet UIImageView *designerIcon;

/// case title.
@property (weak, nonatomic) IBOutlet UILabel *caseTitleLabel;

/// detail information in case.
@property (weak, nonatomic) IBOutlet UILabel *caseInfoLabel;

/// the view let designer icon become round.
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

//点赞数
@property (weak, nonatomic) IBOutlet UILabel *numLikes;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightContraint;

@end



@implementation MPHomeViewCell
{
    NSInteger _index; //!< _index the index for model in datasource.
}

- (void)awakeFromNib {
	[super awakeFromNib];
    self.designerIcon.layer.cornerRadius = 27.0;
    self.designerIcon.layer.masksToBounds = YES;
    [self.avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(designerIconClicked:)]];
    
    self.caseTitleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
}

- (void) updateCellUIForIndex:(NSUInteger)index {
    _index = index;
    
    if ([self.delegate respondsToSelector:@selector(getDatamodelForIndex:)]) {
        
        ESDesignCaseList* model = [self.delegate getDatamodelForIndex:index];
        [self.designerIcon sd_setImageWithURL:[NSURL URLWithString:model.designerAvatar] placeholderImage:[UIImage imageNamed:ICON_HEADER_DEFAULT]];
        self.caseTitleLabel.text = [NSString stringWithFormat:@"%@  %@  %@",
                                    model.style ?: @"其他",
                                    model.roomType ?: @"其他",
                                    model.area ?: @"0㎡"];
        self.numLikes.text = model.favoriteCount ? model.favoriteCount : @"0";
        
        [self.caseImageView sd_setImageWithURL:[NSURL URLWithString:model.designCover] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    }
}


#pragma mark TapAction
- (void)designerIconClicked:(id)sender{
    if ([self.delegate respondsToSelector:@selector(designerIconClickedAtIndex:)]) {
        [self.delegate designerIconClickedAtIndex:_index];
    }
}


@end
