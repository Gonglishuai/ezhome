//
//  ESMakeSureNormalOrderController.m
//  Consumer
//
//  Created by jiang on 2017/7/11.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMakeSureNormalOrderController.h"

#import "ESMSNoAddressCell.h"
#import "ESMSAddressCell.h"
#import "ESMSTextFieldCell.h"
#import "ESLabelHeaderFooterView.h"
#import "ESOrderProductCell.h"
#import "ESClickCell.h"
#import "ESNoClickCell.h"
#import "ESMSPriceCell.h"
#import "ESSaleAgreementCell.h"
#import "ESMSGoldTableViewCell.h"
#import "ESOrderAPI.h"
#import "ESGrayTableViewHeaderFooterView.h"

#import "ESMSBar.h"
#import "ESProductDetailViewController.h"
#import "ESMakeSureInvoiceController.h"
#import "CoStringManager.h"

#import "ESSelectAddressController.h"
#import "ESAddress.h"
#import "ESPickerView.h"
#import "MBProgressHUD+NJ.h"
#import "ESAddrerssAPI.h"
#import "CoStringManager.h"
#import "ESSaleAgreementViewController.h"

#import "ESPayTimesViewController.h"
#import "ESPaySucessViewController.h"
#import <ESFoundation/UMengServices.h>
#import "SHRequestTool.h"
#import "ESMakeSureOrderGoodsPriceTableViewCell.h"
#import "ESGoldAlertView.h"
#import "MGJRouter.h"

@interface ESMakeSureNormalOrderController ()
<UITableViewDataSource,UITableViewDelegate,ESPickerViewDelegate,
ESSaleAgreementCellDelegate,ESSaleAgreementViewControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *datasSource;
@property (nonatomic,copy)    NSArray *pendingOrders;
@property (strong, nonatomic) NSMutableDictionary *updateDic;
@property (strong, nonatomic) NSMutableArray *invoiceArray;//已选发票
@property (strong, nonatomic) NSMutableArray *couponArray;//已选优惠券
@property (strong, nonatomic) NSMutableArray *selectServerStoreArray;//已选服务门店
@property (strong, nonatomic) NSMutableArray *serverStoreArray;//获取服务门店
@property (strong, nonatomic) NSMutableArray *serverStoreTitleArray;//获取服务门店名称
@property (strong, nonatomic) NSMutableArray *selectSaleAgreementArray;//已同意买卖协议
@property (strong, nonatomic) ESMSBar *orderBar;
@property (strong, nonatomic) ESPickerView *datePicker;
@property (strong, nonatomic) ESPickerView *storePicker;
@property (strong, nonatomic) NSIndexPath *selectIndexPath;
@property (strong, nonatomic) ESAddress *addressInfo;
@property (copy, nonatomic)   NSString *addressString;
@property (assign, nonatomic) CGRect keyboardFrame;

@property (copy, nonatomic)   NSString *canUseGoldsNum;//应付金额
@property (copy, nonatomic)   NSString *usedGoldsNum;//已填写装修基金
@property (nonatomic,assign)  ESMakeSureOrderType orderType;

@property (copy, nonatomic)   NSString *brandId;

@end

@implementation ESMakeSureNormalOrderController

#pragma mark - Init
- (instancetype)initViewControllerWithType:(ESMakeSureOrderType)orderType {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.orderType = orderType;
    }
    return self;
}
- (void)initData {
    _canUseGoldsNum = @"0";
    _usedGoldsNum = @"";
    _updateDic = [NSMutableDictionary dictionary];
    _serverStoreArray = [NSMutableArray array];
    _selectServerStoreArray = [NSMutableArray array];
    _serverStoreTitleArray = [NSMutableArray array];
    _selectSaleAgreementArray = [NSMutableArray array];
    _invoiceArray = [NSMutableArray array];
    _couponArray = [NSMutableArray array];
    _selectIndexPath = nil;
    _pendingOrders = [NSArray array];
    _addressString = @"您还没有收货地址，请先去添加哦~";
    if (self.orderType == ESMakeSureOrderTypeDoubleTwelve) {
        self.orderType = ESMakeSureOrderTypeDoubleTwelve;
    } else {
        self.orderType = ESMakeSureOrderTypeNormal;
    }
}

#pragma mark - Life Style
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"确认订单";
    self.rightButton.hidden = YES;
    [self initData];
    [self setTableView];
    [self initTableBar];
    [self setUpTableViewData];
    [self getDefaultAddress];
    [self addNotification];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Network
- (void)getDefaultAddress {//获取默认地址
    WS(weakSelf)
    NSString *region = [JRLocationServices sharedInstance].locationCityInfo.cityCode;
    [ESAddrerssAPI getOrderDefaultAddressWithRegionId:(region?region:@"") withSuccess:^(NSDictionary *dict) {
        NSString *addressId = [NSString stringWithFormat:@"%@", dict[@"addressId"]?dict[@"addressId"]:@""];
        if ([addressId isKindOfClass:[NSString class]] && (![addressId isEqualToString:@""])) {
            weakSelf.addressInfo = [ESAddress objFromDict:dict];
            [weakSelf.updateDic setObject:addressId forKey:@"addressId"];
        } else {
            weakSelf.addressInfo = nil;
            weakSelf.addressString = [NSString stringWithFormat:@"%@", dict[@"msg"]];
        }
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    } andFailure:^(NSError *error) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:error]]toView:weakSelf.view];
    }];
}

