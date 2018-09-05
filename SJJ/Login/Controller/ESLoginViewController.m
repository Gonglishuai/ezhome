//
//  ESLoginViewController.m
//  Homestyler
//
//  Created by shiyawei on 25/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESLoginViewController.h"
#import "ESRegisterViewController.h"

#import "ESHeaderView.h"
#import "ESAccountTableCell.h"
#import "ESPasswordCell.h"
#import "ESBottomTableCell.h"
#import "ESCaptchaTableCell.h"

#import "ESLoginAPI.h"
#import "ESLoginManager.h"
#import "UserRO.h"
#import "ESUserData.h"

#import "Masonry.h"
#import "UserManager.h"


@interface ESLoginViewController ()<UITableViewDelegate,UITableViewDataSource,ESAccountTableCellDelegate,ESPasswordCellDelegate,ESBottomTableCellDelegate,ESCaptchaTableCellDelegate>
@property (nonatomic,strong)    UITableView *tableView;
@property (nonatomic,strong)    ESHeaderView *headerView;
@property (nonatomic,weak)    ESBottomTableCell *bottomCell;

@property (nonatomic,assign)    BOOL accountEnable;
@property (nonatomic,assign)    BOOL passwordEnable;
@property (nonatomic,assign)    BOOL captchaEnable;

@property (nonatomic,assign)    NSInteger rowNumber;
@property (nonatomic,assign)    NSInteger errLoginCount;

@property (nonatomic,copy)    NSString *account;//账号
@property (nonatomic,copy)    NSString *password;//密码
@property (nonatomic,copy)    NSString *captcha;//图片验证码
@property (nonatomic,copy)    NSString *imageRandomCodeKey;//图片验证码的Key
@end

@implementation ESLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.rowNumber = 3;
    self.errLoginCount = 0;
    
    
    self.headerView.signInType = ESSignInTypeLoginWitRegister;
    [self createUIView];
}



- (void)setBottomBtnStyle:(ESBottomBtnStyle)bottomBtnStyle {
    _bottomBtnStyle = bottomBtnStyle;
    
}

#pragma mark --- private method
- (void)createUIView {
    [self.view addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(80);
        make.left.mas_offset(0);
        make.right.mas_offset(0);
        make.height.mas_offset(120);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom).offset(15);
        make.height.mas_offset(250);
        make.left.mas_offset(25);
        make.right.mas_offset(-25);
    }];
}

//计算登录失败次数
- (void)countErrLoginTime {
    self.errLoginCount += 1;
    if (self.errLoginCount == 5) {
        self.rowNumber = 4;
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(300);
        }];
        
        [self.tableView reloadData];
        [self resetBottomStyle];
    }
    
}
- (void)SSOLoginAction:(NSString *)accessToken {
    [[UserRO new] userLoginWithSSO:accessToken completionBlock:^(id serverResponse) {
        UserDO * respUser=(UserDO*)serverResponse;
        
        if ( respUser.errorCode==-1) {
            [UserManager sharedInstance].currentUser = respUser;
            [[UserManager sharedInstance] currentUser].usertype=kUserTypePhone;
            [[UserManager sharedInstance] currentUser].userPhone = self.account;
            [[UserManager sharedInstance] currentUser].userPassword = self.password;
            [[UserManager sharedInstance] currentUser].umsToken = accessToken;
            
            [[UserManager sharedInstance] saveCurrentUserInfo];
            
            [[UserManager sharedInstance] postLoginActionsWithQueue:dispatch_get_main_queue()];
            
        }
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } failureBlock:^(NSError *error) {
        SHLog(@"%@",error);
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } queue:dispatch_get_main_queue()];
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
    if (indexPath.row == 0) {
        ESAccountTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESAccountTableCell" forIndexPath:indexPath];
        cell.delegate = self;
        return cell;
    }else if (indexPath.row == 1){
        ESPasswordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESPasswordCell" forIndexPath:indexPath];
        cell.delegate = self;
        cell.isCreateEyeBtn = NO;
        return cell;
    }else if (indexPath.row == self.rowNumber - 1){
        ESBottomTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESBottomTableCell" forIndexPath:indexPath];
        cell.delegate = self;
        cell.bottomBtnStyle = self.bottomBtnStyle;
        self.bottomCell = cell;
        return cell;
    }else {
        ESCaptchaTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESCaptchaTableCell" forIndexPath:indexPath];
        cell.delegate = self;
        cell.pageType = ESRegisterPageTypeLogin;
        cell.isShowIndicatorView = YES;
        return cell;
    }
}

