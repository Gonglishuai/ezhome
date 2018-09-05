
#import "ESBaseModel.h"

//{
//    "activityId":"217591444268875776",
//    "activityName":"定金20171127",
//    "activityType":40,
//    "earnestAmount":100,
//    "discountAmount":500,
//    "earnestDexTime":-186053811,
//    "finalPaymentStartTime":1511820563000,
//    "finalPaymentEndTime":1511906963000,
//    "placeQuantity":0,
//    "finalPaymentAmount":2966
//}

@interface ESProductDetailEarnestModel : ESBaseModel

@property (nonatomic, copy) NSString *activityId;
@property (nonatomic, copy) NSString *activityName;
@property (nonatomic, copy) NSString *activityType;
@property (nonatomic, copy) NSString *earnestAmount;
@property (nonatomic, copy) NSString *discountAmount;
@property (nonatomic, copy) NSString *earnestDexTime;
@property (nonatomic, copy) NSString *finalPaymentStartTime;
@property (nonatomic, copy) NSString *finalPaymentEndTime;
@property (nonatomic, copy) NSString *placeQuantity;
@property (nonatomic, copy) NSString *finalPaymentAmount;
@property (nonatomic, assign) BOOL isStart;
@property (nonatomic, assign) BOOL isEarnestStart;

// 我的新增
/// 商品名称
@property (nonatomic, copy) NSString *productName;
@property (nonatomic, copy) NSString *activityPrice;
@property (nonatomic, copy) NSString *skuId;

@end