- (void)useGoldWithOrderId:(NSString *)pendingOrderId goldNum:(NSString *)goldNum indexPath:(NSIndexPath *)indexPath {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WS(weakSelf);
    [ESOrderAPI useGoldWithOrderId:pendingOrderId goldNum:goldNum Success:^(NSDictionary *dict) {
        [_orderBar setOrderInfo:dict isCustom:NO];
        weakSelf.usedGoldsNum = goldNum;
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    } failure:^(NSError *error) {
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:error]] toView:weakSelf.view];
    }];
}

- (void)addPendingCouponWithCouponId:(NSString *)couponId subOrderId:(NSString *)subOrderId indexPath:(NSIndexPath *)indexPath newCouponDic:(NSMutableDictionary *)newCouponDic{
    WS(weakSelf);
    [ESOrderAPI addPendingCouponWithCouponId:couponId SubOrderId:subOrderId Success:^(NSDictionary *dict) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (weakSelf.couponArray.count>indexPath.section-1) {
            [weakSelf.couponArray replaceObjectAtIndex:indexPath.section-1 withObject:newCouponDic];
        }
        [weakSelf.datasSource setValue:(dict[@"pendingAmount"]?dict[@"pendingAmount"]:@"") forKey:@"payAmount"];
        NSArray *arr = [weakSelf.datasSource objectForKey:@"pendingOrders"] ? [weakSelf.datasSource objectForKey:@"pendingOrders"] : [NSArray array];
        NSMutableArray *pendingOrders = [NSMutableArray arrayWithArray:arr];
        NSMutableDictionary *pendDic = [NSMutableDictionary dictionary];
        if (pendingOrders.count>indexPath.section-1) {
            pendDic = [NSMutableDictionary dictionaryWithDictionary:[pendingOrders objectAtIndex: indexPath.section-1]];
        }
        [pendDic setValue:(dict[@"pendingSubAmount"]?dict[@"pendingSubAmount"]:@"") forKey:@"payAmount"];
        
        if (pendingOrders.count>indexPath.section-1) {
            [pendingOrders replaceObjectAtIndex:indexPath.section-1 withObject:pendDic];
        }
        weakSelf.pendingOrders = [NSMutableArray arrayWithArray:pendingOrders];
        [weakSelf.datasSource setObject:pendingOrders forKey:@"pendingOrders"];
        
        NSString *payDiscount = [NSString stringWithFormat:@"%@", (dict[@"discountAmount"] ? dict[@"discountAmount"] : @"")];
        [weakSelf.datasSource setObject:payDiscount forKey:@"discountAmount"];

        [weakSelf.orderBar setOrderInfo:weakSelf.datasSource isCustom:NO];
        weakSelf.canUseGoldsNum = [NSString stringWithFormat:@"%@", dict[@"usedPointAmount"]?dict[@"usedPointAmount"]:@"0"];
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:pendingOrders.count+1] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSError *error) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:error]] toView:weakSelf.view];
    }];
}

- (void)deletePendingCouponWithCouponId:(NSString *)oldcouponId subOrderId:(NSString *)subOrderId newCouponDic:(NSMutableDictionary *)newCouponDic indexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
    [ESOrderAPI deletePendingCouponWithCouponId:oldcouponId SubOrderId:subOrderId Success:^(NSDictionary *dict) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (weakSelf.couponArray.count>indexPath.section-1) {
            [weakSelf.couponArray replaceObjectAtIndex:indexPath.section-1 withObject:newCouponDic];
        }
        [weakSelf.datasSource setValue:(dict[@"pendingAmount"]?dict[@"pendingAmount"]:@"") forKey:@"payAmount"];
        NSArray *arr = [weakSelf.datasSource objectForKey:@"pendingOrders"] ? [weakSelf.datasSource objectForKey:@"pendingOrders"] : [NSArray array];
        NSMutableArray *pendingOrders = [NSMutableArray arrayWithArray:arr];
        NSMutableDictionary *pendDic = [NSMutableDictionary dictionary];
        if (pendingOrders.count>indexPath.section-1) {
            pendDic = [NSMutableDictionary dictionaryWithDictionary:[pendingOrders objectAtIndex: indexPath.section-1]];
        }
        [pendDic setValue:(dict[@"pendingSubAmount"]?dict[@"pendingSubAmount"]:@"") forKey:@"payAmount"];
        if (pendingOrders.count>indexPath.section-1) {
            [pendingOrders replaceObjectAtIndex:indexPath.section-1 withObject:pendDic];
        }
        weakSelf.pendingOrders = [NSMutableArray arrayWithArray:pendingOrders];
        [weakSelf.datasSource setObject:pendingOrders forKey:@"pendingOrders"];
       
        NSString *payDiscount = [NSString stringWithFormat:@"%@", (dict[@"discountAmount"] ? dict[@"discountAmount"] : @"")];
        [weakSelf.datasSource setObject:payDiscount forKey:@"discountAmount"];

        [weakSelf.orderBar setOrderInfo:weakSelf.datasSource isCustom:NO];
        weakSelf.canUseGoldsNum = [NSString stringWithFormat:@"%@", dict[@"usedPointAmount"]?dict[@"usedPointAmount"]:@"0"];
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:pendingOrders.count+1] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSError *error) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:error]]toView:weakSelf.view];
    }];
}

