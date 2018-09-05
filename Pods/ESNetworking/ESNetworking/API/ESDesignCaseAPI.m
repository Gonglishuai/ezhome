//
//  ESCaseAPI.m
//  Consumer
//
//  Created by 焦旭 on 2017/11/3.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESDesignCaseAPI.h"
#import "JRNetEnvConfig.h"

@implementation ESDesignCaseAPI

+ (void)getDesignCaseTagsWithSuccess:(nullable void(^)(NSDictionary * _Nullable dict))success
                          andFailure:(nullable void(^)(NSError * _Nullable error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.searchDesign;
    NSString *url = [NSString stringWithFormat:@"%@search/design/tags/all", baseUrl];
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeader:header withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"案例筛选tags：%@",dict);
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)get2DCasesWithSearchTerm:(NSString * _Nullable)searchTerm
                       withFacet:(NSString * _Nullable)facet
                        withSort:(NSString * _Nullable)sort
                      withOffset:(NSString * _Nonnull)offset
                       withLimit:(NSString * _Nonnull)limit
                      andSuccess:(nullable void(^)(NSDictionary * _Nullable dict))success
                      andFailure:(nullable void(^)(NSError * _Nullable error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.searchDesign;
    NSString *url = [NSString stringWithFormat:@"%@search/design/case/2d/bySearchTerm", baseUrl];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:offset ?: @"0", @"offset", limit ?: @"10", @"limit", nil];
    if (searchTerm && searchTerm.length > 0) {
        [param setValue:searchTerm forKey:@"searchTerm"];
    }
    if (facet && facet.length > 0) {
        [param setValue:facet forKey:@"filterQuery"];
    }
    if (sort && sort.length > 0) {
        [param setValue:sort forKey:@"sort"];
    }
    
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];

    [SHHttpRequestManager Get:url withParameters:param withHeader:header withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"2D案例列表：%@",dict);
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)get3DCasesWithSearchTerm:(NSString * _Nullable)searchTerm
                       withFacet:(NSString * _Nullable)facet
                        withSort:(NSString * _Nullable)sort
                      withOffset:(NSString * _Nonnull)offset
                       withLimit:(NSString * _Nonnull)limit
                      andSuccess:(nullable void(^)(NSDictionary * _Nullable dict))success
                      andFailure:(nullable void(^)(NSError * _Nullable error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.searchDesign;
    NSString *url = [NSString stringWithFormat:@"%@search/design/case/3d/bySearchTerm", baseUrl];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:offset ?: @"0", @"offset", limit ?: @"10", @"limit", nil];
    if (searchTerm && searchTerm.length > 0) {
        [param setValue:searchTerm forKey:@"searchTerm"];
    }
    if (facet && facet.length > 0) {
        [param setValue:facet forKey:@"filterQuery"];
    }
    if (sort && sort.length > 0) {
        [param setValue:sort forKey:@"sort"];
    }
    
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    
    [SHHttpRequestManager Get:url withParameters:param withHeader:header withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"3D案例列表：%@",dict);
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {      
            failure(error);
        }
    }];
}

+ (void)get2DCaseDetail:(NSString *_Nonnull)assetId
            withSuccess:(nullable void(^)(NSDictionary * _Nullable dict))success
             andFailure:(nullable void(^)(NSError * _Nullable error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@design/case/detail/2D/%@", baseUrl, assetId];
    
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeader:header withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"旧2D案例详情：%@",dict);
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

// 3D 案例集列表(设计师详情下-3D)
+ (void)get3DListOfDesignerCasesWithUrl:(NSDictionary *)urlDict
                                 header:(NSDictionary *)headerDict
                                   body:(NSDictionary *)bodyDict
                                success:(void(^) (NSDictionary *dictionary))success
                                failure:(void(^) (NSError *error))failure {
    
    NSString *url = [NSString stringWithFormat:@"%@search/design/case/3d/designers",[JRNetEnvConfig sharedInstance].netEnvModel.searchService];
    
    NSDictionary *param = @{@"limit"        :urlDict[@"limit"],
                            @"offset"       :urlDict[@"offset"],
                            @"isOnlyPublic" :@"1",
                            @"designerId"   :urlDict[@"designer_id"]
                            };
    NSLog(@" ----- URL %@",url);
    
    headerDict = [[ESHTTPSessionManager sharedInstance]getRequestHeader:headerDict];
    [SHHttpRequestManager Get:url withParameters:param withHeader:headerDict withBody:bodyDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"3D 案例集列表 dic  %@",dict);
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)getListOfDesignerCasesWithUrl:(NSDictionary *)urlDict
                               header:(NSDictionary *)headerDict
                                 body:(NSDictionary *)bodyDict
                              success:(void(^) (NSDictionary *dictionary))success
                              failure:(void(^) (NSError *error))failure {
    
    NSString *url = [NSString stringWithFormat:@"%@search/design/case/2d/designers",[JRNetEnvConfig sharedInstance].netEnvModel.searchService];
    
    NSDictionary *param = @{@"limit"        :urlDict[@"limit"],
                            @"offset"       :urlDict[@"offset"],
                            @"isOnlyPublic" :@"1",
                            @"designerId"   :urlDict[@"designer_id"]
                            };

    headerDict = [[ESHTTPSessionManager sharedInstance]getRequestHeader:headerDict];
    [SHHttpRequestManager Get:url withParameters:param withHeader:headerDict withBody:bodyDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


@end
