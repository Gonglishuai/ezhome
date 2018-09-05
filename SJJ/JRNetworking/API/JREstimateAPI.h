//
//  JREstimateAPI.h
//  Consumer
//
//  Created by jiang on 2017/5/3.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JRBaseAPI.h"
@class JRDesignInfomodel;

@interface JREstimateAPI : JRBaseAPI

/**立即预约、创建套餐*/
+(void)estimateWithParamDic:(NSDictionary*)paramDic andSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**设计详情*/
+ (void)getEngineDetailWithDemandsId:(NSString *)demands_id andSuccess:(void(^)(JRDesignInfomodel *requirement))success andFailure:(void(^)(NSError *error))failure;

/**设计详情*/
+ (void)getDesignDetailWithDesignId:(NSString *)designId
                            success:(void(^)(NSDictionary *dict))success
                            failure:(void(^)(NSError *error))failure;

/**发起收款*/
+(void)makeCollectionsWithDemandsId:(NSString *)demands_id paramDic:(NSDictionary*)paramDic andSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**面对面生成二维码*/
+ (void)getPaymentQRWithBody:(NSDictionary *)body
                 withSuccess:(void (^)(NSDictionary * dict))success
                  andFailure:(void(^)(NSError * error))failure;

/**面对面是否已支付*/
+(void)getPaySuccessWithDemandsId:(NSString *)demands_id andSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**算算你家要花多少钱*/
+(void)computeYourHouseWithParamDic:(NSDictionary*)paramDic andSuccess:(void (^)(NSDictionary * dict))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

/**获取短信验证码--算算你家要花多少钱*/
+(void)getMessageCodeWithParamDic:(NSDictionary*)paramDic andSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

//算算你家要花多少钱--房屋类型几室几厅
+ (void)getHouseTypeSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**套餐首页*/
+ (void)getPackageHomeInfoWithSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**支付定金*/
+(void)payForWithOrderId:(NSString *)orderId orderLineId:(NSString *)orderLineId andSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

//算算你家要花多少钱--已有业主数
+ (void)getComputNumSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/// 获取退款项目列表
+ (void)getReturnGoodsListWithProjectId:(NSString *)pid
                                 offset:(NSInteger)offset
                                  limlt:(NSInteger)limit
                                success:(void (^) (NSDictionary *dict))success
                                failure:(void (^) (NSError *error))failure;

/// 创建退款项目
+ (void)createReturnGoodsWithOrderId:(NSString *)orderId
                              reason:(NSString *)reason
                             success:(void (^) (NSDictionary *dict))success
                             failure:(void (^) (NSError *error))failure;

/// 获取退款项目详情
+ (void)getRefundDetailWithRefundId:(NSString *)refundId
                            success:(void (^) (NSDictionary *dict))success
                            failure:(void (^) (NSError *error))failure;

@end
