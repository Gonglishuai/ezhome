//
//  ESRecommendAPI.h
//  ESNetworking
//
//  Created by jiang on 2018/1/4.
//  Copyright © 2018年 Easyhome Shejijia. All rights reserved.
//

#import "ESMaterialBaseAPI.h"

@interface ESRecommendAPI : ESMaterialBaseAPI

/**
 获取推荐清单列表
 
 @param name 搜索名字
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getRecommendListWithName:(NSString *)name pageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;
/**
 获取推荐清单详情
 
 @param recommendId 推荐清单id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getRecommendDetailWithRecommendId:(NSString *)recommendId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;


/**
 获取推荐品牌列表
 
 @param name 搜索名字
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getBrandRecommendListWithName:(NSString *)name pageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;
/**
 获取推荐品牌详情
 
 @param recommendId 推荐品牌id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getBrandRecommendDetailWithRecommendId:(NSString *)recommendId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;
/**
 删除推荐品牌
 
 @param recommendId 推荐品牌id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)deleteBrandRecommendDetailWithRecommendId:(NSString *)recommendId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 获取合作品牌列表
 
 @param name 搜索名字
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getCooperativeBrandRecommendListWithName:(NSString *)name pageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 获取客户订单订单列表
 
 @param searchName 搜索字段
 @param orderType 订单类型
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getRecommendOrderListWithName:(NSString *)searchName OrderType:(NSString *)orderType pageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 客户订单退货订单列表
 
 @param searchName 搜索字段
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getRecommendReturnOrderListWithName:(NSString *)searchName PageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 获取推荐清单列表
 
 @param X_Member_Id 设计师id
 @param offset 起始记录数
 @param limit 每页条数
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getDesignerRecommendList:(NSString *)X_Member_Id
                      withOffset:(NSInteger)offset
                       withLimit:(NSInteger)limit
                     withSuccess:(void(^)(NSDictionary *dict))success
                      andFailure:(void(^)(NSError *error))failure;


/**
 推送分享 --- 设计师使用
 
 @param dict 数据模型  包括推荐分享的资源和消费者信息
 @param success success
 @param failure failure
 */
+ (void)postRecommendShareDictionary:(NSDictionary *)dict
                         withSuccess:(void(^)(NSDictionary *dict))success
                          andFailure:(void(^)(NSError *error))failure;

/**
 校验手机号是否为平台用户
 
 @param phoneNumber 推送的手机号
 @param success success
 @param failure failure
 */
+ (void)postCheckPhoneNumberIsUser:(NSString *)phoneNumber
                       withSuccess:(void(^)(NSDictionary *dict))success
                        andFailure:(void(^)(NSError *error))failure;
@end
