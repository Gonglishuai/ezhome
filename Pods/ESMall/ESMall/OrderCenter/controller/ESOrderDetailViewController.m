//
//  ESOrderDetailViewController.m
//  Consumer
//
//  Created by jiang on 2017/6/27.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESOrderDetailViewController.h"
#import "ESLabelHeaderFooterView.h"

#import "ESOrderStateCell.h"
#import "ESTitleSubTitleTableViewCell.h"
#import "ESLabelTableViewCell.h"
#import "ESOrderProductCell.h"
#import "ESPreferentCell.h"
#import "ESThreeLabelCell.h"
#import "ESNoClickCell.h"
#import "ESClickCell.h"
#import "ESSaleAgreementCell.h"

#import "ESOrderDetailTabbar.h"
#import "ESGrayTableViewHeaderFooterView.h"
#import "ESReceiptViewController.h"
#import "ESProductDetailViewController.h"

#import "ESOrderAPI.h"
#import "MBProgressHUD+NJ.h"
#import "ESLabelDownHeaderFooterView.h"
#import "ESReturnGoodsApplyController.h"
#import "ESSaleAgreementViewController.h"
#import "ESPayTimesViewController.h"
#import "ESTitleSubTitleTableViewCell.h"

#import "ESOrderDetailPersonTableViewCell.h"

@interface ESOrderDetailViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
UIGestureRecognizerDelegate,
ESSaleAgreementCellDelegate
>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) ESOrderDetailTabbar *orderBar;
@property (copy, nonatomic) NSString *orderId;
@property (strong, nonatomic) NSMutableDictionary *datasSource;
@property (strong, nonatomic) void (^myblock)(BOOL);
@property (assign, nonatomic) BOOL stateChanged;
@property (assign, nonatomic) BOOL isFromRecommend;
@end

@implementation ESOrderDetailViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.rightButton.hidden = YES;
    self.titleLabel.text = @"订单详情";
    _stateChanged = NO;
    // Do any additional setup after loading the view.
    _datasSource = [NSMutableDictionary dictionary];
    [self setTableView];
    [self getOrderInfo];
}


- (void)setOrderId:(NSString *)orderId Block:(void(^)(BOOL))block {
    _orderId = orderId;
    _myblock = block;
}

- (void)setIsFromRecommendCon:(BOOL)isFromRecommend {
    _isFromRecommend = isFromRecommend;
}

