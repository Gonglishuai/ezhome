//
//  ESShoppingCartController.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/30.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESShoppingCartController.h"
#import "ESShoppingCartView.h"
#import "ESShoppingCartViewModel.h"
#import "MBProgressHUD.h"
#import "ESMakeSureNormalOrderController.h"
#import "ESProductDetailViewController.h"
#import "ESDefaultPageView.h"
#import "MGJRouter.h"
#import "Masonry.h"
#import "ESLoginManager.h"
#import "ESProductAddCartViewController.h"
#import <ESNetworking/SHAlertView.h>

@interface ESShoppingCartController ()<ESShoppingCartViewDelegate, ESLoginManagerDelegate,ESProductAddCartViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) ESCartInfo *cartInfo;
@property (nonatomic, strong) ESShoppingCartView *mainView;
@property (nonatomic, assign) BOOL editAll;//是否是编辑全部
@property (nonatomic, strong) NSMutableDictionary *brandEditStatusDict;//品牌编辑状态
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) ESProductAddCartViewController *cartVC;
@property (nonatomic, strong) UIView *cartView;
@end

@implementation ESShoppingCartController
{
    UIView *_blurView;
    
    NSInteger _updateSkuSection;
    NSInteger _updateSkuIndex;
}

- (MBProgressHUD *)hud {
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.removeFromSuperViewOnHide = NO;
        [self.view addSubview:_hud];
    }
    [self.view bringSubviewToFront:_hud];
    return _hud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.brandEditStatusDict = [NSMutableDictionary dictionary];
    
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    [[ESLoginManager sharedManager] addLoginDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAppActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNav];
    self.mainView = [[ESShoppingCartView alloc] initWithTableBaseVC:self];
    self.mainView.delegate = self;
    [self.view addSubview: self.mainView];
    
    __block UIView *b_view = self.view;
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(b_view.mas_top);
        make.left.equalTo(b_view.mas_left);
        make.bottom.equalTo(b_view.mas_bottom);
        make.right.equalTo(b_view.mas_right);
    }];
    
    self.editAll = NO;
}

