//
//  CoDesignerCommentCell.m
//  Consumer
//
//  Created by xuezy on 16/7/25.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoDesignerCommentCell.h"
#import "UIImageView+WebCache.h"

@interface CoDesignerCommentCell ()
{
    __weak IBOutlet UIImageView *_headImageView;
    
    __weak IBOutlet UILabel *_nameLabel;
    
    __weak IBOutlet UILabel *_dataLabel;
    
    __weak IBOutlet UILabel *_commentLabel;
    
    __weak IBOutlet UIImageView *_firstStarImageView;
    
    __weak IBOutlet UIImageView *_secondStarImageView;
    
    __weak IBOutlet UIImageView *_threeStarImageView;
    
    __weak IBOutlet UIImageView *_fourStarImageView;
    
    __weak IBOutlet UIImageView *_fiveImageView;
}
@end

@implementation CoDesignerCommentCell

- (void)updateCellForIndex:(NSInteger)index {
    
    if ([self.delegate respondsToSelector:@selector(getDesignerCommentModelAtIndex:)]) {
        CoDesignerCommentModel *model = [self.delegate getDesignerCommentModelAtIndex:index];
        _nameLabel.text = model.member_name;
        
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[model.estimate_data integerValue]/1000];
//        NSString *confromTimespStr = [dateFormatter stringFromDate:confromTimesp];
//
        NSString *timeStr = model.estimate_data;
        
        if (timeStr.length >10) {
            timeStr = [timeStr substringToIndex:10];
        }

        _dataLabel.text = timeStr;
        _commentLabel.text = model.member_estimate;
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",model.avatar]] placeholderImage:[UIImage imageNamed:HOUSE_DEFAULT_IMAGE]];

        NSInteger scoreValue = [model.member_grade integerValue];
        if (scoreValue == 1) {
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
            _fiveImageView.image = [UIImage imageNamed:@"designer_shi"];
            
        }

        
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.cornerRadius = 22;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    // Configure the view for the selected state
}

@end
