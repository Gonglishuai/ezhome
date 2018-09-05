//
//  ESReturnGoodsDetailController.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/11.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESReturnGoodsDetailController.h"
#import "ESReturnGoodsDetailView.h"
#import "ESReturnGoodsViewModel.h"
#import "MBProgressHUD.h"
#import <ESFoundation/DefaultSetting.h>
#import <ESBasic/ESDevice.h>
#import "ESOrderDetailPersonTableViewCell.h"
#import "MBProgressHUD+NJ.h"

@interface ESReturnGoodsDetailController ()<ESReturnGoodsDetailViewDelegate>
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) ESReturnGoodsDetailView *mainView;
@property (nonatomic, strong) ESReturnOrderDetail *order;
@property (strong, nonatomic) void (^myblock)(BOOL);
@property (assign, nonatomic) BOOL stateChanged;
@property (assign, nonatomic) BOOL isFromRecommend;
@end

@implementation ESReturnGoodsDetailController

- (instancetype)initWithOrderId:(NSString *)orderId Block:(void(^)(BOOL))block {
    self = [super init];
    if (self) {
        self.orderId = orderId;
        self.myblock = block;
    }
    return self;
}

- (void)setIsFromRecommendCon:(BOOL)isFromRecommend {
    _isFromRecommend = isFromRecommend;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = @"退款订单详情";
    self.rightButton.hidden = YES;
    _stateChanged = NO;
    self.mainView = [[ESReturnGoodsDetailView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBAR_HEIGHT)];
    self.mainView.delegate = self;
    [self.view addSubview:self.mainView];
    
    [self initData];
}

- (void)initData {
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:self.mainView animated:YES];
    [ESReturnGoodsViewModel retrieveReturnGoodsDetailWithId:self.orderId withSuccess:^(ESReturnOrderDetail *order) {
        [MBProgressHUD hideHUDForView:weakSelf.mainView animated:YES];
        [weakSelf removeNoDataView];
        weakSelf.order = order;
        [weakSelf.mainView refreshMainView];
        if (weakSelf.isFromRecommend) {
            [weakSelf.mainView showBottomView:NO];
        } else {
            [weakSelf.mainView showBottomView:order.processStatus == ESReturnGoodsTypeFinished];
        }
    } andFailure:^{
        [MBProgressHUD hideHUDForView:weakSelf.mainView animated:YES];
        NSString *title = [NSString stringWithFormat:@"网络有问题\n刷新一下试试吧"];
        CGRect frame = CGRectMake(0, 0, weakSelf.mainView.frame.size.width, weakSelf.mainView.frame.size.height);
        [weakSelf showNoDataIn:weakSelf.mainView imgName:@"nodata_net" frame:frame Title:title buttonTitle:@"刷新" Block:^{
            [weakSelf initData];
        }];
    }];
}

#pragma mark - Override
- (void)tapOnLeftButton:(id)sender {
    if (_myblock && _stateChanged) {
        _myblock(_stateChanged);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    SHLog(@"--------");
    if (_myblock && _stateChanged) {
        _myblock(_stateChanged);
        _stateChanged = NO;
    }
    return YES;
}


#pragma mark - ESReturnGoodsDetailViewDelegate
- (NSInteger)getSectionNums {
    if (!self.order) {
        return 0;
    }
    if (_isFromRecommend) {
        return 6;
    } else {
        return 5;
    }
    
}

- (NSInteger)getItemsNums:(NSInteger)section {
    if (section == 2) {
        return [ESReturnGoodsViewModel getCommodityNumsWithOrder:self.order] + 1;
    }
    return 1;
}

- (BOOL)getFromRecommend {
    return _isFromRecommend;
}
- (__kindof UITableViewCell *)getCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {//状态栏
        cell = [tableView dequeueReusableCellWithIdentifier:@"ESOrderStatusCell"];
        ESOrderStatusCell *statusCell = (ESOrderStatusCell *)cell;
        statusCell.delegate = (id)self.mainView.delegate;
        [statusCell updateStatusCell];
    }else if (indexPath.section == 1) {//实退金额/退款拒绝原因
        ESReturnGoodsType type = [ESReturnGoodsViewModel getOrderTypeWithOrder:self.order];
        if (type == ESReturnGoodsTypeRefuse) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ESOrderDescriptionCell"];
            ESOrderDescriptionCell *reasonCell = (ESOrderDescriptionCell *)cell;
            reasonCell.delegate = (id)self.mainView.delegate;
            [reasonCell updateDescriptionCell];
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ESReturnGoodsPriceCell"];
            ESReturnGoodsPriceCell *priceCell = (ESReturnGoodsPriceCell *)cell;
            priceCell.delegate = (id)self.mainView.delegate;
            [priceCell updateCell];
        }
    }else if (indexPath.section == 2) {
        if (indexPath.row == 0) {//品牌信息
            cell = [tableView dequeueReusableCellWithIdentifier:@"ESTitleTableViewCell"];
            ESTitleTableViewCell *brandCell = (ESTitleTableViewCell *)cell;
            NSString *brand = [ESReturnGoodsViewModel getBrandName:self.order];
            [brandCell setTitle:brand textColor:[UIColor blackColor] font:[UIFont fontWithName:@"PingFangSC-Regular" size:13.0f]];
        }else {//商品
            cell = [tableView dequeueReusableCellWithIdentifier:@"ESReturnGoodsItemCell"];
            ESReturnGoodsItemCell *itemCell = (ESReturnGoodsItemCell *)cell;
            itemCell.delegate = (id)self.mainView.delegate;
            [itemCell updateItemCell:indexPath.row];
        }
    }else if (indexPath.section == 3) {//联系商家
        cell = [tableView dequeueReusableCellWithIdentifier:@"ESClickCell"];
        ESClickCell *clickCell = (ESClickCell *)cell;
        NSString *number = [ESReturnGoodsViewModel getContactNumberWithOrder:self.order];
        [clickCell setTitle:@"联系商家" subTitle:number subTitleColor:[UIColor stec_phoneTextColor]];
    } else if (indexPath.section == 4) {//订单信息
        cell = [tableView dequeueReusableCellWithIdentifier:@"ESReturnGoodsOrderInfoCell"];
        ESReturnGoodsOrderInfoCell *orderInfoCell = (ESReturnGoodsOrderInfoCell *)cell;
        orderInfoCell.delegate = (id)self.mainView.delegate;
        [orderInfoCell updateOrderInfoCell];
    } else if (indexPath.section == 5) {//客户信息
        cell = [tableView dequeueReusableCellWithIdentifier:@"ESOrderDetailPersonTableViewCell"];
        ESOrderDetailPersonTableViewCell *personInfoCell = (ESOrderDetailPersonTableViewCell *)cell;
        
        NSString *avatar = [NSString stringWithFormat:@"%@", self.order.consumerAvatar? self.order.consumerAvatar : @""];
        NSString *nickName = [NSString stringWithFormat:@"客户姓名：%@", self.order.consumerName ? self.order.consumerName : @"客户姓名"];
        NSString *phoneNum = [NSString stringWithFormat:@"%@", self.order.consumerMobile ? self.order.consumerMobile : @""];
        [personInfoCell setAvatar:avatar name:nickName phone:phoneNum phoneBlock:^(NSString *phoneNum) {
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
    }
    return cell;
}

- (void)didSelectCellWithCellClass:(NSString *)className {
    if ([className isEqualToString:@"ESClickCell"]) {
        NSString *phoneNum = [ESReturnGoodsViewModel getContactNumberWithOrder:self.order];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNum]];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)confirmReturnTap {
    WS(weakSelf);
    NSString *title = self.order.returnType == ESReturnTypeGoodsAndMoney?@"是否确定退货退款?":@"是否确定退款?";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [weakSelf returnMoney];
                                                   }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
}

