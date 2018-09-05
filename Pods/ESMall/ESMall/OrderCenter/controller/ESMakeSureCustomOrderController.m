//
//  ESMakeSureCustomOrderController.m
//  Consumer
//
//  Created by jiang on 2017/7/11.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMakeSureCustomOrderController.h"

#import "ESMSNoAddressCell.h"
#import "ESMSAddressCell.h"
#import "ESMSTextFieldCell.h"
#import "ESLabelHeaderFooterView.h"
#import "ESOrderProductCell.h"
#import "ESClickCell.h"
#import "ESMSGoldTableViewCell.h"

#import "ESOrderAPI.h"
#import "ESGrayTableViewHeaderFooterView.h"

#import "ESMSBar.h"
#import "ESProductDetailViewController.h"
#import "ESPickerView.h"
#import "MBProgressHUD+NJ.h"

#import "ESSelectAddressController.h"
#import "ESAddress.h"
#import "MBProgressHUD+NJ.h"
#import "ESAddrerssAPI.h"
#import "CoStringManager.h"
#import "ESSaleAgreementCell.h"
#import "ESSaleAgreementViewController.h"

#import "ESPayTimesViewController.h"

#import "ESPaySucessViewController.h"
#import <ESFoundation/UMengServices.h>
#import "ESGoldAlertView.h"
#import "MGJRouter.h"

@interface ESMakeSureCustomOrderController ()
<
UITableViewDataSource,
UITableViewDelegate,
ESPickerViewDelegate,
ESSaleAgreementCellDelegate,
ESSaleAgreementViewControllerDelegate
>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *datasSource;
@property (strong, nonatomic) ESMSBar *orderBar;
@property (strong, nonatomic) ESPickerView *datePicker;
@property (strong, nonatomic) ESPickerView *storePicker;
@property (strong, nonatomic) NSIndexPath *selectIndexPath;
@property (strong, nonatomic) NSMutableDictionary *updateDic;
@property (strong, nonatomic) NSMutableDictionary *couponDic;//已选优惠券
@property (strong, nonatomic) NSMutableDictionary *serverStoreDic;//已选服务门店
@property (strong, nonatomic) NSMutableArray *serverStoreArray;//获取服务门店
@property (strong, nonatomic) NSMutableArray *serverStoreTitleArray;//获取服务门店名称
@property (strong, nonatomic) ESAddress *addressInfo;
@property (assign, nonatomic) CGRect keyboardFrame;
@property (copy, nonatomic) NSString *addressString;

@property (copy, nonatomic) NSString *canUseGoldsNum;
@property (copy, nonatomic) NSString *usedGoldsNum;//已填写装修基金
@property (copy, nonatomic)   NSString *brandId;

@end

@implementation ESMakeSureCustomOrderController
{
    BOOL _hasApproved;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = @"确认订单";
    self.rightButton.hidden = YES;
    _canUseGoldsNum = @"0";
    _usedGoldsNum = @"";
    _datasSource = [NSMutableDictionary dictionary];
    _updateDic = [NSMutableDictionary dictionary];
    _couponDic = [NSMutableDictionary dictionary];
    _serverStoreDic = [NSMutableDictionary dictionary];
    _serverStoreTitleArray = [NSMutableArray array];
    _serverStoreArray = [NSMutableArray array];
    _selectIndexPath = nil;
    // Do any additional setup after loading the view.
    [self setTableView];
    WS(weakSelf)
    _orderBar = [ESMSBar creatWithFrame:CGRectMake(0, SCREEN_HEIGHT-TABBAR_HEIGHT-BOTTOM_SAFEAREA_HEIGHT, SCREEN_WIDTH, TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT) Info:nil block:^{
        [weakSelf placeOrderInfo];
        
    }];
    [self.view addSubview:_orderBar];
    [self getOrderInfo];
    _addressString = @"您还没有收货地址，请先去添加哦~";
    [self getDefaultAddress];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

#pragma mark - 键盘处理
#pragma mark 键盘即将显示
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
#pragma mark 键盘即将退出
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
    [_tableView registerNib:[UINib nibWithNibName:@"ESMSGoldTableViewCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESMSGoldTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESSaleAgreementCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESSaleAgreementCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESLabelHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESLabelHeaderFooterView"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESGrayTableViewHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESGrayTableViewHeaderFooterView"];
    //    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = [UIColor stec_lineGrayColor];
    [self.view addSubview:_tableView];
}

- (void)getOrderInfo {//获取结算订单详情
    WS(weakSelf)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESOrderAPI getPendingOrderWithSuccess:^(NSDictionary *dict) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        weakSelf.datasSource = [NSMutableDictionary dictionaryWithDictionary:dict];
        weakSelf.canUseGoldsNum = [NSString stringWithFormat:@"%@", weakSelf.datasSource[@"usedPointAmount"]?weakSelf.datasSource[@"usedPointAmount"]:@"0"];
        [weakSelf.orderBar setOrderInfo:weakSelf.datasSource isCustom:YES];
        [weakSelf refreshPickerView];
        [weakSelf refreshUpdateDic];
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        SHLog(@"%@", error);
    }];
    
}

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
    }];
    
}

