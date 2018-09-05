//
//  MPHome3DViewCell.m
//  Consumer
//
//  Created by 董鑫 on 16/8/22.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "MPHome3DViewCell.h"
#import "UIImageView+WebCache.h"

@interface MPHome3DViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *caseImageView;
@property (weak, nonatomic) IBOutlet UIImageView *designerIcon;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *numLikes;
@property (weak, nonatomic) IBOutlet UILabel *caseTitleLabel;
@end

@implementation MPHome3DViewCell

{
    NSInteger _index; //!< _index the index for model in datasource.
}

- (void)awakeFromNib {
	[super awakeFromNib];
    self.designerIcon.layer.cornerRadius = 27.0;
    self.designerIcon.layer.masksToBounds = YES;
    [self.avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(designer3DIconClicked:)]];
    self.avatarImageView.userInteractionEnabled = YES;
    self.caseTitleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    self.avatarImageView.layer.cornerRadius = 28;
}

- (void) update3DCellUIForIndex:(NSUInteger)index {
    _index = index;
    if ([self.delegate respondsToSelector:@selector(get3DDatamodelForIndex:)]) {
        ESDesignCaseList* model = [self.delegate get3DDatamodelForIndex:index];
        
        [self.designerIcon sd_setImageWithURL:[NSURL URLWithString:model.designerAvatar] placeholderImage:[UIImage imageNamed:ICON_HEADER_DEFAULT]];
        
        self.caseTitleLabel.text = [NSString stringWithFormat:@"%@  %@  %@",
                                    model.style ?: @"其他",
                                    model.roomType ?: @"其他",
                                    model.area ?: @"0㎡"];
        self.numLikes.text = [NSString stringWithFormat:@"%@",model.favoriteCount];
        
        [self.caseImageView sd_setImageWithURL:[NSURL URLWithString:model.designCover] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    }
    
}

- (void)designer3DIconClicked:(id)sender{
    if ([self.delegate respondsToSelector:@selector(designer3DIconClickedAtIndex:)]) {
        [self.delegate designer3DIconClickedAtIndex:_index];
    }
}
@end
