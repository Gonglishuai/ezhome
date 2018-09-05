
#import "MPBaseViewController.h"

/// 商品详情页
typedef NS_ENUM(NSInteger, ESProductDetailButtonType)
{
    ESProductDetailButtonTypeUnknow = 0,
    ESProductDetailButtonTypeShoppingCart,
    ESProductDetailButtonTypeAddToCart,
    ESProductDetailButtonTypeBuy,
    ESProductDetailButtonTypeCustomMade,
    ESProductDetailButtonTypeFlashSale
};

/// 弹窗类型, default:商品详情, ShopCart: 购物车
typedef NS_ENUM(NSInteger, ESProductDetailAlertType)
{
    ESProductDetailAlertTypeDefault = 0,
    ESProductDetailAlertTypeShopCart,
};

@class ESProductModel;
@protocol ESProductAddCartViewControllerDelegate <NSObject>

- (void)cartCloseButtonDidTapped;

- (void)addItemWithSkuId:(NSString *)skuId
            itemQuantity:(NSInteger)itemQuantity
          isCustomizable:(ESProductDetailButtonType)buttonType
               alertType:(ESProductDetailAlertType)alertType;

@end

/// 添加购物车页面
@interface ESProductAddCartViewController : MPBaseViewController

@property (nonatomic, assign) id<ESProductAddCartViewControllerDelegate>delegate;

/// 商品数据模型, 必传
@property (nonatomic, retain) ESProductModel *product;

/// 商品详情页按钮类型
@property (nonatomic, assign) ESProductDetailButtonType buttonType;

/// 弹窗类型, 商品详情页或者购物车页
@property (nonatomic, assign) ESProductDetailAlertType alertType;

/// 选中属性信息 @{@"nameId1":@"valueId1", @"nameId2":@"valueId2"}, 目前用于购物车页
@property (nonatomic, retain) NSDictionary *selectedAttributesIDs;

@end
