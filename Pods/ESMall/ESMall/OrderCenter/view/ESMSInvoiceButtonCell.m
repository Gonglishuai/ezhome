//
//  ESMSInvoiceButtonCell.m
//  Consumer
//
//  Created by jiang on 2017/7/13.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMSInvoiceButtonCell.h"

@interface ESMSInvoiceButtonCell()
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (strong, nonatomic) void(^myblock)(ESMSInvoiceBtnType);

@property (assign, nonatomic)ESMSInvoiceBtnType leftType;
@property (assign, nonatomic)ESMSInvoiceBtnType rightType;
@property (assign, nonatomic) BOOL isSelectRight;
@end

@implementation ESMSInvoiceButtonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _leftButton.titleLabel.font = [UIFont stec_subTitleFount];
    [_leftButton setTitleColor:[UIColor stec_blueTextColor] forState:UIControlStateNormal];
    _leftButton.clipsToBounds = YES;
    _leftButton.layer.cornerRadius = 1;
    _leftButton.layer.borderWidth = 0.5;
    _leftButton.layer.borderColor = [[UIColor stec_ableButtonBackColor] CGColor];
    _rightButton.titleLabel.font = [UIFont stec_subTitleFount];
    [_rightButton setTitleColor:[UIColor stec_subTitleTextColor] forState:UIControlStateNormal];
    _rightButton.clipsToBounds = YES;
    _rightButton.layer.cornerRadius = 1;
    _rightButton.layer.borderWidth = 0.5;
    _rightButton.layer.borderColor = [[UIColor stec_lineGrayColor] CGColor];
    
    
}
- (void)setLeftTitle:(NSString *)leftTitle leftType:(ESMSInvoiceBtnType)leftType rightTitle:(NSString *)rightTitle rightType:(ESMSInvoiceBtnType)rightType isSelectRight:(BOOL)isSelectRight block:(void(^)(ESMSInvoiceBtnType))block {
    [_leftButton setTitle:leftTitle forState:UIControlStateNormal];
    _leftType = leftType;
    [_rightButton setTitle:rightTitle forState:UIControlStateNormal];
    _rightType = rightType;
    _myblock = block;
    _isSelectRight = isSelectRight;
    if (isSelectRight) {
        [_rightButton setTitleColor:[UIColor stec_blueTextColor] forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor stec_subTitleTextColor] forState:UIControlStateNormal];
        _rightButton.layer.borderColor = [[UIColor stec_ableButtonBackColor] CGColor];
        _leftButton.layer.borderColor = [[UIColor stec_lineGrayColor] CGColor];
    } else {
        [_leftButton setTitleColor:[UIColor stec_blueTextColor] forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor stec_subTitleTextColor] forState:UIControlStateNormal];
        _leftButton.layer.borderColor = [[UIColor stec_ableButtonBackColor] CGColor];
        _rightButton.layer.borderColor = [[UIColor stec_lineGrayColor] CGColor];
    }
    
}

- (IBAction)leftButtonClicked:(UIButton *)sender {
    if (_myblock && _isSelectRight) {
        _myblock(_leftType);
    }
    
}
- (IBAction)rightButtonClicked:(UIButton *)sender {
    if (_myblock && (!_isSelectRight)) {
        _myblock(_rightType);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
