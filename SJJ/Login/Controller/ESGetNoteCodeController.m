//
//  ESGetNoteCodeController.m
//  Homestyler
//
//  Created by shiyawei on 27/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESGetNoteCodeController.h"
#import "ESSetPasswordController.h"

#import "ESBottomTableCell.h"
#import "ESNoteCodeTableCell.h"
#import "ESCaptchaTableCell.h"

#import "ESLoginAPI.h"
#import "ESDeviceUtil.h"

#import "Masonry.h"

@interface ESGetNoteCodeController ()<UITableViewDelegate,UITableViewDataSource,ESNoteCodeTableCellDelegate,ESBottomTableCellDelegate,ESCaptchaTableCellDelegate>
@property (nonatomic,strong)    UILabel *titleLabel;
@property (nonatomic,strong)    UILabel *subLabel;
@property (nonatomic,strong)    UITableView *tableView;
@property (nonatomic,weak)    ESBottomTableCell *bottomTableCell;
@property (nonatomic,weak)    ESNoteCodeTableCell *noteCodeTableCell;
@property (nonatomic,assign)    BOOL noteCodeCheckStatus;//短信验证码校验结果
@property (nonatomic,assign)    BOOL noteCodeEnable;

@property (nonatomic,assign)    NSInteger rowNumber;

@property (nonatomic,copy)    NSString *code;
@property (nonatomic,copy)    NSString *imgCode;
@end

@implementation ESGetNoteCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title = @"注册";
    self.view.backgroundColor = [UIColor whiteColor];
    self.noteCodeCheckStatus = YES;
    self.imgCode = @"";
    
    self.rowNumber = 2;
    
    [self createUIView];
    
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)setPhoneNumber:(NSString *)phoneNumber {
    _phoneNumber = phoneNumber;
    NSString *str = [phoneNumber stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    
    self.subLabel.text = [NSString stringWithFormat:@"已发送短信验证码至\n+86 %@",str];
}
- (void)setPageType:(ESRegisterPageType)pageType {
    _pageType = pageType;
}
#pragma mark --- private method
- (void)createUIView {
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(80);
        make.left.mas_offset(0);
        make.right.mas_offset(0);
        make.height.mas_offset(55);
    }];
    
    [self.view addSubview:self.subLabel];
    [self.subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.mas_offset(50);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subLabel.mas_bottom).offset(10);
        make.height.mas_offset(200);
        make.left.mas_offset(25);
        make.right.mas_offset(-25);
    }];
}

- (void)resetBottomBtnStyle {
    if (self.noteCodeEnable) {
        [self.bottomTableCell resetBottomStyle:YES];
    }else {
        [self.bottomTableCell resetBottomStyle:NO];
    }
}

- (void)resetTable {
    
    [self.noteCodeTableCell invalidateTimer];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(250);
    }];
    [self.tableView reloadData];
    [self resetBottomBtnStyle];
    
}

#pragma mark --- UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.rowNumber;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.rowNumber - 1) {
        return 120;
    }else {
        return 50;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.rowNumber - 2) {
        ESNoteCodeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESNoteCodeTableCellG" forIndexPath:indexPath];
        cell.delegate = self;
        cell.cellBlock = ^{//60s结束后，出现图片验证码
            self.rowNumber = 3;
            [self resetTable];
        };
        if (self.rowNumber == 2) {
            [cell fireTimer];
        }else {
            [cell invalidateTimer];
        }
        return cell;
    }else if (indexPath.row == self.rowNumber - 1) {
        ESBottomTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESBottomTableCellG" forIndexPath:indexPath];
        cell.bottomBtnStyle = ESBottomBtnStyleDefault;
        cell.delegate = self;
        self.bottomTableCell = cell;
        return cell;
    }else {
        ESCaptchaTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESCaptchaTableCellG" forIndexPath:indexPath];
        cell.delegate = self;
        cell.isShowIndicatorView = YES;
        return cell;
    }
}
#pragma mark --- ESCaptchaTableCellDelegate
- (void)esCaptchaTableCell:(ESCaptchaTableCell *)cell textDidEndEditing:(NSString *)text imageRandomCodeKey:(NSString *)imageRandomCodeKey{
    self.imgCode = text;
}