- (void)setupNav {
    self.title = @"购物车";
    
    self.rightButton = [[UIButton alloc] init];
    [self.rightButton.titleLabel setFont:[UIFont stec_titleFount]];
    [self.rightButton addTarget:self action:@selector(tapOnRightButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton setImage:nil forState:UIControlStateNormal];
    [self.rightButton setTitle:@"编辑全部" forState:UIControlStateNormal];
    [self.rightButton setTitle:@"完成" forState:UIControlStateSelected];
    [self.rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.rightButton.selected = NO;
    self.rightButton.hidden = YES;
    [self.rightButton sizeToFit];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    WS(weakSelf);
//    if (![ESLoginManager sharedManager].isLogin) {
//        [self showLogoutDefault];
//        return;
//    }
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *status = [userDefaults objectForKey:@"app_location_key"];
    if (status
        && [status isKindOfClass:[NSString class]]
        && [status isEqualToString:@"NO"])
    {
        [weakSelf initDataShowHUD:NO];
        return;
    }
    [self.hud showAnimated:YES];
    [ESShoppingCartViewModel getLocalInfoWithSuccess:^(BOOL success) {
        [weakSelf checkLocalInfo:YES];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[ESLoginManager sharedManager] removeLoginDelegate:self];
}

- (void)receiveAppActive {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *status = [userDefaults objectForKey:@"app_location_key"];
    if (status
        && [status isKindOfClass:[NSString class]]
        && [status isEqualToString:@"NO"])
    {
        [self initDataShowHUD:NO];
        return;
    }
    
    WS(weakSelf);
    [self.hud showAnimated:YES];
    [ESShoppingCartViewModel getLocalInfoWithSuccess:^(BOOL success) {
        [weakSelf checkLocalInfo:YES];
    }];
}

- (void)checkLocalInfo:(BOOL)hasShowHUD {
    WS(weakSelf);
    [ESShoppingCartViewModel checkLocalRegionInfoWithSuccess:^{
//        [ESDefaultPageView hideDefaultFromView:weakSelf.view];
        [weakSelf initDataShowHUD:!hasShowHUD];
    } withNoPermission:^{
        [weakSelf.hud hideAnimated:YES];
        [ESDefaultPageView showDefaultInView:weakSelf.view withImage:@"nodata_location" withText:@"您需要打开定位权限,\n才可以进入购物车查看哦~" withButtonTitle:@"去设置" withHandler:^{
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                } else {
                    // Fallback on earlier versions
                }
            }
        }];
    } withFailure:^{
        [weakSelf.hud hideAnimated:YES];
        [ESDefaultPageView showDefaultInView:weakSelf.view
                                   withImage:@"nodata_location"
                                    withText:@"啊哦~\n获取定位失败, 刷新试试"
                             withButtonTitle:@"刷新"
                                 withHandler:^
        {
            [weakSelf.hud showAnimated:YES];
            [ESShoppingCartViewModel getLocalInfoWithSuccess:^(BOOL success) {
                if (success) {
                    [ESDefaultPageView hideDefaultFromView:weakSelf.view];
                    [weakSelf initDataShowHUD:NO];
                }else {
                    [weakSelf.hud hideAnimated:YES];
                }
            }];
        }];
    }];
}


- (void)initDataShowHUD:(BOOL)show {
    WS(weakSelf);
    if (show) {
        [self.hud showAnimated:YES];
    }
    [ESShoppingCartViewModel retrieveCartInfoWithSuccess:^(NSArray *dataList, ESCartInfo *cartInfo) {
        [weakSelf.hud hideAnimated:YES];
        weakSelf.dataList = [NSMutableArray arrayWithArray:dataList];
        weakSelf.cartInfo = cartInfo;
        [weakSelf showEmptyView:weakSelf.dataList.count == 0];
        [weakSelf.mainView setBottomVisible:YES];
    } andFailure:^{
        [weakSelf.hud hideAnimated:YES];
        [weakSelf showErrorView:YES];
    }];
}

- (void)manageEmptyView {
    if (self.editAll == YES) {//处于编辑全部状态
        NSInteger num = [self getSectionNums];
        if (num == 0) {
            self.rightButton.selected = NO;
            [self.mainView refreshBottomView];
            [self showEmptyView:YES];
        }
    }else {
        [self showEmptyView:self.dataList.count == 0];
    }
}

- (void)showEmptyView:(BOOL)empty {
    self.rightButton.hidden = empty;
    WS(weakSelf);
    if (empty) {
        NSString *title = [NSString stringWithFormat:@"购物车空空如也哦~\n快去选购商品吧~"];
        [ESDefaultPageView showDefaultInView:weakSelf.view withImage:@"nodata_shop_car" withText:title withButtonTitle:@"去逛逛" withHandler:^{
            [MGJRouter openURL:@"/Mall/MallHome"];
        }];
        [self.mainView refreshBottomView];
    }else {
        [ESDefaultPageView hideDefaultFromView:weakSelf.view];
        [self.mainView refreshMainView];
        [self.mainView refreshBottomView];
    }
    
}

- (void)showErrorView:(BOOL)error {
    WS(weakSelf);
    self.rightButton.hidden = error;
    if (error) {
        NSString *title = [NSString stringWithFormat:@"网络有问题\n刷新一下试试吧"];
        [ESDefaultPageView showDefaultInView:self.view withImage:@"nodata_net" withText:title withButtonTitle:@"刷新" withHandler:^{
            [weakSelf initDataShowHUD:YES];
        }];
    }else {
        [ESDefaultPageView hideDefaultFromView:self.view];
        [self.mainView refreshMainView];
    }
    
}

#pragma mark - Override
- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapOnRightButton:(id)sender {
    
    if (self.editAll == NO) {
        self.editAll = YES;
        NSInteger num = [self getSectionNums];
        if (num == 0) {
            self.editAll = NO;
            [self showSuccessHUD:@"当前没有可编辑的商品"];
            return;
        }
    }
    
    UIButton *rightButton = (UIButton *)sender;
    self.editAll = !rightButton.selected;
    [ESShoppingCartViewModel markAllItemsEditingStatus:self.editAll withDict:self.brandEditStatusDict];
    if (self.editAll) {//进入编辑状态
        rightButton.selected = !rightButton.selected;
        [self.mainView scrollToTop];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.mainView refreshMainView];
        });
        [self.mainView setBottomRightBtn:ESCartConfirmButtonTypeDelete];
    }else {//完成编辑全部
        rightButton.selected = !rightButton.selected;
        [self.mainView setBottomRightBtn:ESCartConfirmButtonTypeSettleValid];
        [self.mainView refreshBottomView];
        [self.mainView refreshMainView];
    }
}

