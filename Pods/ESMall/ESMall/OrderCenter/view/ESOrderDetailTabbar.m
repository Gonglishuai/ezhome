//
//  ESOrderDetailTabbar.m
//  Consumer
//
//  Created by jiang on 2017/6/27.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESOrderDetailTabbar.h"

@interface ESOrderDetailTabbar ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (strong, nonatomic) void(^myblock)(ESOrderTabbarBtnType);

@property (assign, nonatomic)ESOrderTabbarBtnType leftType;
@property (assign, nonatomic)ESOrderTabbarBtnType rightType;

@end

@implementation ESOrderDetailTabbar


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.font = [UIFont stec_titleFount];
    [_leftButton setTitleColor:[UIColor stec_subTitleTextColor] forState:UIControlStateNormal];
    _leftButton.clipsToBounds = YES;
    _leftButton.layer.cornerRadius = 15.0;
    _leftButton.layer.borderColor = [[UIColor stec_subTitleTextColor] CGColor];
    _leftButton.layer.borderWidth = 0.5;
    _leftButton.titleLabel.font = [UIFont stec_subTitleFount];
    [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rightButton.clipsToBounds = YES;
    _rightButton.layer.cornerRadius = 15.0;
    _rightButton.backgroundColor = [UIColor stec_ableButtonBackColor];
    _rightButton.titleLabel.font = [UIFont stec_subTitleFount];
    
}

+ (instancetype)creatWithFrame:(CGRect)frame Info:(NSDictionary *)info block:(void(^)(ESOrderTabbarBtnType))block {
    ESOrderDetailTabbar *orderDetailTabbar = [[ESMallAssets hostBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
    orderDetailTabbar.frame = frame;
    orderDetailTabbar.myblock = block;
    orderDetailTabbar.rightType = ESOrderTabbarBtnTypePay;
    orderDetailTabbar.leftType = ESOrderTabbarBtnTypeCancel;
    return orderDetailTabbar;
}

- (void)setOrderInfo:(NSDictionary *)orderInfo {
    [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rightButton.backgroundColor = [UIColor stec_ableButtonBackColor];
    
    NSString *orderState = [NSString stringWithFormat:@"%@", [orderInfo objectForKey:@"orderStatus"]];
    NSString *orderType = [NSString stringWithFormat:@"%@", [orderInfo objectForKey:@"orderType"]];
    
    double pay = [[NSString stringWithFormat:@"%@", (orderInfo[@"payAmount"] ? orderInfo[@"payAmount"] : @"0.00")] doubleValue];
    
    NSString *payAccount = @"";
    if (pay > 10000000.0) {
        payAccount = [NSString stringWithFormat:@"%@万",[NSString stringWithFormat:@"%.2f",pay/10000.0]];
    } else {
        payAccount = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%.2f",pay]];
    }
    
    NSString *factAccount = [NSString stringWithFormat:@"合计: ￥%@",payAccount];
    
    if ([orderState isEqualToString:@"10"] || [orderState isEqualToString:@"15"] || [orderState isEqualToString:@"16"]) {
        double unPaid = [[NSString stringWithFormat:@"%@", (orderInfo[@"unPaidAmount"] ? orderInfo[@"unPaidAmount"] : @"0.00")] doubleValue];
        
        NSString *unPaidAmount = @"";
        if (unPaid > 10000000.0) {
            unPaidAmount = [NSString stringWithFormat:@"%@万",[NSString stringWithFormat:@"%.2f",unPaid/10000.0]];
        } else {
            unPaidAmount = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%.2f",unPaid]];
        }
        factAccount = [NSString stringWithFormat:@"待付: ￥%@",unPaidAmount];
    }
    
    NSMutableAttributedString *factAccountStr = [[NSMutableAttributedString alloc] initWithString:factAccount];
    [factAccountStr addAttribute:NSFontAttributeName value:[UIFont stec_bigTitleFount] range:NSMakeRange(5,factAccountStr.length - 5)];
    [factAccountStr addAttribute:NSForegroundColorAttributeName value:[UIColor stec_redTextColor] range:NSMakeRange(5,factAccountStr.length - 5)];
    _titleLabel.attributedText = factAccountStr;
    
    
    _leftButton.hidden = NO;
    _rightButton.hidden = NO;
    if ([orderState isEqualToString:@"10"]) {//待支付
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
    } else if ([orderState isEqualToString:@"15"]) {//部分支付
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
    }else if ([orderState isEqualToString:@"20"]) {//已支付
        _leftButton.layer.borderColor = [[UIColor stec_lineGrayColor] CGColor];
        _leftButton.layer.borderWidth = 0.5;
        _leftButton.backgroundColor = [UIColor whiteColor];
        [_leftButton setTitle:@"申请退款" forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor stec_subTitleTextColor] forState:UIControlStateNormal];
        
        if (orderInfo && [orderInfo objectForKey:@"canRefund"]) {
            BOOL canRefund = [[orderInfo objectForKey:@"canRefund"] boolValue];
            [_leftButton setHidden:!canRefund];
        }
        
        _rightButton.layer.borderWidth = 0;
        _rightButton.backgroundColor = [UIColor stec_ableButtonBackColor];
        
        
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
        [self removeFromSuperview];
    }
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
