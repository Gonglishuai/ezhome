
#import "MPBaseViewController.h"

// 施工支付or商城
typedef NS_ENUM(NSInteger, ESPayType)
{
    ESPayTypeUnKnow = 0,
    ESPayTypeEnterprise,
    ESPayTypeMaterial,
    ESPayTypePkgProjectList,
    ESPayTypePkgProjectDetail
};

// 是否首次支付
typedef NS_ENUM(NSInteger, ESPayTimesType)
{
    ESPayTimesTypeUnKnow = 0,
    ESPayTimesTypeFirst,
    ESPayTimesTypeAgain,
};

/// 分笔支付页面
@interface ESPayTimesViewController : MPBaseViewController

/**
 支付页面初始化

 @param orderId 支付订单id
 @param amount 金额
 @param partPayment 是否允许分笔支付
 @param loanDic 费率字典
 @param payType 支付类型
 @param payTimesType 支付次数类型
 @return 初始化
 */

- (instancetype)initWithOrderId:(__kindof NSString *)orderId
                     payOrderId:(__kindof NSString *)payOrderId
                        brandId:(__kindof NSString *)brandId
                         amount:(__kindof NSString *)amount
                    partPayment:(BOOL)partPayment
                        loanDic:(NSDictionary *)loanDic
                        payType:(ESPayType)payType
                   payTimesType:(ESPayTimesType)payTimesType;

@end