#pragma mark - ESShoppingCartViewDelegate
- (void)refreshLoadNewData {
    
    [self.brandEditStatusDict removeAllObjects];
    
    [self initDataShowHUD:NO];
}

- (BOOL)isEditingWithSection:(NSInteger)section {
    ESCommodityType type = [ESShoppingCartViewModel getSectionTypeFromArray:self.dataList withSection:section];
    if (self.editAll) {
        return type == ESCommodityTypeValid;
    }else {
        if (type == ESCommodityTypeValid) {
            return [ESShoppingCartViewModel brandIsEditingFromArray:self.dataList editDict:self.brandEditStatusDict withSection:section];
        }
        return NO;
    }
}

- (NSInteger)getSectionNums {
    return [ESShoppingCartViewModel getSectionNumsFromArray:self.dataList withEditAll:self.editAll];
}

- (NSInteger)getItemNumsWithSection:(NSInteger)section {
    return [ESShoppingCartViewModel getItemNumsFromArray:self.dataList withSection:section];
}

- (ESCommodityType)getSectionType:(NSInteger)section {
    return [ESShoppingCartViewModel getSectionTypeFromArray:self.dataList withSection:section];
}

- (void)tapItemWithSection:(NSInteger)section andIndex:(NSInteger)index {
    ESCartCommodity *commodity = [ESShoppingCartViewModel getCommodityFromArray:self.dataList withSection:section andIndex:index];
    if ([commodity.itemId isKindOfClass:[NSString class]]
        && ![commodity.itemId isEqualToString:@""]) {
        ESProductDetailViewController *vc = [[ESProductDetailViewController alloc]
                                             initWithProductId:commodity.itemId
                                             type:ESProductDetailTypeSpu
                                             designerId:nil];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - ESShoppingCartBottomViewDelegate
- (BOOL)isSelected {
    return [ESShoppingCartViewModel isSelectedAllItemsFromArray:self.dataList];
}

- (void)selectAllItems:(BOOL)selectAll callBack:(void(^)(BOOL successStatus))callback
{
    NSDictionary *itemIdInfo = [ESShoppingCartViewModel markAllItemsSelected:selectAll withArray:self.dataList];
    /// 选中状态同步到服务器
    if (itemIdInfo
        && [itemIdInfo isKindOfClass:[NSDictionary class]])
    {
        [self.hud showAnimated:YES];
        WS(weakSelf);
        [ESShoppingCartViewModel
         requestForItemSelectedStatus:[itemIdInfo[@"status"] boolValue]
         cartItemIds:itemIdInfo[@"ids"]
         success:^(ESCartInfo *cartInfo)
         {
             [ESShoppingCartViewModel effectiveMarkAllItemsSelected:selectAll withArray:self.dataList];
             [weakSelf.hud hideAnimated:YES];
             weakSelf.cartInfo = cartInfo;
             [weakSelf.mainView refreshMainView];
             [weakSelf.mainView refreshBottomView];
         } failure:^(NSString *errorMsg) {
             if (callback)
             {// 如果失败回调重设按钮状态
                 callback(NO);
             }
             [weakSelf.hud hideAnimated:YES];
             [weakSelf showSuccessHUD:errorMsg];
         }];
    }
}

- (ESCartInfo *)getTotalPrice {
    return self.cartInfo;
}

- (void)cartConfirmBtnClick:(ESCartConfirmButtonType)type {
    WS(weakSelf);
    NSInteger itemNums = [ESShoppingCartViewModel getSelectedTotoalNumsFromArray:self.dataList withType:ESCommodityTypeValid];
    switch (type) {
        case ESCartConfirmButtonTypeSettleValid: {
            if (itemNums == 0) {
                [self showSuccessHUD:@"您还没有选择商品哦~"];
            }else {
                if (![ESLoginManager sharedManager].isLogin) {
                    [[ESLoginManager sharedManager] login];
                    return;
                }
                [self.hud showAnimated:YES];
                [ESShoppingCartViewModel createPendingOrderSuccess:^(NSDictionary *dict){
                    [weakSelf.hud hideAnimated:YES];
                    ESMakeSureNormalOrderController *vc = [[ESMakeSureNormalOrderController alloc] init];
                    [vc setDataSource:dict];
                    vc.hidesBottomBarWhenPushed = YES;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                } andFailure:^(NSString *errorMsg){
                    [weakSelf.hud hideAnimated:YES];
                    [weakSelf showSuccessHUD:errorMsg];
                }];
            }
            break;
        }
        case ESCartConfirmButtonTypeDelete: {
            if (itemNums == 0) {
                [self showSuccessHUD:@"您还没有选择商品哦～"];
            }else {
                NSString *msg = [NSString stringWithFormat:@"确定删除这 %ld 件商品吗?", (long)itemNums];
                [SHAlertView showAlertWithTitle:@"提示" message:msg sureKey:^{
                    [weakSelf.hud showAnimated:YES];
                    [ESShoppingCartViewModel deleteSelectedItemsFromArray:weakSelf.dataList editDict:weakSelf.brandEditStatusDict withSuccess:^() {
    
                        [weakSelf showSuccessHUD:@"删除成功"];
                        [weakSelf initDataShowHUD:NO];
                        
                    } andFailure:^{
                        [weakSelf.hud hideAnimated:YES];
                        [weakSelf showSuccessHUD:@"网络错误，请稍后重试"];
                    }];
                } cancelKey:nil];
            }
            break;
        }
        default:
            break;
    }
}

- (BOOL)hasEditingBrand {
    return [ESShoppingCartViewModel hasEditingBrandFromDict:self.brandEditStatusDict];
}

#pragma mark - ESShoppingCartBrandHeaderViewDelegate
- (BOOL)isSelectBrandWithSection:(NSInteger)section {
    return [ESShoppingCartViewModel isSelectBrandFromArray:self.dataList withSection:section];
}

- (NSString *)getBrandNameWithSection:(NSInteger)section {
    return [ESShoppingCartViewModel getBrandNameFromArray:self.dataList withSection:section];
}

- (void)selectBrandWithSection:(NSInteger)section callBack:(void(^)(BOOL successStatus))callback
{
    NSDictionary *itemIdInfo = [ESShoppingCartViewModel selectBrandFromArray:self.dataList withSection:section];
    /// 选中状态同步到服务器
    if (itemIdInfo
        && [itemIdInfo isKindOfClass:[NSDictionary class]])
    {
        [self.hud showAnimated:YES];
        WS(weakSelf);
        [ESShoppingCartViewModel
         requestForItemSelectedStatus:[itemIdInfo[@"status"] boolValue]
         cartItemIds:itemIdInfo[@"ids"]
         success:^(ESCartInfo *cartInfo)
         {
             [ESShoppingCartViewModel effectiveSelectBrandFromArray:weakSelf.dataList withSection:section];
             [weakSelf.hud hideAnimated:YES];
             weakSelf.cartInfo = cartInfo;
             NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
             [weakSelf.mainView refreshSections:indexSet];
             [weakSelf.mainView refreshBottomView];
         } failure:^(NSString *errorMsg) {
             if (callback)
             {// 如果失败回调重设按钮选中状态
                 callback(NO);
             }
             [weakSelf.hud hideAnimated:YES];
             [weakSelf showSuccessHUD:errorMsg];
         }];
    }
}

- (void)editBrandWithSection:(NSInteger)section
                  withStatus:(BOOL)isEditing {
    [self.mainView setBottomRightBtn:isEditing ? ESCartConfirmButtonTypeSettleInvalid : ESCartConfirmButtonTypeSettleValid];
    [ESShoppingCartViewModel updateBrandSelectedStatusFromArray:self.dataList editDict:self.brandEditStatusDict withSection:section];

    [self.mainView refreshBottomView];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [self.mainView refreshSections:indexSet];
}

- (BOOL)isEditAllStatus {
    return self.editAll;
}

#pragma mark - ESShoppingCartInvalidHeaderViewDelegate
- (void)clearItemsWithSection:(NSInteger)section {
    WS(weakSelf);
    [SHAlertView showAlertWithTitle:@"提示" message:@"确定清空吗?" sureKey:^{
        [weakSelf.hud showAnimated:YES];
        [ESShoppingCartViewModel clearInvalidItemsFromArray:weakSelf.dataList withSection:section withSuccess:^{
            [weakSelf.hud hideAnimated:YES];
            [weakSelf.mainView deleteSectionWithIndexSet:[NSIndexSet indexSetWithIndex:section]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf manageEmptyView];
            });
        } andFailure:^{
            [weakSelf.hud hideAnimated:YES];
            [weakSelf showSuccessHUD:@"网络错误，请稍后重试"];
        }];
    } cancelKey:nil];
    
}

