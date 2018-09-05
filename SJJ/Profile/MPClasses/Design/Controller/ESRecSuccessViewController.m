//
//  ESRecSuccessViewController.m
//  demo
//
//  Created by shiyawei on 13/4/18.
//  Copyright © 2018年 hu. All rights reserved.
//

#import "ESRecSuccessViewController.h"
#import "ESShareView.h"



@interface ESRecSuccessViewController ()
@property (nonatomic,strong)    UIView *backView;
@property (nonatomic,strong)    UIImageView *imgView;
@property (nonatomic,strong)    UILabel *titleLabel;
@property (nonatomic,strong)    UILabel *subLabel;
@property (nonatomic,strong)    UIButton *backBtn;
@property (nonatomic,strong)    UIButton *sharedBtn;
@end

@implementation ESRecSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = ColorFromRGA(0xF9F9F9, 1.0);//#F9F9F9 100%
    
    [self.view addSubview:self.backView];
    
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.sharedBtn];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}
#pragma mark --- Private Method
#pragma mark -- 返回上一页
- (void)backToSuperView {
    NSInteger count = self.navigationController.viewControllers.count;
    UIViewController *VC = [self.navigationController.viewControllers objectAtIndex:count - 3];
    [self.navigationController popToViewController:VC animated:YES];
}
#pragma mark -- 分享
- (void)shareAction {
    SHLog(@"分享");
    [ESShareView showShareViewWithShareTitle:self.shareModel.shareTitle shareContent:self.shareModel.shareContent shareImg:self.shareModel.shareImg shareUrl:self.shareModel.shareUrl shareStyle:ShareStyleTextAndImage Result:^(PlatformType type, BOOL isSuccess) {
        if (isSuccess) {
            [self backToSuperView];
        }
    }];
}

#pragma mark --- 懒加载
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height / 2);
        
        [_backView addSubview:self.imgView];
        [_backView addSubview:self.titleLabel];
        [_backView addSubview:self.subLabel];
    }
    return _backView;
}
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"cg_icon"];
        CGFloat x = self.backView.frame.size.width / 2 - 75 / 2;
        CGFloat y = self.backView.frame.size.height / 2 - 75 / 2 - 40;
        _imgView.frame = CGRectMake(x, y, image.size.width, image.size.height);
        _imgView.image = image;
    }
    return _imgView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.text = @"恭喜，您已成功绑定该业主~";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = ColorFromRGA(0x2D2D34, 1.0);//#2D2D34 100%
        _titleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.imgView.frame) + 30, self.backView.frame.size.width, 22);
    }
    return _titleLabel;
}
- (UILabel *)subLabel {
    if (!_subLabel) {
        _subLabel = [[UILabel alloc] init];
        _subLabel.font = [UIFont systemFontOfSize:13];
        _subLabel.text = @"快去分享给业主吧~";
        _subLabel.textColor = ColorFromRGA(0xBBBBBB, 1.0);//#BBBBBB 100%
        _subLabel.textAlignment = NSTextAlignmentCenter;
        _subLabel.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame) + 13, self.backView.frame.size.width, 18);
    }
    return _subLabel;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setTitle:@"返回" forState:UIControlStateNormal];
        [_backBtn setTitleColor:ColorFromRGA(0x2696C4, 1.0) forState:UIControlStateNormal];//#2696C4 100%
        _backBtn.backgroundColor = [UIColor whiteColor];
        _backBtn.layer.borderWidth = 1;
        _backBtn.layer.cornerRadius = 4;
        [_backBtn addTarget:self action:@selector(backToSuperView) forControlEvents:UIControlEventTouchUpInside];
        _backBtn.layer.borderColor = ColorFromRGA(0x2696C4, 1.0).CGColor;//#2696C4 100%
        _backBtn.frame = CGRectMake(27, CGRectGetMaxY(self.backView.frame) + 55, (self.view.frame.size.width - 80) / 2, 43);
    }
    return _backBtn;
}
- (UIButton *)sharedBtn {
    if (!_sharedBtn) {
        _sharedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sharedBtn setTitle:@"分享" forState:UIControlStateNormal];
        [_sharedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sharedBtn.backgroundColor = ColorFromRGA(0x419DCB, 1.0);//#419DCB 100%
        [_sharedBtn addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
        _sharedBtn.layer.cornerRadius = 4;
        _sharedBtn.frame = CGRectMake(CGRectGetMaxX(self.backBtn.frame) + 23, self.backBtn.frame.origin.y, (self.view.frame.size.width - 80) / 2, 43);
    }
    return _sharedBtn;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
