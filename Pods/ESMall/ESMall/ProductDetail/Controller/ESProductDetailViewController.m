
#import "ESProductDetailViewController.h"
#import "ESProductDetailView.h"
#import "SHSegmentedControl.h"
#import "JRWebViewController.h"
#import "ESProductAddCartViewController.h"
#import "ESShoppingCartController.h"
#import "ESMakeSureCustomOrderController.h"
#import "ESProductDetailModel.h"
#import "MBProgressHUD.h"
#import "ESProductDetailModel.h"
#import "ESCartUtil.h"
#import "ESProductHeaderView.h"
#import "ESPhotoBrowser.h"
#import "HtmlURL.h"
#import "ESLoginManager.h"
#import "ESFlashSaleView.h"
#import "ESMakeSureNormalOrderController.h"
#import "ESProductCouponListView.h"
#import "ESProductDeatilStoreMapViewController.h"
#import <ESFoundation/UMengServices.h>
#import "MGJRouter.h"

@interface ESProductDetailViewController ()
<
ESProductHeaderViewDelegate,
ESProductDetailViewDelegate,
ESProductAddCartViewControllerDelegate,
ESFlashSaleViewDelegate
>

@property (nonatomic, strong) ESProductAddCartViewController *cartVC;
@property (nonatomic, strong) UIView *cartView;

@end

@implementation ESProductDetailViewController
{
    NSString *_productId;
    NSString *_designerId;
    ESProductDetailType _type;
    
    ESProductDetailView *_productView;
    ESProductHeaderView *_headerView;
    ESFlashSaleView *_flashSaleView;
    
    BOOL _promiseShowStatus;
    BOOL _productCartViewShowStatus;
    
    NSDictionary *_dictPromise;
    
    UIView *_blurView;
    
    ESProductDetailModel *_model;
    
    NSTimer *_countDownTimer;
    NSString *_flashSaleItemId;
    NSString *_activityId;
}

- (instancetype _Nonnull )initWithProductId:(NSString * _Nonnull)productId
                                       type:(ESProductDetailType)type
                                 designerId:(NSString * __nullable)designerId
{
    self = [super init];
    if (self)
    {
        if (productId && [productId isKindOfClass:[NSString class]])
        {
            _productId = productId;
        }
        else
        {
            _productId = @"";
        }
        
        if (designerId && ![designerId isKindOfClass:[NSNull class]])
        {
            _designerId = [designerId description];
        }
        
        _type = type;
    }
    return self;
}

- (instancetype _Nonnull )initWithProductId:(NSString * _Nonnull)productId
                            flashSaleItemId:(NSString * _Nonnull)flashSaleItemId
                                 activityId:(NSString * _Nonnull)activityId
{
    self = [super init];
    if (self)
    {
        if (productId
            && [productId isKindOfClass:[NSString class]])
        {
            _productId = productId;
        }
        else
        {
            _productId = @"";
        }
        if (flashSaleItemId
            && [flashSaleItemId isKindOfClass:[NSString class]])
        {
            _flashSaleItemId = flashSaleItemId;
        }
        else
        {
            _flashSaleItemId = @"";
        }
        if (activityId
            && [activityId isKindOfClass:[NSString class]])
        {
            _activityId = activityId;
        }
        else
        {
            _activityId = @"";
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavi];
    
    [self initData];
    
    [self initUI];
    
    [self requestData];
}

- (void)setNavi
{
    if (self.navigationController)
    {
        UIImage *buttonNormal = [[UIImage imageNamed:@"nav_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.navigationController.navigationBar setBackIndicatorImage:buttonNormal];
        [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:buttonNormal];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc]
                                     initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                     target:nil
                                     action:nil];
        self.navigationItem.backBarButtonItem = backItem;
    }
}

- (void)initData
{
    _productCartViewShowStatus = NO;
    
    _dictPromise = [ESProductDetailModel getJuranPromise];
}

- (void)initUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.rightButton setImage:nil
                      forState:UIControlStateNormal];
    
    _productView = [[ESProductDetailView alloc]
                    initWithFrame:CGRectMake(
                                             0,
                                             NAVBAR_HEIGHT,
                                             SCREEN_WIDTH,
                                             SCREEN_HEIGHT - NAVBAR_HEIGHT
                                             )];
    _productView.viewDelegate = self;
    [self.view addSubview:_productView];
    
    _headerView = [[ESProductHeaderView alloc] initWithFrame:CGRectMake(
                                                                        55,
                                                                        NAVBAR_HEIGHT-40,
                                                                        SCREEN_WIDTH - 55 * 2,
                                                                        33
                                                                        )];
    _headerView.headerDelegate = self;
    [_headerView updateHeaderWithSegTitles:@[@"商品",@"详情",@"参数"]
                               bottomTitle:@"图文详情"];
    [self.navgationImageview addSubview:_headerView];
    
    _blurView = [[UIView alloc] initWithFrame:self.view.bounds];
    _blurView.backgroundColor = [UIColor blackColor];
    _blurView.hidden = YES;
    _blurView.alpha = 0.01f;
    [_blurView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(removeBlurView)]];
    [self.view addSubview:_blurView];
}

