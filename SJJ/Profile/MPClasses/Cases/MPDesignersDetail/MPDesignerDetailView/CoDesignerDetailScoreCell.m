//
//  CoDesignerDetailScoreCell.m
//  Consumer
//
//  Created by xuezy on 16/7/26.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoDesignerDetailScoreCell.h"
@interface CoDesignerDetailScoreCell ()
{
    __weak IBOutlet UIImageView *_firstStarImageView;
    
    __weak IBOutlet UIImageView *_secondStarImageView;
    
    __weak IBOutlet UIImageView *_threeStarImageView;
    
    __weak IBOutlet UIImageView *_fourStarImageView;
    
    __weak IBOutlet UIImageView *_fiveStarImageView;
    
}
@end

@implementation CoDesignerDetailScoreCell

- (void)updateCellForIndex:(NSInteger)index {
    
    if ([self.delegate respondsToSelector:@selector(getDesignerScore)]) {
        float scoreValue = [self.delegate getDesignerScore];
        
//              DesignStar_Selected    designer_one_half
        
        
        if (scoreValue < 1 && scoreValue != 0) {
            _firstStarImageView.image = [UIImage imageNamed:@"designer_one_half"];
        }else if (scoreValue >1 && scoreValue < 2) {
            _firstStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _secondStarImageView.image = [UIImage imageNamed:@"designer_one_half"];

        }else if (scoreValue > 2 && scoreValue <3) {
            _firstStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _secondStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _threeStarImageView.image = [UIImage imageNamed:@"designer_one_half"];

        }else if (scoreValue > 3 && scoreValue < 4) {
            _firstStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _secondStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _threeStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _fourStarImageView.image = [UIImage imageNamed:@"designer_one_half"];

        }else if (scoreValue > 4 && scoreValue < 5) {
            _firstStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _secondStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _threeStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _fourStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _fiveStarImageView.image = [UIImage imageNamed:@"designer_one_half"];

        }else if (scoreValue == 1) {
            _firstStarImageView.image = [UIImage imageNamed:@"designer_shi"];

        }else if (scoreValue == 2) {
            _firstStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _secondStarImageView.image = [UIImage imageNamed:@"designer_shi"];
        }else if (scoreValue == 3) {
            _firstStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _secondStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _threeStarImageView.image = [UIImage imageNamed:@"designer_shi"];
        }else if (scoreValue == 4) {
            _firstStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _secondStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _threeStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _fourStarImageView.image = [UIImage imageNamed:@"designer_shi"];
        }else if (scoreValue == 5) {
            _firstStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _secondStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _threeStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _fourStarImageView.image = [UIImage imageNamed:@"designer_shi"];
            _fiveStarImageView.image = [UIImage imageNamed:@"designer_shi"];

        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
