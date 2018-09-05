//
//  ESRecViewController.m
//  demo
//
//  Created by shiyawei on 12/4/18.
//  Copyright © 2018年 hu. All rights reserved.
//

#import "ESRecViewController.h"

#import "ESRecDetailDescreptionViewController.h"
#import "ESRecSuccessViewController.h"

#import "ESRecNameCell.h"
#import "ESRecDetailAddressCell.h"
#import "ESRecAddressCell.h"
#import "ESCityPickerView.h"
#import <MBProgressHUD.h>

#import "ESRecommendAPI.h"
#import "ESCaseShareModel.h"
#import "ESRecommendShareCustomer.h"

#import "MTPFormCheck.h"

@interface ESRecViewController ()<UITableViewDelegate,UITableViewDataSource,ESRecNameCellDelegate,ESRecDetailAddressCellDelegate,ESCityPickerViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong)    UITableView *mTableView;
@property (nonatomic,strong)    UIButton *recIntroBtn;//推荐说明
@property (nonatomic,strong)    UIButton *sendBtn;
@property (nonatomic,copy)    NSString *phoneNumber;
@property (nonatomic,strong)    ESCityPickerView *cityPickView;

@property (nonatomic,strong)    ESRecommendShareCustomer *customer;
    
@property (nonatomic,weak)    ESRecAddressCell *addressCell;

@end