- (void)requestData
{
    [MBProgressHUD showHUDAddedTo:_productView
                         animated:YES];
    
    __weak ESProductDetailViewController *weakSelf = self;
    [ESProductDetailModel requestForProductDetailWithID:_productId
                                                   type:_type == ESProductDetailTypeSpu ? @"spu" : @"sku"                                        flashSaleItemId:_flashSaleItemId                                             activityId:_activityId
                                                success:^(ESProductDetailModel *model)
    {
        [MBProgressHUD hideHUDForView:_productView animated:YES];
        
        _model = model;
                
        [weakSelf showErrorView:NO];

        [_productView refreshProductDetailView];

    } failure:^{
        
        [MBProgressHUD hideHUDForView:_productView animated:YES];
        [weakSelf showErrorView:YES];
    }];
}

- (void)showErrorView:(BOOL)empty
{
    __weak ESProductDetailViewController *weakSelf = self;
    if (empty)
    {
        [weakSelf removeNoDataView];
        [weakSelf showNoDataIn:_productView
                       imgName:@"nodata_net"
                         frame:_productView.bounds
                         Title:@"网络有问题\n刷新一下试试吧"
                   buttonTitle:@"刷新"
                         Block:^
        {
            [weakSelf requestData];
        }];
    }
    else
    {
        [weakSelf removeNoDataView];
        [_productView refreshProductDetailView];
    }
}

#pragma mark - Super Methods
- (void)tapOnLeftButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - SHSegmentedControlDelegate
- (void)segBtnClickWithTitleIndex:(NSInteger)index
{
    ESProductDetailSegControlType type = index + 1;
    [_productView updateProductDetailViewWithType:type];
}

#pragma mark - ESProductDetailViewDelegate
- (void)registerCellAtTableView:(UITableView *)tableView
                           type:(ESProductDetailTableType)tableType
{
    if (tableType == ESProductDetailTableTypeParameters)
    {
        [tableView registerNib:[UINib nibWithNibName:@"ESProductDetailParametersCell" bundle:[ESMallAssets hostBundle]]
        forCellReuseIdentifier:@"ESProductDetailParametersCell"];
    }
    else if (tableType == ESProductDetailTableTypeProduct)
    {
        [tableView registerNib:[UINib nibWithNibName:@"ESProductDetailLoopCell" bundle:[ESMallAssets hostBundle]]
        forCellReuseIdentifier:@"ESProductDetailLoopCell"];
        
        [tableView registerNib:[UINib nibWithNibName:@"ESProductInformationCell" bundle:[ESMallAssets hostBundle]]
        forCellReuseIdentifier:@"ESProductInformationCell"];
        
        [tableView registerNib:[UINib nibWithNibName:@"ESProductDetailBrandCell" bundle:[ESMallAssets hostBundle]]
        forCellReuseIdentifier:@"ESProductDetailBrandCell"];
        
        [tableView registerNib:[UINib nibWithNibName:@"ESProductDetailPromiseCell" bundle:[ESMallAssets hostBundle]]
        forCellReuseIdentifier:@"ESProductDetailPromiseCell"];
        
        [tableView registerNib:[UINib nibWithNibName:@"ESPeoductDetailAddressCell" bundle:[ESMallAssets hostBundle]]
        forCellReuseIdentifier:@"ESPeoductDetailAddressCell"];
        
        [tableView registerNib:[UINib nibWithNibName:@"ESProductDetailModelCell" bundle:[ESMallAssets hostBundle]]
        forCellReuseIdentifier:@"ESProductDetailModelCell"];
        
        [tableView registerNib:[UINib nibWithNibName:@"ESProductFlashInfoCell" bundle:[ESMallAssets hostBundle]]
        forCellReuseIdentifier:@"ESProductFlashInfoCell"];
        
        [tableView registerNib:[UINib nibWithNibName:@"ESProductDetailDiscountCell" bundle:[ESMallAssets hostBundle]]
        forCellReuseIdentifier:@"ESProductDetailDiscountCell"];
        
        [tableView registerNib:[UINib nibWithNibName:@"ESProductDetailCouponsCell" bundle:[ESMallAssets hostBundle]]
        forCellReuseIdentifier:@"ESProductDetailCouponsCell"];
        
        [tableView registerNib:[UINib nibWithNibName:@"ESProductDetailEarnestCell" bundle:[ESMallAssets hostBundle]]
        forCellReuseIdentifier:@"ESProductDetailEarnestCell"];
        
        [tableView registerNib:[UINib nibWithNibName:@"ESProductDetailEarnestPriceCell" bundle:[ESMallAssets hostBundle]]
        forCellReuseIdentifier:@"ESProductDetailEarnestPriceCell"];
        
        [tableView registerNib:[UINib nibWithNibName:@"ESProductDetailPromotionCell" bundle:[ESMallAssets hostBundle]]
        forCellReuseIdentifier:@"ESProductDetailPromotionCell"];
    }
    else
    {
        SHLog(@"未知table类型");
    }
}