- (void)setTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-TABBAR_HEIGHT-BOTTOM_SAFEAREA_HEIGHT) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"ESOrderStateCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESOrderStateCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESTitleSubTitleTableViewCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESTitleSubTitleTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESLabelTableViewCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESLabelTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESClickCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESClickCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESSaleAgreementCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESSaleAgreementCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESNoClickCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESNoClickCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESTitleSubTitleTableViewCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESTitleSubTitleTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESOrderProductCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESOrderProductCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESPreferentCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESPreferentCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESThreeLabelCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESThreeLabelCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"UITableViewCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"UITableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESOrderDetailPersonTableViewCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESOrderDetailPersonTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESLabelHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESLabelHeaderFooterView"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESLabelDownHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESLabelDownHeaderFooterView"];
    
    [_tableView registerNib:[UINib nibWithNibName:@"ESGrayTableViewHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESGrayTableViewHeaderFooterView"];
    //    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 250.0f;
    _tableView.separatorColor = [UIColor stec_lineGrayColor];
    [self.view addSubview:_tableView];
    WS(weakSelf)
    _orderBar = [ESOrderDetailTabbar creatWithFrame:CGRectMake(0, SCREEN_HEIGHT-TABBAR_HEIGHT-BOTTOM_SAFEAREA_HEIGHT, SCREEN_WIDTH, TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT) Info:nil block:^(ESOrderTabbarBtnType orderTabbarBtnType) {
        switch (orderTabbarBtnType) {
            case ESOrderTabbarBtnTypeCancel: {//取消订单
                SHLog(@"取消订单");
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"您确定要取消该订单?" message:nil preferredStyle:UIAlertControllerStyleAlert];
                // Create the actions.
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil)
                                                                       style:UIAlertActionStyleCancel
                                                                     handler:nil];
                
                UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil)
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
                                                                   [weakSelf cancelOrder];
                                                               }];
                
                [alertController addAction:cancelAction];
                [alertController addAction:action];
                [weakSelf presentViewController:alertController animated:YES completion:nil];
                break;
            }
            case ESOrderTabbarBtnTypePay: {//去支付
                SHLog(@"去支付");
                NSString *orderId = [NSString stringWithFormat:@"%@",([weakSelf.datasSource objectForKey:@"ordersId"] ? [weakSelf.datasSource objectForKey:@"ordersId"] : @"")];
                //                NSString *factAccount = [NSString stringWithFormat:@"%@",([weakSelf.datasSource objectForKey:@"payAmount"] ? [weakSelf.datasSource objectForKey:@"payAmount"] : @"0.00")];
                double pay = [[NSString stringWithFormat:@"%@", (weakSelf.datasSource[@"unPaidAmount"] ? weakSelf.datasSource[@"unPaidAmount"] : @"0.00")] doubleValue];
                NSString *factAccount = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%.2f",pay]];
                NSString *orderStatus = [NSString stringWithFormat:@"%@",([weakSelf.datasSource objectForKey:@"orderStatus"] ? [weakSelf.datasSource objectForKey:@"orderStatus"] : @"")];
                NSString *orderType = [NSString stringWithFormat:@"%@",([weakSelf.datasSource objectForKey:@"orderType"] ? [weakSelf.datasSource objectForKey:@"orderType"] : @"")];
                NSString *brandId = [NSString stringWithFormat:@"%@",([weakSelf.datasSource objectForKey:@"brandId"] ? [weakSelf.datasSource objectForKey:@"brandId"] : @"")];
                [weakSelf goPayWithOrderId:orderId brandId:brandId payAmount:factAccount orderStatus:orderStatus orderType:orderType];
                break;
            }
            case ESOrderTabbarBtnTypeDrawback: {//申请退款
                SHLog(@"申请退款");
                NSString *orderId = [NSString stringWithFormat:@"%@",([weakSelf.datasSource objectForKey:@"ordersId"] ? [weakSelf.datasSource objectForKey:@"ordersId"] : @"")];
                ESReturnGoodsApplyController *returnGoodsApplyCon = [[ESReturnGoodsApplyController alloc] initWithOrderId:orderId];
                [weakSelf.navigationController pushViewController:returnGoodsApplyCon animated:YES];
                
                break;
            }
            case ESOrderTabbarBtnTypeGetPage: {//确认收货
                SHLog(@"确认收货");
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否确认已收货?" message:nil preferredStyle:UIAlertControllerStyleAlert];
                // Create the actions.
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil)
                                                                       style:UIAlertActionStyleCancel
                                                                     handler:nil];
                
                UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil)
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
                                                                   [weakSelf getGoods];
                                                               }];
                
                [alertController addAction:cancelAction];
                [alertController addAction:action];
                [weakSelf presentViewController:alertController animated:YES completion:nil];
                break;
            }
            case ESOrderTabbarBtnTypeGetServer: {//确认服务
                SHLog(@"确认服务");
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否确认已服务?" message:nil preferredStyle:UIAlertControllerStyleAlert];
                // Create the actions.
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil)
                                                                       style:UIAlertActionStyleCancel
                                                                     handler:nil];
                
                UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil)
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
                                                                   [weakSelf getGoods];
                                                               }];
                
                [alertController addAction:cancelAction];
                [alertController addAction:action];
                [weakSelf presentViewController:alertController animated:YES completion:nil];
                break;
            }
            default:
                break;
        }
    }];
    [self.view addSubview:_orderBar];
    if (_isFromRecommend) {
        _orderBar.hidden = YES;
    }
}


