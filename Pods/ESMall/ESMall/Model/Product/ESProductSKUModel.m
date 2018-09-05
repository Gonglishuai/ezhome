
#import "ESProductSKUModel.h"

@implementation ESProductSKUModel

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
        if ([@"model" isEqualToString:key])
        {
            self.model = [models firstObject];
        }
        else if ([@"brandResponseBean" isEqualToString:key])
        {
            self.brandResponseBean = [models firstObject];
        }
        else
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

- (NSString *)getModelNameWithKey:(NSString *)key
{
    if (!key
        || ![key isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    NSDictionary *dict = @{
                           @"definingAttributes"    : @"ESProductAttributeSelectedValueModel",
                           @"descriptionAttributes" : @"ESProductAttributeSelectedValueModel",
                           @"prices"                : @"ESProductPriceModel",
                           @"model"                 : @"ESProductModelModel",
                           @"images"                : @"ESProductImagesModel",
                           @"brandResponseBean"     : @"ESProductBrandModel"
                           };
    return dict[key];
}

@end
