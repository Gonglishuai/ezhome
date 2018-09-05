//
//  ESDesignAPI.h
//  Consumer
//
//  Created by 焦旭 on 2017/11/13.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "JRBaseAPI.h"

@interface ESDesignAPI : JRBaseAPI

/**
 获取业主项目列表

 @param j_member_id id
 @param offset 起始数
 @param limit 返回数
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getProprietorProjectList:(NSString *)j_member_id
                      withOffset:(NSString *)offset
                       withLimit:(NSString *)limit
                     withSuccess:(void(^)(NSDictionary *dict))success
                      andFailure:(void(^)(NSError *error))failure;

/**
 获取设计师项目列表

 @param dispatchType 项目类型 //5:套餐  6:其它  7:个性定制
 @param designerId 设计师id
 @param offset 起始数
 @param limit 返回数
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getDemandListWithDispatchType:(NSString *)dispatchType
                       withDesignerId:(NSString *)designerId
                           withOffset:(NSString *)offset
                            withLimit:(NSString *)limit
                          withSuccess:(void(^)(NSDictionary *dict))success
                           andFailure:(void(^)(NSError *error))failure;

/**
 项目详情
 
 @param demandId 项目id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getDemandDetailWithDemandId:(NSString *)demandId
                         andSuccess:(void(^)(NSDictionary *dict))success
                         andFailure:(void(^)(NSError *error))failure;


/**
 获取设计师详情

 @param designerId 设计师id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getDesignerInfoWithDesignerId:(NSString *)designerId
                              success:(void (^)(NSDictionary *dict))success
                              failure:(void(^) (NSError *error))failure;
@end