@implementation ESRecViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ColorFromRGA(0xF9F9F9, 1.0);
    
    self.titleLabel.text = @"推荐分享";
    self.rightButton.hidden = YES;
    self.leftButton.hidden = NO;
    
    self.customer = [[ESRecommendShareCustomer alloc] init];
    
    
    [self createUIView];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)tapOnLeftButton:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark  --- UITableViewDelegate,UITableViewDataSource ------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        return 130;
    }
    return 50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        ESRecNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESRecNameCell" forIndexPath:indexPath];
        cell.cellType = ESRecNameCellTypeName;
        cell.delegate = self;
        return cell;
    }else if (indexPath.row == 1) {
        ESRecNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESRecPhoneCell" forIndexPath:indexPath];
        cell.cellType = ESRecNameCellTypePhoneNumber;
        cell.delegate = self;
        return cell;
    }else if (indexPath.row == 2) {
        ESRecAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESRecAddressCell" forIndexPath:indexPath];
        self.addressCell = cell;
        return cell;
    }
    ESRecDetailAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESRecDetailAddressCell" forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {//地址选择
        [self.view endEditing:YES];
        
        [self.cityPickView showPickView];
    }
}
#pragma mark ---- ESRecNameCellDelegate ----
- (void)esRecNameCell:(ESRecNameCell *)cell cellType:(ESRecNameCellType)cellType reminder:(NSString *)reminder {
    [self showAleartWithTitle:reminder];
}
- (void)esRecNameCell:(ESRecNameCell *)cell name:(NSString *)name {
    
    self.customer.name = name;
}
- (void)esRecNameCell:(ESRecNameCell *)cell phoneNumber:(NSString *)phoneNumber {
    
    self.customer.phone = phoneNumber;
    if (![phoneNumber isEqualToString:self.phoneNumber]) {
        [self checkThePhoneNumber];
    }
    self.phoneNumber = phoneNumber;
    
}
#pragma mark ---- ESRecDetailAddressCellDelegate ----
- (void)esRecDetailAddressCell:(ESRecDetailAddressCell *)cell didEndEditing:(NSString *)detailAddress {
    self.customer.detailAddress = detailAddress;
}
#pragma mark ---- ESCityPickerViewDelegate
- (void)esCityPickerView:(ESCityPickerView *)pickerView didSelectedArea:(ESRecommendShareCustomer *)customerArea {
    self.customer.province = customerArea.province;
    self.customer.provinceName = customerArea.provinceName;
    self.customer.city = customerArea.city;
    self.customer.cityName = customerArea.cityName;
    self.customer.district = customerArea.district;
    self.customer.districtName = customerArea.districtName;
    
    self.addressCell.address = [NSString stringWithFormat:@"%@ %@ %@",customerArea.provinceName,customerArea.cityName,customerArea.districtName];
    if (customerArea.district == nil || customerArea.district.length == 0 ) {
        self.addressCell.address = [NSString stringWithFormat:@"%@ %@",customerArea.provinceName,customerArea.cityName];
    }
    if (customerArea.city == nil || customerArea.city.length == 0 ) {
        self.addressCell.address = [NSString stringWithFormat:@"%@",customerArea.provinceName];
    }
    
}
#pragma mark ---- UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(nonnull UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {//判断点击的是tableView的cell，就把手势给关闭了
        return NO;//关闭手势
    }//否则手势存在
    return YES;
}
#pragma mark ---- Private Method----------
#pragma mark 推荐说明
- (void)showRecommendDetail {
    [self.view endEditing:YES];
    ESRecDetailDescreptionViewController *recDetailVC = [[ESRecDetailDescreptionViewController alloc] init];
    [self.navigationController presentViewController:recDetailVC animated:YES completion:nil];
}
#pragma mark --- 校验手机号是否为平台用户
- (void)checkThePhoneNumber {
    [ESRecommendAPI postCheckPhoneNumberIsUser:self.customer.phone withSuccess:^(NSDictionary *dict) {
//        NSString *msg = [dict valueForKey:@"msg"];
        [self showAleartWithTitle:@"该手机号尚未注册，发送成功后将自动为用户注册设计家账号。"];
    } andFailure:^(NSError *error) {
        NSDictionary *dic = error.userInfo;
        NSData *data = [dic objectForKey:@"com.alamofire.serialization.response.error.data"];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"dict");
    }];
}
#pragma mark 发送
- (void)sendUserInfo {
    [self.view endEditing:YES];
    
    if (self.customer.name.length == 0 || self.customer.name == nil || [self.customer.name isKindOfClass:[NSNull class]]) {//业主姓名不能为空
        [self showAleartWithTitle:@"请输入客户姓名"];
        return;
    }
    if (self.customer.phone.length == 0 || self.customer.phone == nil || [self.customer.phone isKindOfClass:[NSNull class]]) {//业主手机号不能为空
        [self showAleartWithTitle:@"请输入客户手机号码"];
        return;
    }else {//校验手机号格式
        if (![MTPFormCheck chectMobile:self.customer.phone]) {
            [self showAleartWithTitle:@"手机号码格式不正确"];
        }
    }
    if (self.customer.province.length == 0 || self.customer.province == nil || [self.customer.province isKindOfClass:[NSNull class]]) {//请选择省市区不能为空
        [self showAleartWithTitle:@"请选择省市区"];
        return;
    }
    if (self.customer.detailAddress.length == 0 || self.customer.detailAddress == nil || [self.customer.detailAddress isKindOfClass:[NSNull class]]) {//详细地址不能为空
        [self showAleartWithTitle:@"请输入详细地址"];
        return;
    }

    if (self.baseId == nil || [self.baseId isEqualToNumber:@0]) {//未获取到详情ID
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.customer.name forKey:@"name"];
    [dict setObject:self.customer.phone forKey:@"phone"];
    [dict setValue:self.customer.province forKey:@"province"];
    [dict setValue:self.customer.provinceName forKey:@"provinceName"];
    [dict setValue:self.customer.city forKey:@"city"];
    [dict setValue:self.customer.cityName forKey:@"cityName"];
    [dict setValue:self.customer.district forKey:@"district"];
    [dict setValue:self.customer.districtName forKey:@"districtName"];
    [dict setValue:self.customer.detailAddress forKey:@"detailAddress"];
    
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setObject:self.sourceType forKey:@"sourceType"];//资源类型 10:3D案例 20:商品清单 30:品牌清单 ,
    [body setObject:self.baseId forKey:@"baseId"];
    [body setObject:dict forKey:@"customer"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.sendBtn.userInteractionEnabled = NO;
    [ESRecommendAPI postRecommendShareDictionary:body withSuccess:^(NSDictionary *dict) {
        SHLog(@"请求结果 %@",dict);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.sendBtn.userInteractionEnabled = YES;
        ESRecSuccessViewController *recSuccessVC = [[ESRecSuccessViewController alloc] init];
        recSuccessVC.shareModel = self.sharedModel;
        [self.navigationController pushViewController:recSuccessVC animated:YES];
    } andFailure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.sendBtn.userInteractionEnabled = YES;
        NSDictionary *dic = error.userInfo;
        NSData *data = [dic objectForKey:@"com.alamofire.serialization.response.error.data"];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        [self showAleartWithTitle:@"发送失败"];
        SHLog(@"请求结果error =  %@",dictionary);
    }];
    
}
#pragma mark --- 提醒----需要抽离
- (void)showAleartWithTitle:(NSString *)title{
    UIWindow *window  = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabel.text = title;
    hud.margin = 30.f;
    [hud setOffset:CGPointMake(hud.offset.x, 0)];
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1];
    
}
#pragma mark --- 创建UI控件
- (void)createUIView {
    [self.view addSubview:self.mTableView];
    [self.mTableView addSubview:self.recIntroBtn];
    [self.view addSubview:self.sendBtn];
}

