//
//  ESInvoiceAPI.h
//  Consumer
//
//  Created by jiang on 2017/7/19.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMaterialBaseAPI.h"

@interface ESInvoiceAPI : ESMaterialBaseAPI

/**
 获取发票列表信息
 
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getInvoiceListWithSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 创建发票
 
 @param paramDic 要创建的发票信息集合
 @param success 成功回调
 @param failure 失败回调
 */
+(void)createInvoiceWithParamDic:(NSDictionary*)paramDic Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

@end
