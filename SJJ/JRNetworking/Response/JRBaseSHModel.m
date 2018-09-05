//
//  JRBaseSHModel.m
//  Consumer
//
//  Created by 姜云锋 on 17/4/21.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JRBaseSHModel.h"

@implementation JRBaseSHModel

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


+ (id)createModelWithDic:(NSDictionary *)dic {
    return [[JRBaseSHModel alloc] initWithDic:dic];
}

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:dic];
        } else {
            SHLog(@"传入的数据源有误!");
        }
    }
    return self;
}

- (NSString *)descriptionValue:(NSString *)value
{
    if (value == nil ||
        [value isKindOfClass:[NSNull class]])
    {
        value = @"";
    }
    value = [NSString stringWithFormat:@"%@",value];
    return value;
}

@end
