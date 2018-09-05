
#import "ESSampleRoomListModel.h"
#import "ESCaseAPI.h"

@implementation ESSampleRoomListModel

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
                           @"data"       : @"ESSampleRoomModel"
                           };
    return dict[key];
}

#pragma mark - Public Method
+ (void)requestForSampleRoomListWithOffset:(NSInteger)offset
                                     limlt:(NSInteger)limit
                                    tagStr:(NSString *)tagStr
                                searchTerm:(NSString *)searchTerm
                                   success:(void (^) (ESSampleRoomListModel *model))success
                                   failure:(void (^) (NSError *error))failure
{
    [ESCaseAPI getSampleRoomListWithOffset:offset
                                     limlt:limit
                                    tagStr:tagStr
                                searchTerm:searchTerm
                                   success:^(NSDictionary *dict)
    {
        SHLog(@"套餐样板间列表: %@", dict);
        
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            ESSampleRoomListModel *model = [ESSampleRoomListModel createModelWithDic:dict];
            if (success)
            {
                success(model);
            }
        }
        
    } failure:failure];
}

@end