- (NSInteger)numberOfSectionsInProductViewWithType:(ESProductDetailSegControlType)type
{
    if (type == ESProductDetailSegControlTypeParameters)
    {
        return 1;
    }
    else if (type == ESProductDetailSegControlTypeProduct)
    {
        return 8;
        
    }
    return 0;
}

- (NSInteger)numberOfRowsInProductViewWithSection:(NSInteger)section
                                             type:(ESProductDetailSegControlType)type
{
    if (type == ESProductDetailSegControlTypeParameters)
    {
        return _model.product.descriptionAttributes.count;
    }
    else if (type == ESProductDetailSegControlTypeProduct)
    {
        switch (section)
        {
            case 0:
            {// 轮播图加基本信息
                return 2;
            }
            case 1:
            {// 促销
                if (_model.promotiomStatus)
                {
                    return _model.product.productTagResponseBeans.count;
                }
                return 0;
            }
            case 2:
            {// 定金的定金与尾款部分
                if (_model.earnestStatus)
                {
                    return 1;
                }
                return 0;
            }
            case 3:
            {// 优惠券折扣
                if ((_model.hasCoupons && !_model.hasDiscount)
                    || (!_model.hasCoupons && _model.hasDiscount))
                {
                    return 1;
                }
                else if (_model.hasCoupons && _model.hasDiscount)
                {
                    return 2;
                }
                else
                {
                    return 0;
                }
            }
            case 4:
            {// 样板间
                if (_model.hasModel)
                {
                    return 1;
                }
                return 0;
            }
            case 5:
            {// 品牌信息
                return 1;
            }
            case 6:
            {// 居然承诺
                if (_promiseShowStatus)
                {
                    return 1;
                }
                
                return 0;
            }
            case 7:
            { // 门店地址
                if (_model.hasStores)
                {
                    return 1;
                }
                return 0;
            }
            default:
                return 0;
        }
    }
    return 0;
}

- (NSString *)getCellIDAtIndexPath:(NSIndexPath *)indexPath
                         tableType:(ESProductDetailTableType)tableType
{
    if (tableType == ESProductDetailTableTypeProduct)
    {
        if (indexPath.section == 0 && indexPath.row == 0)
        {
            static NSString *loopCellID = @"ESProductDetailLoopCell";
            return loopCellID;
        }
        else if (indexPath.section == 0 && indexPath.row == 1)
        {
            if (_model.earnestStatus)
            {
                static NSString *earnestCellID = @"ESProductDetailEarnestCell";
                return earnestCellID;
            }
            else if (_model.flashSaleStatus)
            {
                static NSString *flashCellID = @"ESProductFlashInfoCell";
                return flashCellID;
            }
            
            static NSString *informationCellID = @"ESProductInformationCell";
            return informationCellID;
        }
        else if (indexPath.section == 1)
        {
            static NSString *promotionCellID = @"ESProductDetailPromotionCell";
            return promotionCellID;
        }
        else if (indexPath.section == 2)
        {
            static NSString *earnestPriceCellID = @"ESProductDetailEarnestPriceCell";
            return earnestPriceCellID;
        }
        else if (indexPath.section == 3 && indexPath.row == 0)
        {
            if (_model.hasCoupons)
            {
                static NSString *couponCellID = @"ESProductDetailCouponsCell";
                return couponCellID;
            }
            static NSString *discountCellID = @"ESProductDetailDiscountCell";
            return discountCellID;
        }
        else if (indexPath.section == 3 && indexPath.row == 1)
        {
            static NSString *discountCellID = @"ESProductDetailDiscountCell";
            return discountCellID;
        }
        else if (indexPath.section == 4)
        {
            static NSString *modelCellID = @"ESProductDetailModelCell";
            return modelCellID;
        }
        else if (indexPath.section == 5)
        {
            static NSString *brandCellID = @"ESProductDetailBrandCell";
            return brandCellID;
        }
        else if (indexPath.section == 6)
        {
            static NSString *promiseCellID = @"ESProductDetailPromiseCell";
            return promiseCellID;
        }
        else if (indexPath.section == 7)
        {
            static NSString *addressCellID = @"ESPeoductDetailAddressCell";
            return addressCellID;
        }
    }
    
    static NSString *paramCellId = @"ESProductDetailParametersCell";
    return paramCellId;
}

- (NSString *)getProductDetailHtmlStr
{
    return _model.product.longDescription;
}

