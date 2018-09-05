//
//  ESInvoiceAPI.m
//  Consumer
//
//  Created by jiang on 2017/7/19.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESInvoiceAPI.h"
#import "JRNetEnvConfig.h"

@implementation ESInvoiceAPI

/**
 获取发票列表信息
 
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getInvoiceListWithSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@invoices/getInvoiceList", baseUrl];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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
 创建发票
 
 @param paramDic 要创建的发票信息集合
 @param success 成功回调
 @param failure 失败回调
 */
+(void)createInvoiceWithParamDic:(NSDictionary*)paramDic Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@invoices/createInvoice", baseUrl];
    
    [SHHttpRequestManager Post:url withParameters:nil withHeader:headerDict withBody:paramDic  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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
@end