#pragma mark - ESShoppingCartCellDelegate
- (ESCommodityType)getCommodityTyep:(NSInteger)section
                           andIndex:(NSInteger)index {
    return [ESShoppingCartViewModel getSectionTypeFromArray:self.dataList withSection:section];
}

- (BOOL)isSelected:(NSInteger)section andIndex:(NSInteger)index {
    return [ESShoppingCartViewModel isSelectedFromArray:self.dataList withSection:section andIndex:index];
}

- (NSString *)getItemImage:(NSInteger)section andIndex:(NSInteger)index {
    return [ESShoppingCartViewModel getItemImageFromArray:self.dataList withSection:section andIndex:index];
}

- (NSString *)getItemName:(NSInteger)section andIndex:(NSInteger)index {
    return [ESShoppingCartViewModel getItemNameFromArray:self.dataList withSection:section andIndex:index];
}

- (NSString *)getItemSKU:(NSInteger)section andIndex:(NSInteger)index {
    return [ESShoppingCartViewModel getItemSKUFromArray:self.dataList withSection:section andIndex:index];
}

- (double)getItemPrice:(NSInteger)section andIndex:(NSInteger)index {
    return [ESShoppingCartViewModel getItemPriceFromArray:self.dataList withSection:section andIndex:index];
}

