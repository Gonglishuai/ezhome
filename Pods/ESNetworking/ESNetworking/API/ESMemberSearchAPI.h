//
//  ESMemberSearchAPI.h
//  ESNetworking
//
//  Created by 焦旭 on 2017/11/22.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "JRBaseAPI.h"

@interface ESMemberSearchAPI : JRBaseAPI

/**
 获取设计师列表
 
 @param paramDict 参数
 @param headerDict 请求头
 @param bodyDict 请求体
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getDesignersListWithParam:(NSDictionary *)paramDict
                           header:(NSDictionary *)headerDict
                             body:(NSDictionary *)bodyDict
                       andSuccess:(void(^) (NSDictionary *dict))success
                       andFailure:(void(^) (NSError *error))failure;

@end
