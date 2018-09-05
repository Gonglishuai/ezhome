
#import "ESProductAttributeModel.h"

@implementation ESProductAttributeModel

#pragma mark - Super Methods
- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([@"values" isEqualToString:key])
    {
        if (value
            && [value isKindOfClass:[NSArray class]])
        {
            self.values = (id)[self createModelsWithArray:value
                                                modelName:NSStringFromClass([ESProductAttributeValueModel class])];
        }
    }
    else
    {
        [super setValue:value forKey:key];
    }
}

#pragma mark - Super Methods
+ (ESProductAttributeModel *)copyAttributeModel:(ESProductAttributeModel *)attributeModel
{
    if (!attributeModel
        || ![attributeModel isKindOfClass:[ESProductAttributeModel class]])
    {
        return nil;
    }

    ESProductAttributeModel *model = [[ESProductAttributeModel alloc] init];
    model.facetable = attributeModel.facetable;
    model.identifier = attributeModel.identifier;
    model.name = attributeModel.name;
    model.sequence = attributeModel.sequence;
    model.usage = attributeModel.usage;
    model.values = attributeModel.values;
    model.selectedValue = attributeModel.selectedValue;
    model.onSelected = attributeModel.onSelected;
    
    return model;
}

@end
