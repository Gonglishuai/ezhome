//
//  ESReturnGoodsApplyController.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/11.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESReturnGoodsApplyController.h"
#import "ESReturnGoodsApplyView.h"
#import "ESReturnGoodsApplyViewModel.h"
#import "MBProgressHUD.h"
#import "ESReturnApplySuccessController.h"
#import <ESBasic/ESDevice.h>
#import <ESFoundation/DefaultSetting.h>

@interface ESReturnGoodsApplyController ()<ESReturnGoodsApplyViewDelegate>
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) ESReturnGoodsApplyView *mainView;
@property (nonatomic, strong) ESReturnApplyOrderInfo *orderInfo;
@end

@implementation ESReturnGoodsApplyController

- (instancetype)initWithOrderId:(NSString *)orderId {
    self = [super init];
    if (self) {
        self.orderId = orderId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"申请退款";
    self.rightButton.hidden = YES;
    self.mainView = [[ESReturnGoodsApplyView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBAR_HEIGHT)];
    self.mainView.delegate = self;
    [self.view addSubview:self.mainView];
    
    [self addKeyboardListener];
    
    [self initData];
}

- (void)addKeyboardListener {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardBounds = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.mainView.tableView.contentInset = UIEdgeInsetsMake(self.mainView.tableView.contentInset.top, 0, keyboardBounds.size.height, 0);
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.mainView.tableView.contentInset = UIEdgeInsetsMake(self.mainView.tableView.contentInset.top, 0, 0, 0);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)initData {
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:self.mainView animated:YES];
    [ESReturnGoodsApplyViewModel retrieveRefundOrderInfoWithOrderId:self.orderId withSuccess:^(ESReturnApplyOrderInfo *orderInfo) {
        [MBProgressHUD hideHUDForView:weakSelf.mainView animated:YES];
        [weakSelf removeNoDataView];
        weakSelf.orderInfo = orderInfo;
        [weakSelf updateAmountData];
        [weakSelf.mainView refreshMainView];
        
    } andFailure:^{
        [MBProgressHUD hideHUDForView:weakSelf.mainView animated:YES];
        NSString *title = [NSString stringWithFormat:@"网络有问题\n刷新一下试试吧"];
        [weakSelf showNoDataIn:weakSelf.mainView imgName:@"nodata_net" frame:weakSelf.mainView.bounds Title:title buttonTitle:@"刷新" Block:^{
            [weakSelf initData];
        }];
    }];
}

- (void)updateAmountData
{
    NSString *amount = [ESReturnGoodsApplyViewModel getTotoalPriceWithOrder:self.orderInfo];
    if (amount
        && [amount isKindOfClass:[NSString class]]
        && [amount rangeOfString:@"¥"].length > 0)
    {
        self.orderInfo.returnMoney = [amount substringFromIndex:1];
    }
}

#pragma mark - Override
- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ESReturnGoodsApplyViewDelegate
- (NSInteger)getSectionNums {
    if (self.orderInfo) {
        return 3;
    }
    return 0;
}

- (NSInteger)getItemsNumsWithSection:(NSInteger)section {
    return [ESReturnGoodsApplyViewModel getItemsNumsWithSection:section withOrder:self.orderInfo];
}

- (NSString *)getContactNumber {
    return [ESReturnGoodsApplyViewModel getContactNumberWithOrder:self.orderInfo];
}

- (void)refundBtnTap {
    WS(weakSelf);

    [ESReturnGoodsApplyViewModel createNewReturnGoods:self.orderInfo withSuccess:^(NSString *returnGoodsId){
        [MBProgressHUD hideHUDForView:weakSelf.mainView animated:YES];
        [weakSelf showSuccessHUD:@"申请成功!"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ESReturnApplySuccessController *vc = [[ESReturnApplySuccessController alloc] initWithReturnGoodsId:returnGoodsId];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        });
    } inProgress:^{
        [MBProgressHUD showHUDAddedTo:weakSelf.mainView animated:YES];
    } andFailure:^(NSString *errorMsg, NSInteger index) {
        [MBProgressHUD hideHUDForView:weakSelf.mainView animated:YES];
        [weakSelf showSuccessHUD:errorMsg];
        if (index > -1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.mainView setInputFocus:index];
            });
        }
    }];
}

