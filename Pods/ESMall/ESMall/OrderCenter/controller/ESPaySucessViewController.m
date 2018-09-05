//
//  ESPaySucessViewController.m
//  Consumer
//
//  Created by jiang on 2017/6/27.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESPaySucessViewController.h"
#import "ESMyOrderViewController.h"
#import "ESMallAssets.h"

@interface ESPaySucessViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UILabel *lineRightLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *describTitle;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *subRightButton;
@property (weak, nonatomic) IBOutlet UIButton *subLeftButton;
@property (weak, nonatomic) IBOutlet UIView *centerView;

@property (copy, nonatomic) NSString *orderId;
@property (copy, nonatomic) NSString *money;
@end

@implementation ESPaySucessViewController


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 开启
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[ESMallAssets hostBundle] loadNibNamed:@"ESPaySucessViewController" owner:self options:nil];
    self.titleLabel.text = @"支付成功";
    self.rightButton.hidden = YES;
    self.leftButton.hidden = YES;
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    _centerView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _lineRightLabel.backgroundColor = [UIColor stec_lineGrayColor];
    _lineLeftLabel.backgroundColor = [UIColor stec_lineGrayColor];
    _describTitle.textColor = [UIColor stec_titleTextColor];
    _describTitle.font = [UIFont stec_bigTitleFount];
    _subTitleLabel.textColor = [UIColor stec_contentTextColor];
    _subTitleLabel.font = [UIFont stec_subTitleFount];
    _priceLabel.textColor = [UIColor stec_titleTextColor];
    _priceLabel.font = [UIFont stec_packageTitleFount];
    
    NSMutableAttributedString *moneyStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%@", _money]];
    [moneyStr addAttribute:NSFontAttributeName value:[UIFont stec_remarkTextFount] range:NSMakeRange(0,1)];
    _priceLabel.attributedText = moneyStr;
    
    _subLeftButton.backgroundColor = [UIColor whiteColor];
    [_subLeftButton setTitleColor:[UIColor stec_blueTextColor] forState:UIControlStateNormal];
    _subLeftButton.clipsToBounds = YES;
    _subLeftButton.layer.cornerRadius = 4;
    _subLeftButton.layer.borderWidth = 0.5;
    _subLeftButton.titleLabel.font = [UIFont stec_bigTitleFount];
    _subLeftButton.layer.borderColor = [[UIColor stec_blueTextColor] CGColor];
    NSString *leftButtonTitle  = @"查看订单";
    if (_type == ESPaySucessTypeEnterprise)
    {
        leftButtonTitle = @"查看项目";
    }
    [_subLeftButton setTitle:leftButtonTitle forState:UIControlStateNormal];
    
    _subRightButton.backgroundColor = [UIColor stec_ableButtonBackColor];
    [_subRightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _subRightButton.clipsToBounds = YES;
    _subRightButton.layer.cornerRadius = 4;
    [_subRightButton setTitle:@"返回首页" forState:UIControlStateNormal];
    _subRightButton.titleLabel.font = [UIFont stec_bigTitleFount];
    // Do any additional setup after loading the view from its nib.

}
- (void)setOrderId:(NSString *)orderId money:(NSString *)money {
    _orderId = orderId;
    _money = money;
}

- (IBAction)subLeftbuttonClicked:(UIButton *)sender {
    
    if (_type == ESPaySucessTypeEnterprise)
    {
        NSArray *arrayVc = [self.navigationController viewControllers];
        if (arrayVc.count > 3)
        {
            [self.navigationController popToViewController:arrayVc[arrayVc.count - 3]
                                                  animated:YES];
        }
        return;
    } else if (_type == ESPaySucessTypePkgProjectList) {
        [MGJRouter openURL:@"/Shejijia/PkgProject/List"];
        return;
    } else if (_type == ESPaySucessTypePkgProjectDetail) {
        [MGJRouter openURL:@"/Shejijia/PkgProject/Detail"];
        return;
    }

    SHLog(@"订单详情");
    ESMyOrderViewController *myOrderViewCon = [[ESMyOrderViewController alloc] init];
    [self.navigationController pushViewController:myOrderViewCon animated:YES];
}
- (IBAction)subRightbuttonClicked:(UIButton *)sender {
    self.tabBarController.selectedIndex = 0;
    self.tabBarController.selectedViewController = self.tabBarController.viewControllers[0];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
