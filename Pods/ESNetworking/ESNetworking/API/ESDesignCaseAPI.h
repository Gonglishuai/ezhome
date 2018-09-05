//
//  ESCaseAPI.h
//  Consumer
//
//  Created by 焦旭 on 2017/11/3.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  案例相关API
#import "JRBaseAPI.h"

@interface ESDesignCaseAPI : JRBaseAPI

/**
 获取案例筛选所有标签

 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getDesignCaseTagsWithSuccess:(nullable void(^)(NSDictionary * _Nullable dict))success
                          andFailure:(nullable void(^)(NSError * _Nullable error))failure;

/**
 根据搜索词获得相关的2D案例

 @param searchTerm 案例名称或者室厅卫等
 @param facet 标签筛选项
 @param sort 排序,以逗号分隔如果多重排序 （sort asc,roomArea asc）
 @param offset 记录开始位置
 @param limit 返回条数
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)get2DCasesWithSearchTerm:(NSString * _Nullable)searchTerm
                       withFacet:(NSString * _Nullable)facet
                        withSort:(NSString * _Nullable)sort
                      withOffset:(NSString * _Nonnull)offset
                       withLimit:(NSString * _Nonnull)limit
                      andSuccess:(nullable void(^)(NSDictionary * _Nullable dict))success
                      andFailure:(nullable void(^)(NSError * _Nullable error))failure;

/**
 根据搜索词获得相关的3D案例
 
 @param searchTerm 案例名称或者室厅卫等
 @param facet 标签筛选项
 @param sort 排序,以逗号分隔如果多重排序 （sort asc,roomArea asc）
 @param offset 记录开始位置
 @param limit 返回条数
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)get3DCasesWithSearchTerm:(NSString * _Nullable)searchTerm
                       withFacet:(NSString * _Nullable)facet
                        withSort:(NSString * _Nullable)sort
                      withOffset:(NSString * _Nonnull)offset
                       withLimit:(NSString * _Nonnull)limit
                      andSuccess:(nullable void(^)(NSDictionary * _Nullable dict))success
                      andFailure:(nullable void(^)(NSError * _Nullable error))failure;

/**
 获取2D案例详情

 @param assetId id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)get2DCaseDetail:(NSString *_Nonnull)assetId
            withSuccess:(nullable void(^)(NSDictionary * _Nullable dict))success
             andFailure:(nullable void(^)(NSError * _Nullable error))failure;



/**
 // 3D 案例集列表(设计师详情下-3D)

 @param urlDict urlDict
 @param headerDict headerDict
 @param bodyDict bodyDict
 @param success 成功回调
 @param failure  失败回调
 */
+ (void)get3DListOfDesignerCasesWithUrl:(NSDictionary *_Nullable)urlDict
                                 header:(NSDictionary *_Nullable)headerDict
                                   body:(NSDictionary *_Nullable)bodyDict
                                success:(nullable void(^)(NSDictionary * _Nullable dictionary))success
                                failure:(nullable void(^)(NSError * _Nullable error))failure;



/**
 3D 案例集列表(设计师详情下-效果图)

 @param urlDict urlDict
 @param headerDict headerDict
 @param bodyDict bodyDict
 @param success 成功回调
 @param failure  失败回调
 */
+ (void)getListOfDesignerCasesWithUrl:(NSDictionary *_Nullable)urlDict
                               header:(NSDictionary *_Nullable)headerDict
                                 body:(NSDictionary *_Nullable)bodyDict
                              success:(nullable void(^)(NSDictionary * _Nullable dictionary))success
                              failure:(nullable void(^)(NSError * _Nullable error))failure;
@end
