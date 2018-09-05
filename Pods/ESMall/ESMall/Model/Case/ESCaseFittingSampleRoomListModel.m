
#import "ESCaseFittingSampleRoomListModel.h"
#import "ESCaseAPI.h"

@implementation ESCaseFittingSampleRoomListModel

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
                           @"data" : @"ESFittingSampleRoomModel"
                           };
    return dict[key];
}

#pragma mark - Public Method
+ (void)requestForFittingRoomListWithOffset:(NSInteger)offset
                                      limlt:(NSInteger)limit
                                  apaceType:(NSString *)spaceType
                                    success:(void (^) (ESCaseFittingSampleRoomListModel *model))success
                                    failure:(void (^) (NSError *error))failure
{
    [ESCaseAPI getFittingRoomListWithOffset:offset
                                      limlt:limit
                                  spaceType:spaceType
                                    success:^(NSDictionary *dict)
    {
        
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            ESCaseFittingSampleRoomListModel *model = [ESCaseFittingSampleRoomListModel createModelWithDic:dict];
            if (success)
            {
                success(model);
            }
        }
        
    } failure:failure];
}

@end