- (void)didTapView {
    [self.view endEditing:YES];
}
#pragma mark ---  懒加载 -----
- (UITableView *)mTableView {
    if (!_mTableView) {
        
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,NAVBAR_HEIGHT + 10, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) style:UITableViewStylePlain];
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        _mTableView.backgroundColor = self.view.backgroundColor;
        _mTableView.scrollEnabled = NO;
        _mTableView.tableFooterView = [UIView new];
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView)];
        tap.delegate = self;
        [_mTableView addGestureRecognizer:tap];
        
        [_mTableView registerClass:[ESRecNameCell class] forCellReuseIdentifier:@"ESRecNameCell"];
        [_mTableView registerClass:[ESRecNameCell class] forCellReuseIdentifier:@"ESRecPhoneCell"];
        [_mTableView registerClass:[ESRecAddressCell class] forCellReuseIdentifier:@"ESRecAddressCell"];
        [_mTableView registerClass:[ESRecDetailAddressCell class] forCellReuseIdentifier:@"ESRecDetailAddressCell"];
        
        
        
    }
    return _mTableView;
}
- (UIButton *)recIntroBtn {
    if (!_recIntroBtn) {
        _recIntroBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recIntroBtn addTarget:self action:@selector(showRecommendDetail) forControlEvents:UIControlEventTouchUpInside];
        [_recIntroBtn setTitle:@"推荐说明" forState:UIControlStateNormal];
        _recIntroBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_recIntroBtn setTitleColor:ColorFromRGA(0x4E9BD6, 1.0) forState:UIControlStateNormal];//#4E9BD6 100%
        _recIntroBtn.frame = CGRectMake((SCREEN_WIDTH - 100) / 2, 300, 100, 30);
    }
    return _recIntroBtn;
}
- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setTitle:@"发送给客户" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_sendBtn addTarget:self action:@selector(sendUserInfo) forControlEvents:UIControlEventTouchUpInside];
        _sendBtn.frame = CGRectMake(0, SCREEN_HEIGHT - TABBAR_HEIGHT - BOTTOM_SAFEAREA_HEIGHT, SCREEN_WIDTH, TABBAR_HEIGHT + BOTTOM_SAFEAREA_HEIGHT);
        _sendBtn.backgroundColor = ColorFromRGA(0x4E9BD6, 1.0);//#4E9BD6 100%
    }
    return _sendBtn;
}
- (ESCityPickerView *)cityPickView {
    if (!_cityPickView) {
        _cityPickView = [[ESCityPickerView alloc] init];
        _cityPickView.frame = self.view.frame;
        _cityPickView.delegate = self;
        [self.view addSubview:_cityPickView];
    }
    return _cityPickView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


@end
