//
//  JRHomeAPI.h
//  Consumer
//
//  Created by jiang on 2017/5/22.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JRBaseAPI.h"

@interface JRHomeAPI : JRBaseAPI

/**首页  1业主  2设计师*/
+ (void)getHomePageWithType:(NSString *)type loginStatus:(BOOL)loginStatus Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;
/**论坛*/
+ (void)getBBSUrlWithSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;
/**完善信息*/
+ (void)getPerfectInfoOrNotWithJid:(NSString *)jid
                       withSuccess:(void (^)(NSDictionary * dict))success
                        andFailure:(void(^)(NSError * error))failure;
@end
