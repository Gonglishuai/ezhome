
#import "ESConstructListModel.h"
#import "ESEnterpriseAPI.h"

@implementation ESConstructListModel

#pragma mark - Super Methods
- (void)setValue:(id)value forKey:(NSString *)key
{
    NSString *modelName = [self getModelNameWithKey:key];
    if (modelName)
    {
        NSArray *arrayValue = nil;
        if (value
            && [value isKindOfClass:[NSArray class]])
        {
            arrayValue = value;
        }
        else if ([value isKindOfClass:[NSDictionary class]])
        {
            arrayValue = @[value];
        }
        
        NSArray *models = [self createModelsWithArray:arrayValue
                                            modelName:modelName];
        if (models)
        {
            [super setValue:models forKey:key];
        }
    }
    else
    {
        [super setValue:value forKey:key];
    }
}

#pragma mark - Methods
- (NSString *)getModelNameWithKey:(NSString *)key
{
    if (!key
        || ![key isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    NSDictionary *dict = @{
                           @"data" : @"ESConstructModel"
                           };
    return dict[key];
}

#pragma mark - Super Methods
+ (void)requestConstructListWithOffset:(NSInteger)offset
                                 limlt:(NSInteger)limit
                               success:(void (^) (ESConstructListModel *model))success
                               failure:(void (^) (NSError *error))failure
{
    [ESEnterpriseAPI getConstructListWithOffset:offset
                                          limlt:limit
                                        success:^(NSDictionary *dict)
    {
        if (dict
            && [dict isKindOfClass:[NSDictionary class]])
        {
            SHLog(@"获取施工订单:%@",dict);
            ESConstructListModel *model = [ESConstructListModel createModelWithDic:dict];
            if (success)
            {
                success(model);
            }
        }
        else
        {
            if (failure)
            {
                failure(ERROR(@"-1", 999, @"获取施工订单, response格式不争取"));
            }
        }
        
    } failure:failure];
}

@end
