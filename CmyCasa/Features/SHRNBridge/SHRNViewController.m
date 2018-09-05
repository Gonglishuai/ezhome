//
//  SHRNViewController.m
//  Consumer
//
//  Created by 牛洋洋 on 2017/2/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "SHRNViewController.h"
#import "ESLoginViewController.h"
#import "ESRegisterViewController.h"

#import "ESLoginChoiceView.h"
#import "ESLoginWithAccountView.h"

//#import "SHRNBridge.h"
#import "ESLoginAPI.h"
#import "ESLoginManager.h"
#import "UserRO.h"

#import "Masonry.h"
#import "CoStringManager.h"
#import "UserManager.h"

@interface SHRNViewController ()
@property (nonatomic,strong)    UIButton *backBtn;
@property (nonatomic,strong)    ESLoginChoiceView *loginChoiceView;
@property (nonatomic,strong)    ESLoginWithAccountView *loginWithAccountView;
@property (nonatomic,copy)    NSString *phone;
///登录的错误次数，错误五次将会出现图片验证码
@property (nonatomic,assign)    NSInteger errLoginCount;
@end

@implementation SHRNViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.errLoginCount = 0;
  
    self.phone = [[NSUserDefaults standardUserDefaults] objectForKey:@"Account"];
    if ([CoStringManager isEmptyString:self.phone]) {
        [self createUIView];
    }else {
        [self createUIViewWithAccount];
    }
    
    

    [self.view addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(5);
        make.top.equalTo(self.view).offset(STATUSBAR_HEIGHT);
        make.width.mas_offset(60);
        make.height.mas_offset(60);
    }];
}

#pragma mark --- private method
- (void)createUIView {
    [self.view addSubview:self.loginChoiceView];
    [self.backBtn setImage:[UIImage imageNamed:@"master_leftArrow"] forState:UIControlStateNormal];
}

- (void)createUIViewWithAccount {
    [self.view addSubview:self.loginWithAccountView];
    [self.backBtn setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
}
//记录登录错误次数
- (void)countErrNumber {
    self.errLoginCount += 1;
    if (self.errLoginCount == 5) {
        [self.loginWithAccountView addCaptcha];
    }
}
//返回
- (void)backToSuper {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
//登录事件
- (void)loginAction {
    [self.view endEditing:YES];
    
    [ESMBProgressToast showToastAddTo:self.loginWithAccountView];
    
//    if (![ConfigManager isFromDIY]) {
        [ESLoginAPI loginUserName:self.phone password:self.loginWithAccountView.passwordText loginImageCodeKey:self.loginWithAccountView.loginImageCodeKey userLoginImageCodeValue:self.loginWithAccountView.captcha andSuccess:^(NSDictionary *dictionary) {
            [ESMBProgressToast hideToastForView:self.loginWithAccountView];
            [ESMBProgressToast showToastAddTo:self.loginWithAccountView text:@"登录成功"];
            SHLog(@"登录 成功 %@",dictionary);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kHomePageReloadNotification object:nil];
            [[ESLoginManager sharedManager] loginComplete:dictionary];
            [[NSUserDefaults standardUserDefaults] setObject:self.phone forKey:@"Account"];
            [self performSelectorInBackground:@selector(SSOLoginAction:) withObject:dictionary[@"accessToken"]];
            
            
        } andFailure:^(NSError *error) {
            [ESMBProgressToast hideToastForView:self.loginWithAccountView];
            NSString *text = [ESLoginAPI errMessge:error];
            [ESMBProgressToast showToastAddTo:self.loginWithAccountView text:text];
            SHLog(@"登录 error结果 %@",error);
            
            [self countErrNumber];
            
        }];
//    }else{
//        [[UserManager sharedInstance]
//         userLoginWithPhone:self.phone withPass:self.loginWithAccountView.passwordText withToken:nil completionBlock:^(id serverResponse, id error) {
//             [ESMBProgressToast hideToastForView:self.loginWithAccountView];
//             if (!error) {
//                 SHLog(@"%@",serverResponse);
//                 [[NSUserDefaults standardUserDefaults] setObject:self.phone forKey:@"Account"];
//                 [ESMBProgressToast showToastAddTo:self.loginWithAccountView text:@"登录成功"];
//                 [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//             }else{
//                 SHLog(@"%@",error);
//                 [ESMBProgressToast showToastAddTo:self.loginWithAccountView text:error];
//             }
//         } queue:dispatch_get_main_queue()];
//    }
}
- (void)SSOLoginAction:(NSString *)accessToken {
    [[UserRO new] userLoginWithSSO:accessToken completionBlock:^(id serverResponse) {
        UserDO * respUser=(UserDO*)serverResponse;
        
        if ( respUser.errorCode==-1) {
            [UserManager sharedInstance].currentUser = respUser;
            [[UserManager sharedInstance] currentUser].usertype=kUserTypePhone;
            [[UserManager sharedInstance] currentUser].userPhone = self.phone;
            [[UserManager sharedInstance] currentUser].userPassword = self.loginWithAccountView.passwordText;
            [[UserManager sharedInstance] currentUser].umsToken = accessToken;

            [[UserManager sharedInstance] saveCurrentUserInfo];
            
            [[UserManager sharedInstance] postLoginActionsWithQueue:dispatch_get_main_queue()];
            
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    } failureBlock:^(NSError *error) {
        SHLog(@"%@",error);
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } queue:dispatch_get_main_queue()];
}
#pragma mark --- 懒加载
- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"master_leftArrow"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backToSuper) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}
- (ESLoginChoiceView *)loginChoiceView {
    if (!_loginChoiceView) {
        _loginChoiceView = [[ESLoginChoiceView alloc] init];
        _loginChoiceView.frame = self.view.frame;
    }
    return _loginChoiceView;
}
- (ESLoginWithAccountView *)loginWithAccountView {
    if (!_loginWithAccountView) {
        _loginWithAccountView = [[ESLoginWithAccountView alloc] init];
        _loginWithAccountView.frame = self.view.frame;
        _loginWithAccountView.backgroundColor = [UIColor whiteColor];
        
        WS(weakSelf)
        _loginWithAccountView.bottomBtnClickBlock = ^{
            [weakSelf loginAction];
        };
    }
    return _loginWithAccountView;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
