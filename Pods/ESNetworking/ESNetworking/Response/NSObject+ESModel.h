//
//  NSObject+ESModel.h
//  Manufacturer
//
//  Created by 焦旭 on 2017/9/6.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ESModel)

+ (nullable instancetype)es_modelWithJSON:(id)json;

+ (nullable instancetype)es_modelWithDictionary:(NSDictionary *)dictionary;

- (BOOL)es_modelSetWithJSON:(id)json;

- (BOOL)es_modelSetWithDictionary:(NSDictionary *)dic;

- (nullable id)es_modelToJSONObject;

- (nullable NSData *)es_modelToJSONData;

- (nullable NSString *)es_modelToJSONString;

- (nullable id)es_modelCopy;

- (void)es_modelEncodeWithCoder:(NSCoder *)aCoder;

- (id)es_modelInitWithCoder:(NSCoder *)aDecoder;

- (NSUInteger)es_modelHash;

- (BOOL)es_modelIsEqual:(id)model;

- (NSString *)es_modelDescription;

@end

@interface NSArray (ESModel)

+ (nullable NSArray *)es_modelArrayWithClass:(Class)cls json:(id)json;

@end


@interface NSDictionary (ESModel)

+ (nullable NSDictionary *)es_modelDictionaryWithClass:(Class)cls json:(id)json;

@end


@protocol ESModel <NSObject>
@optional

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper;

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass;

+ (nullable Class)modelCustomClassForDictionary:(NSDictionary *)dictionary;

+ (nullable NSArray<NSString *> *)modelPropertyBlacklist;

+ (nullable NSArray<NSString *> *)modelPropertyWhitelist;

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic;

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
