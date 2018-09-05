//
//  ESCaseNoNetCommentCell.m
//  Consumer
//
//  Created by jiang on 2017/8/24.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseNoNetCommentCell.h"

@interface ESCaseNoNetCommentCell()
@property (weak, nonatomic) IBOutlet UIImageView *backImgView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (strong, nonatomic) void(^tapBlock)(void);

@end

@implementation ESCaseNoNetCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _refreshButton.clipsToBounds = YES;
    _refreshButton.layer.cornerRadius = 3;
    _refreshButton.layer.borderColor = [[UIColor stec_lineGrayColor] CGColor];
    _refreshButton.layer.borderWidth = 0.5;
    [_refreshButton setTitleColor:[UIColor stec_contentTextColor] forState:UIControlStateNormal];
    _refreshButton.titleLabel.font = [UIFont stec_titleFount];
    // Initialization code
}

- (void)setTapBlock:(void(^)(void))tapBlock {
    _tapBlock = tapBlock;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)buttonClicked:(UIButton *)sender {
    if (_tapBlock) {
        _tapBlock();
    }
}

@end
