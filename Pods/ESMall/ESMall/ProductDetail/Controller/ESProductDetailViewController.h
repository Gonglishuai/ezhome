
#import "MPBaseViewController.h"

typedef NS_ENUM(NSInteger, ESProductDetailType)
{
    ESProductDetailTypeSpu = 0,
    ESProductDetailTypeSku,
};

/// 商品详情页面
@interface ESProductDetailViewController : MPBaseViewController

- (instancetype _Nonnull )initWithProductId:(NSString * _Nonnull)productId
                                       type:(ESProductDetailType)type
                                 designerId:(NSString * __nullable)designerId;

- (instancetype _Nonnull )initWithProductId:(NSString * _Nonnull)productId
                            flashSaleItemId:(NSString * _Nonnull)flashSaleItemId
                                 activityId:(NSString * _Nonnull)activityId;

@end
