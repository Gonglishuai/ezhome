//
//  ESOrderListButtonCell.m
//  Consumer
//
//  Created by jiang on 2017/7/4.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESOrderListButtonCell.h"

@interface ESOrderListButtonCell()
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (strong, nonatomic) void(^myblock)(ESOrderTabbarBtnType);

@property (assign, nonatomic)ESOrderTabbarBtnType leftType;
@property (assign, nonatomic)ESOrderTabbarBtnType rightType;
@end


@implementation ESOrderListButtonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _leftButton.clipsToBounds = YES;
    _leftButton.layer.cornerRadius = 15;
    _leftButton.titleLabel.font = [UIFont stec_subTitleFount];
    _rightButton.clipsToBounds = YES;
    _rightButton.layer.cornerRadius = 15;
    _rightButton.titleLabel.font = [UIFont stec_subTitleFount];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setInfo:(NSDictionary *)info block:(void(^)(ESOrderTabbarBtnType))block {
    _myblock = block;
    NSString *orderState = [NSString stringWithFormat:@"%@", [info objectForKey:@"orderStatus"]];
    NSString *orderType = [NSString stringWithFormat:@"%@", [info objectForKey:@"orderType"]];

    _leftButton.hidden = NO;
    _rightButton.hidden = NO;
    if ([orderState isEqualToString:@"10"]) {//未支付
        _leftButton.layer.borderColor = [[UIColor stec_lineGrayColor] CGColor];
        _leftButton.layer.borderWidth = 0.5;
        _leftButton.backgroundColor = [UIColor whiteColor];
        [_leftButton setTitle:@"取消订单" forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor stec_subTitleTextColor] forState:UIControlStateNormal];
        
        _rightButton.layer.borderWidth = 0;
        _rightButton.backgroundColor = [UIColor stec_ableButtonBackColor];
        
        NSString *text = @"去支付";
        if ([orderType isEqualToString:@"5"]) {//定金订单
            text = @"付定金";
        }
        [_rightButton setTitle:text forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _rightType = ESOrderTabbarBtnTypePay;
        _leftType = ESOrderTabbarBtnTypeCancel;
    }else if ([orderState isEqualToString:@"15"]) { //部分支付
        _leftButton.layer.borderColor = [[UIColor stec_lineGrayColor] CGColor];
        _leftButton.layer.borderWidth = 0.5;
        _leftButton.backgroundColor = [UIColor whiteColor];
        [_leftButton setTitle:@"申请退款" forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor stec_subTitleTextColor] forState:UIControlStateNormal];
        
        _rightButton.layer.borderWidth = 0;
        _rightButton.backgroundColor = [UIColor stec_ableButtonBackColor];
        [_rightButton setTitle:@"去支付" forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _rightType = ESOrderTabbarBtnTypePay;
        _leftType = ESOrderTabbarBtnTypeDrawback;
    } else if ([orderState isEqualToString:@"16"]) {//定金已支付
        _leftButton.layer.borderColor = [[UIColor stec_lineGrayColor] CGColor];
        _leftButton.layer.borderWidth = 0.5;
        _leftButton.backgroundColor = [UIColor whiteColor];
        [_leftButton setTitle:@"申请退款" forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor stec_subTitleTextColor] forState:UIControlStateNormal];
        
        _rightButton.layer.borderWidth = 0;
        _rightButton.backgroundColor = [UIColor stec_ableButtonBackColor];
        [_rightButton setTitle:@"付尾款" forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _rightType = ESOrderTabbarBtnTypePay;
        _leftType = ESOrderTabbarBtnTypeDrawback;
    } else if ([orderState isEqualToString:@"20"]) {//已支付
        _leftButton.layer.borderColor = [[UIColor stec_lineGrayColor] CGColor];
        _leftButton.layer.borderWidth = 0.5;
        _leftButton.backgroundColor = [UIColor whiteColor];
        [_leftButton setTitle:@"申请退款" forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor stec_subTitleTextColor] forState:UIControlStateNormal];
        if (info && [info objectForKey:@"canRefund"]) {
            BOOL canRefund = [[info objectForKey:@"canRefund"] boolValue];
            [_leftButton setHidden:!canRefund];
        }
        
        _rightButton.layer.borderWidth = 0;
        _rightButton.backgroundColor = [UIColor stec_ableButtonBackColor];
        
        NSString *orderType = [NSString stringWithFormat:@"%@", [info objectForKey:@"orderType"]];
        if ([orderType isEqualToString:@"0"]) {
            [_rightButton setTitle:@"确认服务" forState:UIControlStateNormal];
            _rightType = ESOrderTabbarBtnTypeGetServer;
        } else {
            [_rightButton setTitle:@"确认收货" forState:UIControlStateNormal];
            _rightType = ESOrderTabbarBtnTypeGetPage;
        }
        
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        
        _leftType = ESOrderTabbarBtnTypeDrawback;
    } else if ([orderState isEqualToString:@"40"] || [orderState isEqualToString:@"41"]) {//交易完成
        _rightButton.layer.borderColor = [[UIColor stec_lineGrayColor] CGColor];
        _rightButton.layer.borderWidth = 0.5;
        _rightButton.backgroundColor = [UIColor whiteColor];
        [_rightButton setTitle:@"申请退款" forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor stec_subTitleTextColor] forState:UIControlStateNormal];
        
        _leftButton.hidden = YES;
        _rightType = ESOrderTabbarBtnTypeDrawback;
    } else {//交易关闭
        
    }
}

- (void)setReturnInfo:(NSDictionary *)info block:(void(^)(ESOrderTabbarBtnType))block {
    _myblock = block;
    _leftButton.hidden = NO;
    _rightButton.layer.borderWidth = 0;
    _rightButton.backgroundColor = [UIColor stec_ableButtonBackColor];
    [_rightButton setTitle:@"确认退款成功" forState:UIControlStateNormal];
    [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rightType = ESOrderTabbarBtnTypeDrawback;
    _leftButton.hidden = YES;
}

- (IBAction)leftButtonClicked:(UIButton *)sender {
    if (_myblock) {
        _myblock(_leftType);
    }
}
- (IBAction)rightButtonClicked:(UIButton *)sender {
    if (_myblock) {
        _myblock(_rightType);
    }
}

@end
