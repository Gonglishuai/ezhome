
#import "ESBaseModel.h"

/**
 "orderSerialNumber": "103086104231542786",
 "payTime": "2017-09-11 18:46:41",
 "payAmount": 123,
 "payMethod": "线下支付"
 */

/// 交易明细
@interface ESTransactionDetailModel : ESBaseModel

@property (nonatomic, copy) NSString *orderSerialNumber;
@property (nonatomic, copy) NSString *payTime;
@property (nonatomic, copy) NSString *payAmount;
@property (nonatomic, copy) NSString *payMethod;

@end
