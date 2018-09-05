//
//  CoMyFocusCell.m
//  Consumer
//
//  Created by Jiao on 16/7/18.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoMyFocusCell.h"
#import "ESCommentFocusModel.h"
#import "UIImageView+WebCache.h"
@interface CoMyFocusCell ()

/// _index the index for model in datasource.
@property (assign, nonatomic) NSUInteger index;
@end
@implementation CoMyFocusCell
{
    __weak IBOutlet UIButton *_focusButton;

}
-(void) updateCellForIndex:(NSUInteger) index
{
    if ([self.delegate respondsToSelector:@selector(getFocusDesignersModelForIndex:)])
    {
        
        self.index = index;
         ESCommentFocusModel *model = [self.delegate getFocusDesignersModelForIndex:index];
    
//        [self.memberAvatar sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:ICON_HEADER_DEFAULT]];
        
        if([model.avatar rangeOfString:@"default_avatar"].location !=NSNotFound)
        {
            [self.memberAvatar setImage:[UIImage imageNamed:ICON_HEADER_DEFAULT]];
        }else{
            [self.memberAvatar sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:ICON_HEADER_DEFAULT]];

        }
        
        
        if ([model.isRealName isEqualToString:@"2"]) {
            self.idImageView.image = [UIImage imageNamed:VERIFIED_V];//已认证
        } else {
            self.idImageView.image = [UIImage imageNamed:@""];
        }
        self.nameLabel.text = (model.nickName == nil)?NSLocalizedString(@"暂无数据", nil):model.nickName;
        
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.memberAvatar.layer.masksToBounds = YES;
    self.memberAvatar.layer.cornerRadius = 30.0f;
    _focusButton.layer.cornerRadius = 5.0f;
    _focusButton.layer.borderWidth = 1.0f;
    _focusButton.layer.borderColor = [[UIColor stec_blueTextColor] CGColor];
    [_focusButton setTitleColor:[UIColor stec_blueTextColor] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)cancleBtn:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(clickUnsubscribeDesignerForIndex:)]) {
        
        [self.delegate clickUnsubscribeDesignerForIndex:self.index];
    }
}
@end