- (void)refreshStorePickerViewWithSubOrderId:(NSString *)subOrderId {
    WS(weakSelf)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESOrderAPI getStoreListWithSubOrderId:subOrderId Success:^(NSDictionary *dict) {
        [weakSelf.serverStoreTitleArray removeAllObjects];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSArray *arr = (NSArray *)dict;
        [_serverStoreArray removeAllObjects];
        [_serverStoreArray addObjectsFromArray:arr];
        for (NSDictionary *dic in _serverStoreArray) {
            [weakSelf.serverStoreTitleArray addObject:dic[@"storeName"]];
        }
        if (weakSelf.serverStoreTitleArray.count > 0) {
            weakSelf.storePicker = [[ESPickerView alloc] initPickviewWithArray:_serverStoreTitleArray];
            [weakSelf.storePicker setPickViewColer:[UIColor whiteColor]];
            weakSelf.storePicker.delegate = self;
        }
        [weakSelf.storePicker show];
    } failure:^(NSError *error) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:error]]toView:weakSelf.view];
    }];
}
- (void)commitOrder {
    WS(weakSelf)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESOrderAPI placeOrderAppWithParamDic:_updateDic Success:^(NSDictionary *dict) {
        SHLog(@"跳转支付界面");
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSString *payOrderId = dict[@"data"] ? dict[@"data"] : @"";
        NSString *orderId = dict[@"orderId"] ? dict[@"orderId"] : @"";
        double pay = [[NSString stringWithFormat:@"%@", (dict[@"orderAmount"] ? dict[@"orderAmount"] : @"0.00")] doubleValue];
        NSString *factAccount = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%.2f",pay]];
        
        NSDictionary *loanDic = [NSDictionary dictionaryWithDictionary:([dict objectForKey:@"installment"] ? [dict objectForKey:@"installment"]:[NSDictionary dictionary])];
        
        if ([factAccount isEqualToString:@"0.00"]) {
            [weakSelf paySuccessWithOrderId:payOrderId payAmount:factAccount];
        } else {
            BOOL doubleTwelve = weakSelf.orderType == ESMakeSureOrderTypeDoubleTwelve ? NO:YES;
            ESPayTimesViewController *payTimesViewCon = [[ESPayTimesViewController alloc] initWithOrderId:orderId payOrderId:payOrderId brandId:_brandId amount:factAccount partPayment:doubleTwelve loanDic:loanDic payType:ESPayTypeMaterial payTimesType:ESPayTimesTypeFirst];
            [self.navigationController pushViewController:payTimesViewCon animated:YES];
        }
    } failure:^(NSError *error) {
        SHLog(@"%@", error);
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:error]]toView:weakSelf.view];
    }];
}
#pragma mark - 键盘处理
- (void)keyBoardWillShow:(NSNotification *)note{
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        NSDictionary *userInfo = [note userInfo];
        NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardRect = [aValue CGRectValue];
        int height = keyboardRect.size.height;
        
        if (CGRectGetMaxY(_keyboardFrame)>height) {
            self.view.transform = CGAffineTransformMakeTranslation(0, -height);
        }
    }];
}
- (void)keyBoardWillHide:(NSNotification *)note{
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

- (void)tapOnLeftButton:(id)sender {
    [_datePicker remove];
    [_storePicker remove];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setDataSource:(NSDictionary *)dict {
    _datasSource = [NSMutableDictionary dictionaryWithDictionary:dict];
}

- (void)setTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-TABBAR_HEIGHT) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"ESMSNoAddressCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESMSNoAddressCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESMSAddressCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESMSAddressCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESOrderProductCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESOrderProductCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESMSTextFieldCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESMSTextFieldCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESClickCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESClickCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESNoClickCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESNoClickCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESMSPriceCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESMSPriceCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESSaleAgreementCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESSaleAgreementCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESMSGoldTableViewCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESMSGoldTableViewCell"];
    
    [_tableView registerNib:[UINib nibWithNibName:@"ESLabelHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESLabelHeaderFooterView"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESGrayTableViewHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESGrayTableViewHeaderFooterView"];
    //    if (_orderType == ESMakeSureOrderTypeDoubleTwelve) {
    [_tableView registerNib:[UINib nibWithNibName:@"ESMakeSureOrderGoodsPriceTableViewCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESMakeSureOrderGoodsPriceTableViewCell"];
    //        [_tableView registerClass:[ESMakeSureOrderGoodsPriceCell class] forCellReuseIdentifier:@"ESMakeSureOrderGoodsPriceCell"];
    //    }
    _tableView.separatorColor = [UIColor stec_lineGrayColor];
    [self.view addSubview:_tableView];
}

- (void)initTableBar {
    WS(weakSelf)
    _orderBar = [ESMSBar creatWithFrame:CGRectMake(0, SCREEN_HEIGHT-TABBAR_HEIGHT-BOTTOM_SAFEAREA_HEIGHT, SCREEN_WIDTH, TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT) Info:nil block:^{
        [weakSelf placeOrderInfo];
    }];
    [self.view addSubview:_orderBar];
}

- (void)setUpTableViewData {
    
    if (_datasSource.allKeys.count > 0) {
        [_orderBar setOrderInfo:_datasSource isCustom:NO];
        _pendingOrders = [_datasSource objectForKey:@"pendingOrders"] ? [_datasSource objectForKey:@"pendingOrders"] : [NSArray array];
        [self refreshPickerView];
        [self refreshUpdateDic];
        self.canUseGoldsNum = [NSString stringWithFormat:@"%@", _datasSource[@"usedPointAmount"]?_datasSource[@"usedPointAmount"]:@"0"];
        if ([_pendingOrders isKindOfClass:[NSArray class]]) {
            for (NSInteger i = 0; i < _pendingOrders.count; i++) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [_invoiceArray addObject:dic];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [_couponArray addObject:dict];
                
                NSMutableDictionary *dictt = [NSMutableDictionary dictionary];
                [_selectServerStoreArray addObject:dictt];
                [_selectSaleAgreementArray addObject:@"NO"];
            }
        }
        [_tableView reloadData];
    } else {
        _datasSource = [NSMutableDictionary dictionary];
        [self getOrderInfo];
    }
}
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)getOrderInfo {//获取结算订单详情
    WS(weakSelf)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESOrderAPI getPendingOrderWithSuccess:^(NSDictionary *dict) {
        
        SHLog(@"确认订单:%@", dict);
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        _datasSource = [NSMutableDictionary dictionaryWithDictionary:dict];
        weakSelf.canUseGoldsNum = [NSString stringWithFormat:@"%@", weakSelf.datasSource[@"usedPointAmount"]?weakSelf.datasSource[@"usedPointAmount"]:@"0"];
        weakSelf.pendingOrders = [_datasSource objectForKey:@"pendingOrders"] ? [_datasSource objectForKey:@"pendingOrders"] : [NSArray array];
        
        if ([weakSelf.pendingOrders isKindOfClass:[NSArray class]])
        {
            for (NSInteger i = 0; i < weakSelf.pendingOrders.count; i++)
            {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [_invoiceArray addObject:dic];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [_couponArray addObject:dict];
                
                NSMutableDictionary *dictt = [NSMutableDictionary dictionary];
                [_selectServerStoreArray addObject:dictt];
                
                [_selectSaleAgreementArray addObject:@"NO"];
            }
        }
        [_orderBar setOrderInfo:_datasSource isCustom:NO];
        [weakSelf refreshPickerView];
        [weakSelf refreshUpdateDic];
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:error]]toView:weakSelf.view];
        SHLog(@"%@", error);
    }];
}

