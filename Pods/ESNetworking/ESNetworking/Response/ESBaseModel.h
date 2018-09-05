//
//  ESBaseModel.h
//  Consumer
//
//  Created by 姜云锋 on 17/4/21.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESBaseModel : NSObject //轻量化模型，不需要SHModel里方法的模型，可继承此model

+ (id)createModelWithDic:(NSDictionary *)dic;
- (id)initWithDic:(NSDictionary *)dic;
- (id)createModelWithDic:(NSDictionary *)dic;

- (NSString *)descriptionValue:(id)value;

/**
 * @brief 根据数据源与模型名称创建一组模型
 *
 * @param array 传入的数据源
 * @param modelName 模型名称(只能是ESBaseModel机器子类类型)
 *
 * @return NSArray 包含模型的数组
 */
- (NSArray <ESBaseModel *> *)createModelsWithArray:(NSArray <NSDictionary *> *)array
                                         modelName:(NSString *)modelName;

/// 获取失败信息
+ (NSString *)getErrorMessage:(NSError *)error;

@end