- (BOOL)getShowModelStatus
{
    return _model.hasModel;
}

- (void)scrollDidEndDragingWithIndex:(NSInteger)index
{
    [_headerView updateSelectedSegmentAtIndex:index];
}

- (void)productDescriptionViewDidPull
{
    SHLog(@"详情下拉");
    [_headerView updateHeaderWithType:ESProductHeaderTypeSeg];
}

- (void)productInformationViewDidUpdate
{
    SHLog(@"商品上拉");
    [_headerView updateHeaderWithType:ESProductHeaderTypeLabel];
}

#pragma mark - ESProductDetailParametersCellDelegate
- (ESProductAttributeSelectedValueModel *)getProductDetailParametersAtIndex:(NSInteger)index
{
    // 产品参数
    if (index < _model.product.descriptionAttributes.count)
    {
        ESProductAttributeSelectedValueModel *model = _model.product.descriptionAttributes[index];
        return model;
    }
    
    return nil;
}

- (BOOL)getParametersBottomConstraintShowStatusWithIndex:(NSInteger)index
{
    return (index == _model.product.descriptionAttributes.count - 1);
}

#pragma mark - ESProductDetailLoopCellDelegate
- (NSArray *)getLoopImagesAtIndexPath:(NSIndexPath *)indexPath
{
    return _model.product.images;
}

- (NSString *)getLoopModelUrlAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_model.product.model isKindOfClass:[ESProductModelModel class]])
    {
        return _model.product.model.modelUrl;
    }
    
    return nil;
}

- (void)imageDidTppedAtLoopCell:(UIView *)cell
                          index:(NSInteger)index
                     imageViews:(NSArray <UIImageView *> *)imageViews
{
    SHLog(@"点击了第%ld张图片", index);
    
    if (!imageViews
        || ![imageViews isKindOfClass:[NSArray class]]
        || imageViews.count <= 0
        || ![[imageViews firstObject] isKindOfClass:[UIImageView class]]
        || index >= imageViews.count)
    {
        return;
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSInteger i = 0; i < _model.product.images.count; i++)
    {
        ESProductImagesModel *model = _model.product.images[i];
        NSString *imageUrl = model.imageUrl;
        if (imageUrl
            && [imageUrl isKindOfClass:[NSString class]])
        {
            ESPhoto *photo = [[ESPhoto alloc] init];
            photo.url = [NSURL URLWithString:imageUrl];
            photo.srcImageView = imageViews[i];
            [arrM addObject:photo];
        }
    }
    
    ESPhotoBrowser *browser = [[ESPhotoBrowser alloc] init];
    browser.currentPhotoIndex = index;
    browser.photos = [arrM copy];
    browser.delegate = (id)cell;
    [browser show];
}

#pragma mark - ESProductDetailBrandCellDelegate
- (ESProductBrandModel *)getBrandInformationAtIndexPath:(NSIndexPath *)indexPath
{
    // 品牌信息
    return _model.product.brandResponseBean;
}

- (void)chatButtonDidTapped
{
    if ([[ESLoginManager sharedManager] isLogin]) {
        if (_model && _model.product && _model.product.dealerId) {
            NSDictionary *info = @{@"id" : _model.product.dealerId,
                                   @"viewController" : self,
                                   @"source" : @"productDetail"
                                   };
            [MGJRouter openURL:@"/NIM/ByDealerId" withUserInfo:info completion:nil];
        }
    }else {
        [[ESLoginManager sharedManager] login];
    }
}

#pragma mark - ESProductDetailModelCellDelegate
- (NSInteger)getProductSampleroomCountAtIndexPath:(NSIndexPath *)indexPath
{
    return _model.sampleroom.count;
}

- (ESProductDetailSampleroomModel *)getSampleroomWithIndex:(NSInteger)index
{
    if ([_model.sampleroom isKindOfClass:[NSArray class]]
        && index < _model.sampleroom.count)
    {
        return _model.sampleroom[index];
    }
    
    return nil;
}