- (void)getOrderInfo {//获取订单详情
    WS(weakSelf)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESOrderAPI getOrderDetailWithOrderId:self.orderId Success:^(NSDictionary *dict) {
        SHLog(@"%@", dict);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        _datasSource = [NSMutableDictionary dictionaryWithDictionary:dict];
        [_tableView reloadData];
        [_orderBar setOrderInfo:_datasSource];
        NSString *orderState = [NSString stringWithFormat:@"%@", [_datasSource objectForKey:@"orderStatus"]];
        NSString *canRefund = [NSString stringWithFormat:@"%@", [_datasSource objectForKey:@"canRefund"]];
        if ([orderState isEqualToString:@"50"] || [orderState isEqualToString:@"51"] || [canRefund isEqualToString:@"0"] || weakSelf.isFromRecommend) {
            _orderBar.hidden = YES;
            _tableView.frame = CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT);
        } else {
            _orderBar.hidden = NO;
            _tableView.frame = CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-TABBAR_HEIGHT);
        }
        [weakSelf removeNoDataView];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf showNoDataIn:weakSelf.view imgName:@"nodata_net" frame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) Title:@"网络有问题\n刷新一下试试吧" buttonTitle:@"刷新" Block:^{
            [weakSelf getOrderInfo];
        }];
    }];
}
- (void)cancelOrder {
    WS(weakSelf)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [ESOrderAPI cancelOrderWithOrderId:self.orderId Success:^(NSDictionary *dict) {
        SHLog(@"%@", dict);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showSuccess:@"取消成功"];
        weakSelf.stateChanged = YES;
        [weakSelf getOrderInfo];
    } failure:^(NSError *error) {
        SHLog(@"%@", error);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [self getErrorMessage:error]]];
    }];
}
- (void)getGoods {
    WS(weakSelf)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESOrderAPI getGoodsWithOrderId:self.orderId Success:^(NSDictionary *dict) {
        SHLog(@"%@", dict);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showSuccess:@"确认成功"];
        weakSelf.stateChanged = YES;
        [weakSelf getOrderInfo];
    } failure:^(NSError *error) {
        SHLog(@"%@", error);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [self getErrorMessage:error]]];
    }];
}

- (void)goPayWithOrderId:(NSString *)orderId
                 brandId:(NSString *)brandId
               payAmount:(NSString *)payAmount
             orderStatus:(NSString *)orderStatus
               orderType:(NSString *)orderType {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WS(weakSelf)
    [ESOrderAPI goPayWithOrderId:orderId brandId:brandId Success:^(NSDictionary *dict) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSDictionary *resultDic = [NSDictionary dictionaryWithDictionary:([dict objectForKey:@"data"] ? [dict objectForKey:@"data"]:[NSDictionary dictionary])];
        NSString *orId = [NSString stringWithFormat:@"%@",([resultDic objectForKey:@"payOrderId"] ? [resultDic objectForKey:@"payOrderId"] : @"")];
        
        NSDictionary *loanDic = [NSDictionary dictionaryWithDictionary:([resultDic objectForKey:@"loan"] ? [resultDic objectForKey:@"loan"]:[NSDictionary dictionary])];
                                                                                                                                            
        ESPayTimesType type = ESPayTimesTypeFirst;
        if ([orderStatus isEqualToString:@"15"] || [orderStatus isEqualToString:@"16"]) {
            type = ESPayTimesTypeAgain;
        }
        
        BOOL partPayment = YES;
        if ([orderType isEqualToString:@"5"]) {//定金订单不能分笔支付
            partPayment = NO;
        }
        ESPayTimesViewController *payTimesViewCon = [[ESPayTimesViewController alloc] initWithOrderId:orderId payOrderId:orId brandId:brandId amount:payAmount partPayment:partPayment loanDic:loanDic payType:ESPayTypeMaterial payTimesType:type];
        [self.navigationController pushViewController:payTimesViewCon animated:YES];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [self getErrorMessage:error]]];
    }];
}

