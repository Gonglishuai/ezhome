//
//  ESOrderStateCell.m
//  Consumer
//
//  Created by jiang on 2017/6/27.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESOrderStateCell.h"

@interface ESOrderStateCell()
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (assign, nonatomic) NSInteger secondsCountDown;
@property (strong, nonatomic) NSTimer *countDownTimer;
@end

@implementation ESOrderStateCell
{
    NSDictionary *_orderinfo;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _stateLabel.textColor = [UIColor whiteColor];
    _stateLabel.font = [UIFont stec_bigTitleFount];
    _priceLabel.textColor = [UIColor whiteColor];
    _priceLabel.font = [UIFont stec_remarkTextFount];
    
}
- (void)setOrderInfo:(NSDictionary *)orderinfo {
    _orderinfo = orderinfo;
    NSString *orderState = [NSString stringWithFormat:@"%@", [orderinfo objectForKey:@"orderStatus"]];
    NSString *orderType = [NSString stringWithFormat:@"%@",([orderinfo objectForKey:@"orderType"] ?: @"")];
    NSString *leadTime = [NSString stringWithFormat:@"%@", [orderinfo objectForKey:@"leadTime"]];
    NSString *day = [NSString stringWithFormat:@"该商品备货周期为%@天", [self displayCheckday:leadTime]];
    
    if ([orderState isEqualToString:@"10"] ||
        [orderState isEqualToString:@"15"]) {
        _mainImageView.image = [UIImage imageNamed:@"order_detail_wait_pay"];
        _priceLabel.text = day;
        
        NSString *timeStr = [NSString stringWithFormat:@"%@",([orderinfo objectForKey:@"autoTime"] != [NSNull null])?[orderinfo objectForKey:@"autoTime"]:@"0"];
        _secondsCountDown = [timeStr integerValue]/1000;//倒计时秒数
        _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(countDownAction) userInfo:nil repeats:YES]; //启动倒计时后会每秒钟调用一次方法 countDownAction
        //设置倒计时显示的时间
        NSString *str_hour = [NSString stringWithFormat:@"%02ld",_secondsCountDown/3600];//时
        NSString *str_minute = [NSString stringWithFormat:@"%02ld",(_secondsCountDown%3600)/60];//分
        NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_hour,str_minute];
        SHLog(@"time:%@",format_time);
        
        NSString *title = @"待支付";
        NSInteger start = 4;
        
        NSMutableAttributedString *stateStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@     %@", title, format_time]];
        [stateStr addAttribute:NSFontAttributeName value:[UIFont stec_remarkTextFount] range:NSMakeRange(start,stateStr.length - start)];
        _stateLabel.attributedText = stateStr;
        

    } else if ([orderState isEqualToString:@"16"] && [orderType isEqualToString:@"5"]) {
        _mainImageView.image = [UIImage imageNamed:@"order_detail_wait_pay"];
        _priceLabel.text = day;
        _stateLabel.text = @"定金支付完成";
        
    } else if ([orderState isEqualToString:@"20"]) {
        _mainImageView.image = [UIImage imageNamed:@"order_detail_pay_finish"];
        
        if ([orderType isEqualToString:@"5"]) {
            _stateLabel.text = @"尾款支付完成";
        } else {
            _stateLabel.text = @"已支付";
        }
        
        _priceLabel.text = day;
    } else if ([orderState isEqualToString:@"40"] || [orderState isEqualToString:@"41"]) {
        _mainImageView.image = [UIImage imageNamed:@"order_detail_finish"];
        _stateLabel.text = @"交易完成";
        _priceLabel.text = day;
    } else {
        _mainImageView.image = [UIImage imageNamed:@"order_detail_close"];
        _stateLabel.text = @"交易关闭";
        _priceLabel.text = day;
    }
   
}

-(void) countDownAction{
    NSString *orderState = [NSString stringWithFormat:@"%@", [_orderinfo objectForKey:@"orderStatus"]];
    NSString *orderType = [NSString stringWithFormat:@"%@",([_orderinfo objectForKey:@"orderType"] ?: @"")];
    //倒计时-1
    _secondsCountDown = _secondsCountDown-60;
    
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",(long)_secondsCountDown/3600];
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(long)(_secondsCountDown%3600)/60];
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_hour,str_minute];
    //修改倒计时标签现实内容
    NSString *title = @"待支付";
    NSInteger start = 4;
    if ([orderState isEqualToString:@"16"] && [orderType isEqualToString:@"5"]) {
        start = 6;
        title = @"定金支付完成";
    }
    NSMutableAttributedString *stateStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@     %@", title, format_time]];
    [stateStr addAttribute:NSFontAttributeName value:[UIFont stec_remarkTextFount] range:NSMakeRange(start,stateStr.length - start)];
    _stateLabel.attributedText = stateStr;
    //当倒计时到0时，做需要的操作，比如验证码过期不能提交
    if(_secondsCountDown==0){
        [_countDownTimer invalidate];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSString *)displayCheckday:(NSString *)day {
    if ([day isEqualToString:@"<null>"] || day == nil || [day isKindOfClass:[NSNull class]] || day.length == 0 || [day isEqualToString:@"(null)"]) {
        return @"30";
    }
    
    return day;
}

@end
