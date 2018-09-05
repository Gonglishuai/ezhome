
#import "ESBaseModel.h"

typedef NS_ENUM(NSInteger, ESPayWay)
{
    ESPayWayUnKnow = 0,
    ESPayWayAlipy,
    ESPayWayWeChat,
    ESpayWayUPA,//银联
    ESpayWayFinance,//居然金融
};

@interface ESPayTimesModel : ESBaseModel

/// 获取所有的cellIds
+ (NSArray *)getPayTimesCellIds;

/// 获取施工支付需要的信息
+ (NSMutableArray *)createEnterprisePayCells:(BOOL)firstStatus
                                 partPayment:(BOOL)partPayment
                                  hasFinance:(BOOL)hasFinance
                                      amount:(NSString *)amount
                                     message:(NSString *)message;

/// 获取非施工支付显示的信息
+ (NSMutableArray *)createMaterialPayCells:(BOOL)firstStatus
                               partPayment:(BOOL)partPayment
                                hasFinance:(BOOL)hasFinance
                                    amount:(NSString *)amount;

/// seitch切换时刷新ui
+ (void)updateDataSourceWithSwitchStatus:(BOOL)switchOn
                                      ds:(NSMutableArray *)dataSource;

/// 刷新支付方式
+ (void)updatePayWayWithDataSource:(NSMutableArray *)dataSource
                         indexPath:(NSIndexPath *)indexPath
                             title:(NSString *)title;

/// 获取施工协议是否同意的信息
+ (BOOL)getEnterpriseAgreementStatusWithDataSource:(NSArray *)dataSource;

/// 获取支付方式
+ (ESPayWay)getPayWayWithDataSource:(NSArray *)dataSource;


/**
 获取支付方式

 @param payWay ESPayWay
 @return NSString
 */
+ (NSString *)getPayWayString:(ESPayWay)payWay;

/// 支付
+ (void)payForWithOrderId:(NSString *)orderId
                   rateId:(NSString *)rateId
                   payWay:(ESPayWay)payWay
                payAmount:(NSString *)payAmount
createOrderSuccessCallback:(void (^)(NSDictionary *dict))callback
                  success:(void (^)(BOOL success, NSString *tipMessage))success
                  failure:(void(^)(NSString *errorMessage))failure;

/// 获取施工返现活动的提示文字
+ (void)requestForEnterpriseTipMessage:(void (^) (NSString *message))success
                               failure:(void (^) (NSError *error))failure;

@end
