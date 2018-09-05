//
//  ESCaseNoCommentCell.m
//  Consumer
//
//  Created by jiang on 2017/8/22.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseNoCommentCell.h"
#import <Masonry.h>

@interface ESCaseNoCommentCell()
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;

@end

@implementation ESCaseNoCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    WS(weakSelf)
    [_backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(weakSelf.contentView.mas_width);
        make.height.equalTo(weakSelf.contentView.mas_height);
        make.height.greaterThanOrEqualTo(@(150));
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
