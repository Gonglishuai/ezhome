//
//  ESCaseAPI.h
//  Consumer
//
//  Created by jiang on 2017/8/18.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JRBaseAPI.h"
#import "ESCaseDetailModel.h"

@interface ESCaseAPI : JRBaseAPI

/**
 获取案例详情
 
 @param caseId 案例id
 @param caseType 2d或3d
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getCaseDetailWithCaseId:(NSString *)caseId
                        brandId:(NSString *)brandId
                       caseType:(NSString *)caseType
                     caseSource:(NSString *)source
                     andSuccess:(void(^)(ESCaseDetailModel *caseDetailModel))success
                     andFailure:(void(^)(NSError *error))failure;

+ (void)getCaseDetailWithCaseId:(NSString *)caseId
                       caseType:(NSString *)caseType
                     caseSource:(NSString *)source
                     andSuccess:(void(^)(ESCaseDetailModel *caseDetailModel))success
                     andFailure:(void(^)(NSError *error))failure;

/// 套餐样板间列表
+ (void)getSampleRoomListWithOffset:(NSInteger)offset
                              limlt:(NSInteger)limit
                             tagStr:(NSString *)tagStr
                         searchTerm:(NSString *)searchTerm
                            success:(void (^) (NSDictionary *dict))success
                            failure:(void (^) (NSError *error))failure;

/// 套餐样板间列表筛选tags

+ (void)getSampleRoomFilterTagsSuccess:(void (^) (NSArray *array))success
                               failure:(void (^) (NSError *error))failure;
/**
 获取案例详情评论列表
 
 @param caseId 案例id
 @param pageNum 页码 1开始
 @param pageSize 每页数量
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getCaseDetailCommentListWithCaseId:(NSString *)caseId
                                   pageNum:(NSInteger)pageNum
                                  pageSize:(NSInteger)pageSize
                                andSuccess:(void(^)(NSArray *array, NSInteger commentNum))success
                                andFailure:(void(^)(NSError *error))failure;


/**
 评论案例详情
 
 @param caseId 案例id
 @param caseType 2d或3d
 @param caseComment 评论内容
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)saveCaseDetailCommentWithCaseId:(NSString *)caseId
                               caseName:(NSString *)caseName
                               caseType:(NSString *)caseType
                            caseComment:(NSString *)caseComment
                             andSuccess:(void(^)(NSDictionary *dict))success
                             andFailure:(void(^)(NSError *error))failure;

/**
 加入样板间
 
 @param productId 案例id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)addToModelRoomWithProductId:(NSString *)productId
                         andSuccess:(void(^)(NSDictionary *dict))success
                         andFailure:(void(^)(NSError *error))failure;

/**
 我的评论列表
 
 @param pageNum 页码 1开始
 @param pageSize 每页数量
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getMyCommentListWithPageNum:(NSInteger)pageNum
                           pageSize:(NSInteger)pageSize
                         andSuccess:(void(^)(NSArray *array, NSInteger commentNum))success
                         andFailure:(void(^)(NSError *error))failure;

/**
 删除评论
 
 @param goalId 评论id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)deleteCommentWithGoalId:(NSString *)goalId
                     andSuccess:(void(^)(NSDictionary *dict))success
                     andFailure:(void(^)(NSError *error))failure;



/**
 案例推荐商品顶级目录
 
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getCaseCategoryListWithSuccess:(void(^)(NSArray *array))success
                            andFailure:(void(^)(NSError *error))failure;




/**
 推荐商品类别
 
 @param categoryId 案例id
 @param categoryId 目录id
 @param pageNum 页码 1开始
 @param pageSize 每页数量
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getRecommendProductListWithCaseId:(NSString *)caseId
                               CategoryId:(NSString *)categoryId
                                  pageNum:(NSInteger)pageNum
                                 pageSize:(NSInteger)pageSize
                               andSuccess:(void(^)(NSArray *array, NSInteger commentNum))success
                               andFailure:(void(^)(NSError *error))failure;

/// 家装试衣间首页
+ (void)getCaseFittingRoomHomeSuccess:(void (^) (NSDictionary *dict))success
                              failure:(void (^) (NSError *error))failure;

/// 家装试衣间列表
+ (void)getFittingRoomListWithOffset:(NSInteger)offset
                               limlt:(NSInteger)limit
                           spaceType:(NSString *)spaceType
                             success:(void (^) (NSDictionary *dict))success
                             failure:(void (^) (NSError *error))failure;

/**
 丽屋超市首页
 
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getLiWuMarketHomeSuccess:(void(^)(NSDictionary *dict))success
                      andFailure:(void(^)(NSError *error))failure;
@end