- (void)refreshUpdateDic {
    [_updateDic setObject:_datasSource[@"pendingOrderId"] forKey:@"pendingOrderId"];
    NSMutableArray *orders = [NSMutableArray array];
    for (NSDictionary *order in _pendingOrders) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:order[@"subOrderId"] forKey:@"subOrderId"];
        [orders addObject:dic];
    }
    [_updateDic setObject:orders forKey:@"pendingOrders"];
    
    if (_pendingOrders.count>1) {
        [_updateDic setObject:@"0" forKey:@"brandId"];
        _brandId = @"0";
    } else {
        NSDictionary *dic = _pendingOrders.firstObject;
        NSString *brandId = [NSString stringWithFormat:@"%@", dic[@"brandId"]?dic[@"brandId"]:@""];
        [_updateDic setObject:brandId forKey:@"brandId"];
        _brandId = brandId;
    }
    
}

- (void)placeOrderInfo {//提交订单
    [UMengServices eventWithEventId:Event_commit_order_button];
    
    double pay = [[NSString stringWithFormat:@"%@", (_datasSource[@"payAmount"] ? _datasSource[@"payAmount"] : @"0.00")] doubleValue];
    if (pay > 10000000.0) {
        [MBProgressHUD showError:@"订单金额过大无法支付"];
        return;
    }
    NSString *addressId = [_updateDic objectForKey:@"addressId"];
    if (addressId == nil || addressId.length<1) {
        [MBProgressHUD showError:@"请选择收货地址"];
        return;
    }
    
    NSArray *pendingOrders = [_updateDic objectForKey:@"pendingOrders"] ? [_updateDic objectForKey:@"pendingOrders"] : [NSArray array];
    if ([pendingOrders isKindOfClass:[NSArray class]]) {
        for (NSDictionary *pendDic in pendingOrders) {
            NSString *time = pendDic[@"dispatchTime"];
            if (time == nil || [time isEqualToString:@""]) {
                [MBProgressHUD showError:@"请选择配送时间"];
                return;
            }
            NSString *storeId = pendDic[@"storeId"];
            if (storeId == nil || [storeId isEqualToString:@""]) {
                [MBProgressHUD showError:@"请选择服务门店"];
                return;
            }
            NSString *remark = pendDic[@"remark"] ? pendDic[@"remark"] : @"";
            if ([CoStringManager stringContainsEmoji:remark]) {
                [MBProgressHUD showError:@"留言含有特殊字符"];
                return;
            }
        }
    }
    for (NSString *hasApproved in _selectSaleAgreementArray) {
        BOOL hasApp = [hasApproved boolValue];
        if (!hasApp) {
            [MBProgressHUD showError:@"请您查看并同意买卖协议"];
            return;
        }
    }
    [self commitOrder];
}

