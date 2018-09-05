
#import "ESBaseModel.h"
#import "ESFlashSaleValueModel.h"

/**
 "itemPrice":10620,
 "salePrice":10,
 "dexTime":0,
 "limitQuantity":1,
 "stockQuantity":10,
 "skuValues":[
 {
 "name":"花色",
 "value":"其他"
 },
 {
 "name":"材质",
 "value":"实木"
 },
 {
 "name":"规格",
 "value":"其他"
 }
 ],
 "isStart":false,
 "itemName":"乔伊",
 "itemImg":"http://img-beta.gdfcx.net/img/546e8b19498e74f7718b4035.img",
 "sku":"0000310009083"
 */

/// 秒杀商品信息
@interface ESFlashSaleInfoModel : ESBaseModel

@property (nonatomic, copy) NSString *itemPrice;
@property (nonatomic, copy) NSString *salePrice;
@property (nonatomic, copy) NSString *dexTime;
@property (nonatomic, copy) NSString *limitQuantity;
@property (nonatomic, copy) NSString *buyQuantity;
@property (nonatomic, copy) NSString *stockQuantity;
@property (nonatomic, copy) NSString *activityName;
@property (nonatomic, copy) NSString *activityType;
@property (nonatomic, copy) NSString *activityId;

@property (nonatomic, retain) NSArray <ESFlashSaleValueModel *> *skuValues;

@property (nonatomic, copy) NSString *isStart;
@property (nonatomic, copy) NSString *itemName;
@property (nonatomic, copy) NSString *itemImg;
@property (nonatomic, copy) NSString *sku;

// 我的新增
@property (nonatomic, copy) NSString *skuValueMessage;
@property (nonatomic, copy) NSString *productName;

/// 更新可购数量
- (void)updateLimitQuantityWithCount:(NSInteger)count;

@end