- (NSString *)getReturnGoodsDescription {
    return [ESReturnGoodsApplyViewModel getReturnGoodsDescription];
}

- (BOOL)getReturnAmountStatus
{
    return self.orderInfo.returnWay == ESReturnAmountTypeMoney;
}

#pragma mark - ESReturnBrandHeaderViewDelegate
- (NSString *)getBrandName {
    return @"选择退款商品";
}

#pragma mark - ESReturnBrandFooterViewDelegate
- (BOOL)isSelectedAll {
    return [ESReturnGoodsApplyViewModel itemsIsSelectedAllWithOrder:self.orderInfo];
}

- (NSString *)getTotalPrice {
    return [ESReturnGoodsApplyViewModel getTotoalPriceWithOrder:self.orderInfo];
}

- (void)selectAllItems:(BOOL)selectAll {
    if ([ESReturnGoodsApplyViewModel isInstalmentWithOrder:self.orderInfo]) {
        [self showSuccessHUD:@"未完成付款前，订单不支持部分商品申请退款操作"];
        return;
    }
    [ESReturnGoodsApplyViewModel selectAllItems:selectAll withOrder:self.orderInfo];
    [self.mainView refreshMainView];
}

- (BOOL)couldSelectAll {
    if ([ESReturnGoodsApplyViewModel hasSelectedItemWithOrder:self.orderInfo]
        && ![ESReturnGoodsApplyViewModel isInstalmentWithOrder:self.orderInfo]) {
        return YES;
    }
    return NO;
}

#pragma mark - ESReturnApplyWayCellDelegate
- (NSInteger)getReturnWayStatus
{
    return self.orderInfo.returnWay;
}

- (void)applyGoodsWithMoneyDidTapped
{
    [self.view endEditing:YES];
    
    if (self.orderInfo.returnWay != ESReturnAmountTypeGoodsAndMoney)
    {
        self.orderInfo.returnMoney = [ESReturnGoodsApplyViewModel getTotoalPriceWithOrder:self.orderInfo];
        self.orderInfo.returnWay = ESReturnAmountTypeGoodsAndMoney;
        [self.mainView refreshMainViewAnimationWithSection:1];
    }
}

- (void)applyMoneyDidTapped
{
    [self.view endEditing:YES];
    
    if (self.orderInfo.orderStatus != ESReturnAmountTypeMoney)
    {
        self.orderInfo.returnMoney = @"";
        self.orderInfo.returnWay = ESReturnAmountTypeMoney;
        [self.mainView refreshMainViewAnimationWithSection:1];
    }
}

#pragma mark - ESReturnApplyAmountInputCellDelegate
- (NSString *)getReturnAmountWithIndexPath:(NSIndexPath *)indexPath
{
    return [ESReturnGoodsApplyViewModel getTotoalPriceWithOrder:self.orderInfo];
}

- (void)returnAmountDidEndEditing:(NSString *)amount;
{
    self.orderInfo.returnMoney = amount;
}

#pragma mark - ESReturnApplyItemCellDelegate
- (BOOL)itemIsSelected:(NSInteger)index {
    return [ESReturnGoodsApplyViewModel itemIsSelectedWithIndex:index withOrder:self.orderInfo];
}

- (NSString *)getItemImage:(NSInteger)index {
    return [ESReturnGoodsApplyViewModel getItemImage:index withOrder:self.orderInfo];
}

- (NSString *)getItemName:(NSInteger)index {
    return [ESReturnGoodsApplyViewModel getItemName:index withOrder:self.orderInfo];
}

- (NSString *)getItemSKUs:(NSInteger)index {
    return [ESReturnGoodsApplyViewModel getItemSKUs:index withOrder:self.orderInfo];
}

- (NSString *)getItemPrice:(NSInteger)index {
    return [ESReturnGoodsApplyViewModel getItemPrice:index withOrder:self.orderInfo];
}

