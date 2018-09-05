
#import "ESFittingHomeModel.h"
#import "ESCaseAPI.h"

@implementation ESFittingHomeModel

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
                           @"sampleList" : @"ESFittingSampleModel",
                           @"banner"     : @"ESFittingRoomBannerModel"
                           };
    return dict[key];
}

#pragma mark - Super Method
- (id)createModelWithDic:(NSDictionary *)dic
{
    [super createModelWithDic:dic];
    
    [self updateSampleList];
    
    return self;
}

#pragma mark - Public Method
+ (void)requestForCaseFittingRoomHomeSuccess:(void (^) (ESFittingHomeModel *model))success
                                     failure:(void (^) (NSError *error))failure
{
    [ESCaseAPI getCaseFittingRoomHomeSuccess:^(NSDictionary *dict) {
        
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            SHLog(@"家装试衣间:%@", dict);
            
            ESFittingHomeModel *model = [ESFittingHomeModel createModelWithDic:dict];
            if (success)
            {
                success(model);
            }
        }
        
    } failure:failure];
}

- (void)updateSampleList
{
    if (!self.sampleList
        || ![self.sampleList isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    NSString *plistPath = [[ESMallAssets hostBundle] pathForResource:@"fittingRoom"
                                                          ofType:@"plist"];
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:plistPath];
    for (NSInteger i = 0; i < array.count; i++)
    {
        NSDictionary *dict = array[i];
        if (i < self.sampleList.count)
        {
            ESFittingSampleModel *sampleModel = self.sampleList[i];
            if ([sampleModel isKindOfClass:[ESFittingSampleModel class]])
            {
                sampleModel.spaceTitle = dict[@"title"];
                sampleModel.spaceSubTitle = dict[@"subTitle"];
                sampleModel.spaceimageName = dict[@"spaceImage"];
                sampleModel.spaceTitleIconName = dict[@"titleImage"];
            }
        }
    }
}

@end
