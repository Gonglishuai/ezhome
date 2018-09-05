//
//  ESModifyPasswordController.m
//  Homestyler
//
//  Created by shiyawei on 28/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESModifyPasswordController.h"

#import "ESModifyPasswordTableCell.h"
#import "ESBottomTableCell.h"

#import "ESLoginAPI.h"

#import "Masonry.h"


@interface ESModifyPasswordController ()<UITextFieldDelegate>

@property (nonatomic,strong)    UIButton *bottomBtn;
@property (nonatomic,copy)    NSString *oldPassword;
@property (nonatomic,copy)    NSString *nowPassword;
@property (nonatomic,strong)    UIView *backgroundView;
@property (nonatomic,strong)    UITextField *oldPasswordInput;
@property (nonatomic,strong)    UITextField *nowPasswordInput;
@property (nonatomic,strong)    UITextField *checkPasswordInput;
@end

@implementation ESModifyPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改密码";
    
    [self createUIView];
}


#pragma mark --- private method
- (void)createUIView {
    [self.view addSubview:self.backgroundView];
    
    [self.backgroundView addSubview:self.oldPasswordInput];
    [self.oldPasswordInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(5);
        make.left.mas_offset(20);
        make.right.mas_offset(-20);
        make.height.mas_offset(40);
    }];
    UIView  *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor stec_lineGrayColor];
    [self.backgroundView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.oldPasswordInput.mas_bottom).offset(5);
        make.left.equalTo(self.oldPasswordInput.mas_left);
        make.right.equalTo(self.oldPasswordInput.mas_right);
        make.height.mas_offset(0.5);
    }];

    [self.backgroundView addSubview:self.nowPasswordInput];
    [self.nowPasswordInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom).offset(5);
        make.left.equalTo(self.oldPasswordInput.mas_left);
        make.right.equalTo(self.oldPasswordInput.mas_right);
        make.height.mas_offset(40);
    }];

    UIView  *nowLineView = [[UIView alloc] init];
    nowLineView.backgroundColor = [UIColor stec_lineGrayColor];
    [self.backgroundView addSubview:nowLineView];
    [nowLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nowPasswordInput.mas_bottom).offset(5);
        make.left.equalTo(self.oldPasswordInput.mas_left);
        make.right.equalTo(self.oldPasswordInput.mas_right);
        make.height.mas_offset(0.5);
    }];

    [self.backgroundView addSubview:self.checkPasswordInput];
    [self.checkPasswordInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nowLineView.mas_bottom).offset(5);
        make.left.equalTo(self.oldPasswordInput.mas_left);
        make.right.equalTo(self.oldPasswordInput.mas_right);
        make.height.mas_offset(40);
    }];
    
    [self.view addSubview:self.bottomBtn];
    [self.bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backgroundView.mas_bottom).offset(20);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.mas_offset(50);
    }];
}

- (void)oldPasswordChanged:(UITextField *)textField {
    [self resetBottomBtnStyle];
}
- (void)nowPasswordChanged:(UITextField *)textField {
    [self resetBottomBtnStyle];
}
- (void)checkPasswordChanged:(UITextField *)textField {
    [self resetBottomBtnStyle];
}

- (void)resetBottomBtnStyle {
    if (self.oldPasswordInput.text.length > 0 && self.nowPasswordInput.text.length > 0 && self.checkPasswordInput.text.length > 0) {
        self.bottomBtn.userInteractionEnabled = YES;
        self.bottomBtn.backgroundColor = [UIColor stec_blueTextColor];
        [self.bottomBtn setTitleColor:[UIColor stec_whiteTextColor] forState:UIControlStateNormal];
    }else {
        self.bottomBtn.userInteractionEnabled = NO;
        self.bottomBtn.backgroundColor = [UIColor stec_unabelButtonBackColor];
        [self.bottomBtn setTitleColor:[UIColor stec_whiteTextColor] forState:UIControlStateNormal];
    }
    
    
}
- (void)sendAction {
    [self.view endEditing:YES];
    
    
    if (self.nowPasswordInput.text != self.checkPasswordInput.text) {
        [ESMBProgressToast showToastAddTo:self.view text:@"两次密码不一致"];
        return;
    }
    
    [ESMBProgressToast showToastAddTo:self.view];
    [ESLoginAPI updatePasswordOldClearTextPassword:self.oldPasswordInput.text newClearTextPassword:self.nowPasswordInput.text andSuccess:^(NSDictionary *dict) {
        [ESMBProgressToast hideToastForView:self.view];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        SHLog(@"修改密码成功 %@",dict);
    } andFailure:^(NSError *error) {
        [ESMBProgressToast hideToastForView:self.view];
        NSString *text = [ESLoginAPI errMessge:error];
        [ESMBProgressToast showToastAddTo:self.view text:text];
        SHLog(@"修改密码 %@",error);
    }];
}
#pragma mark --- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    
    return YES;
}

#pragma mark --- 懒加载
- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor whiteColor];
        _backgroundView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 160);
    }
    return _backgroundView;
}

- (UITextField *)oldPasswordInput {
    if (!_oldPasswordInput) {
        _oldPasswordInput = [[UITextField alloc] init];
        _oldPasswordInput.placeholder = @"原密码";
        _oldPasswordInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        _oldPasswordInput.delegate = self;
        _oldPasswordInput.secureTextEntry = YES;
        [_oldPasswordInput addTarget:self action:@selector(oldPasswordChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _oldPasswordInput;
}
- (UITextField *)nowPasswordInput {
    if (!_nowPasswordInput) {
        _nowPasswordInput = [[UITextField alloc] init];
        _nowPasswordInput.placeholder = @"新密码";
        _nowPasswordInput.delegate = self;
        _nowPasswordInput.secureTextEntry = YES;
        _nowPasswordInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_nowPasswordInput addTarget:self action:@selector(nowPasswordChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _nowPasswordInput;
}
- (UITextField *)checkPasswordInput {
    if (!_checkPasswordInput) {
        _checkPasswordInput = [[UITextField alloc] init];
        _checkPasswordInput.placeholder = @"再输一次";
        _checkPasswordInput.delegate = self;
        _checkPasswordInput.secureTextEntry = YES;
        _checkPasswordInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_checkPasswordInput addTarget:self action:@selector(checkPasswordChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _checkPasswordInput;
}
- (UIButton *)bottomBtn {
    if (!_bottomBtn) {
        _bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
        [_bottomBtn setTitle:@"确定" forState:UIControlStateNormal];
        _bottomBtn.backgroundColor = [UIColor stec_unabelButtonBackColor];
        [_bottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _bottomBtn.userInteractionEnabled = NO;
        _bottomBtn.layer.cornerRadius = 5;
        _bottomBtn.layer.masksToBounds = YES;
    }
    return _bottomBtn;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