#pragma mark --- ESAccountTableCellDelegate
- (void)esAccountTableCell:(ESAccountTableCell *)cell textShouldChange:(BOOL)enable {
    self.accountEnable = enable;
    [self resetBottomStyle];
}
- (void)esAccountTableCell:(ESAccountTableCell *)cell textDidEndEditing:(NSString *)text {
    self.account = text;
}
#pragma mark --- ESPasswordCellDelegate
- (void)esPasswordCell:(ESPasswordCell *)cell textShouldChange:(BOOL)enable {
    self.passwordEnable = enable;
    [self resetBottomStyle];
}
- (void)esPasswordCell:(ESPasswordCell *)cell textDidEndEditing:(NSString *)text {
    self.password = text;
}
#pragma mark --- ESCaptchaTableCellDelegate
- (void)esCaptchaTableCell:(ESCaptchaTableCell *)cell textShouldChange:(BOOL)enable {
    self.captchaEnable = enable;
    [self resetBottomStyle];
}
- (void)esCaptchaTableCell:(ESCaptchaTableCell *)cell textDidEndEditing:(NSString *)text imageRandomCodeKey:(NSString *)imageRandomCodeKey {
    self.captcha = text;
    self.imageRandomCodeKey = imageRandomCodeKey;
}
#pragma mark --- ESBottomTableCellDelegate
//登录事件
- (void)registerBtnAction {
    [self.view endEditing:YES];
    
    [ESMBProgressToast showToastAddTo:self.view];
    
//    if (![ConfigManager isFromDIY]) {
        [ESLoginAPI loginUserName:self.account password:self.password loginImageCodeKey:self.imageRandomCodeKey userLoginImageCodeValue:self.captcha andSuccess:^(NSDictionary *dictionary) {
            [ESMBProgressToast hideToastForView:self.view];
            [ESMBProgressToast showToastAddTo:self.view text:@"登录成功"];
            SHLog(@"登录 成功 %@",dictionary);
            [[NSNotificationCenter defaultCenter] postNotificationName:kHomePageReloadNotification object:nil];
            [[ESLoginManager sharedManager] loginComplete:dictionary];
            [[NSUserDefaults standardUserDefaults] setObject:self.account forKey:@"Account"];

            [self performSelectorInBackground:@selector(SSOLoginAction:) withObject:dictionary[@"accessToken"]];
            
            
            
        } andFailure:^(NSError *error) {
            [ESMBProgressToast hideToastForView:self.view];
            NSString *text = [ESLoginAPI errMessge:error];
            [ESMBProgressToast showToastAddTo:self.view text:text];
            SHLog(@"登录 error结果 %@",error);
            
            [self countErrLoginTime];
        }];
//    }else{
//        [[UserManager sharedInstance]
//         userLoginWithPhone:self.account withPass:self.password withToken:nil completionBlock:^(id serverResponse, id error) {
//             [ESMBProgressToast hideToastForView:self.view];
//             if (!error) {
//                 NSLog(@"%@",serverResponse);
//
//                 [[NSUserDefaults standardUserDefaults] setObject:self.account forKey:@"Account"];
//                 [ESMBProgressToast showToastAddTo:self.view text:@"登录成功"];
//                 [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//             }else{
//                 NSLog(@"%@",error);
//                 [ESMBProgressToast showToastAddTo:self.view text:error];
//             }
//         } queue:dispatch_get_main_queue()];
//    }
}
//进入注册
- (void)esBottomTableCellBottomLeftBtnAction {
    ESRegisterViewController *registerVC = [[ESRegisterViewController alloc] init];
    registerVC.pageType = ESRegisterPageTypeCreate;
    registerVC.titleName = @"注册";
    [self.navigationController pushViewController:registerVC animated:YES];
}
//找回密码流程
- (void)getBackPasswordAction {
    ESRegisterViewController *registerVC = [[ESRegisterViewController alloc] init];
    registerVC.pageType = ESRegisterPageTypeFind;
    registerVC.titleName = @"找回密码";
    [self.navigationController pushViewController:registerVC animated:YES];
}
#pragma mark --- private method
//重置登录按钮状态
- (void)resetBottomStyle {
    if (self.errLoginCount == 5) {
        if (self.accountEnable && self.passwordEnable && self.captchaEnable) {
            [self.bottomCell resetBottomStyle:YES];
        }else {
            [self.bottomCell resetBottomStyle:NO];
        }
    }else {
        if (self.accountEnable && self.passwordEnable) {
            [self.bottomCell resetBottomStyle:YES];
        }else {
            [self.bottomCell resetBottomStyle:NO];
        }
    }
    
}

#pragma mark --- 懒加载
- (ESHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[ESHeaderView alloc] init];
    }
    return _headerView;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.scrollEnabled = NO;
        _tableView.backgroundColor = self.view.backgroundColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[ESPasswordCell class] forCellReuseIdentifier:@"ESPasswordCell"];
        [_tableView registerClass:[ESAccountTableCell class] forCellReuseIdentifier:@"ESAccountTableCell"];
        [_tableView registerClass:[ESBottomTableCell class] forCellReuseIdentifier:@"ESBottomTableCell"];
        [_tableView registerClass:[ESCaptchaTableCell class] forCellReuseIdentifier:@"ESCaptchaTableCell"];
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
