//
//  ESCaseAPI.m
//  Consumer
//
//  Created by jiang on 2017/8/18.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseAPI.h"
#import "SHHttpRequestManager.h"
#import "SHRequestTool.h"
#import "JRKeychain.h"
#import "JRNetEnvConfig.h"
#import "JRLocationServices.h"
#import "ESCaseCommentModel.h"
#import "ESCaseCategoryModel.h"

@implementation ESCaseAPI

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
                     andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@cases/%@?type=%@&source=%@", baseUrl, caseId, caseType, source];
    if (brandId
        && [brandId isKindOfClass:[NSString class]]
        && brandId.length > 0)
    {
        url = [NSString stringWithFormat:@"%@&brandId=%@", url, brandId];
    }
    
    [SHHttpRequestManager Get:url withParameters:nil withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success([ESCaseDetailModel objFromDict:returnDict]);
        }
        
    } andFailure:failure];
}

+(void)getCaseDetailWithCaseId:(NSString *)caseId
                      caseType:(NSString *)caseType
                    caseSource:(NSString *)source
                    andSuccess:(void(^)(ESCaseDetailModel *caseDetailModel))success
                    andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.host;
    NSString *url;
    if ([caseType isEqualToString:@"2d"]) {
        url = [NSString stringWithFormat:@"%@/jrdesign/api/v1/2d/detail/%@",baseUrl,caseId];
    }else{
        if ([source isEqualToString:@"1"]) {
            url = [NSString stringWithFormat:@"%@/search-design/api/v1/search/design/case/3d/byId/%@",baseUrl,caseId];
        }else{
            url = [NSString stringWithFormat:@"%@/jrdesign/api/v1/3d/detail/%@",baseUrl,caseId];
        }
    }
    
    [SHHttpRequestManager Get:url withParameters:nil withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success([ESCaseDetailModel objFromDict:returnDict]);
        }
        
    } andFailure:failure];
}

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
                                andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.commentService;
    NSString *url = [NSString stringWithFormat:@"%@comment/%@/%ld/%ld", baseUrl, caseId, (long)pageNum, (long)pageSize];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        NSMutableArray *array = [NSMutableArray array];
        if (success) {
            if (returnDict && ([returnDict[@"data"] isKindOfClass:[NSArray class]])) {
                for (NSDictionary *dic in returnDict[@"data"]) {
                    ESCaseCommentModel *model = [ESCaseCommentModel objFromDict:dic];
                    [array addObject:model];
                }
            }
            NSString *numStr = [NSString stringWithFormat:@"%@", returnDict[@"count"]?returnDict[@"count"]:@"0"];
            NSInteger num = [numStr integerValue];
            success(array, num);
        }
        
    } andFailure:failure];
}

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
                             andFailure:(void(^)(NSError *error))failure{
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.commentService;
    NSString *url = [NSString stringWithFormat:@"%@comment/save", baseUrl];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setObject:caseId forKey:@"resourceId"];
    [body setObject:caseName forKey:@"resourceName"];
    [body setObject:caseType forKey:@"type"];
    [body setObject:caseComment forKey:@"comment"];
    [body setObject:@"3" forKey:@"platform"];
    [SHHttpRequestManager Post:url withParameters:nil withHeader:headerDict withBody:body withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(returnDict);
        }
    } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
}

