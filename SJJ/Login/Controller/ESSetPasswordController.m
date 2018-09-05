//
//  ESSetPasswordController.m
//  Homestyler
//
//  Created by shiyawei on 27/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESSetPasswordController.h"

#import "ESPasswordCell.h"
#import "ESBottomTableCell.h"

#import "ESLoginManager.h"

#import "Masonry.h"
#import "ESLoginAPI.h"

@interface ESSetPasswordController ()<UITableViewDelegate,UITableViewDataSource,ESBottomTableCellDelegate,ESPasswordCellDelegate>
@property (nonatomic,strong)    UILabel *titleLabel;
@property (nonatomic,strong)    UITableView *tableView;
@property (nonatomic,strong)    ESBottomTableCell *bottomTableCell;
@property (nonatomic,copy)    NSString *password;
@end

@implementation ESSetPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title = @"注册";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createUIView];
    
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
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(30);
        make.height.mas_offset(150);
        make.left.mas_offset(25);
        make.right.mas_offset(-25);
    }];
}
- (void)dismissViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark --- UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 50;
    }
    return 70;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        ESPasswordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESPasswordCellS" forIndexPath:indexPath];
        cell.delegate = self;
        cell.isCreateEyeBtn = YES;
        return cell;
    }else {
        ESBottomTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESBottomTableCellS" forIndexPath:indexPath];
        cell.delegate = self;
        self.bottomTableCell = cell;
        return cell;
    }
}
#pragma mark --- ESBottomTableCellDelegate
///完成密码设置
- (void)registerBtnAction {
    [self.view endEditing:YES];
    
    if (self.pageType == ESRegisterPageTypeCreate) {//创建密码
        [self registerPassword];
    }else if (self.pageType == ESRegisterPageTypeFind) {//找回密码
        [self resetPassword];
    }else {
        
    }
    
    
}

- (void)registerPassword {
    [ESMBProgressToast showToastAddTo:self.view];
    [ESLoginAPI registerUserMobile:self.phone smsCode:self.msgCode cleartextPassword:self.password andSuccess:^(NSDictionary *dict) {
//        [ESMBProgressToast hideToastForView:self.view];
//        [self dismissViewController];
        [self loginAction];
        SHLog(@"dict %@",dict);
    } andFailure:^(NSError *error) {
        [ESMBProgressToast hideToastForView:self.view];
        NSString *text = [ESLoginAPI errMessge:error];
        [ESMBProgressToast showToastAddTo:self.view text:text];
    }];
}

- (void)resetPassword {
    [ESMBProgressToast showToastAddTo:self.view];
    [ESLoginAPI findPasswordMobile:self.phone SmsCode:self.msgCode NewPassword:self.password andSuccess:^(NSDictionary *dict) {
        
//        [self dismissViewController];
//        SHLog(@"dict %@",dict);
        [self loginAction];
    } andFailure:^(NSError *error) {
        [ESMBProgressToast hideToastForView:self.view];
        NSString *text = [ESLoginAPI errMessge:error];
        [ESMBProgressToast showToastAddTo:self.view text:text];
        
    }];
}
- (void)loginAction {
    
    [ESLoginAPI loginUserName:self.phone password:self.password loginImageCodeKey:@"" userLoginImageCodeValue:@"" andSuccess:^(NSDictionary *dict) {
        [ESMBProgressToast hideToastForView:self.view];
        
        [[ESLoginManager sharedManager] loginComplete:dict];
        [[NSUserDefaults standardUserDefaults] setObject:self.phone forKey:@"Account"];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
    } andFailure:^(NSError *error) {
        [ESMBProgressToast hideToastForView:self.view];
        NSString *text = [ESLoginAPI errMessge:error];
        [ESMBProgressToast showToastAddTo:self.view text:text];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
    }];
}
#pragma mark --- ESPasswordCellDelegate
- (void)esPasswordCell:(ESPasswordCell *)cell textShouldChange:(BOOL)enable {
    [self.bottomTableCell resetBottomStyle:enable];
}
- (void)esPasswordCell:(ESPasswordCell *)cell textDidEndEditing:(NSString *)text {
    self.password = text;
}

#pragma mark --- 懒加载
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"请设置密码";
        _titleLabel.font = [UIFont stec_packageTitleBigFount];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.scrollEnabled = NO;
        _tableView.backgroundColor = self.view.backgroundColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerClass:[ESPasswordCell class] forCellReuseIdentifier:@"ESPasswordCellS"];
        [_tableView registerClass:[ESBottomTableCell class] forCellReuseIdentifier:@"ESBottomTableCellS"];
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
