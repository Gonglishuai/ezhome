
#import "ESCartCommodityPromotion.h"

@implementation ESCartCommodityPromotion

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
        if ([@"rewardInfos" isEqualToString:key])
        {
            if (models)
            {
                [super setValue:models forKey:key];
            }
        }
    }
    else
    {
        [super setValue:value forKey:key];
    }
}

- (id)createModelWithDic:(NSDictionary *)dic
{
    [super createModelWithDic:dic];
    
    [self updateModel];
    
    return self;
}

- (void)updateModel
{
    if (self.rewardInfos
        && [self.rewardInfos isKindOfClass:[NSArray class]])
    {
        NSInteger giftsCount = 0;
        for (ESCartCommodityPromotionGift *gift in self.rewardInfos)
        {
            if ([gift isKindOfClass:[ESCartCommodityPromotionGift class]])
            {
                giftsCount += [gift.objQuantity integerValue];
            }
        }
        self.giftsCount = giftsCount;
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
                           @"rewardInfos" : @"ESCartCommodityPromotionGift",
                           };
    return dict[key];
}

@end
