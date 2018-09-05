//
//  SHVersionModel.m
//  Enterprise
//
//  Created by 牛洋洋 on 2017/4/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "SHVersionModel.h"

@implementation SHVersionModel

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        if (dict && [dict isKindOfClass:[NSDictionary class]])
        {
            if (dict[@"ios"] && [dict[@"ios"] isKindOfClass:[NSArray class]])
            {
                NSArray *apps = dict[@"ios"];
                if (apps.count > 0)
                {
                    NSDictionary *dic = [apps firstObject];
                    if (dic && [dic isKindOfClass:[NSDictionary class]])
                    {
                        [self setValuesForKeysWithDictionary:dic];
                        return  self;
                    }
                }
            }
        }
    }
    return nil;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"local_notifications"])
    {
        NSMutableArray *arrM = [NSMutableArray array];
        if (value && [value isKindOfClass:[NSArray class]])
        {
            for (NSDictionary *dict in value)
            {
                SHLocalNotificationModel *model = [[SHLocalNotificationModel alloc] initWithDictionary:dict];
                [arrM addObject:model];
            }
        }
        self.local_notifications = [arrM copy];
    }
    else if ([key isEqualToString:@"message"])
    {
        NSMutableArray *arrM = [NSMutableArray array];
        if (value && [value isKindOfClass:[NSArray class]])
        {
            for (NSString *message in value)
            {
                if (message && [message isKindOfClass:[NSString class]])
                {
                    [arrM addObject:message];
                }
            }
        }
        self.message = [arrM copy];
    }
    else
    {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}

@end

@implementation SHLocalNotificationModel

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        if (dict && [dict isKindOfClass:[NSDictionary class]])
        {
            [self setValuesForKeysWithDictionary:dict];
            return self;
        }
    }
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}

@end
