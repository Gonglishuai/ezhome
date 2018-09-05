
#import "ESSampleRoomTagModel.h"
#import "ESCaseAPI.h"

@implementation ESSampleRoomTagModel
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
                           @"tagList" : @"ESSampleRoomTagFilterModel"
                           };
    return dict[key];
}

#pragma mark - Public Methods
+ (void)requestForSampleRoomFilterTagsSuccess:(void (^) (NSArray <ESSampleRoomTagModel *> *array))success
                                      failure:(void (^) (NSError *error))failure
{
    [ESCaseAPI getSampleRoomFilterTagsSuccess:^(NSArray *array) {
        
        NSMutableArray *arrM = [NSMutableArray array];
        if (array
            && [array isKindOfClass:[NSArray class]])
        {
            for (NSDictionary *dict in array)
            {
                if ([dict isKindOfClass:[NSDictionary class]])
                {
                    ESSampleRoomTagModel *model = [ESSampleRoomTagModel createModelWithDic:dict];
                    [arrM addObject:model];
                }
            }
        }
        
        if (success)
        {
            success([arrM copy]);
        }
        
    } failure:failure];
}

+ (void)updateTags:(NSArray *)tags
{
    if (!tags
        || ![tags isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    for (ESSampleRoomTagModel *tagModel in tags)
    {
        if ([tagModel isKindOfClass:[ESSampleRoomTagModel class]]
            && [tagModel.tagList isKindOfClass:[NSArray class]])
        {
            for (ESSampleRoomTagFilterModel *filterModel in tagModel.tagList)
            {
                if ([filterModel isKindOfClass:[ESSampleRoomTagFilterModel class]])
                {
                    filterModel.currentSelectedStatus = filterModel.selectedStatus;
                }
            }
        }
    }
}

+ (void)resetTags:(NSArray *)tags
{
    if (!tags
        || ![tags isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    for (ESSampleRoomTagModel *tagModel in tags)
    {
        if ([tagModel isKindOfClass:[ESSampleRoomTagModel class]]
            && [tagModel.tagList isKindOfClass:[NSArray class]])
        {
            for (ESSampleRoomTagFilterModel *filterModel in tagModel.tagList)
            {
                if ([filterModel isKindOfClass:[ESSampleRoomTagFilterModel class]])
                {
                    filterModel.currentSelectedStatus = NO;
                }
            }
        }
    }
}

+ (void)updateTags:(NSArray *)tags
         indexPath:(NSIndexPath *)indexPath
{
    if (!tags
        || ![tags isKindOfClass:[NSArray class]]
        || indexPath.section >= tags.count)
    {
        return;
    }
    
    ESSampleRoomTagModel *model = tags[indexPath.section];
    if ([model isKindOfClass:[ESSampleRoomTagModel class]]
        && [model.tagList isKindOfClass:[NSArray class]])
    {
        for (NSInteger i = 0; i< model.tagList.count; i++)
        {
            ESSampleRoomTagFilterModel *filterModel = model.tagList[i];
            if ([filterModel isKindOfClass:[ESSampleRoomTagFilterModel class]])
            {
                if (i == indexPath.item
                    && filterModel.currentSelectedStatus)
                {
                    filterModel.currentSelectedStatus = NO;
                }
                else
                {
                    filterModel.currentSelectedStatus = i == indexPath.item;
                }
            }
        }
    }
}

+ (NSString *)getSelectedTagsStrWithTags:(NSArray *)tags
{
    if (!tags
        || ![tags isKindOfClass:[NSArray class]])
    {
        return @"";
    }
    
    // 先筛选出选中的标签
    NSMutableDictionary *tagDict = [NSMutableDictionary dictionary];
    BOOL hasSelectedValue = NO;
    for (ESSampleRoomTagModel *tagModel in tags)
    {
        if ([tagModel isKindOfClass:[ESSampleRoomTagModel class]]
            && [tagModel.tagList isKindOfClass:[NSArray class]])
        {
            NSString *filterName = @"";
            for (ESSampleRoomTagFilterModel *filterModel in tagModel.tagList)
            {
                if ([filterModel isKindOfClass:[ESSampleRoomTagFilterModel class]]
                    && [filterModel.tagId isKindOfClass:[NSString class]])
                {
                    filterModel.selectedStatus = filterModel.currentSelectedStatus;
                    if (filterModel.selectedStatus)
                    {
                        filterName = [NSString stringWithFormat:@"%@,%@", filterName, filterModel.tagId];
                    }
                }
            }
            
            if ([filterName hasPrefix:@","])
            {
                filterName = [filterName substringFromIndex:1];
            }
            if (filterName.length > 0)
            {
                hasSelectedValue = YES;
                
                if ([tagModel.mark isKindOfClass:[NSString class]])
                {
                    [tagDict setObject:filterName forKey:tagModel.mark];
                }
            }
        }
    }
    
    // 拼接标签为json字符串
    NSString *tagsStr = [self getStrWithStatus:hasSelectedValue
                                          dict:tagDict];
    return tagsStr;
}

+ (NSString *)getStrWithStatus:(BOOL)hasSelectedValue
                          dict:(NSDictionary *)dict
{
    NSString *tagsStr = nil;
    if (hasSelectedValue)
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *jsonString = @"";
        if (jsonData)
        {
            jsonString = [[NSString alloc]initWithData:jsonData
                                              encoding:NSUTF8StringEncoding];
        }
        
        NSMutableString *mutJsonStr = [NSMutableString stringWithString:jsonString];
        NSRange range = {0, jsonString.length};
        //去掉字符串中的空格
        [mutJsonStr replaceOccurrencesOfString:@" "
                                    withString:@""
                                       options:NSLiteralSearch
                                         range:range];
        
        NSRange range2 = {0, mutJsonStr.length};
        //去掉字符串中的换行符
        [mutJsonStr replaceOccurrencesOfString:@"\n"
                                    withString:@""
                                       options:NSLiteralSearch
                                         range:range2];
        
        tagsStr = mutJsonStr;
    }
    else
    {
        tagsStr = @"";
    }
    
    return tagsStr;
}

@end