/**
 加入样板间
 
 @param productId 案例id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)addToModelRoomWithProductId:(NSString *)productId
                         andSuccess:(void(^)(NSDictionary *dict))success
                         andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@demand/addToModelRoom/%@", baseUrl, productId];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    [SHHttpRequestManager Post:url withParameters:nil withHeader:headerDict withBody:nil withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(returnDict);
        }
    } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
}

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
                         andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.commentService;
    NSString *url = [NSString stringWithFormat:@"%@comment/%ld/%ld", baseUrl, (long)pageNum, (long)pageSize];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        NSMutableArray *array = [NSMutableArray array];
        if (success) {
            if (returnDict && ([returnDict[@"data"] isKindOfClass:[NSArray class]])) {
                for (NSDictionary *dic in returnDict[@"data"]) {
                    ESCaseCommentModel *model = [ESCaseCommentModel objFromDict:dic];
                    [array addObject:model];
                }
            }
            NSString *numStr = [NSString stringWithFormat:@"%@", returnDict[@"count"]?returnDict[@"count"]:@"0"];
            NSInteger num = [numStr integerValue];
            success(array, num);
        }
        
    } andFailure:failure];
}

/**
 删除评论
 
 @param goalId 评论id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)deleteCommentWithGoalId:(NSString *)goalId
                     andSuccess:(void(^)(NSDictionary *dict))success
                     andFailure:(void(^)(NSError *error))failure {
    
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.commentService;
    NSString *url = [NSString stringWithFormat:@"%@comment/%@", baseUrl, goalId];
    [SHHttpRequestManager Delete:url withParameters:nil withHeader:headerDict withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) {
            failure(error);
        }
    }];
}

/**
 案例推荐商品顶级目录
 
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getCaseCategoryListWithSuccess:(void(^)(NSArray *array))success
                            andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@cases/topcategory", baseUrl];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        NSMutableArray *array = [NSMutableArray array];
        if (success) {
            if (returnDict && ([returnDict[@"data"] isKindOfClass:[NSArray class]])) {
                for (NSDictionary *dic in returnDict[@"data"]) {
                    ESCaseCategoryModel *model = [ESCaseCategoryModel objFromDict:dic];
                    [array addObject:model];
                }
            }
            success(array);
        }
        
    } andFailure:failure];
}

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
                               andFailure:(void(^)(NSError *error))failure {
    
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@cases/recommendProduct/%@?categoryId=%@&offset=%ld&limit=%ld", baseUrl, caseId, categoryId, (long)pageNum, (long)pageSize];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        NSMutableArray *array = [NSMutableArray array];
        if (success) {
            if (returnDict && ([returnDict[@"data"] isKindOfClass:[NSArray class]])) {
                for (NSDictionary *dic in returnDict[@"data"]) {
                    ESCaseProductModel *model = [ESCaseProductModel objFromDict:dic];
                    [array addObject:model];
                }
            }
            NSString *numStr = [NSString stringWithFormat:@"%@", returnDict[@"count"]?returnDict[@"count"]:@"0"];
            NSInteger num = [numStr integerValue];
            success(array, num);
        }
        
    } andFailure:failure];
    
}

+ (void)getSampleRoomListWithOffset:(NSInteger)offset
                              limlt:(NSInteger)limit
                             tagStr:(NSString *)tagStr
                         searchTerm:(NSString *)searchTerm
                            success:(void (^) (NSDictionary *dict))success
                            failure:(void (^) (NSError *error))failure
{
    if (!tagStr
        || ![tagStr isKindOfClass:[NSString class]])
    {
        tagStr = @"";
    }
    
    if (!searchTerm
        || ![searchTerm isKindOfClass:[NSString class]])
    {
        searchTerm = @"";
    }
    
    NSString *type = @"1";// 1 套餐样板间
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@sampleRoom/list/%@?offset=%ld&limit=%ld&tags=%@&searchTerm=%@", baseUrl, type, (long)offset, (long)limit, tagStr, searchTerm];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *header = [self getDefaultHeader];
    [SHHttpRequestManager Get:url
               withParameters:nil
              withHeaderField:header
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:^(NSData * _Nullable responseData)
     {
         NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
         if (success)
         {
             success(returnDict);
         }
     } andFailure:failure];
}

+ (void)getSampleRoomFilterTagsSuccess:(void (^) (NSArray *array))success
                               failure:(void (^) (NSError *error))failure
{
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [baseUrl stringByAppendingString:@"sampleRoom/tags"];
    
    NSDictionary *header = [self getDefaultHeader];
    [SHHttpRequestManager Get:url
               withParameters:nil
              withHeaderField:header
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:^(NSData * _Nullable responseData)
     {
         NSArray * returnArray = [NSJSONSerialization JSONObjectWithData:responseData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:nil];
         if (success)
         {
             success(returnArray);
         }
     } andFailure:failure];
}
+ (void)getCaseFittingRoomHomeSuccess:(void (^) (NSDictionary *dict))success
                              failure:(void (^) (NSError *error))failure
{
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [baseUrl stringByAppendingString:@"espot/sampleroomIndex"];
    NSDictionary *header = [self getDefaultHeader];
    [SHHttpRequestManager Get:url
               withParameters:nil
              withHeaderField:header
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:^(NSData * _Nullable responseData)
     {
         NSDictionary * returnDict = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingMutableContainers
                                      error:nil];
         if (success)
         {
             success(returnDict);
         }
     } andFailure:failure];
}

+ (void)getFittingRoomListWithOffset:(NSInteger)offset
                               limlt:(NSInteger)limit
                           spaceType:(NSString *)spaceType
                             success:(void (^) (NSDictionary *dict))success
                             failure:(void (^) (NSError *error))failure
{
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:
                     @"%@sampleRoom/list/spacetype/%@?offset=%ld&limit=%ld",
                     baseUrl,
                     spaceType,
                     (long)offset,
                     (long)limit];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *header = [self getDefaultHeader];
    [SHHttpRequestManager Get:url
               withParameters:nil
              withHeaderField:header
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:^(NSData * _Nullable responseData)
     {
         NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
         if (success)
         {
             success(returnDict);
         }
     } andFailure:failure];
}

+ (void)getLiWuMarketHomeSuccess:(void(^)(NSDictionary *dict))success
                      andFailure:(void(^)(NSError *error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@espot/supermarketIndex", baseUrl];
    
    NSDictionary *header = [self getDefaultHeader];
    [SHHttpRequestManager Get:url
               withParameters:nil
              withHeaderField:header
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:^(NSData * _Nullable responseData)
     {
         NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
         if (success)
         {
             success(returnDict);
         }
     } andFailure:failure];
}
@end