- (void)tapOnLeftButton:(id)sender {
    if (_myblock && _stateChanged) {
        _myblock(_stateChanged);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_isFromRecommend) {
        return 8;
    } else {
        return 7;
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (2 == section) {
        return 0;
    } else if (3 == section) {
        NSMutableArray *array = [_datasSource objectForKey:@"orderItemList"];
        return array.count+6;
    } else if (6 == section) {
        NSMutableArray *array = [_datasSource objectForKey:@"payList"];
        if ([array isKindOfClass:[NSArray class]]) {
            return array.count;
        }
        return 0;
    } else {
        return 1;
    }
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (0 == section || 4 == section || 5 == section || 6 == section || 7 == section) {
        return 0.0001;
    } else {
        return 50;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (3 == section || 4 == section || 5 == section || 6 == section || 7 == section) {
        return 10;
    } else {
        return 0.001;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 1: {
            ESLabelDownHeaderFooterView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESLabelDownHeaderFooterView"];
            [header setTitle:@"收货人" titleColor:[UIColor stec_subTitleTextColor] backColor:[UIColor stec_viewBackgroundColor]];
            return header;
            break;
        }
        case 2:{
            ESLabelDownHeaderFooterView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESLabelDownHeaderFooterView"];
            [header setTitle:@"商品清单" titleColor:[UIColor stec_subTitleTextColor] backColor:[UIColor stec_viewBackgroundColor]];
            return header;
            break;
        }
        case 3:{
            NSString * brandName = [NSString stringWithFormat:@"%@", _datasSource[@"brandName"] ? _datasSource[@"brandName"] : @""];
            ESLabelHeaderFooterView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESLabelHeaderFooterView"];
            [header setTitle:brandName titleColor:[UIColor stec_titleTextColor] subTitle:nil subTitleColor:nil backColor:[UIColor whiteColor]];
            header.lineLabel.hidden = NO;
            return header;
            break;
        }
        default:{
            ESLabelHeaderFooterView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESLabelHeaderFooterView"];
            [header setTitle:@"" titleColor:[UIColor stec_titleTextColor] subTitle:nil subTitleColor:nil backColor:[UIColor whiteColor]];
            header.lineLabel.hidden = YES;
            return header;
            break;
        }
    }
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ESGrayTableViewHeaderFooterView *footer = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
    
    [footer setBackViewColor:[UIColor stec_viewBackgroundColor]];
    return footer;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        
        ESOrderStateCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESOrderStateCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (_datasSource.allKeys.count>0) {
            [cell setOrderInfo:_datasSource];
        }
        
        return cell;
    } else if (1 == indexPath.section) {
        ESTitleSubTitleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESTitleSubTitleTableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *address = [NSString stringWithFormat:@"%@ %@ %@ %@", [_datasSource objectForKey:@"province"], [_datasSource objectForKey:@"city"], [_datasSource objectForKey:@"region"], [_datasSource objectForKey:@"addressDetail"]];
        [cell setTitle:[_datasSource objectForKey:@"name"] subTitle:address];
        return cell;
    } else if (2 == indexPath.section) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (3 == indexPath.section) {
        NSMutableArray *array = [_datasSource objectForKey:@"orderItemList"];
        if (indexPath.row < array.count) {
            ESOrderProductCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESOrderProductCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSString *orderType = [NSString stringWithFormat:@"%@", [_datasSource objectForKey:@"orderType"]];
            [cell setProductInfo:[array objectAtIndex:indexPath.row] orderType:orderType isFromMakeSureController:NO];
            if (indexPath.row == array.count-1) {
                cell.separatorInset = UIEdgeInsetsMake(0, 0, SCREEN_WIDTH, 1);
            } else {
                cell.separatorInset = UIEdgeInsetsMake(0, 15, SCREEN_WIDTH-30, 15);
            }
            return cell;
        } else if (array.count == indexPath.row) {
            ESLabelTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESLabelTableViewCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSString *orderType = [NSString stringWithFormat:@"%@", [_datasSource objectForKey:@"orderType"]];
            NSString *title = @"配送时间:";
            if ([orderType isEqualToString:@"0"]) {
                title = @"服务时间:";
            }
            NSString *dispatchTime = [_datasSource objectForKey:@"dispatchTime"];
            if (dispatchTime == nil || [dispatchTime isKindOfClass:[NSNull class]]) {
                dispatchTime = @"";
            }
            [cell setTitle:title subTitle:dispatchTime subTitleColor:[UIColor stec_titleTextColor]];
            return cell;
        } else if (array.count+1 == indexPath.row) {
            ESNoClickCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESNoClickCell" forIndexPath:indexPath];
            NSString *storeName = [_datasSource objectForKey:@"storeName"];
            if (![storeName isKindOfClass:[NSString class]]) {
                storeName = @"";
            }
            
            [cell setTitle:@"服务门店" subTitle:storeName subTitleColor:[UIColor stec_subTitleTextColor]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (array.count+2 == indexPath.row) {
            
            ESClickCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESClickCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;//展示有箭头，需加逻辑判断
            NSString *invoiceId = [NSString stringWithFormat:@"%@", ([_datasSource objectForKey:@"invoiceId"] ? [_datasSource objectForKey:@"invoiceId"] : @"")];
            if ([invoiceId isEqualToString:@""]) {
                [cell setTitle:@"发票信息:" subTitle:@"不开具发票" subTitleColor:[UIColor stec_subTitleTextColor]];
            } else if ([invoiceId isEqualToString:@"0"]) {
                [cell setTitle:@"发票信息:" subTitle:@"纸质发票 个人" subTitleColor:[UIColor stec_subTitleTextColor]];
            } else {
                NSString *invoiceType = [NSString stringWithFormat:@"%@", [_datasSource objectForKey:@"invoiceType"]?[_datasSource objectForKey:@"invoiceType"]:@""];
                NSString *invoiceTitle = [NSString stringWithFormat:@"%@", [_datasSource objectForKey:@"invoiceTitle"]?[_datasSource objectForKey:@"invoiceTitle"]:@""];
                if ([invoiceTitle isEqualToString:@"个人"]) {
                    [cell setTitle:@"发票信息:" subTitle:@"纸质发票 个人" subTitleColor:[UIColor stec_subTitleTextColor]];
                } else if ([invoiceType isEqualToString:@"0"]) {
                    [cell setTitle:@"发票信息:" subTitle:@"纸质发票 普票" subTitleColor:[UIColor stec_subTitleTextColor]];
                } else if ([invoiceType isEqualToString:@"1"]) {
                    [cell setTitle:@"发票信息:" subTitle:@"纸质发票 增值税" subTitleColor:[UIColor stec_subTitleTextColor]];
                } else if ([invoiceType isEqualToString:@"2"]){
                    [cell setTitle:@"发票信息:" subTitle:@"纸质发票 专票" subTitleColor:[UIColor stec_subTitleTextColor]];
                } else {
                    [cell setTitle:@"发票信息:" subTitle:@"不开具发票" subTitleColor:[UIColor stec_subTitleTextColor]];
                }
            }
            
            return cell;
        } else if (array.count+3 == indexPath.row) {
            // 买卖协议
            static NSString *cellID = @"ESSaleAgreementCell";
            ESSaleAgreementCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID
                                                                        forIndexPath:indexPath];
            cell.cellDelegate = self;
            [cell updateSaleAgreementCellWithIndex:indexPath];
            return cell;
            
        } else if (array.count+4 == indexPath.row) {
            ESLabelTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESLabelTableViewCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSString *remark = [_datasSource objectForKey:@"remark"];
            if ([remark isKindOfClass:[NSString class]]) {
            } else {
                remark = @"";
            }
            [cell setTitle:@"买家留言:" subTitle:remark subTitleColor:[UIColor stec_subTitleTextColor]];
            return cell;
        } else {
            ESPreferentCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESPreferentCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setPreferentInfo:_datasSource];
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, MAXFLOAT);
            return cell;
        }
        
    } else if(4 == indexPath.section) {
        ESClickCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESClickCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *num = [_datasSource objectForKey:@"contactMobile"];
        NSString *phoneNum = @"暂无商家电话";
        UIColor *subColor = [UIColor stec_subTitleTextColor];
        if ([num isKindOfClass:[NSString class]] && num.length>0) {
            phoneNum = num;
            subColor = [UIColor stec_blueTextColor];
        }
        
        [cell setTitle:@"联系商家:" subTitle:phoneNum subTitleColor:subColor];
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, MAXFLOAT);
        return cell;
    }  else if(5 == indexPath.section) {
        ESTitleSubTitleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESTitleSubTitleTableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *ordersId = [NSString stringWithFormat:@"订单号: %@", [_datasSource objectForKey:@"ordersId"]];
        NSString *createTime = [NSString stringWithFormat:@"下单时间: %@", [_datasSource objectForKey:@"createTime"]];
        
        [cell setTitle:ordersId subTitle:createTime titleColor:[UIColor stec_contentTextColor] subTitleColor:[UIColor stec_contentTextColor]];
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, MAXFLOAT);
        return cell;
    } else if (6 == indexPath.section) {
        
        NSMutableArray *array = [_datasSource objectForKey:@"payList"];
        ESThreeLabelCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESThreeLabelCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([array isKindOfClass:[NSArray class]]) {
            if (array.count>indexPath.row) {
                NSDictionary *dic = array[indexPath.row];
                NSString *payTypeDesc = [NSString stringWithFormat:@"%@", [dic objectForKey:@"payMethod"]];
                NSString *contentTitle = [NSString stringWithFormat:@"付款方式: %@", [dic objectForKey:@"payMethod"]];
                if ([payTypeDesc isEqualToString:@""] || payTypeDesc.length<1) {
                    contentTitle = @"";
                }
                
                double payAmount = [[NSString stringWithFormat:@"%@", (dic[@"payAmount"] ? dic[@"payAmount"] : @"0.00")] doubleValue];
                NSString *factAccount = [NSString stringWithFormat:@"付款金额: ￥%@",[NSString stringWithFormat:@"%.2f",payAmount]];
                
                [cell setTitle:[NSString stringWithFormat:@"交易流水号: %@", ([dic objectForKey:@"orderSerialNumber"]?[dic objectForKey:@"orderSerialNumber"]:@"")] subTitle:[NSString stringWithFormat:@"支付时间: %@", [dic objectForKey:@"payTime"]] priceTitle:factAccount contentTitle:contentTitle];
            }
            
        }
        
        if (array.count == indexPath.row+1) {
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, MAXFLOAT);
        } else {
            cell.separatorInset = UIEdgeInsetsMake(0, 0, SCREEN_WIDTH, 1);
        }
        
        
        return cell;
    }  else {
        ESOrderDetailPersonTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESOrderDetailPersonTableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *avatar = [NSString stringWithFormat:@"%@", _datasSource[@"consumerAvatar"] ? _datasSource[@"consumerAvatar"] : @""];
        NSString *nickName = [NSString stringWithFormat:@"客户姓名：%@", _datasSource[@"consumerName"] ? _datasSource[@"consumerName"] : @""];
        NSString *phoneNum = [NSString stringWithFormat:@"%@", _datasSource[@"consumerMobile"] ? _datasSource[@"consumerMobile"] : @""];
        [cell setAvatar:avatar name:nickName phone:phoneNum phoneBlock:^(NSString *phoneNum) {
            if (phoneNum.length>0) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNum]];
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:url];
                }
            } else {
                [MBProgressHUD showError:@"手机号码为空"];
            }
            
        }];
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, MAXFLOAT);
        return cell;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.section) {
        return 90;
    } else if (1 == indexPath.section) {
        return 70;
    } else if (2 == indexPath.section) {
        return 0.001;
    } else if (3 == indexPath.section) {
        NSMutableArray *array = [_datasSource objectForKey:@"orderItemList"];
        if (indexPath.row < array.count) {
            return 130;
        } else if (array.count+5 == indexPath.row) {
            return UITableViewAutomaticDimension;
        } else {
            return 50;
        }
    } else if (4 == indexPath.section) {
        return 50;
    } else if (5 == indexPath.section) {
        return 70;
    } else if (6 == indexPath.section) {
        return 150;
    } else {
        return 50;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray *array = [_datasSource objectForKey:@"orderItemList"];
    if (3 == indexPath.section && (array.count+2 == indexPath.row)) {
        NSString *invoiceType = [NSString stringWithFormat:@"%@", [_datasSource objectForKey:@"invoiceType"]];
        NSString *invoiceTitle = [NSString stringWithFormat:@"%@", [_datasSource objectForKey:@"invoiceTitle"]?[_datasSource objectForKey:@"invoiceTitle"]:@""];
        NSString *invoiceId = [NSString stringWithFormat:@"%@", [_datasSource objectForKey:@"invoiceId"]?[_datasSource objectForKey:@"invoiceId"]:@""];
        
        if ([invoiceType isEqualToString:@"0"] || [invoiceType isEqualToString:@"1"] || [invoiceType isEqualToString:@"2"] || [invoiceTitle isEqualToString:@"个人"] || [invoiceId isEqualToString:@"0"]) {
            ESReceiptViewController *receiptViewCon = [[ESReceiptViewController alloc] init];
            NSString *invoiceId = [NSString stringWithFormat:@"%@", ([_datasSource objectForKey:@"invoiceId"] ? [_datasSource objectForKey:@"invoiceId"] : @"")];
            [receiptViewCon setInvoiceId:invoiceId];
            [self.navigationController pushViewController:receiptViewCon animated:YES];
        } else {
            [MBProgressHUD showSuccess:@"此订单没有发票信息"];
        }
        
        
    } else if (3 == indexPath.section && (array.count+3 == indexPath.row)) {
        
        ESSaleAgreementViewController *vc = [[ESSaleAgreementViewController alloc] init
                                             ];
        vc.hasApproved = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (3 == indexPath.section && (indexPath.row < array.count)) {
        NSDictionary *pruinfo = [array objectAtIndex:indexPath.row];
        ESProductDetailViewController *productDetailViewCon = [[ESProductDetailViewController alloc] initWithProductId:[pruinfo objectForKey:@"itemId"] type:ESProductDetailTypeSpu designerId:nil];
        [self.navigationController pushViewController:productDetailViewCon animated:YES];
    } else if (4 == indexPath.section && 0 == indexPath.row) {
        NSString *phoneNum = [NSString stringWithFormat:@"%@", ([_datasSource objectForKey:@"contactMobile"] != [NSNull null]) ? [_datasSource objectForKey:@"contactMobile"] : @""];
        if (phoneNum == nil || [phoneNum isEqualToString:@""] || phoneNum.length < 1) {
            //            [MBProgressHUD showError:@"暂无商家电话"];
            return;
        }
        if (phoneNum == nil || [phoneNum isEqualToString:@""] || phoneNum.length < 1) {
            return;
        }
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNum]];
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url] ;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        CGFloat sectionHeaderHeight = 50; //sectionHeaderHeight
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    SHLog(@"--------");
    if (_myblock && _stateChanged) {
        _myblock(_stateChanged);
        _stateChanged = NO;
    }
    return YES;
}

#pragma mark - ESSaleAgreementCellDelegate
- (BOOL)getSaleAgreementStatus
{
    return YES;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
