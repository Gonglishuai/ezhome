//
//  ESRegisterViewController.m
//  Homestyler
//
//  Created by shiyawei on 26/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESRegisterViewController.h"
#import "ESGetNoteCodeController.h"
#import "ESRegisterProtocolController.h"

#import "ESAccountTableCell.h"
#import "ESCaptchaTableCell.h"
#import "ESBottomTableCell.h"


#import "ESDeviceUtil.h"
#import "Masonry.h"

@interface ESRegisterViewController ()<UITableViewDelegate,UITableViewDataSource,ESCaptchaTableCellDelegate,ESAccountTableCellDelegate,ESBottomTableCellDelegate>
@property (nonatomic,strong)    UILabel *titleLabel;
@property (nonatomic,strong)    UITableView *tableView;
@property (nonatomic,strong)    ESBottomTableCell *bottomCell;
@property (nonatomic,assign)    BOOL accountIsEnable;
@property (nonatomic,assign)    BOOL captchaIsEnable;
@property (nonatomic,copy)    NSString *phone;
@property (nonatomic,copy)    NSString *code;
@property (nonatomic,assign)    ESSmsCodeType smsCodeType;
@property (nonatomic,strong)    UIButton *backBtn;
@end

@implementation ESRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.titleName;
    
    self.view.backgroundColor = [UIColor stec_whiteTextColor];
    [self createUIView];
    
}

- (void)setPageType:(ESRegisterPageType)pageType {
    _pageType = pageType;
    switch (pageType) {
        case ESRegisterPageTypeBing://绑定手机号
            self.title = @"绑定手机号";
            [self createBackBtn];
            break;
        case ESRegisterPageTypeFind://找回密码
            self.title = @"找回密码";
            self.smsCodeType = ESFind;
            break;
        case ESRegisterPageTypeCreate://注册
            self.title = @"注册";
            self.smsCodeType = ESCreate;
            break;
        default:
            break;
    }
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
        make.top.equalTo(self.titleLabel.mas_bottom).offset(40);
        make.height.mas_offset(250);
        make.left.mas_offset(25);
        make.right.mas_offset(-25);
    }];
}
- (void)createBackBtn {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backBtn];
//    [self.navigationItem addSubview:self.backBtn];
//    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.offset(STATUSBAR_HEIGHT + 15);
//        make.left.offset(15);
//        make.height.offset(30);
//        make.width.offset(30);
//    }];
}
- (void)resetBottomStyle {
    if (self.accountIsEnable && self.captchaIsEnable) {
        [self.bottomCell resetBottomStyle:YES];
    }else {
        [self.bottomCell resetBottomStyle:NO];
    }
    
}
- (void)backAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark --- UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        return 120;
    }else {
        return 50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        ESAccountTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESAccountTableCellR" forIndexPath:indexPath];
        cell.delegate = self;
        cell.keyBoardType = KeyboardTypeNumber;
        return cell;
    }else if (indexPath.row == 1) {
        ESCaptchaTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESCaptchaTableCellR" forIndexPath:indexPath];
        cell.delegate = self;
        cell.isShowIndicatorView = YES;
        return cell;
    }else {
        ESBottomTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESBottomTableCellR" forIndexPath:indexPath];
        cell.delegate = self;
        if (self.pageType == ESRegisterPageTypeCreate) {
            cell.bottomBtnStyle = ESBottomBtnStyleProtocol;
        }else {
            cell.bottomBtnStyle = ESBottomBtnStyleDefault;
        }
        
        self.bottomCell = cell;
        return cell;
    }
}
#pragma mark --- ESAccountTableCellDelegate
- (void)esAccountTableCell:(ESAccountTableCell *)cell textShouldChange:(BOOL)enable {
    self.accountIsEnable = enable;
    [self resetBottomStyle];
}
- (void)esAccountTableCell:(ESAccountTableCell *)cell textDidEndEditing:(NSString *)text {
    self.phone = text;
}
#pragma mark --- ESCaptchaTableCellDelegate
- (void)esCaptchaTableCell:(ESCaptchaTableCell *)cell textShouldChange:(BOOL)enable {
    self.captchaIsEnable = enable;
    [self resetBottomStyle];
}
- (void)esCaptchaTableCell:(ESCaptchaTableCell *)cell textDidEndEditing:(NSString *)text imageRandomCodeKey:(NSString *)imageRandomCodeKey{
    self.code = text;
}

#pragma mark --- ESBottomTableCellDelegate
//校验图片验证码
- (void)registerBtnAction {
    
    [self.view endEditing:YES];
    
    
    if (self.pageType == ESRegisterPageTypeBing) {
        [self loadBingData];//绑定
    }else {
        [self loadRegisterAndFigotData];//忘记密码
    }
    
    
    
}
//忘记密码
- (void)loadRegisterAndFigotData {
    [ESMBProgressToast showToastAddTo:self.view];
    [ESLoginAPI getSendSmsCode:self.smsCodeType Mobile:self.phone UUID:[ESDeviceUtil getUUID] Code:self.code andSuccess:^(NSDictionary *dict) {
        SHLog(@"dict %@",dict);
        [ESMBProgressToast hideToastForView:self.view];
        ESGetNoteCodeController *getNotCodeVC = [[ESGetNoteCodeController alloc] init];
        getNotCodeVC.pageType = self.pageType;
         getNotCodeVC.title = self.titleName;
        getNotCodeVC.phoneNumber = self.phone;
        [self.navigationController pushViewController:getNotCodeVC animated:YES];
        
    } andFailure:^(NSError *error) {
        [ESMBProgressToast hideToastForView:self.view];
        NSString *text = [ESLoginAPI errMessge:error];
        [ESMBProgressToast showToastAddTo:self.view text:text];
        SHLog(@"error %@",error);
    }];
}
//绑定
- (void)loadBingData {
    [ESMBProgressToast showToastAddTo:self.view];
    [ESLoginAPI sendSmsForBindMobile:self.phone andSuccess:^(NSDictionary *dict) {
        [ESMBProgressToast hideToastForView:self.view];
        SHLog(@"dict %@",dict);
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
        _titleLabel.text = @"请输入手机号";
        _titleLabel.font = [UIFont stec_packageTitleBigFount];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
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
        [_tableView registerClass:[ESCaptchaTableCell class] forCellReuseIdentifier:@"ESCaptchaTableCellR"];
        [_tableView registerClass:[ESAccountTableCell class] forCellReuseIdentifier:@"ESAccountTableCellR"];
        [_tableView registerClass:[ESBottomTableCell class] forCellReuseIdentifier:@"ESBottomTableCellR"];
    }
    return _tableView;
}
- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"navigation_back"];
        [_backBtn setImage:image forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        _backBtn.frame = CGRectMake(0, 0, 40, 40 *image.size.height / image.size.width);
        
    }
    return _backBtn;
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
