
#import "ESBaseModel.h"
#import "ESProductModel.h"
#import "ESProductStoreModel.h"
#import "ESProductDetailSampleroomModel.h"
#import "ESFlashSaleInfoModel.h"
#import "ESProductDetailCouponsModel.h"
#import "ESProductDetailEarnestModel.h"

typedef NS_ENUM(NSInteger, ESProductDetailActivityInfoType)
{
    ESProductDetailActivityInfoTypeUnknow = 0,
    ESProductDetailActivityInfoTypeFlashSale = 10,
    ESProductDetailActivityInfoTypeEarnest = 40,
};

/**
 "product":Object{...},
 "stores":[],
 "merchantMobile":"400-650-3333"
 */

@interface ESProductDetailModel : ESBaseModel

//@property (nonatomic, retain) ESFlashSaleInfoModel *flashSaleInfo;
//@property (nonatomic, retain) NSArray *activityInfo; 活动信息

@property (nonatomic, retain) ESProductModel *product;
@property (nonatomic, retain) NSArray <ESProductStoreModel *> *stores;
@property (nonatomic, copy) NSString *merchantMobile;
@property (nonatomic, retain) NSArray <ESProductDetailSampleroomModel *> *sampleroom;
@property (nonatomic, retain) NSArray <NSString *> *discount;
@property (nonatomic, retain) NSArray <ESProductDetailCouponsModel *> *coupons;

/// 我的新增
@property (nonatomic, assign) BOOL hasStores;
@property (nonatomic, assign) BOOL hasModel;
@property (nonatomic, assign) BOOL hasStockQuantity;
@property (nonatomic, assign) BOOL hasDiscount;
@property (nonatomic, assign) BOOL hasCoupons;
@property (nonatomic, assign) BOOL flashSaleStatus;
@property (nonatomic, assign) BOOL flashSaleStartStatus;
@property (nonatomic, assign) BOOL earnestStatus;
@property (nonatomic, assign) BOOL earnestStartStatus;
@property (nonatomic, assign) BOOL promotiomStatus;//促销

/// 详情页优惠券
@property (nonatomic, retain) NSArray <NSString *> *couponDS;
/// 抢购信息, 从activityInfo中获取
@property (nonatomic, retain) ESFlashSaleInfoModel *flashSaleInfo;
/// 定金膨胀信息, 从activityInfo中获取
@property (nonatomic, retain) ESProductDetailEarnestModel *earnestInfo;

+ (NSDictionary *)getJuranPromise;

+ (void)requestForProductDetailWithID:(NSString *)productId
                                 type:(NSString *)type
                      flashSaleItemId:(NSString *)flashSaleItemId
                           activityId:(NSString *)activityId
                              success:(void (^) (ESProductDetailModel *model))success
                              failure:(void (^)(void))failure;

+ (void)requestForAddItemWithSkuId:(NSString *)skuId
                      itemQuantity:(NSInteger)itemQuantity
                        designerId:(NSString *)designerId
                           success:(void (^) (NSDictionary *dict))success
                           failure:(void (^) (NSDictionary *errorDict))failure;

+ (void)requestForBuyItemWithSkuId:(NSString *)skuId
                      itemQuantity:(NSInteger)itemQuantity
                           success:(void (^) (NSDictionary *))success
                           failure:(void (^) (NSString *errMeg))failure;

+ (void)requestForAddCustomItemWithSkuId:(NSString *)skuId
                            itemQuantity:(NSInteger)itemQuantity
                                 success:(void (^) (NSDictionary *dict))success
                                 failure:(void (^)(void))failure;

/// 活动购买, 包括抢购, 定金膨胀
+ (void)requestForBuyWithActivityType:(NSString *)activityType
                           activityId:(NSString *)activityId
                                skuId:(NSString *)skuId
                         itemQuantity:(NSInteger)itemQuantity
                              success:(void (^) (NSDictionary *dict))success
                              failure:(void (^) (NSString *errorMessage,
                                                 NSInteger quantity))failure;

@end
