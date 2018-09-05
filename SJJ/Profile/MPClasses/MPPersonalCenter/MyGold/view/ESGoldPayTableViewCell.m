//
//  ESGoldPayTableViewCell.m
//  Mall
//
//  Created by jiang on 2017/9/17.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESGoldPayTableViewCell.h"
@interface ESGoldPayTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *typePriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondSubTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdSubTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *failureImageView;
@property (weak, nonatomic) IBOutlet UIButton *orderButton;

@property (strong, nonatomic) void(^myblock)(void);
@end
@implementation ESGoldPayTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _typeLabel.textColor = [UIColor stec_titleTextColor];
    _typeLabel.font = [UIFont stec_bigerTitleFount];
    
    _typePriceLabel.textColor = [UIColor stec_blueTextColor];
    _typePriceLabel.font = [UIFont stec_packageTitleBigFount];
    
    _secondTitleLabel.textColor = [UIColor stec_subTitleTextColor];
    _secondTitleLabel.font = [UIFont stec_subTitleFount];
    _secondSubTitleLabel.textColor = [UIColor stec_subTitleTextColor];
    _secondSubTitleLabel.font = [UIFont stec_subTitleFount];
    
    _thirdTitleLabel.textColor = [UIColor stec_subTitleTextColor];
    _thirdTitleLabel.font = [UIFont stec_subTitleFount];
    _thirdSubTitleLabel.font = [UIFont stec_subTitleFount];
    
}

- (void)setType:(NSString *)type info:(NSDictionary *)info block:(void(^)(void))block {
    
    if ([type isEqualToString:@"1"]) {
        _myblock = nil;
        NSString *type = @"返现";
        if (info
            && [info isKindOfClass:[NSDictionary class]]
            && info[@"subLogType"])
        {
            NSInteger subLogType = [info[@"subLogType"] integerValue];
            if (subLogType == 10)
            {
                type = @"消费返现";
            }
            else if (subLogType == 11)
            {
                type = @"退单返现";
            }
        }
        _typeLabel.text = type;
        
        NSString *opAmount = [NSString stringWithFormat:@"%@",info[@"opAmount"] ? info[@"opAmount"] : @"0"];
        _typePriceLabel.text = [NSString stringWithFormat:@"+%@", opAmount];
        
        _secondTitleLabel.text = @"支付时间:";
        if ([info[@"payTime"] isKindOfClass:[NSString class]]) {
            NSString *payTime = [NSString stringWithFormat:@"%@",info[@"payTime"] ? info[@"payTime"] : @""];
            _secondSubTitleLabel.text = payTime;
        }
        
        
        _thirdTitleLabel.text = @"返现时间:";
        if ([info[@"createdTime"] isKindOfClass:[NSString class]]) {
            NSString *createdTime = [NSString stringWithFormat:@"%@",info[@"createdTime"] ? info[@"createdTime"] : @""];
            _thirdSubTitleLabel.text = createdTime;
        }
        
        
        _thirdSubTitleLabel.textColor = [UIColor stec_subTitleTextColor];
    } else {
        _myblock = block;
           
        NSString *type = @"消费";
        BOOL shouFailureImageView = NO;
        if (info
            && [info isKindOfClass:[NSDictionary class]]
            && info[@"subLogType"])
        {
            NSInteger subLogType = [info[@"subLogType"] integerValue];
            if (subLogType == 21)
            {
                type = @"冻结";
                shouFailureImageView = YES;
            }
            else if (subLogType == 22)
            {
                type = @"失效";
                shouFailureImageView = YES;
            }
        }
        _typeLabel.text = type;
        _failureImageView.hidden = !shouFailureImageView;

        NSString *opAmount = [NSString stringWithFormat:@"%@",info[@"opAmount"] ? info[@"opAmount"] : @"0"];
        _typePriceLabel.text = [NSString stringWithFormat:@"%@", opAmount];
        
        _secondTitleLabel.text = shouFailureImageView?@"失效时间:":@"消费时间:";
        
        if ([info[@"createdTime"] isKindOfClass:[NSString class]]) {
            NSString *createdTime = [NSString stringWithFormat:@"%@",info[@"createdTime"] ? info[@"createdTime"] : @""];
            _secondSubTitleLabel.text = createdTime;
        }
        
        _thirdTitleLabel.text = shouFailureImageView?@"失效原因":@"订单编号:";
        
        _thirdSubTitleLabel.text = @"";
        _thirdSubTitleLabel.attributedText = nil;
        if (shouFailureImageView)
        {
            _thirdSubTitleLabel.textColor = [UIColor stec_subTitleTextColor];
            _orderButton.enabled = NO;
            if (info
                && [info isKindOfClass:[NSDictionary class]]
                && info[@"logInfo"]
                && [info[@"logInfo"] isKindOfClass:[NSString class]])
            {
                _thirdSubTitleLabel.text = info[@"logInfo"];
            }
        }
        else
        {
            _thirdSubTitleLabel.textColor = [UIColor stec_blueTextColor];
            _orderButton.enabled = YES;
            if ([info[@"orderId"] isKindOfClass:[NSString class]]) {
                NSString *orderIdStr = [NSString stringWithFormat:@"%@",info[@"orderId"] ? info[@"orderId"] : @""];
                NSString *textStr = orderIdStr;
                NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
                NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attribtDic];
                _thirdSubTitleLabel.attributedText = attribtStr;
            }
        }
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (IBAction)orderButtonClicked:(UIButton *)sender {
    if (_myblock) {
        _myblock();
    }
}

@end
