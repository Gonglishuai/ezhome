
#import "ESCartCommodityPromotionGift.h"

@implementation ESCartCommodityPromotionGift

- (id)createModelWithDic:(NSDictionary *)dic
{
    [super createModelWithDic:dic];
    
    [self upateModel];
    
    return self;
}

- (void)upateModel
{
    if ([self.objType isKindOfClass:[NSString class]]
        && ([self.objType isEqualToString:@"10"]
            || [self.objType isEqualToString:@"11"]))
    {//`obj_type` int(1) DEFAULT NULL COMMENT '10-真实商品\\r\\n            11-商品\\r\\n            20-虚拟商品\\r\\n            21-活动门票   30-优惠券',
        self.productStatus = YES;
    }
}

@end