- (void)refreshUpdateDic {
    [_updateDic setObject:_datasSource[@"pendingOrderId"] forKey:@"pendingOrderId"];
    NSArray *pendingOrders = [_datasSource objectForKey:@"pendingOrders"] ? [_datasSource objectForKey:@"pendingOrders"] : [NSArray array];
    NSMutableArray *orders = [NSMutableArray array];
    for (NSDictionary *order in pendingOrders) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:order[@"subOrderId"] forKey:@"subOrderId"];
        [orders addObject:dic];
    }
    [_updateDic setObject:orders forKey:@"pendingOrders"];
    
    if (pendingOrders.count>1) {
        [_updateDic setObject:@"0" forKey:@"brandId"];
        _brandId = @"0";
    } else {
        NSDictionary *dic = pendingOrders.firstObject;
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
    
    if (!_hasApproved)
    {
        [MBProgressHUD showError:@"请您查看并同意买卖协议"];
        return;
    }
    
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
            [weakSelf paySuccessWithOrderId:orderId payAmount:factAccount];
        } else {
            ESPayTimesViewController *payTimesViewCon = [[ESPayTimesViewController alloc] initWithOrderId:orderId payOrderId:payOrderId brandId:_brandId amount:factAccount partPayment:ESPayTypeMaterial loanDic:loanDic payType:ESPayTypeMaterial payTimesType:ESPayTimesTypeFirst];

            [self.navigationController pushViewController:payTimesViewCon animated:YES];
        }
    } failure:^(NSError *error) {
        SHLog(@"%@", error);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [weakSelf getErrorMessage:error]]];
    }];
    
}

- (void)paySuccessWithOrderId:(NSString *)orderId payAmount:(NSString *)payAmount {
    ESPaySucessViewController *paySucessViewCon = [[ESPaySucessViewController alloc] init];
    [paySucessViewCon setOrderId:orderId money:payAmount];
    paySucessViewCon.type = ESPaySucessTypeDefault;
    [self.navigationController pushViewController:paySucessViewCon
                                         animated:YES];
}

- (NSString *)getErrorMessage:(NSError *)error {
    NSString *msg = @"网络错误, 请稍后重试!";
    @try {
        NSData *data = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSError *err = nil;
        NSDictionary * errorDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        
        if (err == nil && errorDict && [errorDict objectForKey:@"msg"]) {
            msg = [errorDict objectForKey:@"msg"];
        }
        
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
    } @finally {
        return msg;
    }
}

