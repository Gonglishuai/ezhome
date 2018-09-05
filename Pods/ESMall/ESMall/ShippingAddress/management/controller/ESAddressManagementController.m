//
//  ESAddressManagementController.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/28.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESAddressManagementController.h"
#import "ESAddressManagementView.h"
#import "ESAddressManagementViewModel.h"
#import "MBProgressHUD.h"
#import "ESEditAddressController.h"
#import <ESNetworking/SHAlertView.h>

@interface ESAddressManagementController ()<ESAddressManagementViewDelegate>

@property (nonatomic, strong) ESAddressManagementView *mainView;
@property (nonatomic, strong) NSMutableArray <ESAddress *>* addrData;

@end

@implementation ESAddressManagementController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    
    self.titleLabel.text = @"收货地址管理";
    self.rightButton.hidden = YES;
    
    self.mainView = [[ESAddressManagementView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBAR_HEIGHT)];
    self.mainView.delegate = self;
    [self.view addSubview: self.mainView];
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.mainView startFreshHeaderView];
}

#pragma mark - Data
// 获取地址列表
- (void)retrieveData {
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:self.mainView animated:YES];
    [ESAddressManagementViewModel retrieveAddressListWithSuccess:^(NSArray<ESAddress *> *addresses) {
        [MBProgressHUD hideHUDForView:weakSelf.mainView animated:YES];
        [weakSelf.mainView stopFreshHeaderView];
        weakSelf.addrData = [NSMutableArray arrayWithArray:addresses];
        [weakSelf.mainView setNewAddressButtonVisible:YES];
        if (weakSelf.addrData.count <= 0) {
            [weakSelf.mainView refreshMainView];
            [weakSelf showEmptyView];
            return;
        }
        
        [weakSelf removeNoDataView];
        [weakSelf.mainView refreshMainView];
    } andFailure:^(NSString *msg) {
        [MBProgressHUD hideHUDForView:weakSelf.mainView animated:YES];
        [weakSelf.mainView stopFreshHeaderView];
        [weakSelf showErrorView];
    }];
}

- (void)showEmptyView {
    CGRect frame = CGRectMake(0, 0, self.mainView.frame.size.width, self.mainView.frame.size.height - 49);
    [self showNoDataIn:self.mainView imgName:@"location" frame:frame Title:@"还没有收货地址呢~\n点击下方按钮新增" buttonTitle:nil Block:nil];
}

- (void)showErrorView {
    WS(weakSelf);
    [self removeNoDataView];
    NSString *title = [NSString stringWithFormat:@"网络有问题\n刷新一下试试吧"];
    [self showNoDataIn:self.mainView imgName:@"nodata_net" frame:CGRectMake(0, 0, self.mainView.frame.size.width, self.mainView.frame.size.height) Title:title buttonTitle:@"刷新" Block:^{
        [weakSelf retrieveData];
    }];
}

#pragma mark - Override
- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ESAddressManagementViewDelegate
- (NSInteger)getAddressNums {
    if (self.addrData) {
        return self.addrData.count;
    }
    return 0;
}

- (void)addNewAddress {
    if (self.addrData.count >= 10) {
        [self showSuccessHUD:@"收货地址最多10个哦～"];
        return;
    }
    ESEditAddressController *vc = [[ESEditAddressController alloc] initWithAddress:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)refreshLoadNewData {
    [self retrieveData];
}

#pragma mark - ESAddressManagementCellDelegate
- (NSString *)getAddressName:(NSInteger)index {
    return [ESAddressManagementViewModel getAddressNameFromArray:self.addrData withIndex:index];
}

- (NSString *)getAddressPhone:(NSInteger)index {
    return [ESAddressManagementViewModel getAddressPhoneFromArray:self.addrData withIndex:index];
}

- (NSString *)getAddressDetail:(NSInteger)index {
    return [ESAddressManagementViewModel getAddressDetailFromArray:self.addrData withIndex:index];
}

- (BOOL)isDefaultAddress:(NSInteger)index {
    return [ESAddressManagementViewModel isDefaultAddressFromArray:self.addrData withIndex:index];
}

- (void)setDefaultAddress:(NSInteger)index {
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:self.mainView animated:YES];
    [ESAddressManagementViewModel setDefaultAddressFromArray:self.addrData withIndex:index withSuccess:^{
        [MBProgressHUD hideHUDForView:weakSelf.mainView animated:YES];
//        [weakSelf showSuccessHUD:@"设置成功"];
        [weakSelf.mainView refreshMainView];
    } andFailure:^{
        [MBProgressHUD hideHUDForView:weakSelf.mainView animated:YES];
        [weakSelf showSuccessHUD:@"网络错误，请稍后重试!"];
    }];
}

- (void)editAddress:(NSInteger)index {
    ESAddress *address = [ESAddressManagementViewModel getAddressFromArray:self.addrData withIndex:index];
    if (address) {
        ESEditAddressController *vc = [[ESEditAddressController alloc] initWithAddress:address];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)deleteAddress:(NSInteger)index {
    WS(weakSelf);
    [SHAlertView showAlertWithTitle:@"提示" message:@"确定删除该收货地址吗?" sureKey:^{
        [MBProgressHUD showHUDAddedTo:weakSelf.mainView animated:YES];
        [ESAddressManagementViewModel deleteAddressFromArray:weakSelf.addrData withIndex:index withSuccess:^(BOOL shouldRefresh){
            [MBProgressHUD hideHUDForView:weakSelf.mainView animated:YES];
            [weakSelf showSuccessHUD:@"删除成功"];
            [weakSelf.mainView deleteAddressWithIndex:index];
            if (weakSelf.addrData.count == 0) {
                [weakSelf showEmptyView];
            }else {
                if (shouldRefresh) {
                    [weakSelf.mainView startFreshHeaderView];
                }
            }
        } andFailure:^{
            [MBProgressHUD hideHUDForView:weakSelf.mainView animated:YES];
            [weakSelf showSuccessHUD:@"网络错误，请稍后重试!"];
        }];
    } cancelKey:nil];
}

#pragma mark - Custom Method
- (void)showSuccessHUD:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
//    hud.labelText = message;
    hud.label.text = message;
    hud.margin = 30.f;
//    hud.yOffset = 0;
    [hud setOffset:CGPointMake(hud.offset.x, 0)];
    hud.removeFromSuperViewOnHide = YES;
//    [hud hide:YES afterDelay:1.5];
    [hud hideAnimated:YES afterDelay:1.5];
}
@end
