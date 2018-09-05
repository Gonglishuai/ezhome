//
//  ESMasterSearchHistoryCell.m
//  Mall
//
//  Created by jiang on 2017/8/30.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMasterSearchHistoryCell.h"

@interface ESMasterSearchHistoryCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ESMasterSearchHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleLabel.textColor = [UIColor stec_subTitleTextColor];
    _titleLabel.font = [UIFont stec_subTitleFount];
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
