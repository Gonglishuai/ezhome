//
//  ESChooseWayCell.m
//  Consumer
//
//  Created by jiang on 2017/6/26.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESChooseWayCell.h"

@interface ESChooseWayCell()
@property (weak, nonatomic) IBOutlet UIImageView *wayImageView;
@property (weak, nonatomic) IBOutlet UILabel *wayTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *waySelectImageView;

@end

@implementation ESChooseWayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _wayTitleLabel.textColor = [UIColor stec_titleTextColor];
    _wayTitleLabel.font = [UIFont stec_titleFount];
//    _waySelectImageView.clipsToBounds = YES;
//    _waySelectImageView.layer.cornerRadius = 25.0/2;
//    _waySelectImageView.layer.borderWidth = 1;
//    _waySelectImageView.layer.borderColor = [[UIColor stec_lineGrayColor]CGColor];
    _lineLabel.backgroundColor = [UIColor stec_lineGrayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setWayImageName:(NSString *)imgName wayTitle:(NSString *)wayTitle selected:(BOOL)selected {
    _wayImageView.image = [UIImage imageNamed:imgName];
    _wayTitleLabel.text = wayTitle;
    if (selected) {
//        _waySelectImageView.layer.borderWidth = 0;
        _waySelectImageView.image = [UIImage imageNamed:@"pay_way_select"];
    } else {
//        _waySelectImageView.layer.borderWidth = 0.5;
        _waySelectImageView.image = [UIImage imageNamed:@"pay_way_unselect"];
    }
}

@end