- (void)paySuccessWithOrderId:(NSString *)orderId payAmount:(NSString *)payAmount {
    ESPaySucessViewController *paySucessViewCon = [[ESPaySucessViewController alloc] init];
    [paySucessViewCon setOrderId:orderId money:payAmount];
    paySucessViewCon.type = ESPaySucessTypeDefault;
    [self.navigationController pushViewController:paySucessViewCon
                                         animated:YES];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_orderType == ESMakeSureOrderTypeDoubleTwelve) {
        return 1 + _pendingOrders.count;
    }
    return 1 + _pendingOrders.count + 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return 1;
    } else if (section <= _pendingOrders.count) {
        NSDictionary *penDic = [self returnPendDic:section];
        NSMutableArray *array = [self returnOrderItems:penDic];
        if (_orderType == ESMakeSureOrderTypeDoubleTwelve) {
            return 6 + array.count;
        } else {
            return 9 + array.count;
        }
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (0 == section) {
        return 0.001;
    } else if (section <= _pendingOrders.count) {
        return 50;
    } else {
        return 0.001;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ESLabelHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESLabelHeaderFooterView"];
    NSString *brandName = @"";
    if (section > 0) {
        NSDictionary *pendDic = [self returnPendDic:section];
        brandName = pendDic[@"brandName"] ? pendDic[@"brandName"] : @"";
    }
    [header setTitle:brandName titleColor:[UIColor stec_titleTextColor] subTitle:nil subTitleColor:nil backColor:[UIColor whiteColor]];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ESGrayTableViewHeaderFooterView *footer = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
    [footer setBackViewColor:[UIColor stec_viewBackgroundColor]];
    return footer;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {//地址
        if (_addressInfo) {
            ESMSAddressCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESMSAddressCell" forIndexPath:indexPath];
            [cell setMakeSureOrderAdress:_addressInfo];
            return cell;
        } else {
            ESMSNoAddressCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESMSNoAddressCell" forIndexPath:indexPath];
            [cell setTitle:_addressString];
            return cell;
        }
    } else if (indexPath.section <= _pendingOrders.count) {
        NSDictionary *pendDic = [self returnPendDic:indexPath.section];
        NSMutableArray *array = [self returnOrderItems:pendDic];
        if (indexPath.row < array.count) {//商品描述
            ESOrderProductCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESOrderProductCell" forIndexPath:indexPath];
            NSString *orderType = [NSString stringWithFormat:@"%@", [pendDic objectForKey:@"orderType"]];
            [cell setProductInfo:[array objectAtIndex:indexPath.row] orderType:orderType isFromMakeSureController:YES];
            return cell;
        } else if (array.count == indexPath.row) {//配送时间
            ESMSTextFieldCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESMSTextFieldCell" forIndexPath:indexPath];
            [cell setDeliveryTime:_updateDic indexPath:indexPath];
            return cell;
        } else if (array.count+1 == indexPath.row) {//是否需要发票
            ESClickCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESClickCell" forIndexPath:indexPath];
            [cell setInvoiceData:indexPath invoiceArray:_invoiceArray];
            return cell;
        }
        if (_orderType == ESMakeSureOrderTypeDoubleTwelve) {//双十二
            if (3 == indexPath.row) {//服务门店
                return [self returnESClickCell:tableView indexPath:indexPath];
            } else if (4 == indexPath.row){//买卖协议
                return [self returnESSaleAgreementCell:tableView indexPath:indexPath];
            } else if (5 == indexPath.row) {//买家留言
                return [self returnESMSTextFieldCell:tableView indexPath:indexPath];
            } else {//双十二定金(商品件数，金额)
                ESMakeSureOrderGoodsPriceTableViewCell *priceCell = [tableView dequeueReusableCellWithIdentifier:@"ESMakeSureOrderGoodsPriceTableViewCell" forIndexPath:indexPath];
                [priceCell setGoodsPriceMessage:pendDic];
                return priceCell;
            }
        } else {
            if(array.count+2 == indexPath.row) {//优惠券
                ESClickCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESClickCell" forIndexPath:indexPath];
                [cell setCouponData:indexPath couponArray:_couponArray];
                return cell;
            } else if (array.count+3 == indexPath.row) {//平台优惠
                ESNoClickCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESNoClickCell" forIndexPath:indexPath];
                [cell setDiscountData:pendDic];
                return cell;
            } else if (array.count+4 == indexPath.row) {//商家优惠
                ESNoClickCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESNoClickCell" forIndexPath:indexPath];
                [cell setShopperDiscount:pendDic];
                return cell;
            } else if (array.count+5 == indexPath.row) {//服务门店
                return [self returnESClickCell:tableView indexPath:indexPath];
            } else if (array.count+6 == indexPath.row){// 买卖协议
                return [self returnESSaleAgreementCell:tableView indexPath:indexPath];
            } else if (array.count+7 == indexPath.row) {
                return [self returnESMSTextFieldCell:tableView indexPath:indexPath];
            } else {//共%ld件商品 合计
                ESMSPriceCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESMSPriceCell" forIndexPath:indexPath];
                [cell setGoodsNumberAndPrice:array pendDic:pendDic];
                return cell;
            }
        }
    } else { //装修基金:
        ESMSGoldTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESMSGoldTableViewCell" forIndexPath:indexPath];
        NSString *pendingOrderId = [_datasSource objectForKey:@"pendingOrderId"] ? [_datasSource objectForKey:@"pendingOrderId"] : @"";
        NSString *canpointAmount = [cell returnCanpointAmount:_datasSource];
        WS(weakSelf)
        [cell setTitle:@"装修基金:" subTitle:canpointAmount placeholder:@"输入抵现金额" textFieldText:_usedGoldsNum block:^(NSString *goldNum, void(^resetStatus)(BOOL resetStatus)) {
            if ([goldNum isEqualToString:weakSelf.usedGoldsNum]) {
                return;
            }
            if ([goldNum doubleValue] >= [_canUseGoldsNum doubleValue])
            {
                [ESGoldAlertView showGoldAlertViewCallBack:^(BOOL sureStatus)
                 {
                     if (sureStatus)
                     {
                         [weakSelf useGoldWithOrderId:pendingOrderId goldNum:goldNum indexPath:indexPath];
                     }
                     else
                     {
                         if (resetStatus)
                         {
                             resetStatus(YES);
                         }
                     }
                 }];
            }
            else
            {
                [weakSelf useGoldWithOrderId:pendingOrderId goldNum:goldNum indexPath:indexPath];
            }
        }];
        [cell setCanUseGold:_canUseGoldsNum];
        [cell setKeyboardBlock:^(CGRect inSuperViewFrame) {
            _keyboardFrame = inSuperViewFrame;
        }];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        if (_addressInfo) {
            return 75;
        } else {
            return 55;
        }
    } else if (indexPath.section <= _pendingOrders.count) {
        NSDictionary *pendDic = [self returnPendDic:indexPath.section];
        NSMutableArray *array = [self returnOrderItems:pendDic];
        if (_orderType == ESMakeSureOrderTypeDoubleTwelve && 6 == indexPath.row) {
            return 110;
        }
        if (indexPath.row < array.count) {
            return 130;
        } else if (array.count+7 == indexPath.row) {
            return 55;
        } else if (array.count+8 == indexPath.row) {
            return 55;
        } else {
            return 46;
        }
    } else {
        return 55;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_datePicker remove];
    [_storePicker remove];
    [self.view endEditing:YES];
    _selectIndexPath = indexPath;
    if (0 == indexPath.section) {
        SHLog(@"跳转地址列表");
        [self jumpToAddressListViewController];
    } else if (indexPath.section <= _pendingOrders.count) {
        NSDictionary *pendDic = [self returnPendDic:indexPath.section];
        NSMutableArray *array = [self returnOrderItems:pendDic];
        if (indexPath.row < array.count) {
            SHLog(@"商品详情");
            [self jumpToGoodsDetail:array indexPath:indexPath];
        } else if (array.count == indexPath.row) {//配送时间
            SHLog(@"配送时间");
            [_datePicker show];
        } else if (array.count+1 == indexPath.row) {
            SHLog(@"发票");
            [self makeSureInvoice:indexPath];
        }
        if (_orderType == ESMakeSureOrderTypeDoubleTwelve) {
            if (3 == indexPath.row) {
                [self refreshStorePickerViewWithSubOrderId:[NSString stringWithFormat:@"%@", pendDic[@"subOrderId"]?pendDic[@"subOrderId"]:@""]];
            } else if (4 == indexPath.row) {
                [self jumpToSaleAgreement];
            }
        } else {
            if (array.count+2 == indexPath.row) {
                SHLog(@"优惠券");
                [self makeSureCoupon:indexPath pendDic:pendDic];
            } else if (array.count+5 == indexPath.row) {
                SHLog(@"服务门店");
                [self refreshStorePickerViewWithSubOrderId:[NSString stringWithFormat:@"%@", pendDic[@"subOrderId"]?pendDic[@"subOrderId"]:@""]];
            } else if (array.count+6 == indexPath.row) {
                SHLog(@"买卖协议");
                [self jumpToSaleAgreement];
            }
        }
    }
}
#pragma mark - Action Method
- (void)jumpToAddressListViewController {
    NSString *addressId = @"";
    if (_addressInfo) {
        addressId = _addressInfo.addressId;
    }
    ESSelectAddressController *selectAddressCon = [[ESSelectAddressController alloc] initWithAddressID:addressId withSelectedAddress:^(ESAddress *selectedAddr) {
        _addressInfo = selectedAddr;
        if (selectedAddr == nil) {
            [_updateDic removeObjectForKey:@"addressId"];
        } else {
            [_updateDic setObject:[NSString stringWithFormat:@"%@",selectedAddr.addressId] forKey:@"addressId"];
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [self.navigationController pushViewController:selectAddressCon animated:YES];
}

- (void)jumpToGoodsDetail:(NSMutableArray *)array indexPath:(NSIndexPath*)indexPath {
    NSDictionary *pruinfo = [array objectAtIndex:indexPath.row];
    ESProductDetailViewController *productDetailViewCon = [[ESProductDetailViewController alloc] initWithProductId:[pruinfo objectForKey:@"itemId"] type:ESProductDetailTypeSku designerId:nil];
    
    [self.navigationController pushViewController:productDetailViewCon animated:YES];
}

- (void)jumpToSaleAgreement {
    ESSaleAgreementViewController *vc = [[ESSaleAgreementViewController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)makeSureCoupon:(NSIndexPath *)indexPath pendDic:(NSDictionary *)pendDic{
    NSMutableDictionary *couponDic = [NSMutableDictionary dictionary];
    if (_couponArray.count > indexPath.section-1) {
        couponDic = _couponArray[indexPath.section-1];
    }
    
    WS(weakSelf)
    NSString *subOrderId = [pendDic objectForKey:@"subOrderId"];
    NSString *orderId = [_datasSource objectForKey:@"pendingOrderId"];
    NSDictionary *userInfo = @{@"subOrderId" : subOrderId,
                               @"pendingOrderId" : orderId,
                               @"couponDict": couponDic
                               };
    [MGJRouter openURL:@"/Mall/ChooseCoupons" withUserInfo:userInfo completion:^(id result) {
        NSMutableDictionary *newCouponDic = (NSMutableDictionary *)[result mutableCopy];
        NSString *oldcouponId = [NSString stringWithFormat:@"%@", couponDic[@"couponId"]];
        NSString *couponId = [NSString stringWithFormat:@"%@", newCouponDic[@"couponId"]];
        if ([oldcouponId isEqualToString:couponId]) {
            return;
        }
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        if (newCouponDic.allKeys.count > 0) {
            [weakSelf addPendingCouponWithCouponId:couponId subOrderId:subOrderId indexPath:indexPath newCouponDic:newCouponDic];
        } else {
            [weakSelf deletePendingCouponWithCouponId:oldcouponId subOrderId:subOrderId newCouponDic:newCouponDic indexPath:indexPath];
        }
    }];
}

- (void)makeSureInvoice:(NSIndexPath *)indexPath {
    WS(weakSelf)
    ESMakeSureInvoiceController *makeSureInvoiceCon = [[ESMakeSureInvoiceController alloc] init];
    [makeSureInvoiceCon setInvoiceBlock:^(NSMutableDictionary *invoiceDic) {
        
        if (weakSelf.invoiceArray.count>indexPath.section-1) {
            [weakSelf.invoiceArray replaceObjectAtIndex:indexPath.section-1 withObject:invoiceDic];
        }
        
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        NSString *invoiceId = @"";
        if (invoiceDic.allKeys.count>0) {
            NSString *invoiceHeadType = [NSString stringWithFormat:@"%@", [invoiceDic objectForKey:@"invoiceHeadType"]];
            if ([invoiceHeadType isEqualToString:@"0"]) {
                invoiceId = @"0";
            } else {
                invoiceId = [NSString stringWithFormat:@"%@", invoiceDic[@"invoiceId"] ? invoiceDic[@"invoiceId"] : @""];
            }
        }
        
        NSArray *arr = [weakSelf.updateDic objectForKey:@"pendingOrders"] ? [weakSelf.updateDic objectForKey:@"pendingOrders"] : [NSArray array];
        NSMutableArray *pendingOrders = [NSMutableArray arrayWithArray:arr];
        NSMutableDictionary *pendDic = [NSMutableDictionary dictionary];
        if (pendingOrders.count>indexPath.section-1) {
            pendDic = [NSMutableDictionary dictionaryWithDictionary:[pendingOrders objectAtIndex: indexPath.section-1]];
        }
        if ([invoiceId isEqualToString:@""]) {
            [pendDic removeObjectForKey:@"invoiceId"];
        } else {
            [pendDic setValue:invoiceId forKey:@"invoiceId"];
        }
        if (pendingOrders.count>indexPath.section-1) {
            [pendingOrders replaceObjectAtIndex:indexPath.section-1 withObject:pendDic];
        }
        [weakSelf.updateDic setObject:pendingOrders forKey:@"pendingOrders"];
    }];
    
    NSMutableDictionary *invoiceDic = [NSMutableDictionary dictionary];
    if (_invoiceArray.count > indexPath.section-1) {
        invoiceDic = _invoiceArray[indexPath.section-1];
    }
    
    if (invoiceDic.allKeys.count>0) {
        [makeSureInvoiceCon setInvoiceDic:invoiceDic];
    }
    [self.navigationController pushViewController:makeSureInvoiceCon animated:YES];
}

- (void)updateInputMessage:(NSIndexPath *)indexPath remark:(NSString *)remark {
    NSArray *arr = [_updateDic objectForKey:@"pendingOrders"] ? [_updateDic objectForKey:@"pendingOrders"] : [NSArray array];
    NSMutableArray *pendingOrders = [NSMutableArray arrayWithArray:arr];
    NSDictionary *pendDic = [NSDictionary dictionary];
    if (pendingOrders.count > indexPath.section - 1) {
        pendDic = [pendingOrders objectAtIndex: indexPath.section-1];
    }
    [pendDic setValue:remark forKey:@"remark"];
    if (pendingOrders.count>indexPath.section-1) {
        [pendingOrders replaceObjectAtIndex:indexPath.section-1 withObject:pendDic];
    }
    [_updateDic setObject:pendingOrders forKey:@"pendingOrders"];
}

- (ESSaleAgreementCell *)returnESSaleAgreementCell:(UITableView *)tableView  indexPath:(NSIndexPath *)indexPath{
    ESSaleAgreementCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESSaleAgreementCell"forIndexPath:indexPath];
    cell.cellDelegate = self;
    [cell updateSaleAgreementCellWithIndex:indexPath];
    return cell;
}
- (ESClickCell *)returnESClickCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    ESClickCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESClickCell" forIndexPath:indexPath];
    [cell setServeShopData:indexPath selectServerStoreArray:_selectServerStoreArray];
    return cell;
}

- (ESMSTextFieldCell *)returnESMSTextFieldCell:(UITableView *)tableView indexPath:(NSIndexPath*)indexPath {
    ESMSTextFieldCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESMSTextFieldCell" forIndexPath:indexPath];
    NSString *remark = [cell returnBuyerMessage:indexPath updateDic:_updateDic];
    WS(weakSelf)
    [cell  setTitle:@"买家留言:" subTitle:remark placeholder:@"请输入您的留言（选填）" arrowHidden:YES block:^(NSString *remark) {
        [weakSelf updateInputMessage:indexPath remark:remark];
    }];
    [cell setKeyboardBlock:^(CGRect inSuperViewFrame) {
        weakSelf.keyboardFrame = inSuperViewFrame;
    }];
    cell.separatorInset = UIEdgeInsetsMake(0, 0, SCREEN_WIDTH, 1);
    return cell;
}

- (NSDictionary *)returnPendDic:(NSInteger)section {
    NSDictionary *pendDic = [NSDictionary dictionary];
    if (_pendingOrders.count > section-1) {
        pendDic = [_pendingOrders objectAtIndex:section-1];
    }
    return pendDic;
}

- (NSMutableArray *)returnOrderItems:(NSDictionary *)pendDic {
    NSArray *tempArr = [pendDic objectForKey:@"orderItems"];
    NSMutableArray *array = [NSMutableArray array];
    if ([tempArr isKindOfClass:[NSArray class]]) {
        array = [NSMutableArray arrayWithArray:tempArr];
    }
    return array;
}

- (void)refreshPickerView {
    NSDictionary *pendDic = [NSDictionary dictionary];
    if (_pendingOrders.count > 0) {
        pendDic = [_pendingOrders objectAtIndex: 0];
    }
    NSString *dispatchTime = [NSString stringWithFormat:@"%@", [pendDic objectForKey:@"leadTime"]?[pendDic objectForKey:@"leadTime"]:@""];
    
    NSDate *minDate = [NSDate date];
    if (![dispatchTime isEqualToString:@""]) {
        NSDateFormatter *fMinDate = [[NSDateFormatter alloc] init];
        [fMinDate setDateFormat:@"yyyy-MM-dd"];
        minDate = [fMinDate dateFromString:dispatchTime];
    }
    if (minDate == nil) {
        minDate = [NSDate date];
    }
    _datePicker = [[ESPickerView alloc] initDatePickWithDate:[NSDate date] minDate:minDate datePickerMode:UIDatePickerModeDate];
    _datePicker.delegate = self;
}

#pragma mark - ESPickerViewDelegate

- (void)toobarCancelBtnHaveClick:(ESPickerView *)pickView resultString:(NSString *)resultString {
    
    _selectIndexPath = nil;
}

- (void)toobarDonBtnHaveClick:(ESPickerView *)pickView resultString:(NSString *)resultString {
    SHLog(@"%@", resultString);
    if (_datePicker == pickView) {
        [self toobarUpdateDic:resultString serverStoreId:nil];
        [self.tableView reloadRowsAtIndexPaths:@[_selectIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    } else if (_storePicker == pickView) {
        NSMutableDictionary *serverStoreDic = [NSMutableDictionary dictionary];
        NSInteger index = [_serverStoreTitleArray indexOfObject:resultString];
        
        if (_serverStoreArray.count > index) {
            serverStoreDic = _serverStoreArray[index];
        }
        
        if (self.selectServerStoreArray.count>
            _selectIndexPath.section-1) {
            [self.selectServerStoreArray replaceObjectAtIndex:_selectIndexPath.section-1 withObject:serverStoreDic];
        }
        
        NSString *serverStoreId = @"";
        if (serverStoreDic.allKeys.count>0) {
            serverStoreId = [NSString stringWithFormat:@"%@", serverStoreDic[@"storeId"] ? serverStoreDic[@"storeId"] : @""];
        }
        [self toobarUpdateDic:nil serverStoreId:serverStoreId];
        [self.tableView reloadRowsAtIndexPaths:@[_selectIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    _selectIndexPath = nil;
}
- (void)toobarUpdateDic:(NSString *)resultString serverStoreId:(NSString *)serverStoreId {
    NSArray *arr = [_updateDic objectForKey:@"pendingOrders"] ? [_updateDic objectForKey:@"pendingOrders"] : [NSArray array];
    NSMutableArray *pendingOrders = [NSMutableArray arrayWithArray:arr];
    NSMutableDictionary *pendDic = [NSMutableDictionary dictionary];
    if (pendingOrders.count>_selectIndexPath.section-1) {
        pendDic = [NSMutableDictionary dictionaryWithDictionary:[pendingOrders objectAtIndex: _selectIndexPath.section-1]];
    }
    if (resultString) {
        [pendDic setValue:resultString forKey:@"dispatchTime"];
    }
    if (serverStoreId) {
        if ([serverStoreId isEqualToString:@""]) {
            [pendDic removeObjectForKey:@"storeId"];
        } else {
            [pendDic setValue:serverStoreId forKey:@"storeId"];
        }
    }
    if (pendingOrders.count>_selectIndexPath.section-1) {
        [pendingOrders replaceObjectAtIndex:_selectIndexPath.section-1 withObject:pendDic];
    }
    [_updateDic setObject:pendingOrders forKey:@"pendingOrders"];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
    [_datePicker remove];
    [_storePicker remove];
    if (scrollView == self.tableView) {
        CGFloat sectionHeaderHeight = 50; //sectionHeaderHeight
        if(scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}
#pragma mark - ESSaleAgreementCellDelegate

- (BOOL)getSaleAgreementStatus:(NSIndexPath *)indexPath {
    BOOL hasApproved = NO;
    if (_selectSaleAgreementArray.count > indexPath.section-1) {
        hasApproved = [_selectSaleAgreementArray[indexPath.section-1] boolValue];
    }
    return hasApproved;
}
#pragma mark - ESSaleAgreementViewControllerDelegate

- (void)saleAgreementAgreeButtonDidTapped {
    if (self.selectSaleAgreementArray.count>
        _selectIndexPath.section-1) {
        [self.selectSaleAgreementArray replaceObjectAtIndex:_selectIndexPath.section-1 withObject:@"YES"];
    }
    [self.tableView reloadRowsAtIndexPaths:@[_selectIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    _selectIndexPath = nil;
}

@end

