//
//  ESMyCommentTableCell.m
//  Consumer
//
//  Created by jiang on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMyCommentTableCell.h"
#import <Masonry.h>
@interface ESMyCommentTableCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@end

@implementation ESMyCommentTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleLabel.textColor = [UIColor stec_subTitleTextColor];
    _titleLabel.font = [UIFont stec_remarkTextFount];
    
    _detailLabel.textColor = [UIColor stec_titleTextColor];
    _detailLabel.font = [UIFont stec_titleFount];
    
    _dateLabel.textColor = [UIColor stec_subTitleTextColor];
    _dateLabel.font = [UIFont stec_remarkTextFount];
    
    
}

- (void)setInfo:(ESCaseCommentModel *)info {

    _detailLabel.text = info.comment?info.comment:@"";
    _titleLabel.text = info.resourceName?info.resourceName:@"";
    _dateLabel.text = info.createTime ? info.createTime : @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