- (void)callShopper {
    [self.view endEditing:YES];
    NSArray *pendingOrders = [_datasSource objectForKey:@"pendingOrders"] ? [_datasSource objectForKey:@"pendingOrders"] : [NSArray array];
    NSDictionary *pendDic = [NSDictionary dictionary];
    if (pendingOrders.count>0) {
        pendDic = [pendingOrders objectAtIndex: 0];
    }
    
    NSString *phone = [NSString stringWithFormat:@"%@", ([pendDic objectForKey:@"merchantMobile"] != [NSNull null]) ? [pendDic objectForKey:@"merchantMobile"] : @""];
    if (phone == nil || [phone isEqualToString:@""] || phone.length < 1) {
        return;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone]];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:url] ;
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return 1;
    } else if (1 == section) {
        NSArray *pendingOrders = [_datasSource objectForKey:@"pendingOrders"] ? [_datasSource objectForKey:@"pendingOrders"] : [NSArray array];
        NSDictionary *pendDic = [NSDictionary dictionary];
        if (pendingOrders.count>section-1) {
            pendDic = [pendingOrders objectAtIndex: section-1];
        }
        
        NSArray *tempArr = [pendDic objectForKey:@"orderItems"];
        NSMutableArray *array = [NSMutableArray array];
        if ([tempArr isKindOfClass:[NSArray class]]) {
            array = [NSMutableArray arrayWithArray:tempArr];
        }
        //        NSMutableArray *array = [NSMutableArray arrayWithObjects:@"", @"", nil];
        return 5+array.count;
    } else {
        return 1;
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (0 == section || 2 == section) {
        return 0.001;
    } else {
        return 50;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (2 == section) {
        return 0.001;
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ESLabelHeaderFooterView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESLabelHeaderFooterView"];
    if (1 == section) {
        NSArray *pendingOrders = [_datasSource objectForKey:@"pendingOrders"] ? [_datasSource objectForKey:@"pendingOrders"] : [NSArray array];
        NSString *brandName = @"";
        if (section > 0) {
            NSDictionary *pendDic = [NSDictionary dictionary];
            if (pendingOrders.count>section-1) {
                pendDic = [pendingOrders objectAtIndex: section-1];
            }
            brandName = pendDic[@"brandName"] ? pendDic[@"brandName"] : @"";
        }
        
        [header setTitle:brandName titleColor:[UIColor stec_titleTextColor] subTitle:nil subTitleColor:nil backColor:[UIColor whiteColor]];
    } else {
        NSString *title = @"";
        UIColor *back = [UIColor stec_viewBackgroundColor];
        if (3 == section) {
            title = @"详情请咨询商家电话";
        }
        if (2 == section) {
            back = [UIColor whiteColor];
        }
        [header setTitle:title titleColor:[UIColor stec_subTitleTextColor] subTitle:nil subTitleColor:nil backColor:back];
        header.lineLabel.hidden = YES;
    }
    
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ESGrayTableViewHeaderFooterView *footer = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
    [footer setBackViewColor:[UIColor stec_viewBackgroundColor]];
    return footer;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        if (_addressInfo) {
            ESMSAddressCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESMSAddressCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSString *province = _addressInfo.province?_addressInfo.province:@"";
            NSString *city = _addressInfo.city?_addressInfo.city:@"";
            NSString *district = _addressInfo.district?_addressInfo.district:@"";
            NSString *addressInfo = _addressInfo.addressInfo?_addressInfo.addressInfo:@"";
            NSString *address = [NSString stringWithFormat:@"%@ %@ %@ %@", province, city, district, addressInfo];
            
            [cell setTitle:[NSString stringWithFormat:@"%@   %@", _addressInfo.name, _addressInfo.phone] subTitle:address];
            return cell;
        } else {
            ESMSNoAddressCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESMSNoAddressCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setTitle:_addressString];
            return cell;
        }
    } else if (1 == indexPath.section) {
        NSArray *pendingOrders = [_datasSource objectForKey:@"pendingOrders"] ? [_datasSource objectForKey:@"pendingOrders"] : [NSArray array];
        NSDictionary *pendDic = [NSDictionary dictionary];
        if (pendingOrders.count>indexPath.section-1) {
            pendDic = [pendingOrders objectAtIndex: indexPath.section-1];
        }
        NSArray *tempArr = [pendDic objectForKey:@"orderItems"];
        NSMutableArray *array = [NSMutableArray array];
        if ([tempArr isKindOfClass:[NSArray class]]) {
            array = [NSMutableArray arrayWithArray:tempArr];
        }
        //        NSMutableArray *array = [NSMutableArray arrayWithObjects:@"", @"", nil];
        if (indexPath.row < array.count) {
            ESOrderProductCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESOrderProductCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSString *orderType = [NSString stringWithFormat:@"%@", [pendDic objectForKey:@"orderType"]];
            [cell setProductInfo:[array objectAtIndex:indexPath.row] orderType:orderType isFromMakeSureController:YES];
            return cell;
        } else if (array.count == indexPath.row) {
            ESMSTextFieldCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESMSTextFieldCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            NSArray *pendingOrders = [_updateDic objectForKey:@"pendingOrders"] ? [_updateDic objectForKey:@"pendingOrders"] : [NSArray array];
            NSDictionary *pendDic = [NSDictionary dictionary];
            if (pendingOrders.count>indexPath.section-1) {
                pendDic = [pendingOrders objectAtIndex: indexPath.section-1];
            }
            NSString *time = pendDic[@"dispatchTime"] ? pendDic[@"dispatchTime"] : @"";
            [cell setTitle:@"服务时间:" subTitle:time placeholder:@"请选择服务时间（必填）" arrowHidden:NO block:nil];
            return cell;
        } else if (array.count+1 == indexPath.row) {
            
            ESClickCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESClickCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSString *subTitle = @"未使用优惠券";
            if (_couponDic.allKeys.count>0) {
                NSString *couponName = [NSString stringWithFormat:@"%@", [_couponDic objectForKey:@"showContent"] ? [_couponDic objectForKey:@"showContent"] : @""];
                if (![couponName isEqualToString:@""]) {
                    subTitle = couponName;
                }
            }
            [cell setTitle:@"优惠券:" subTitle:subTitle subTitleColor:[UIColor stec_subTitleTextColor]];
            return cell;
        } else if (array.count+2 == indexPath.row) {
            
            ESClickCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESClickCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSString *subTitle = @"请选择服务门店";
            if (_serverStoreDic.allKeys.count>0) {
                NSString *serverStoreName = [NSString stringWithFormat:@"%@", [_serverStoreDic objectForKey:@"storeName"] ? [_serverStoreDic objectForKey:@"storeName"] : @""];
                if (![serverStoreName isEqualToString:@""]) {
                    subTitle = serverStoreName;
                }
            }
            [cell setTitle:@"服务门店:" subTitle:subTitle subTitleColor:[UIColor stec_subTitleTextColor]];
            return cell;
        } else if (array.count+3 == indexPath.row) {
            
            // 买卖协议
            static NSString *cellID = @"ESSaleAgreementCell";
            ESSaleAgreementCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID
                                                                        forIndexPath:indexPath];
            cell.cellDelegate = self;
            [cell updateSaleAgreementCellWithIndex:indexPath];
            return cell;
            
        } else {
            ESMSTextFieldCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESMSTextFieldCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            NSArray *pendingOrders = [_updateDic objectForKey:@"pendingOrders"] ? [_updateDic objectForKey:@"pendingOrders"] : [NSArray array];
            NSDictionary *pendDic = [NSDictionary dictionary];
            if (pendingOrders.count>indexPath.section-1) {
                pendDic = [pendingOrders objectAtIndex: indexPath.section-1];
            }
            NSString *remark = pendDic[@"remark"] ? pendDic[@"remark"] : @"";
            [cell  setTitle:@"买家留言:" subTitle:remark placeholder:@"请输入您的留言（选填）" arrowHidden:YES block:^(NSString *remark) {
                
                NSArray *arr = [_updateDic objectForKey:@"pendingOrders"] ? [_updateDic objectForKey:@"pendingOrders"] : [NSArray array];
                NSMutableArray *pendingOrders = [NSMutableArray arrayWithArray:arr];
                NSDictionary *pendDic = [NSDictionary dictionary];
                if (pendingOrders.count>indexPath.section-1) {
                    pendDic = [pendingOrders objectAtIndex: indexPath.section-1];
                }
                [pendDic setValue:remark forKey:@"remark"];
                if (pendingOrders.count>indexPath.section-1) {
                    [pendingOrders replaceObjectAtIndex:indexPath.section-1 withObject:pendDic];
                }
                [_updateDic setObject:pendingOrders forKey:@"pendingOrders"];
                
            }];
            [cell setKeyboardBlock:^(CGRect inSuperViewFrame) {
                _keyboardFrame = inSuperViewFrame;
            }];
            return cell;
        }
    } else if (2 == indexPath.section) {
        NSString *pendingOrderId = [_datasSource objectForKey:@"pendingOrderId"] ? [_datasSource objectForKey:@"pendingOrderId"] : @"";
        NSString *pointAmount = [CoStringManager displayCheckPrice:[NSString stringWithFormat:@"%@", [_datasSource objectForKey:@"userPointAmount"]]];
        if ([pointAmount isKindOfClass:[NSNull class]]) {
            pointAmount = @"0";
        }
        NSString *canpointAmount = [NSString stringWithFormat:@"%@元可用", pointAmount];
        ESMSGoldTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESMSGoldTableViewCell" forIndexPath:indexPath];
        WS(weakSelf)
        [cell setTitle:@"装修基金" subTitle:canpointAmount placeholder:@"输入抵现金额" textFieldText:_usedGoldsNum block:^(NSString *goldNum,void(^resetStatus)(BOOL resetStatus)) {
            if ([goldNum doubleValue] >= [_canUseGoldsNum doubleValue])
            {
                [ESGoldAlertView showGoldAlertViewCallBack:^(BOOL sureStatus)
                 {
                     if (sureStatus)
                     {
                         [weakSelf updateGoldWithOrderId:pendingOrderId goldNum:goldNum indexPath:indexPath];
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
                [weakSelf updateGoldWithOrderId:pendingOrderId goldNum:goldNum indexPath:indexPath];
            }
        }];
        [cell setCanUseGold:_canUseGoldsNum];
        [cell setKeyboardBlock:^(CGRect inSuperViewFrame) {
            _keyboardFrame = inSuperViewFrame;
        }];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        NSArray *pendingOrders = [_datasSource objectForKey:@"pendingOrders"] ? [_datasSource objectForKey:@"pendingOrders"] : [NSArray array];
        NSDictionary *pendDic = [NSDictionary dictionary];
        if (pendingOrders.count>0) {
            pendDic = [pendingOrders objectAtIndex: 0];
        }
        NSString *num = [pendDic objectForKey:@"merchantMobile"];
        NSString *phoneNum = @"暂无商家电话";
        UIColor *subColor = [UIColor stec_subTitleTextColor];
        if ([num isKindOfClass:[NSString class]] && num.length>0) {
            phoneNum = num;
            subColor = [UIColor stec_blueTextColor];
        }
        
        
        //        NSString *phoneNum = [NSString stringWithFormat:@"%@", [pendDic objectForKey:@"merchantMobile"]?[pendDic objectForKey:@"merchantMobile"]:@""];
        ESClickCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESClickCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //        [cell setTitle:@"联系商家" subTitle:phoneNum subTitleColor:[UIColor stec_subTitleTextColor]];
        [cell setTitle:@"联系商家:" subTitle:phoneNum subTitleColor:subColor];
        return cell;
    }
    
}

- (void)updateGoldWithOrderId:(NSString *)pendingOrderId goldNum:(NSString *)goldNum indexPath:(NSIndexPath *)indexPath
{
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
    [ESOrderAPI useGoldWithOrderId:pendingOrderId goldNum:goldNum Success:^(NSDictionary *dict) {
        [_orderBar setOrderInfo:dict isCustom:YES];
        weakSelf.usedGoldsNum = goldNum;
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [weakSelf getErrorMessage:error]]];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.section) {
        if (_addressInfo) {
            return 75;
        } else {
            return 55;
        }
    } else if (1 == indexPath.section){
        NSArray *pendingOrders = [_datasSource objectForKey:@"pendingOrders"] ? [_datasSource objectForKey:@"pendingOrders"] : [NSArray array];
        NSDictionary *pendDic = [NSDictionary dictionary];
        if (pendingOrders.count>indexPath.section-1) {
            pendDic = [pendingOrders objectAtIndex: indexPath.section-1];
        }
        NSArray *tempArr = [pendDic objectForKey:@"orderItems"];
        NSMutableArray *array = [NSMutableArray array];
        if ([tempArr isKindOfClass:[NSArray class]]) {
            array = [NSMutableArray arrayWithArray:tempArr];
        }
        //        NSMutableArray *array = [NSMutableArray arrayWithObjects:@"", @"", nil];
        if (indexPath.row < array.count) {
            return 130;
        } else {
            return 55;
        }
    } else {
        return 55;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_datePicker remove];
    [_storePicker remove];
    if (0 == indexPath.section) {
        SHLog(@"跳转地址列表");
        [self.view endEditing:YES];
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
    } else if (1 == indexPath.section) {
        [self.view endEditing:YES];
        NSArray *pendingOrders = [_datasSource objectForKey:@"pendingOrders"] ? [_datasSource objectForKey:@"pendingOrders"] : [NSArray array];
        NSDictionary *pendDic = [NSDictionary dictionary];
        if (pendingOrders.count>indexPath.section-1) {
            pendDic = [pendingOrders objectAtIndex: indexPath.section-1];
        }
        NSArray *tempArr = [pendDic objectForKey:@"orderItems"];
        NSMutableArray *array = [NSMutableArray array];
        if ([tempArr isKindOfClass:[NSArray class]]) {
            array = [NSMutableArray arrayWithArray:tempArr];
        }
        //        NSMutableArray *array = [NSMutableArray arrayWithObjects:@"", @"", nil];
        if (indexPath.row < array.count) {
            SHLog(@"商品详情");
            NSDictionary *pruinfo = [array objectAtIndex:indexPath.row];
            ESProductDetailViewController *productDetailViewCon = [[ESProductDetailViewController alloc] initWithProductId:[pruinfo objectForKey:@"itemId"] type:ESProductDetailTypeSku designerId:nil];
            
            [self.navigationController pushViewController:productDetailViewCon animated:YES];
        } else if (array.count == indexPath.row) {
            //配送时间
            SHLog(@"配送时间");
            _selectIndexPath = indexPath;
            [_datePicker show];
        } else if (array.count+1 == indexPath.row) {
            SHLog(@"优惠券");
            NSString *subOrderId = [pendDic objectForKey:@"subOrderId"];
            NSString *orderId = [_datasSource objectForKey:@"pendingOrderId"];
            
            WS(weakSelf)
            NSDictionary *userInfo = @{@"subOrderId" : subOrderId,
                                       @"pendingOrderId" : orderId,
                                       @"couponDict": _couponDic
                                       };
            [MGJRouter openURL:@"/Mall/ChooseCoupons" withUserInfo:userInfo completion:^(id result) {
                NSMutableDictionary *newCouponDic = (NSMutableDictionary *)[result mutableCopy];
                NSString *oldcouponId = [NSString stringWithFormat:@"%@", weakSelf.couponDic[@"couponId"]];
                NSString *couponId = [NSString stringWithFormat:@"%@", newCouponDic[@"couponId"]];
                if ([oldcouponId isEqualToString:couponId]) {
                    return;
                }
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                if (newCouponDic.allKeys.count>0) {
                    [ESOrderAPI addPendingCouponWithCouponId:couponId SubOrderId:subOrderId Success:^(NSDictionary *dict) {
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                        weakSelf.couponDic = newCouponDic;
                        weakSelf.canUseGoldsNum = [NSString stringWithFormat:@"%@", dict[@"usedPointAmount"]?dict[@"usedPointAmount"]:@"0"];
                        [weakSelf.datasSource setValue:(dict[@"pendingAmount"]?dict[@"pendingAmount"]:@"") forKey:@"payAmount"];
                        [weakSelf.orderBar setOrderInfo:weakSelf.datasSource isCustom:YES];
                        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
                    } failure:^(NSError *error) {
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [self getErrorMessage:error]]];
                    }];
                } else {
                    [ESOrderAPI deletePendingCouponWithCouponId:oldcouponId SubOrderId:subOrderId Success:^(NSDictionary *dict) {
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                        weakSelf.couponDic = newCouponDic;
                        weakSelf.canUseGoldsNum = [NSString stringWithFormat:@"%@", dict[@"usedPointAmount"]?dict[@"usedPointAmount"]:@"0"];
                        [weakSelf.datasSource setValue:(dict[@"pendingAmount"]?dict[@"pendingAmount"]:@"") forKey:@"payAmount"];
                        [weakSelf.orderBar setOrderInfo:weakSelf.datasSource isCustom:YES];
                        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
                    } failure:^(NSError *error) {
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [self getErrorMessage:error]]];
                    }];
                }
            }];
            
        } else if (array.count+2 == indexPath.row) {
            _selectIndexPath = indexPath;
            SHLog(@"服务门店");
            [self refreshStorePickerViewWithSubOrderId:[NSString stringWithFormat:@"%@", pendDic[@"subOrderId"]?pendDic[@"subOrderId"]:@""]];
            
        } else if (array.count+3 == indexPath.row) {
            SHLog(@"买卖协议");
            ESSaleAgreementViewController *vc = [[ESSaleAgreementViewController alloc] init
                                                 ];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        [self callShopper];
    }
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
        if (weakSelf.serverStoreTitleArray.count>0) {
            weakSelf.storePicker = [[ESPickerView alloc] initPickviewWithArray:_serverStoreTitleArray];
            [weakSelf.storePicker setPickViewColer:[UIColor whiteColor]];
            weakSelf.storePicker.delegate = self;
        }
        [weakSelf.storePicker show];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshPickerView {
    NSArray *pendingOrders = [_datasSource objectForKey:@"pendingOrders"] ? [_datasSource objectForKey:@"pendingOrders"] : [NSArray array];
    NSDictionary *pendDic = [NSDictionary dictionary];
    if (pendingOrders.count>0) {
        pendDic = [pendingOrders objectAtIndex: 0];
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

- (void)toobarCancelBtnHaveClick:(ESPickerView *)pickView resultString:(NSString *)resultString {
    SHLog(@"%@", resultString);
    _selectIndexPath = nil;
}

- (void)toobarDonBtnHaveClick:(ESPickerView *)pickView resultString:(NSString *)resultString {
    SHLog(@"%@", resultString);
    if (_datePicker == pickView) {
        NSArray *arr = [_updateDic objectForKey:@"pendingOrders"] ? [_updateDic objectForKey:@"pendingOrders"] : [NSArray array];
        NSMutableArray *pendingOrders = [NSMutableArray arrayWithArray:arr];
        NSDictionary *pendDic = [NSDictionary dictionary];
        if (pendingOrders.count>_selectIndexPath.section-1) {
            pendDic = [pendingOrders objectAtIndex: _selectIndexPath.section-1];
        }
        [pendDic setValue:resultString forKey:@"dispatchTime"];
        if (pendingOrders.count>_selectIndexPath.section-1) {
            [pendingOrders replaceObjectAtIndex:_selectIndexPath.section-1 withObject:pendDic];
        }
        [_updateDic setObject:pendingOrders forKey:@"pendingOrders"];
        [self.tableView reloadRowsAtIndexPaths:@[_selectIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    } else  if (_storePicker == pickView) {
        
        NSMutableDictionary *serverStoreDic = [NSMutableDictionary dictionary];
        NSInteger index = [_serverStoreTitleArray indexOfObject:resultString];
        
        if (_serverStoreArray.count > index) {
            serverStoreDic = _serverStoreArray[index];
        }
        
        self.serverStoreDic = serverStoreDic;
        
        NSString *serverStoreId = @"";
        if (serverStoreDic.allKeys.count>0) {
            serverStoreId = [NSString stringWithFormat:@"%@", serverStoreDic[@"storeId"] ? serverStoreDic[@"storeId"] : @""];
        }
        
        NSArray *arr = [self.updateDic objectForKey:@"pendingOrders"] ? [self.updateDic objectForKey:@"pendingOrders"] : [NSArray array];
        NSMutableArray *pendingOrders = [NSMutableArray arrayWithArray:arr];
        NSMutableDictionary *pendDic = [NSMutableDictionary dictionary];
        if (pendingOrders.count>_selectIndexPath.section-1) {
            pendDic = [NSMutableDictionary dictionaryWithDictionary:[pendingOrders objectAtIndex: _selectIndexPath.section-1]];
        }
        if ([serverStoreId isEqualToString:@""]) {
            [pendDic removeObjectForKey:@"storeId"];
        } else {
            [pendDic setValue:serverStoreId forKey:@"storeId"];
        }
        
        
        if (pendingOrders.count>_selectIndexPath.section-1) {
            [pendingOrders replaceObjectAtIndex:_selectIndexPath.section-1 withObject:pendDic];
        }
        
        [self.updateDic setObject:pendingOrders forKey:@"pendingOrders"];
        [self.tableView reloadRowsAtIndexPaths:@[_selectIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    _selectIndexPath = nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
    [_datePicker remove];
    [_storePicker remove];
    if (scrollView == self.tableView) {
        CGFloat sectionHeaderHeight = 50; //sectionHeaderHeight
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
    
}

#pragma mark - ESSaleAgreementCellDelegate
- (BOOL)getSaleAgreementStatus:(NSIndexPath *)indexPath
{
    return _hasApproved;
}

#pragma mark - ESSaleAgreementViewControllerDelegate
- (void)saleAgreementAgreeButtonDidTapped
{
    _hasApproved = YES;
    [_tableView reloadData];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
