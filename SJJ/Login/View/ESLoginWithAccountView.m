//
//  ESLoginWithAccountView.m
//  Homestyler
//
//  Created by shiyawei on 29/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESLoginWithAccountView.h"

#import "ESLoginViewController.h"
#import "ESGetNoteCodeController.h"
#import "ESRegisterViewController.h"

#import "ESHeaderView.h"
#import "ESPasswordCell.h"
#import "ESBottomTableCell.h"
#import "ESCaptchaTableCell.h"

#import "ESPublicMethods.h"

#import "Masonry.h"


@interface ESLoginWithAccountView ()<ESPasswordCellDelegate,ESBottomTableCellDelegate,UITableViewDataSource,UITableViewDelegate,ESCaptchaTableCellDelegate>
//@property (nonatomic,strong)    ESHeaderView *headerView;
@property (nonatomic,strong)    UITableView *tableView;
@property (nonatomic,strong)    UIImageView *headerImgView;
@property (nonatomic,strong)    UILabel *titleLabel;
@property (nonatomic,weak)    ESBottomTableCell *bottomCell;
@property (nonatomic,assign)    NSInteger rowNumber;

@property (nonatomic,assign)    BOOL passwordEnable;
@property (nonatomic,assign)    BOOL captchaEable;
@end

@implementation ESLoginWithAccountView

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.rowNumber = 2;
    [self createUIView];
    
}

- (void)createUIView {
    [self addSubview:self.headerImgView];
    [self.headerImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(NAVBAR_HEIGHT + 100);
        make.centerX.equalTo(self);
        make.height.mas_offset(60);
        make.width.mas_offset(60);
    }];
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerImgView.mas_bottom).offset(10);
        make.height.mas_offset(30);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
    }];
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(20);
        make.left.mas_offset(25);
        make.right.mas_offset(-25);
        make.height.mas_offset(170);
    }];
}

- (void)addCaptcha {
    self.rowNumber = 3;
    [self.tableView reloadData];
    [self.bottomCell resetBottomStyle:NO];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(210);
    }];
}
- (void)resetBottomStyle {
    if (self.rowNumber == 3) {
        if (self.passwordEnable && self.captchaEable) {
            [self.bottomCell resetBottomStyle:YES];
        }else {
           [self.bottomCell resetBottomStyle:NO];
        }
    }else {
        [self.bottomCell resetBottomStyle:self.passwordEnable];
    }
}
#pragma mark --- UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rowNumber;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.rowNumber - 1) {
        return 120;
    }
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        ESPasswordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESPasswordCellL" forIndexPath:indexPath];
        cell.isCreateEyeBtn = YES;
        cell.delegate = self;
        return cell;
    }else if (indexPath.row == self.rowNumber - 1) {
        ESBottomTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESBottomTableCellL" forIndexPath:indexPath];
        cell.bottomBtnStyle = ESBottomBtnStyleOtherAccountAndGetBackPassword;
        cell.delegate = self;
        self.bottomCell = cell;
        return cell;
    }else {
        ESCaptchaTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESCaptchaTableCellL" forIndexPath:indexPath];
        cell.delegate = self;
        cell.pageType = ESRegisterPageTypeLogin;
        cell.isShowIndicatorView = YES;
        return cell;
    }
}
#pragma mark --- ESPasswordCellDelegate
- (void)esPasswordCell:(ESPasswordCell *)cell textShouldChange:(BOOL)enable {
    self.passwordEnable = enable;
    [self resetBottomStyle];
}
- (void)esPasswordCell:(ESPasswordCell *)cell textDidEndEditing:(NSString *)text {
    self.passwordText = text;
}
#pragma mark --- ESCaptchaTableCellDelegate
- (void)esCaptchaTableCell:(ESCaptchaTableCell *)cell textShouldChange:(BOOL)enable {
    self.captchaEable = enable;
    [self resetBottomStyle];
}
- (void)esCaptchaTableCell:(ESCaptchaTableCell *)cell textDidEndEditing:(NSString *)text imageRandomCodeKey:(NSString *)imageRandomCodeKey {
    self.captcha = text;
    self.loginImageCodeKey = imageRandomCodeKey;
}
#pragma mark --- ESBottomTableCellDelegate
///登录按钮事件
- (void)registerBtnAction {
    [self endEditing:YES];
    if (self.bottomBtnClickBlock) {
        self.bottomBtnClickBlock();
    }
}
///其他账号登录 事件
- (void)esBottomTableCellBottomLeftBtnAction {
    ESLoginViewController *loginVC = [[ESLoginViewController alloc] init];
    loginVC.bottomBtnStyle = ESBottomBtnStyleRegisterAndGetBackPassword;

    UIViewController *vc = [ESPublicMethods currentViewController];
    [vc.navigationController pushViewController:loginVC animated:YES];
}
///找回密码
- (void)getBackPasswordAction {
    ESRegisterViewController *getPSWVC = [[ESRegisterViewController alloc] init];
    getPSWVC.pageType = ESRegisterPageTypeFind;
    getPSWVC.titleName = @"找回密码";
   
    UIViewController *vc = [ESPublicMethods currentViewController];
    [vc.navigationController pushViewController:getPSWVC animated:YES];
}
#pragma mark --- 懒加载
- (UIImageView *)headerImgView {
    if (!_headerImgView) {
        _headerImgView = [[UIImageView alloc] init];
        _headerImgView.image = [UIImage imageNamed:@"juran"];
    }
    return _headerImgView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor stec_grayTextColor];
        NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"Account"];
        NSString *str = [account stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        _titleLabel.text = str;
    }
    return _titleLabel;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.scrollEnabled = NO;
        _tableView.backgroundColor = self.backgroundColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[ESPasswordCell class] forCellReuseIdentifier:@"ESPasswordCellL"];
        [_tableView registerClass:[ESBottomTableCell class] forCellReuseIdentifier:@"ESBottomTableCellL"];
        [_tableView registerClass:[ESCaptchaTableCell class] forCellReuseIdentifier:@"ESCaptchaTableCellL"];
    }
    return _tableView;
}

@end