- (NSInteger)getItemAmount:(NSInteger)section andIndex:(NSInteger)index {
    return [ESShoppingCartViewModel getItemAmountFromArray:self.dataList withSection:section andIndex:index];
}

- (ESCartCommodityPromotion *)getPromotionInfoWithSection:(NSInteger)section andIndex:(NSInteger)index
{
    return [ESShoppingCartViewModel getItemPromotionFromArray:self.dataList withSection:section andIndex:index];
}

- (void)promotionDidTappedWithSection:(NSInteger)section andIndex:(NSInteger)index
{
    SHLog(@"促销被点击");
    NSString *giftId = [ESShoppingCartViewModel getGiftIdFromArray:self.dataList withSection:section andIndex:index];
    if (giftId
        && [giftId isKindOfClass:[NSString class]]
        && giftId.length > 0)
    {
        ESProductDetailViewController *vc = [[ESProductDetailViewController alloc]
                                             initWithProductId:giftId
                                             type:ESProductDetailTypeSpu
                                             designerId:nil];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)selectItemWithSection:(NSInteger)section andIndex:(NSInteger)index callBack:(void(^)(BOOL successStatus))callback
{
    NSDictionary *itemIdInfo = [ESShoppingCartViewModel selectItemFromArray:self.dataList withSection:section andIndex:index];
    /// 选中状态同步到服务器
    if (itemIdInfo
        && [itemIdInfo isKindOfClass:[NSDictionary class]])
    {
        [self.hud showAnimated:YES];
        WS(weakSelf);
        [ESShoppingCartViewModel
         requestForItemSelectedStatus:[itemIdInfo[@"status"] boolValue]
         cartItemIds:itemIdInfo[@"ids"]
         success:^(ESCartInfo *cartInfo)
         {
             [ESShoppingCartViewModel effectiveSelectItemFromArray:weakSelf.dataList withSection:section andIndex:index];
             [weakSelf.hud hideAnimated:YES];
             weakSelf.cartInfo = cartInfo;
             [weakSelf.mainView refreshSections:[NSIndexSet indexSetWithIndex:section]];
             [weakSelf.mainView refreshBottomView];
         } failure:^(NSString *errorMsg) {
             if (callback)
             {// 如果失败回调重设按钮状态
                 callback(NO);
             }
             [weakSelf.hud hideAnimated:YES];
             [weakSelf showSuccessHUD:errorMsg];
         }];
    }
}

- (void)deleteItemWithSection:(NSInteger)section andIndex:(NSInteger)index {
    WS(weakSelf);
    [SHAlertView showAlertWithTitle:@"提示" message:@"确定删除这件商品吗?" sureKey:^{
        [weakSelf.hud showAnimated:YES];
        [ESShoppingCartViewModel deleteItemFromArray:weakSelf.dataList editDict:self.brandEditStatusDict withSection:section withIndex:index withSuccess:^(BOOL refreshStatus, BOOL delSection) {
            
            [weakSelf showSuccessHUD:@"删除成功"];

            if (refreshStatus)
            {
                [weakSelf initDataShowHUD:NO];
            }
            else
            {
                [weakSelf.hud hideAnimated:YES];
                if (delSection) {
                    [weakSelf.mainView deleteSectionWithIndexSet:[NSIndexSet indexSetWithIndex:section]];
                }else {
                    [weakSelf.mainView deleteRowWithIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:section]]];
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf manageEmptyView];
                });
                [weakSelf.mainView refreshBottomView];
            }
        } andFailure:^{
            [weakSelf.hud hideAnimated:YES];
        }];
    } cancelKey:nil];
}