- (void)modelViewDidTappedWithIndex:(NSInteger)index
{
    if (index >= _model.sampleroom.count)
    {
        return;
    }
    ESProductDetailSampleroomModel *model = _model.sampleroom[index];
    SHLog(@"第%ld个样板间被点击: %@", index, model.url);
    if ([model.url isKindOfClass:[NSString class]]
        && model.url.length > 0)
    {
        JRWebViewController *webVC = [[JRWebViewController alloc] init];
        [webVC setTitle:@""
                    url:[NSString stringWithFormat:@"%@&hidearea=true", model.url]];
        [webVC setNavigationBarHidden:YES
                        hasBackButton:YES];
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

#pragma mark - ESProductInformationCellDelegate
- (ESProductModel *)getProductInfomationAtIndexPath:(NSIndexPath *)indexPath
{
    // 商品信息
    return _model.product;
}

#pragma mark - ESProductFlashInfoCellDelegate
- (ESFlashSaleInfoModel *)getProductFlashInfoAtIndexPath:(NSIndexPath *)indexPath
{
    return _model.flashSaleInfo;
}

- (void)countDownTimerDidCreated:(NSTimer *)timer
{
    [self invalidateTimer];
    
    if (timer
        && [timer isKindOfClass:[NSTimer class]])
    {
        _countDownTimer = timer;
    }
}

- (void)countDownDidOver
{
    if ([_model.flashSaleInfo isKindOfClass:[ESFlashSaleInfoModel class]])
    {
        /// 倒计时结束后当售罄处理
        _model.hasStockQuantity = NO;
        [_productView updateBottomButton];
    }
}

#pragma mark - ESProductDetailEarnestCellDelegate
- (ESProductDetailEarnestModel *)getProductEarnestInfoAtIndexPath:(NSIndexPath *)indexPath
{
    return _model.earnestInfo;
}

- (void)earnestCountDownTimerDidCreated:(NSTimer *)timer
{
    [self countDownTimerDidCreated:timer];
}

- (void)earnestCountDownDidOver
{
    
}

#pragma mark - ESProductDetailPromiseCellDelegate
- (NSArray <NSDictionary *> *)getProductPromisesAtIndexPath:(NSIndexPath *)indexPath
{
    return _dictPromise[@"promise"];
}

- (void)productDetailPromiseDetailButtonDidTapped
{
    NSDictionary *info = @{@"title" : @"居然承诺",
                           @"url"   : kJuranPromise
                           };
    [MGJRouter openURL:@"/App/OpenWebView" withUserInfo:info completion:nil];
}

#pragma mark - ESProductDetailHeaderViewDelegate
- (void)productHeaderDidTappedAtIndex:(NSInteger)section
                               status:(BOOL)showStatus
{
    if (section == 6)
    {
        _promiseShowStatus = showStatus;
    }
    
    [_productView refreshProductDetailTableViewWithSection:section];
}

- (BOOL)getShowStatusAtSection:(NSInteger)section
{
    if (section == 6)
    {
        return _promiseShowStatus;
    }
    else
    {
        SHLog(@"未知分区");
        return NO;
    }
}

- (NSString *)getHeaderTitleAtSection:(NSInteger)section
{
    if (section == 6)
    {
        return @"居然承诺";
    }
    else
    {
        SHLog(@"未知分区");
        return @"";
    }
}

#pragma mark - ESPeoductDetailAddressCellDelegate
- (ESProductStoreModel *)getProductAddressAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _model.stores.count)
    {
        ESProductStoreModel *model = _model.stores[indexPath.row];
        if (model
            && [model isKindOfClass:[ESProductStoreModel class]])
        {
            return model;
        }
    }

    return nil;
}

- (void)productDetailMapButtonDidTapped
{
    SHLog(@"跳转门店地图");
    ESProductDeatilStoreMapViewController *vc = [[ESProductDeatilStoreMapViewController alloc] initWithStores:[_model.stores copy]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - ESProductDeltailCallCellDelegate
- (NSString *)getProductPhoneNumerAtIndexPath:(NSIndexPath *)indexPath
{
    return _model.merchantMobile;
}

#pragma mark - ESProductDetailCouponsCellDelegate
- (NSArray <NSString *> *)getCouponsWithIndexPath:(NSIndexPath *)indexPath
{
    return _model.couponDS;
}

- (BOOL)getShowBottomViewStatus
{
    if (_model.hasCoupons && _model.hasDiscount)
    {
        return NO;
    }
    
    return YES;
}

- (void)moreCouponsDidTapped
{
    SHLog(@"查看更多优惠券");
    if (_model.couponDS
        && [_model.couponDS isKindOfClass:[NSArray class]]
        && _model.couponDS.count > 1)
    {
        [ESProductCouponListView showCouponListViewWithDataSource:_model.coupons];
    }
}

#pragma mark - ESProductDetailDiscountCellDelegate
- (NSArray *)getProductDiscountAtIndexPath:(NSIndexPath *)indexPath
{
    return _model.discount;
}

#pragma mark - ESProductDetailPromotionCellDelegate
- (ESCartCommodityPromotion *)getProductPromotionAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _model.product.productTagResponseBeans.count)
    {
        return _model.product.productTagResponseBeans[indexPath.row];
    }
    
    return nil;
}

