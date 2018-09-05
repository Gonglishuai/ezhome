//
//  ESCommentAPI.h
//  Consumer
//
//  Created by jiang on 2017/11/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "JRBaseAPI.h"

@interface ESCommentAPI : JRBaseAPI

/**
 点赞

 @param resourceId 资源id
 @param type 资源类型  0设计师,1.案例,2.商品,3.其他
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)addLikeWithResourceId:(NSString *)resourceId
                      type:(NSString *)type
                     withSuccess:(void(^)(NSDictionary *dict))success
                      andFailure:(void(^)(NSError *error))failure;


/**
 取消点赞

 @param resourceId 资源id
 @param type 资源类型  0设计师,1.案例,2.商品,3.其他
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)deleteLikeWithResourceId:(NSString *)resourceId
                         type:(NSString *)type
                  withSuccess:(void(^)(NSDictionary *dict))success
                   andFailure:(void(^)(NSError *error))failure;


/**
 关注

 @param followId 被关注id
 @param type 资源类型  0设计师,1.案例,2.商品,3.其他
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)addFollowWithFollowId:(NSString *)followId
                         type:(NSString *)type
                  withSuccess:(void(^)(NSDictionary *dict))success
                   andFailure:(void(^)(NSError *error))failure;

/**
 取消关注
 
 @param followId 被关注id
 @param type 资源类型  0设计师,1.案例,2.商品,3.其他
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)deleteFollowWithFollowId:(NSString *)followId
                            type:(NSString *)type
                     withSuccess:(void(^)(NSDictionary *dict))success
                      andFailure:(void(^)(NSError *error))failure;


/**
 获取关注列表

 @param pageNum 页码 1开始
 @param pageSize 每页数量
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getMyFollowListWithPageNum:(NSInteger)pageNum
                          pageSize:(NSInteger)pageSize
                     withSuccess:(void(^)(NSDictionary *dict))success
                      andFailure:(void(^)(NSError *error))failure;

@end
