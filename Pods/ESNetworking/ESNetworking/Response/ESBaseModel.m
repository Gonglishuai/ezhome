//
//  ESBaseModel.m
//  Consumer
//
//  Created by 姜云锋 on 17/4/21.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESBaseModel.h"
#import <AFNetworking/AFNetworking.h>

@implementation ESBaseModel

#pragma mark - KVC
- (void)setValue:(id)value forKey:(NSString *)key
{
    value = [self descriptionValue:value];
    [super setValue:value forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    value = [self descriptionValue:value];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return @"";
}

#pragma mark - Public Methods
+ (id)createModelWithDic:(NSDictionary *)dic
{
    return [[self alloc] initWithDic:dic];
}

- (id)initWithDic:(NSDictionary *)dic
{
    if (self = [super init])
    {
        [self createModelWithDic:dic];
    }
    return self;
}

- (id)createModelWithDic:(NSDictionary *)dic
{
    if (dic
        && [dic isKindOfClass:[NSDictionary class]])
    {
        [self setValuesForKeysWithDictionary:dic];
    }
    else
    {
        NSLog(@"传入的数据源有误!");
    }
    
    return self;
}

- (NSString *)descriptionValue:(id)value
{
    if (value == nil
        || [value isKindOfClass:[NSNull class]])
    {
        value = @"";
    }
    
    if ([value isKindOfClass:[ESBaseModel class]]
        || ([value isKindOfClass:[NSArray class]]
            && [[value firstObject] isKindOfClass:[ESBaseModel class]]))
    {
        return value;
    }
    
    value = [NSString stringWithFormat:@"%@",value];
    return value;
}

- (NSArray <ESBaseModel *> *)createModelsWithArray:(NSArray <NSDictionary *> *)array
                                         modelName:(NSString *)modelName
{
    if (!array
        || ![array isKindOfClass:[NSArray class]]
        || !modelName
        || ![modelName isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    Class modelClass = NSClassFromString(modelName);
    
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSDictionary *dict in array)
    {
        if (dict
            && [dict isKindOfClass:[NSDictionary class]])
        {
            NSObject *obj = [[modelClass alloc] init];
            if ([obj isKindOfClass:[ESBaseModel class]])
            {
                obj = [(ESBaseModel *)obj createModelWithDic:dict];
                [arrM addObject:obj];
            }
        }
    }
    
    if (arrM.count > 0)
    {
        return [arrM copy];
    }
    
    return nil;
}

+ (NSString *)getErrorMessage:(NSError *)error
{
    NSString *msg = @"网络错误, 请稍后重试!";
    if (!error
        || ![error isKindOfClass:[NSError class]])
    {
        return msg;
    }
    
    @try {
        NSData *data = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSError *err = nil;
        NSDictionary * errorDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        
        if (err == nil && errorDict && [errorDict objectForKey:@"msg"]) {
            msg = [errorDict objectForKey:@"msg"];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    } @finally {
        return msg;
    }
}

@end
