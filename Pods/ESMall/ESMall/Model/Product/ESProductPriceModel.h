
#import "ESBaseModel.h"

@interface ESProductPriceModel : ESBaseModel

/**
 currency (string, optional): 货币 ,
 usage (string, optional): 用途 ,
 value (number, optional): 值 ,
 region (string, optional): 区域
 */

@property (nonatomic, copy) NSString *currency;
@property (nonatomic, copy) NSString *usage;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *region;

@property (nonatomic, copy) NSString *showValue;

@end