- (NSString *)getItemQuantity:(NSInteger)index {
    return [ESReturnGoodsApplyViewModel getItemQuantity:index withOrder:self.orderInfo];
}

- (void)selectItem:(BOOL)select withIndex:(NSInteger)index {
    if ([ESReturnGoodsApplyViewModel isInstalmentWithOrder:self.orderInfo]) {
        [self showSuccessHUD:@"未完成付款前，订单不支持部分商品申请退款操作"];
        return;
    }
    [ESReturnGoodsApplyViewModel selectItem:select withIndex:index withOrder:self.orderInfo];
    [self.mainView refreshMainView];
}

- (BOOL)itemIsValidWithIndex:(NSInteger)index {
    return [ESReturnGoodsApplyViewModel itemIsValidWithIndex:index withOrder:self.orderInfo];
}

- (NSString *)getItemOriginalPrice:(NSInteger)index {
    return [ESReturnGoodsApplyViewModel getItemOriginalPrice:index withOrder:self.orderInfo];
}

- (BOOL)itemSelectedStatusWithIndex:(NSInteger)index {
    if ([ESReturnGoodsApplyViewModel isInstalmentWithOrder:self.orderInfo]) {
        return NO;
    }
    return YES;
}

- (BOOL)minusBtnCanSelectWithIndex:(NSInteger)index {
    return [ESReturnGoodsApplyViewModel itemCouldMinus:index withOrder:self.orderInfo];
}

- (BOOL)plusBtnCanSelectWithIndex:(NSInteger)index {
    return [ESReturnGoodsApplyViewModel itemCouldPlus:index withOrder:self.orderInfo];
}

- (void)minusBtnClickWithIndex:(NSInteger)index {
    [ESReturnGoodsApplyViewModel itemMinus:index withOrder:self.orderInfo];
    [self.mainView refreshMainView];
}

- (void)plusBtnClickWithIndex:(NSInteger)index {
    [ESReturnGoodsApplyViewModel itemPlus:index withOrder:self.orderInfo];
    [self.mainView refreshMainView];
}

- (NSString *)getReturnApplyNum:(NSInteger)index {
    return [ESReturnGoodsApplyViewModel getReturnApplyItemNum:index withOrder:self.orderInfo];
}

- (BOOL)getGiftStatusWithIndex:(NSInteger)index
{
    return [ESReturnGoodsApplyViewModel getReturnApplyItemGiftStatusNum:index withOrder:self.orderInfo];
}

#pragma mark - ESReturnApplyInputCellDelegate
- (NSString *)getInputTitle:(NSInteger)index {
    return [ESReturnGoodsApplyViewModel getInputTitle:index withOrder:self.orderInfo];
    
}

- (NSString *)getInputContent:(NSInteger)index {
    return [ESReturnGoodsApplyViewModel getInputContent:index withOrder:self.orderInfo];
}

- (NSString *)getInputPlaceHolder:(NSInteger)index {
    return [ESReturnGoodsApplyViewModel getInputPlaceHolder:index withOrder:self.orderInfo];
    
}

- (void)setInputContent:(NSString *)content withIndex:(NSInteger)index {
    [ESReturnGoodsApplyViewModel setInputContent:content withIndex:index withOrder:self.orderInfo];
}

#pragma mark - ESConnectMerchantCellDelegate
- (NSString *)getMerchantNumberWithSection:(NSInteger)section andIndex:(NSInteger)index {
    return [ESReturnGoodsApplyViewModel getContactNumberWithOrder:self.orderInfo];
}

- (void)clickMerchantNumberWithSection:(NSInteger)section andIndex:(NSInteger)index {
    NSString *phoneNum = [ESReturnGoodsApplyViewModel getContactNumberWithOrder:self.orderInfo];
    if (phoneNum) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNum]];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }        
    }
}

#pragma mark - Custom Method
- (void)showSuccessHUD:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.label.adjustsFontSizeToFitWidth = YES;
    hud.label.minimumScaleFactor = 0.5;
    hud.margin = 30.f;
    [hud setOffset:CGPointMake(hud.offset.x, 0)];
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1.5];
}
@end