#pragma mark --- ESNoteCodeTableCellDelegate
//获取验证码
- (void)esNoteCodeTableCellReloadNoteCode {
    
    [self.view endEditing:YES];
    
    ESSmsCodeType codeType = ESCreate;
    if (self.pageType == ESRegisterPageTypeCreate) {
        codeType = ESCreate;
    }else if (self.pageType == ESRegisterPageTypeFind) {
        codeType = ESFind;
    }
    [ESMBProgressToast showToastAddTo:self.view];
    [ESLoginAPI getSendSmsCode:codeType Mobile:self.phoneNumber UUID:[ESDeviceUtil getUUID] Code:self.imgCode andSuccess:^(NSDictionary *dict) {
        [ESMBProgressToast hideToastForView:self.view];
        [self.noteCodeTableCell fireTimer];
        self.rowNumber = 2;
        [self resetTable];
        SHLog(@"dict %@",dict);
    } andFailure:^(NSError *error) {
        [ESMBProgressToast hideToastForView:self.view];
        NSString *text = [ESLoginAPI errMessge:error];
        [ESMBProgressToast showToastAddTo:self.view text:text];
        SHLog(@"error %@",error);
        
    }];
}
- (void)esNoteCodeTableCell:(ESNoteCodeTableCell *)cell textShouldChange:(BOOL)enable {
    self.noteCodeEnable = enable;
    [self resetBottomBtnStyle];
}
- (void)esNoteCodeTableCell:(ESNoteCodeTableCell *)cell textDidEndEditing:(NSString *)text {
    self.code = text;
}
#pragma mark --- ESBottomTableCellDelegate
//校验验证码
- (void)registerBtnAction {
    [self.view endEditing:YES];
    
    ESSmsCodeType codeType = (NSInteger)self.pageType;
    
    [ESMBProgressToast showToastAddTo:self.view];
    [ESLoginAPI checkSmsCode:codeType Mobile:self.phoneNumber smsCode:self.code andSuccess:^(NSDictionary *dict) {
        [ESMBProgressToast hideToastForView:self.view];
        SHLog(@"dict %@",dict);
        
        ESSetPasswordController *setPasswordVC = [[ESSetPasswordController alloc] init];
        setPasswordVC.title = self.title;
        setPasswordVC.phone = self.phoneNumber;
        setPasswordVC.msgCode = self.code;
        setPasswordVC.pageType = self.pageType;
        [self.navigationController pushViewController:setPasswordVC animated:YES];
    } andFailure:^(NSError *error) {
        [ESMBProgressToast hideToastForView:self.view];
        NSString *text = [ESLoginAPI errMessge:error];
        [ESMBProgressToast showToastAddTo:self.view text:text];
        SHLog(@"error %@",error);
        
    }];
}

#pragma mark --- 懒加载
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"请输入短信验证码";
        _titleLabel.font = [UIFont stec_packageTitleBigFount];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
- (UILabel *)subLabel {
    if (!_subLabel) {
        _subLabel = [[UILabel alloc] init];
        
        _subLabel.font = [UIFont stec_paramsFount];
        _subLabel.textAlignment = NSTextAlignmentCenter;
        _subLabel.numberOfLines = 2;
    }
    return _subLabel;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerClass:[ESNoteCodeTableCell class] forCellReuseIdentifier:@"ESNoteCodeTableCellG"];
        [_tableView registerClass:[ESBottomTableCell class] forCellReuseIdentifier:@"ESBottomTableCellG"];
        [_tableView registerClass:[ESCaptchaTableCell class] forCellReuseIdentifier:@"ESCaptchaTableCellG"];
        
    }
    return _tableView;
}


















- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
