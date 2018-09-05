//
//  ESMemberIdAPI.h
//  Consumer
//
//  Created by 焦旭 on 2017/8/18.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JRBaseAPI.h"

@interface ESMemberIdAPI : JRBaseAPI

/**
 通过uid获取j_member_id

 @param uid id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getMemberIdWithUid:(NSString *)uid
                andSuccess:(void(^)(NSDictionary *dict))success
                andFailure:(void(^)(NSError *error))failure;

/**
 通过dealerId获取j_member_id

 @param dealerId 经销商id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getNimIdWithDealerId:(NSString *)dealerId
                  andSuccess:(void(^)(NSDictionary *dict))success
                  andFailure:(void(^)(NSError *error))failure;
@end
