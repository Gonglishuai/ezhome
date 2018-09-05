
#import "ESTransactionListModel.h"
#import "ESEnterpriseAPI.h"

@implementation ESTransactionListModel

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
                           @"data" : @"ESTransactionDetailModel"
                           };
    return dict[key];
}

#pragma mark - Public Method
+ (void)requestTransactionistWithOffset:(NSInteger)offset
                                  limlt:(NSInteger)limit
                               orderNum:(NSString *)orderNum
                                success:(void (^) (ESTransactionListModel *model))success
                                failure:(void (^) (NSError *error))failure
{
    [ESEnterpriseAPI getTransactionListWithOffset:offset
                                            limlt:limit
                                         orderNum:(NSString *)orderNum
                                          success:^(NSArray *array)
     {
         if (array
             && [array isKindOfClass:[NSArray class]])
         {
             SHLog(@"获取交易明细:%@",array);

             NSMutableArray *arrM = [NSMutableArray array];
             for (NSDictionary *dict in array)
             {
                 if ([dict isKindOfClass:[NSDictionary class]])
                 {
                     ESTransactionDetailModel *model = [ESTransactionDetailModel createModelWithDic:dict];
                     [arrM addObject:model];
                 }
             }
             ESTransactionListModel *model = [[ESTransactionListModel alloc] init];
             model.data = [arrM copy];
             if (success)
             {
                 success(model);
             }
         }
         else
         {
             if (failure)
             {
                 failure(ERROR(@"-1", 999, @"获取交易明细, response格式不争取"));
             }
         }
         
     } failure:failure];
}

@end
