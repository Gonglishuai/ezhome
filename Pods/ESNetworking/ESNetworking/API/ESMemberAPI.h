//
//  ESMemberAPI.h
//  Consumer
//
//  Created by 焦旭 on 2017/8/18.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JRBaseAPI.h"

@interface ESMemberAPI : JRBaseAPI

/**
 获取当前用户信息
 
 @param j_member_id id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getMemberInfoWithID:(NSString *)j_member_id
                andSucceess:(void(^)(NSDictionary *dict))success
                 andFailure:(void(^)(NSError *error))failure;

/**
 更新用户头像
 
 @param file 图片文件
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)updateMemberAvatarWithFile:(NSData *)file
                        witSuccess:(void (^)(NSDictionary *dict))success
                        andFailure:(void(^)(NSError *error))failure;

/**
 更新用户信息
 
 @param j_member_id id
 @param dict 更新内容
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)updataMemberInfoWithID:(NSString *)j_member_id
                      withDict:(NSDictionary *)dict
                   withSuccess:(void(^)(NSDictionary *dict))success
                    andFailure:(void(^)(NSError *error))failure;

/**
 获取设计师筛选tags
 
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getDesignerTagsWithSuccess:(void(^)(NSDictionary *dict))success
                        andFailure:(void(^)(NSError *error))failure;

/**
 获取个性定制海报图片

 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getIndividuationImagesWithSuccess:(void(^)(NSDictionary *dict))success
                               andFailure:(void(^)(NSError *error))failure;



/**
 获取我的消息

 @param paramDict NSDictionary参数
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getMyMessageListWithParam:(NSDictionary *)paramDict
                       andSuccess:(void(^) (NSDictionary *dict))success
                       andFailure:(void(^) (NSError *error))failure;


/**
 更新消息的已读状态

 @param paramDict 参数 NSDictionary
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)updateMyMessageStatus:(NSDictionary *)paramDict
                   andSuccess:(void(^) (NSDictionary *dict))success
                   andFailure:(void(^) (NSError *error))failure ;
@end

