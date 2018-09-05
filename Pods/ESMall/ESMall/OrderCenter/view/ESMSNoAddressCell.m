//
//  ESMSNoAddressCell.m
//  Consumer
//
//  Created by jiang on 2017/7/11.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMSNoAddressCell.h"

@interface ESMSNoAddressCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end

@implementation ESMSNoAddressCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    _titleLabel.textColor = [UIColor stec_subTitleTextColor];
    _titleLabel.font = [UIFont stec_subTitleFount];
    // Initialization code
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
