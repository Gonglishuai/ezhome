//
//  ESOrderAPI.h
//  Consumer
//
//  Created by jiang on 2017/6/28.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMaterialBaseAPI.h"

@interface ESOrderAPI : ESMaterialBaseAPI

/**
 获取商城首页信息
 
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getMasterialWithSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 获取商品列表信息
 
 @param categoryId 目录id
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getMasterialListWithCategoryId:(NSString *)categoryId
                            catalogId:(NSString *)catalogId
                             pageSize:(NSInteger)pageSize
                              pageNum:(NSInteger)pageNum
                              Success:(void (^)(NSDictionary * dict))success
                              failure:(void(^)(NSError * error))failure;


/**
 搜索商品列表
 
 @param searchName 搜索词
 @param facet 筛选项
 @param sort 排序
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)searchGoodsListWithName:(NSString *)searchName
                     catalogId:(NSString *)catalogId
                         facet:(NSString *)facet
                          sort:(NSString *)sort
                      pageSize:(NSInteger)pageSize
                       pageNum:(NSInteger)pageNum
                       Success:(void (^)(NSDictionary * dict))success
                       failure:(void(^)(NSError * error))failure;

/**
 支付订单
 
 @param orderId 订单id
 @param payWay 支付方式  支付方式 1支付宝app支付 2支付宝网页支付 3微信app支付 4微信网页扫码支付 5微信公众号支付 6支付宝当面付
 @param success 成功回调
 @param failure 失败回调
 */
+(void)payForWithOrderId:(NSString *)orderId payWay:(NSString *)payWay Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

+(void)payForWithOrderId:(NSString *)orderId
                  rateId:(NSString *)rateId
                  payWay:(NSString *)payWay
               payAmount:(NSString *)payAmount
                 Success:(void (^)(NSDictionary * dict))success
                 failure:(void(^)(NSError * error))failure;
/**
 草签转正签首款支付
 
 @param orderId 订单id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)initialToFormalpayForWithOrderId:(NSString *)orderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 获取订单列表
 
 @param orderType 订单类型
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getOrderListWithOrderType:(NSString *)orderType pageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 我的退货订单列表
 
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getReturnOrderListWithPageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 取消退货单
 
 @param returnOrderId 退货订单id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)cancelReturnOrderWithReturnOrderId:(NSString *)returnOrderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 获取订单详情
 
 @param orderId 订单id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getOrderDetailWithOrderId:(NSString *)orderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 去支付
 
 @param orderId 订单id
 @param brandId 品牌id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)goPayWithOrderId:(NSString *)orderId brandId:(NSString *)brandId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 确认收货
 
 @param orderId 订单id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getGoodsWithOrderId:(NSString *)orderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 取消订单
 
 @param orderId 订单id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)cancelOrderWithOrderId:(NSString *)orderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 购物车结算
 
 @param paramDic 信息集合
 @param success 成功回调
 @param failure 失败回调
 */
+(void)createOrderWithParamDic:(NSDictionary*)paramDic Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 查看结算订单基本信息
 
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getPendingOrderWithSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 提交订单
 
 @param paramDic 要结算的购物车的信息集合
 @param success 成功回调
 @param failure 失败回调
 */
+(void)placeOrderAppWithParamDic:(NSDictionary*)paramDic Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

#pragma mark - 发票

/**
 设置发票信息
 
 @param paramDic 发票信息
 @param success 成功回调
 @param failure 失败回调
 */
+(void)setInvoiceWithParamDic:(NSDictionary*)paramDic Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 获取发票信息

 @param invoiceId 发票id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getInvoiceWithInvoiceId:(NSString *)invoiceId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;


#pragma mark - 退款退货服务

/**
 获取退货详情
 
 @param returnGoodsId 退货单Id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)retrieveReturnGoodsDetailWithId:(NSString *)returnGoodsId
                            withSuccess:(void(^)(NSDictionary *dict))success
                             andFailure:(void(^)(NSError *error))failure;

/**
 确认退款成功
 
 @param returngGoodsId 退货单Id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)confirmReturnGoodsWithId:(NSString *)returngGoodsId
                     withSuccess:(void(^)(void))success
                      andFailure:(void(^)(NSError *error))failure;

/**
 获取申请退货订单信息
 
 @param ordersId 订单id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getReturnGoodsApplyInfo:(NSString *)ordersId
                    withSuccess:(void(^)(NSDictionary *dict))success
                     andFailure:(void(^)(NSError *error))failure;

/**
 新增退货单
 
 @param info 退货单信息
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)createNewReturnGoodsWithInfo:(NSDictionary *)info
                         withSuccess:(void(^)(NSDictionary *dict))success
                          andFailure:(void(^)(NSError *error))failure;

/**
 服务门店列表
 
 @param subOrderId 子订单Id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getStoreListWithSubOrderId:(NSString *)subOrderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;


/**
 选择优惠券列表
 
 @param type 优惠券状态：1可用  2不可用
 @param subOrderId 子订单Id
 @param orderId 订单Id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getSelectCouponsListWithType:(NSString *)type SubOrderId:(NSString *)subOrderId orderId:(NSString *)orderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 添加优惠券
 
 @param couponId 优惠券Id
 @param subOrderId 子订单Id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)addPendingCouponWithCouponId:(NSString *)couponId SubOrderId:(NSString *)subOrderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 取消优惠券
 
 @param couponId 优惠券Id
 @param subOrderId 子订单Id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)deletePendingCouponWithCouponId:(NSString *)couponId SubOrderId:(NSString *)subOrderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 我的优惠券列表
 
 @param type 优惠券状态：1 未使用，2 已使用，3 已过期，4 已退回
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getMyCouponsListWithType:(NSString *)type pageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 我的装修基金券列表
 
 @param type 1 返现记录，2 消费记录
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getMyGoldListWithType:(NSString *)type pageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 使用装修基金
 
 @param orderId 订单Id
 @param goldNum 装修基金数量
 @param success 成功回调
 @param failure 失败回调
 */
+(void)useGoldWithOrderId:(NSString *)orderId goldNum:(NSString *)goldNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

@end