- (void)updateItemCount:(NSInteger)count
            withSection:(NSInteger)section
               andIndex:(NSInteger)index
               callback:(void(^)(BOOL successStatus))callback
{
    ESCartCommodity *commodity = [ESShoppingCartViewModel getCommodityFromArray:self.dataList withSection:section andIndex:index];
    [self.hud showAnimated:YES];
    WS(weakSelf);
    [ESShoppingCartViewModel
     updateSkuAttributesFromArray:self.dataList
     withSection:section
     andIndex:index
     newSkuId:commodity.sku
     itemQuantity:count
     withSuccess:^
     {
         [weakSelf initDataShowHUD:NO];
         
     } andFailure:^(NSString *errorMsg) {
         
         [weakSelf.hud hideAnimated:YES];
         [weakSelf showSuccessHUD:errorMsg];
         
     }];
}

- (NSInteger)getMinAmountWithSection:(NSInteger)section andIndex:(NSInteger)index {
    return [ESShoppingCartViewModel getMinAmountFromArray:self.dataList withSection:section andIndex:index];
}

- (NSInteger)getMaxAmountWithSection:(NSInteger)section andIndex:(NSInteger)index {
    return [ESShoppingCartViewModel getMaxAmountFromArray:self.dataList withSection:section andIndex:index];
}

- (void)showMessage:(NSString *)message
{
    [self showSuccessHUD:message];
}

/// 修改属性之获取所有属性
- (void)changeSkuAttribute:(NSInteger)section
                  andIndex:(NSInteger)index
{
    SHLog(@"获取spu所有属性section: %ld, index: %ld", section, index);
    
    ESCartCommodity *commodity = [ESShoppingCartViewModel getCommodityFromArray:self.dataList withSection:section andIndex:index];
    [self.hud showAnimated:YES];
    WS(weakSelf);
    [ESShoppingCartViewModel requestForAttributesSpuId:commodity.itemId success:^(ESProductModel *model) {
        
        [weakSelf.hud hideAnimated:YES];

        [weakSelf addProductCartViewWithModel:model section:section index:index];
        
    } failure:^{
        
        [weakSelf.hud hideAnimated:YES];
    }];
}

#pragma mark - ESProductCartView
- (void)updateCartViewShowStatus:(BOOL)status
{
    if (status)
    {
        _blurView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _blurView.backgroundColor = [UIColor blackColor];
        _blurView.alpha = 0.01f;
        [_blurView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(removeBlurView)]];
        [[UIApplication sharedApplication].keyWindow addSubview:_blurView];
    }
    else
    {
        [_blurView removeFromSuperview];
        _blurView = nil;
    }
}

