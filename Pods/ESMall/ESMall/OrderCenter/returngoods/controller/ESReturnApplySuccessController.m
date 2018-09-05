//
//  ESReturnApplySuccessController.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/16.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESReturnApplySuccessController.h"
#import "ESMyOrderViewController.h"
#import "ESReturnGoodsDetailController.h"
#import "MGJRouter.h"

@interface ESReturnApplySuccessController ()
@property (weak, nonatomic) IBOutlet UIButton *returnDetailBtn;
@property (weak, nonatomic) IBOutlet UIButton *materialHomeBtn;
@property (nonatomic, strong) NSString *returnGoodsId;
@end

@implementation ESReturnApplySuccessController

- (instancetype)initWithReturnGoodsId:(NSString *)returnGoodsId {
    self = [super init];
    if (self) {
        self.returnGoodsId = returnGoodsId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[ESMallAssets hostBundle] loadNibNamed:@"ESReturnApplySuccessController" owner:self options:nil];
    self.titleLabel.text = @"申请退款";
    self.leftButton.hidden = YES;
    self.rightButton.hidden = YES;
    
    self.returnDetailBtn.layer.borderWidth = 1;
    self.returnDetailBtn.layer.borderColor = [UIColor stec_blueTextColor].CGColor;
    self.returnDetailBtn.layer.cornerRadius = 8.0f;
    
    self.materialHomeBtn.layer.cornerRadius = 8.0f;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (IBAction)returnDetailBtnClick:(UIButton *)sender {
    [self startPopGesture];
    ESReturnGoodsDetailController *returnVc = [[ESReturnGoodsDetailController alloc] initWithOrderId:self.returnGoodsId Block:nil];
    [self.navigationController pushViewController:returnVc animated:YES];
}

- (IBAction)materialHomeBtnClick:(UIButton *)sender {
    [self startPopGesture];
    [MGJRouter openURL:@"/Mall/MallHome"];
}

- (void)startPopGesture {
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

@end