- (void)returnMoney {
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:self.mainView animated:YES];
    [ESReturnGoodsViewModel confirmReturnGoodsWithOrderId:self.orderId withSuccess:^{
        [MBProgressHUD hideHUDForView:weakSelf.mainView animated:YES];
        [weakSelf showSuccessHUD:@"确认成功!"];
        weakSelf.stateChanged = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    } andFailure:^{
        [MBProgressHUD hideHUDForView:weakSelf.mainView animated:YES];
        [weakSelf showSuccessHUD:@"确认失败, 请稍后重试!"];
    }];
}

#pragma mark - ESOrderStatusCellDelegate
- (NSString *)getStatusBackImg {
    return [ESReturnGoodsViewModel getOrderStatusBackImg:self.order];
}

- (NSString *)getStatusTitle {
    return [ESReturnGoodsViewModel getOrderStatusTitle:self.order];
}

#pragma mark - ESOrderDescriptionCellDelegate
- (NSString *)getDescription {
    return [ESReturnGoodsViewModel getOrderRefuseReason:self.order];
}

#pragma mark - ESReturnGoodsPriceCellDelegate
- (NSString *)getReturnGoodsPriceTitle {
    return [ESReturnGoodsViewModel getReturnPriceTitle:self.order];
}

- (NSString *)getReturnGoodsPrice {
    return [ESReturnGoodsViewModel getReturnPrice:self.order];
}

#pragma mark - ESReturnGoodsItemCellDelegate
- (NSString *)getItemImage:(NSInteger)index {
    return [ESReturnGoodsViewModel getItemImage:index withOrder:self.order];
}

- (NSString *)getItemName:(NSInteger)index {
    return [ESReturnGoodsViewModel getItemName:index withOrder:self.order];
}

- (NSString *)getItemPrice:(NSInteger)index {
    return [ESReturnGoodsViewModel getItemPrice:index withOrder:self.order];
}

- (NSString *)getItemQuantity:(NSInteger)index {
    return [ESReturnGoodsViewModel getItemQuantity:index withOrder:self.order];
}

- (NSString *)getItemSKU:(NSInteger)index {
    return [ESReturnGoodsViewModel getItemSKU:index withOrder:self.order];
}

- (NSString *)getReturnAmount:(NSInteger)index {
    return [ESReturnGoodsViewModel getReturnAmount:index withOrder:self.order];
}

#pragma mark - ESReturnGoodsOrderInfoCellDelegate
- (NSString *)getOrderNo {
    return [ESReturnGoodsViewModel getOrderNoWithOrder:self.order];
}

- (NSString *)getOrderCreateTime {
    return [ESReturnGoodsViewModel getOrderCreateTimeWithOrder:self.order];
}

- (NSString *)getOrderReturnAmount {
    return [ESReturnGoodsViewModel getOrderReturnAmountWithOrder:self.order];
}

- (NSString *)getOrderReturnReason {
    return [ESReturnGoodsViewModel getOrderReturnReasonWithOrder:self.order];
}

- (NSString *)getServiceStore {
    return [ESReturnGoodsViewModel getOrderServiceStoreWithOrder:self.order];
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
