//
//  ESSelectAddressController.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/27.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESSelectAddressController.h"
#import "ESSelectAddressView.h"
#import "ESSelectAddrViewModel.h"
#import "ESAddressManagementController.h"
#import "ESEditAddressController.h"
#import "MBProgressHUD.h"

@interface ESSelectAddressController ()<ESSelectAddressViewDelegate>

@property (nonatomic, strong) ESSelectAddressView *mainView;
@property (nonatomic, strong) NSString *selectedAddrId;
@property (nonatomic, strong) NSArray <ESSelectAddresses *>* addrData;
@property (nonatomic, copy) void(^backBlock)(ESAddress *);
@end

@implementation ESSelectAddressController

- (instancetype)initWithAddressID: (NSString *)addressId withSelectedAddress:(void (^)(ESAddress *))address{
    self = [super init];
    if (self) {
        self.selectedAddrId = addressId;
        self.backBlock = address;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    
    self.titleLabel.text = @"选择收货地址";
    [self.rightButton setImage:nil forState:UIControlStateNormal];
    [self.rightButton setTitle:@"管理" forState:UIControlStateNormal];
    [self.rightButton setTitleColor:ColorFromRGA(0x2D2D34, 1) forState:UIControlStateNormal];
    
    self.mainView = [[ESSelectAddressView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBAR_HEIGHT)];
    self.mainView.delegate = self;
    [self.view addSubview: self.mainView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.mainView startFreshHeaderView];

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

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    ESAddress *address = [ESSelectAddrViewModel getAddressWithId:self.selectedAddrId fromArray:self.addrData];
    self.backBlock(address);
    return YES;
}

#pragma mark - Data
// 获取地址列表
- (void)retrieveData {
    WS(weakSelf);
    [ESSelectAddrViewModel retrieveAddressListWithSuccess:^(NSArray <ESSelectAddresses *> *addressArray) {
        [weakSelf.mainView stopFreshHeaderView];
        weakSelf.addrData = addressArray;
        [weakSelf.mainView setNewAddressButtonVisible:YES];
        if (weakSelf.addrData.count <= 0) {
            [weakSelf.mainView refreshMainView];
            [weakSelf showEmptyView];
            return;
        }
        
        [weakSelf removeNoDataView];
        [weakSelf.mainView refreshMainView];
    } andFailure:^(NSString *msg) {
        [weakSelf.mainView stopFreshHeaderView];
    }];
}

#pragma mark - Override
- (void)tapOnLeftButton:(id)sender {
    ESAddress *address = [ESSelectAddrViewModel getAddressWithId:self.selectedAddrId fromArray:self.addrData];
    self.backBlock(address);
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)tapOnRightButton:(id)sender {
    ESAddressManagementController *vc = [[ESAddressManagementController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - ESSelectAddressViewDelegate
- (NSInteger)getAddressGroupNums {
    if (self.addrData) {
        return self.addrData.count;
    }
    return 0;
}

- (NSInteger)getAddressNumsWithSection:(NSInteger)section {
    return [ESSelectAddrViewModel getAddressNumsFromArray:self.addrData withSection:section];
}

- (BOOL)getAddressValidWithSection:(NSInteger)section {
    return [ESSelectAddrViewModel getAddressValidFromArray:self.addrData withSection:section];
}

- (void)selectAddressWithSection:(NSInteger)section
                       WithIndex:(NSInteger)index {
    ESAddress *selectedAddr = [ESSelectAddrViewModel getSelectedAddrFromArray:self.addrData
                                                                  withSection:section
                                                                    withIndex:index];
    self.backBlock(selectedAddr);
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - ESSelectAddressCellDelegate
- (NSString *)getAddressNameWithSection:(NSInteger)section
                               andIndex:(NSInteger)index {
    
    return [ESSelectAddrViewModel getAddressNameFromArray:self.addrData
                                              withSection:section
                                                withIndex:index];
}

- (NSString *)getAddressPhoneWithSection:(NSInteger)section
                                andIndex:(NSInteger)index {
    
    return [ESSelectAddrViewModel getAddressPhoneFromArray:self.addrData
                                               withSection:section
                                                 withIndex:index];
}

- (NSString *)getAddressDetailWithSection:(NSInteger)section
                                 andIndex:(NSInteger)index {
    
    return [ESSelectAddrViewModel getAddressDetailFromArray:self.addrData
                                                withSection:section
                                                  withIndex:index];
}

- (BOOL)isDefaultAddressWithSection:(NSInteger)section
                           andIndex:(NSInteger)index {
    
    return [ESSelectAddrViewModel isDefaultAddressFromArray:self.addrData
                                                withSection:section
                                                  withIndex:index];
}

- (BOOL)isSelectedAddressWithSection:(NSInteger)section
                            andIndex:(NSInteger)index {
    
    return [ESSelectAddrViewModel isSelectedAddressFromArray:self.addrData
                                                 withSection:section
                                                   withIndex:index
                                               andSelectedId:self.selectedAddrId];
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