- (void)addProductCartViewWithModel:(ESProductModel *)model
                            section:(NSInteger)section
                              index:(NSInteger)index
{
    _updateSkuSection = section;
    _updateSkuIndex = index;
    
    [self.view endEditing:YES];
    
    [self updateCartViewShowStatus:YES];
    
    self.cartVC = [[ESProductAddCartViewController alloc] init];
    self.cartVC.product = model;
    self.cartVC.alertType = ESProductDetailAlertTypeShopCart;
    self.cartVC.selectedAttributesIDs = [ESShoppingCartViewModel getSkuAttributesFromArray:self.dataList withSection:section andIndex:index];
    self.cartVC.delegate = self;
    self.cartView = (id)self.cartVC.view;
    self.cartView.frame = CGRectMake(
                                     0,
                                     SCREEN_HEIGHT * (346/1334.0),
                                     SCREEN_WIDTH,
                                     SCREEN_HEIGHT - SCREEN_HEIGHT * (346/1334.0)
                                     );
    [[UIApplication sharedApplication].keyWindow addSubview:self.cartView];
    
    CGRect originalRect = self.cartView.frame;
    self.cartView.frame = CGRectMake(
                                     0,
                                     CGRectGetHeight(self.view.frame),
                                     CGRectGetWidth(originalRect),
                                     CGRectGetHeight(originalRect)
                                     );
    __weak ESShoppingCartController *weakSelf = self;
    [UIView animateWithDuration:0.35f
                     animations:^
     {
         weakSelf.cartView.frame = originalRect;
         _blurView.alpha = 0.5f;
     }];
}

- (void)removeProductCartView
{
    __weak ESShoppingCartController *weakSelf = self;
    [UIView animateWithDuration:0.3f
                     animations:^
     {
         weakSelf.cartView.frame = CGRectMake(
                                              0,
                                              CGRectGetHeight(weakSelf.view.frame),
                                              CGRectGetWidth(weakSelf.view.frame),
                                              CGRectGetHeight(weakSelf.view.frame)
                                              );
         _blurView.alpha = 0.01f;
     }
                     completion:^(BOOL finished)
     {
         [weakSelf.cartView removeFromSuperview];
         
         weakSelf.cartView = nil;
         weakSelf.cartVC.delegate = nil;
         weakSelf.cartVC = nil;
         
         [weakSelf updateCartViewShowStatus:NO];
     }];
}

#pragma mark - ESProductAddCartViewControllerDelegate
- (void)cartCloseButtonDidTapped
{
    [self removeProductCartView];
}

/// 修改属性
- (void)addItemWithSkuId:(NSString *)skuId
            itemQuantity:(NSInteger)itemQuantity
          isCustomizable:(ESProductDetailButtonType)buttonType
               alertType:(ESProductDetailAlertType)alertType
{
    SHLog(@"选中修改属性skuId:%@", skuId);
    [self removeProductCartView];
    
    if (alertType != ESProductDetailAlertTypeShopCart)
    {
        return;
    }
    
    // itemQuantity是添加购物车控件使用的字段
    ESCartCommodity *commodity = [ESShoppingCartViewModel getCommodityFromArray:self.dataList withSection:_updateSkuSection andIndex:_updateSkuIndex];
    [self.hud showAnimated:YES];
    WS(weakSelf);
    [ESShoppingCartViewModel
     updateSkuAttributesFromArray:self.dataList
     withSection:_updateSkuSection
     andIndex:_updateSkuIndex
     newSkuId:skuId
     itemQuantity:[commodity.itemQuantity integerValue]
     withSuccess:^
    {
        [weakSelf initDataShowHUD:NO];
        
    } andFailure:^(NSString *errorMsg) {
        
        [weakSelf.hud hideAnimated:YES];
        [weakSelf showSuccessHUD:errorMsg];
        
    }];
}

#pragma mark - Tap Method
- (void)removeBlurView
{
    [self removeProductCartView];
}

#pragma mark - ESLoginManagerDelegate
- (void)onLogin {
    WS(weakSelf);
    [ESDefaultPageView hideDefaultFromView:self.view];
    [self.hud showAnimated:YES];
    [ESShoppingCartViewModel getLocalInfoWithSuccess:^(BOOL success) {
        [weakSelf checkLocalInfo:YES];
    }];
}

- (void)onLogout {
    [self showLogoutDefault];
}

#pragma mark - Custom Method
- (void)showSuccessHUD:(NSString *)message {
    
    if (!message
        || ![message isKindOfClass:[NSString class]]
        || message.length <= 0)
    {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.margin = 30.f;
    [hud setOffset:CGPointMake(hud.offset.x, 0)];
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1.5];
}

- (void)showLogoutDefault {
    [ESDefaultPageView showDefaultInView:self.view withImage:@"nodata_shop_car" withText:@"暂时还未登录哦~" withButtonTitle:@"去登录" withHandler:^{
        [[ESLoginManager sharedManager] login];
    }];
}
@end