#pragma mark - ESProductDetailBottomButtonDelegate
/// type 1 购物车; 2 添加购物车; 3 立即购买; 4 定制; 5 立即抢购, 6 定金膨胀
- (void)productDetailButtonDidTapped:(NSInteger)type
                              enable:(BOOL)enable
{
    if (![ESLoginManager sharedManager].isLogin && type != 1 && type != 2)
    {
        [[ESLoginManager sharedManager] login];
    }
    else
    {
        switch (type)
        {
            case 1:
            {
                SHLog(@"购物车按钮被点击");
                
                ESShoppingCartController *vc = [[ESShoppingCartController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 2:
            {
                SHLog(@"添加购物车按钮被点击");
                [UMengServices eventWithEventId:Event_click_shop_card attributes:@{@"行为":@"添加购物车"}];
                
                if (enable)
                {
                    [self updateProductCartViewWithStatus:ESProductDetailButtonTypeAddToCart];
                }
                else
                {
                    [self showHudWithMessage:@"此商品已下架"
                              hideAfterDelay:1];
                }
                break;
            }
            case 3:
            {
                SHLog(@"立即购买按钮被点击");
                [UMengServices eventWithEventId:Event_click_shop_card attributes:@{@"行为":@"立即购买"}];
                
                if (enable)
                {
                    [self updateProductCartViewWithStatus:ESProductDetailButtonTypeBuy];
                }
                else
                {
                    [self showHudWithMessage:@"此商品已下架"
                              hideAfterDelay:1];
                }
                break;
            }
            case 4:
            {
                SHLog(@"定制按钮被点击");
                [UMengServices eventWithEventId:Event_click_shop_card attributes:@{@"行为":@"立即定制"}];

                if (enable)
                {
                    [self updateProductCartViewWithStatus:ESProductDetailButtonTypeCustomMade];
                }
                else
                {
                    [self showHudWithMessage:@"此商品已下架"
                              hideAfterDelay:1];
                }
                break;
            }
            case 5:
            {
                SHLog(@"抢购按钮被点击");
                [self flashSaleButtonTapped];
                break;
            }
            case 6:
            {
                SHLog(@"支付定金按钮被点击");
                [self earnestButtonTapped];
            }
            default:
                break;
        }
    }
}

- (NSDictionary *)getBottomParams
{
    BOOL customMade = _model.product.isCustomizable;
    BOOL onSell = _model.product.onShelf;
    return @{
             @"customMade"           : @(customMade),
             @"onSell"               : @(onSell),
             @"flashSaleStatus"      : @(_model.flashSaleStatus),
             @"flashSaleStartStatus" : @(_model.flashSaleStartStatus),
             @"earnestStatus"        : @(_model.earnestStatus),
             @"earnestStartStatus"   : @(_model.earnestStartStatus),
             @"hasStockQuantity"     : @(_model.hasStockQuantity),
             };
}

#pragma mark - ESProductAddCartViewControllerDelegate
- (void)cartCloseButtonDidTapped
{
    [self removeProductCartView];
}

- (void)addItemWithSkuId:(NSString *)skuId
            itemQuantity:(NSInteger)itemQuantity
          isCustomizable:(ESProductDetailButtonType)buttonType
               alertType:(ESProductDetailAlertType)alertType
{
    SHLog(@"skuId:%@", skuId);
    [self removeProductCartView];
 
    if (alertType != ESProductDetailAlertTypeDefault)
    {
        return;
    }
    
    __weak ESProductDetailViewController *weakSelf = self;
    switch (buttonType)
    {
        case ESProductDetailButtonTypeCustomMade:
        {
            [ESProductDetailModel requestForAddCustomItemWithSkuId:skuId
                                                      itemQuantity:itemQuantity
                                                           success:^(NSDictionary *dict)
             {
                 [ESCartUtil resetCartWIthProduct:_model.product
                                   isCustomizable:YES];
                 
                 ESMakeSureCustomOrderController *vc = [[ESMakeSureCustomOrderController alloc] init];
                 [weakSelf.navigationController pushViewController:vc animated:YES];
                 
             } failure:^{
                 
                 [weakSelf showHudWithMessage:@"添加失败"
                               hideAfterDelay:1];
             }];
            break;
        }
            
        case ESProductDetailButtonTypeAddToCart:
        {
            [ESProductDetailModel requestForAddItemWithSkuId:skuId
                                                itemQuantity:itemQuantity
                                                  designerId:_designerId
                                                     success:^(NSDictionary *dict)
             {
                 [ESCartUtil resetCartWIthProduct:_model.product
                                   isCustomizable:NO];
                 
                 [weakSelf showHudWithMessage:@"加入购物车成功"
                               hideAfterDelay:1];
                 
             } failure:^(NSDictionary *errorDict){
                 
                 if (!errorDict[@"quantity"])
                 {
                     [weakSelf showHudWithMessage:@"加入购物车失败, 请稍候再试"
                                   hideAfterDelay:1];
                 }
                 else
                 {
                     [weakSelf showHudWithMessage:@"该商品数量已达上限"
                                   hideAfterDelay:1];
                     
                     NSInteger quantity = [errorDict[@"quantity"] integerValue];
                     quantity = (quantity>0&&quantity<=MAX_CART_NUMBER)?quantity:0;
                     _model.product.cartMaxNum = (MAX_CART_NUMBER - quantity)==0?1:MAX_CART_NUMBER - quantity;
                     _model.product.itemQuantity = _model.product.cartMaxNum;
                     SHLog(@"errorDict:%@",errorDict);
                 }
             }];
            break;
        }
            
        case ESProductDetailButtonTypeBuy:
        {
            [ESProductDetailModel requestForBuyItemWithSkuId:skuId
                                                itemQuantity:itemQuantity
                                                     success:^(NSDictionary *dict)
             {
                 [ESCartUtil resetCartWIthProduct:_model.product
                                   isCustomizable:YES];
                 
                 ESMakeSureNormalOrderController *vc = [[ESMakeSureNormalOrderController alloc] init];
                 [vc setDataSource:dict];
                 [weakSelf.navigationController pushViewController:vc animated:YES];
                 
             } failure:^(NSString *errorMsg){
                 
                 [weakSelf showHudWithMessage:errorMsg
                               hideAfterDelay:1];
             }];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - ESProductCartView
- (void)updateProductCartViewWithStatus:(ESProductDetailButtonType)buttonType
{
    if (!_productCartViewShowStatus)
    {
        [self addProductCartViewWithStatus:buttonType];
    }
    else
    {
        [self removeProductCartView];
    }
}

- (void)updateCartViewShowStatus:(BOOL)status
{
    if (status)
    {
        _productCartViewShowStatus = YES;
        _blurView.hidden = NO;
        [self.view bringSubviewToFront:_blurView];
    }
    else
    {
        _productCartViewShowStatus = NO;
        _blurView.hidden = YES;
        [self.view sendSubviewToBack:_blurView];
    }
}

- (void)addProductCartViewWithStatus:(ESProductDetailButtonType)buttonType
{
    [self updateCartViewShowStatus:YES];
    
    self.cartVC = [[ESProductAddCartViewController alloc] init];
    self.cartVC.product = _model.product;
    self.cartVC.delegate = self;
    self.cartVC.buttonType = buttonType;
    self.cartView = (id)self.cartVC.view;
    self.cartView.frame = CGRectMake(
                                     0,
                                     SCREEN_HEIGHT * (20/100.0),
                                     SCREEN_WIDTH,
                                     SCREEN_HEIGHT - SCREEN_HEIGHT * (20/100.0)
                                     );
    [self.view addSubview:self.cartView];
    
    CGRect originalRect = self.cartView.frame;
    self.cartView.frame = CGRectMake(
                                     0,
                                     CGRectGetHeight(self.view.frame),
                                     CGRectGetWidth(originalRect),
                                     CGRectGetHeight(originalRect)
                                     );
    __weak ESProductDetailViewController *weakSelf = self;
    [UIView animateWithDuration:0.35f
                     animations:^
    {
        weakSelf.cartView.frame = originalRect;
        _blurView.alpha = 0.5f;
    }];
}

- (void)removeProductCartView
{
    __weak ESProductDetailViewController *weakSelf = self;
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

#pragma mark - ESFlashSaleViewDelegate
- (ESFlashSaleInfoModel *)getSkuMessage
{
    return _model.flashSaleInfo;
}

- (void)sureButtonDidTapped:(NSInteger)quantity
{
    [self removeBlurView];

    SHLog(@"立即抢购");
    
    [self activityBuyActivityType:_model.flashSaleInfo.activityType
                       activityId:_model.flashSaleInfo.activityId
                            skuId:_model.flashSaleInfo.sku
                     itemQuantity:quantity];
}

- (void)closeButtonDidTapped
{
    [self removeBlurView];
}

#pragma mark - FlashSale
- (void)showFlashSaleView
{
    [self removeFlashSaleView];
    [self updateCartViewShowStatus:YES];

    CGFloat flashSalViewScale = SCREEN_WIDTH <= 320.0f ? 2.0f : 2.5f;
    _flashSaleView = [ESFlashSaleView flashSaleView];
    _flashSaleView.viewDelegate  = self;
    _flashSaleView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT/flashSalViewScale);
    [_flashSaleView updateView];
    [self.view addSubview:_flashSaleView];
    
    [UIView animateWithDuration:0.3 animations:^{
        _flashSaleView.frame = CGRectMake(
                                          0,
                                          SCREEN_HEIGHT - SCREEN_HEIGHT/flashSalViewScale,
                                          SCREEN_WIDTH,
                                          SCREEN_HEIGHT/flashSalViewScale
                                          );
        _blurView.alpha = 0.5f;
    }];
}

- (void)hideFlashSaleView
{
    CGFloat flashSalViewScale = SCREEN_WIDTH <= 320.0f ? 2.0f : 2.5f;
    WS(weakSelf);
    [UIView animateWithDuration:0.3 animations:^{
        _flashSaleView.frame = CGRectMake(
                                          0,
                                          SCREEN_HEIGHT,
                                          SCREEN_WIDTH,
                                          SCREEN_HEIGHT/flashSalViewScale
                                          );
        _blurView.alpha = 0.01f;
    } completion:^(BOOL finished) {
        
        [weakSelf updateProductCartViewWithStatus:NO];
        [weakSelf removeFlashSaleView];
    }];
}

- (void)removeFlashSaleView
{
    if (_flashSaleView)
    {
        [_flashSaleView removeFromSuperview];
        _flashSaleView.viewDelegate = nil;
        _flashSaleView = nil;
    }
}

#pragma mark - Methods
- (void)updateFlashInfoQuantity:(NSInteger)quantity
{
    if ([_model.flashSaleInfo isKindOfClass:[ESFlashSaleInfoModel class]])
    {
        [_model.flashSaleInfo updateLimitQuantityWithCount:quantity];
    }
}

- (void)flashSaleButtonTapped
{
    if (!_model.flashSaleStartStatus)
    {
        [self showHudWithMessage:@"活动尚未开始" hideAfterDelay:1.2];
    }
    else
    {
        if (!_model.hasStockQuantity)
        {
            [self showHudWithMessage:@"已告罄" hideAfterDelay:1.2];
        }
        else
        {
            SHLog(@"抢购");
            [self showFlashSaleView];
        }
    }
}

- (void)earnestButtonTapped
{
    SHLog(@"支付定金");
    [self activityBuyActivityType:_model.earnestInfo.activityType
                       activityId:_model.earnestInfo.activityId
                            skuId:_model.earnestInfo.skuId
                     itemQuantity:1];
}

- (void)invalidateTimer
{
    if (_countDownTimer
        && [_countDownTimer isKindOfClass:[NSTimer class]])
    {
        [_countDownTimer invalidate];
        _countDownTimer = nil;
    }
}

- (void)activityBuyActivityType:(NSString *)activityType
                     activityId:(NSString *)activityId
                          skuId:(NSString *)skuId
                   itemQuantity:(NSInteger)itemQuantity
{
    [MBProgressHUD showHUDAddedTo:_productView
                         animated:YES];
    __weak ESProductDetailViewController *weakSelf = self;
    [ESProductDetailModel
     requestForBuyWithActivityType:activityType
     activityId:activityId
     skuId:skuId
     itemQuantity:itemQuantity
     success:^(NSDictionary *dict)
     {
         
         [MBProgressHUD hideHUDForView:_productView
                              animated:YES];
         [weakSelf activityBuySuccessActivityType:activityType
                                             dict:dict];
         
     } failure:^(NSString *errorMessage, NSInteger quantity) {
         
         [MBProgressHUD hideHUDForView:_productView
                              animated:YES];
         [weakSelf activityBuyFailureActivityType:activityType
                                         errorMsg:errorMessage
                                         quantity:quantity];
     }];
}

- (void)activityBuySuccessActivityType:(NSString *)activityType
                                  dict:(NSDictionary *)dict
{
    NSInteger activityTypeNum = [activityType integerValue];
    ESMakeSureNormalOrderController *vc = nil;
    if (activityTypeNum == ESProductDetailActivityInfoTypeFlashSale)
    {
        vc = [[ESMakeSureNormalOrderController alloc] init];
    }
    else if (activityTypeNum == ESProductDetailActivityInfoTypeEarnest)
    {
        vc = [[ESMakeSureNormalOrderController alloc] initViewControllerWithType:ESMakeSureOrderTypeDoubleTwelve];
    }
    
    if (vc)
    {
        [vc setDataSource:dict];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)activityBuyFailureActivityType:(NSString *)activityType
                              errorMsg:(NSString *)errorMsg
                              quantity:(NSInteger)quantity
{
    NSInteger activityTypeNum = [activityType integerValue];
    if (activityTypeNum == ESProductDetailActivityInfoTypeFlashSale)
    {
        [self showHudWithMessage:errorMsg
                  hideAfterDelay:1.2f];
        [self updateFlashInfoQuantity:quantity];
    }
    else if (activityTypeNum == ESProductDetailActivityInfoTypeEarnest)
    {
        [self showHudWithMessage:errorMsg
                  hideAfterDelay:1.2f];
    }
}

- (void)showHudWithMessage:(NSString *)message
            hideAfterDelay:(NSTimeInterval)afterDelay
{
    if (!message
        || ![message isKindOfClass:[NSString class]])
    {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                                              animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    [hud hideAnimated:YES afterDelay:afterDelay];
}

#pragma mark - Tap Method
- (void)removeBlurView
{
    if (_model.flashSaleStatus)
    {
        [self hideFlashSaleView];
    }
    else
    {
        [self removeProductCartView];
    }
}

- (void)dealloc
{
    SHLog(@"%@ dealloc", [self class]);
    
    [self invalidateTimer];
}

@end
