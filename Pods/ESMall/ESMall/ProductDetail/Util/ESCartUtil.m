
#import "ESCartUtil.h"
#import "ESProductModel.h"

@implementation ESCartUtil

+ (NSArray *)updateProductModel:(ESProductModel *)product
         withCustomizableStatus:(BOOL)isCustomizable
{
    if (!product
        || ![product isKindOfClass:[ESProductModel class]]
        || ![product.availAttributes isKindOfClass:[NSArray class]]
        || ![product.customizableAvailAttributes isKindOfClass:[NSArray class]])
    {
        return @[];
    }
    
    NSArray *arrAvailAttributes = product.availAttributes;
    if (isCustomizable)
    {
        arrAvailAttributes = product.customizableAvailAttributes;
    }
    
    
    NSMutableArray *arrM = [NSMutableArray array];
    for (ESProductAttributeModel *attributeModel in arrAvailAttributes)
    {
        if ([attributeModel isKindOfClass:[ESProductAttributeModel class]]
            && [attributeModel.values isKindOfClass:[NSArray class]])
        {
            for (ESProductAttributeValueModel *attributeValueModel in attributeModel.values)
            {
                if ([attributeValueModel isKindOfClass:[ESProductAttributeValueModel class]])
                {
                    if (attributeModel.values.count == 1)
                    {
                        attributeValueModel.couldEdit = NO;
                        attributeValueModel.valueStatus = ESCartLabelStatusEnableSelected;
                        attributeModel.selectedValue = attributeValueModel;
                        [arrM addObject:attributeModel];
                    }
                    else
                    {
                        attributeValueModel.couldEdit = YES;
                        if (attributeValueModel.valueStatus == ESCartLabelStatusEnableSelected
                            && ![arrM containsObject:attributeModel])
                        {
                            [arrM addObject:attributeModel];
                        }
                    }
                }
            }
        }
    }
    
    return [arrM copy];
}

+ (void)updateProductModelWithAvailAttributes:(NSArray <ESProductAttributeModel *> *)availAttributes
                              withSeletedSkus:(NSArray <ESProductSKUModel *> *)selectedSkus
{
    // 如果没有选择, 标签全部可选
    if (![selectedSkus isKindOfClass:[NSArray class]]
        || selectedSkus.count <= 0)
    {
        [self updateAllAttributeValuesWithAvailAttributes:availAttributes
                                            defaultStatus:ESCartLabelStatusEnableDisSelected];
        return;
    }
    
    // 获取选中sku的标签
    NSDictionary *dict = [self getSelectedAttributesWithSeletedSkus:selectedSkus];
    if (!dict
        || ![dict isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    
    for (ESProductAttributeModel *attributeModel in availAttributes)
    {
        if ([attributeModel isKindOfClass:[ESProductAttributeModel class]]
            && [attributeModel.identifier isKindOfClass:[NSString class]])
        {
            // 如果是切换某个属性, 不更新此属性的标签状态
            if (attributeModel.onSelected
                && attributeModel.selectedValue
                && [attributeModel.selectedValue isKindOfClass:[ESProductAttributeValueModel class]])
            {
                continue;
            }
            
            NSArray *attributesGroup = dict[attributeModel.identifier];
            attributesGroup = attributesGroup?attributesGroup:@[];
            
            if ([attributesGroup isKindOfClass:[NSArray class]])
            {
                for (ESProductAttributeValueModel *attributeValueModel in attributeModel.values)
                {
                    if ([attributeValueModel isKindOfClass:[ESProductAttributeValueModel class]]
                        && [attributeValueModel.identifier isKindOfClass:[NSString class]]
                        && [attributesGroup containsObject:attributeValueModel.identifier])
                    {
                        if (attributeValueModel.valueStatus != ESCartLabelStatusEnableSelected)
                        {
                            attributeValueModel.valueStatus = ESCartLabelStatusEnableDisSelected;
                        }
                    }
                    else
                    {
                        attributeValueModel.valueStatus = ESCartLabelStatusDisEnable;
                    }
                }
            }
        }
    }
}

+ (BOOL)updateSelectedSectionValues:(NSIndexPath *)indexPath
                     availAttribute:(NSArray <ESProductAttributeModel *> *)availAttributes
{
    if (!availAttributes
        || ![availAttributes isKindOfClass:[NSArray class]])
    {
        return NO;
    }
    
    ESProductAttributeModel *attributeModel = nil;
    for (NSInteger i = 0; i< availAttributes.count; i++)
    {
        ESProductAttributeModel *model = availAttributes[i];
        if (i == indexPath.section)
        {
            model.onSelected = YES;
            attributeModel = model;
        }
        else
        {
            model.onSelected = NO;
        }
    }
    ESProductAttributeValueModel *selectedValueModel = attributeModel.values[indexPath.item];
    
    BOOL selectedStatus = NO;
    for (NSInteger i = 0; i < attributeModel.values.count; i++)
    {
        ESProductAttributeValueModel *valueModel = attributeModel.values[i];
        if (selectedValueModel == valueModel)
        {
            if (valueModel.valueStatus == ESCartLabelStatusEnableDisSelected)
            {
                valueModel.valueStatus = ESCartLabelStatusEnableSelected;
                attributeModel.selectedValue = valueModel;
                selectedStatus = YES;
            }
            else if (valueModel.valueStatus == ESCartLabelStatusEnableSelected)
            {
                valueModel.valueStatus = ESCartLabelStatusEnableDisSelected;
                attributeModel.selectedValue = nil;
                selectedStatus = NO;
            }
        }
        else
        {
            if (valueModel.valueStatus == ESCartLabelStatusEnableSelected)
            {
                valueModel.valueStatus = ESCartLabelStatusEnableDisSelected;
            }
        }
    }
    
    return selectedStatus;
}

+ (NSArray <ESProductSKUModel *> *)getSelectedSkus:(NSArray <ESProductSKUModel *> *)skus
                            seletedAvailAttributes:(NSArray <ESProductAttributeModel *> *)attributes
{
    if (!skus
        || ![skus isKindOfClass:[NSArray class]]
        || ![attributes isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    for (ESProductSKUModel *skuModel in skus)
    {
        NSInteger i = 0;
        for (ESProductAttributeModel *attributeModel in attributes)
        {
            if ([attributeModel isKindOfClass:[ESProductAttributeModel class]]
                && [attributeModel.selectedValue isKindOfClass:[ESProductAttributeValueModel class]]
                && [skuModel isKindOfClass:[ESProductSKUModel class]]
                && [skuModel.definingAttributes isKindOfClass:[NSArray class]])
            {
                for (ESProductAttributeSelectedValueModel *valueModel in skuModel.definingAttributes)
                {
                    if ([attributeModel.identifier isKindOfClass:[NSString class]]
                        && [attributeModel.selectedValue isKindOfClass:[ESProductAttributeValueModel class]]
                        && [attributeModel.selectedValue.identifier isKindOfClass:[NSString class]]
                        && [valueModel.valueId isKindOfClass:[NSString class]]
                        && [valueModel.identifier isKindOfClass:[NSString class]]
                        && [attributeModel.identifier isEqualToString:valueModel.identifier]
                        && [attributeModel.selectedValue.identifier isEqualToString:valueModel.valueId])
                    {
                        i++;
                        break;
                    }
                }
            }
        }
        
        if (i == attributes.count)
        {
            [arrM addObject:skuModel];
        }
    }
    
    return [arrM copy];
}

+ (NSArray <ESProductAttributeModel *> *)getSelectedAttributes:(NSArray <ESProductAttributeModel *> *)attributes
{
    if (!attributes
        || ![attributes isKindOfClass:[NSArray class]])
    {
        return @[];
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    for (ESProductAttributeModel *attributeModel in attributes)
    {
        if ([attributeModel isKindOfClass:[ESProductAttributeModel class]]
            && [attributeModel.values isKindOfClass:[NSArray class]])
        {
            for (ESProductAttributeValueModel *valueModel in attributeModel.values)
            {
                if ([valueModel isKindOfClass:[ESProductAttributeValueModel class]]
                    && valueModel.valueStatus == ESCartLabelStatusEnableSelected
                    && ![arrM containsObject:attributeModel])
                {
                    [arrM addObject:attributeModel];
                    break;
                }
            }
        }
    }
    
    return [arrM copy];
}

+ (NSString *)getHeaderTipMessageWithSelectedValues:(NSArray *)selectedValues
                                      defaultValues:(NSArray *)defaultValues
{
    if (!selectedValues
        || ![selectedValues isKindOfClass:[NSArray class]]
        || !defaultValues
        || ![defaultValues isKindOfClass:[NSArray class]])
    {
        return @"";
    }
    
    NSMutableArray *arrM = [defaultValues mutableCopy];
    [arrM removeObjectsInArray:selectedValues];
    
    NSString *tipMessage = @"";
    if (arrM.count == 0)
    {
        tipMessage = @"已选：";
        for (ESProductAttributeModel *model in defaultValues)
        {
            if ([model isKindOfClass:[ESProductAttributeModel class]])
            {
                tipMessage = [NSString stringWithFormat:@"%@“%@”", tipMessage, model.selectedValue.value];
            }
        }
    }
    else
    {
        tipMessage = @"请选择：";
        for (ESProductAttributeModel *model in arrM)
        {
            if ([model isKindOfClass:[ESProductAttributeModel class]])
            {
                tipMessage = [NSString stringWithFormat:@"%@%@ ", tipMessage, model.name];
            }
        }

    }
    
    return tipMessage;
}

#pragma mark - Methods
+ (NSDictionary *)getSelectedAttributesWithSeletedSkus:(NSArray <ESProductSKUModel *> *)skus
{
    if (!skus
        || ![skus isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    for (ESProductSKUModel *skuModel in skus)
    {
        if ([skuModel isKindOfClass:[ESProductSKUModel class]]
            && [skuModel.definingAttributes isKindOfClass:[NSArray class]])
        {
            for (ESProductAttributeSelectedValueModel *selectedValueModel in skuModel.definingAttributes)
            {
                if ([selectedValueModel isKindOfClass:[ESProductAttributeSelectedValueModel class]]
                    && [selectedValueModel.identifier isKindOfClass:[NSString class]]
                    && [selectedValueModel.valueId isKindOfClass:[NSString class]])
                {
                    NSMutableArray *arrM = [[dictM objectForKey:selectedValueModel.identifier] mutableCopy];
                    if (!arrM
                        || ![arrM isKindOfClass:[NSMutableArray class]])
                    {
                        arrM = [NSMutableArray array];
                    }
                    
                    if (![arrM containsObject:selectedValueModel.valueId])
                    {
                        [arrM addObject:selectedValueModel.valueId];
                    }
                    [dictM setObject:[arrM copy] forKey:selectedValueModel.identifier];
                }
            }
        }
    }
    
    return [dictM copy];
}

+ (void)updateAllAttributeValuesWithAvailAttributes:(NSArray <ESProductAttributeModel *> *)availAttributes
                                      defaultStatus:(ESCartLabelStatus)labelStatus
{
    if (!availAttributes
        || ![availAttributes isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    for (ESProductAttributeModel *attributeModel in availAttributes)
    {
        if ([attributeModel isKindOfClass:[ESProductAttributeModel class]])
        {
            for (ESProductAttributeValueModel *attributeValueModel in attributeModel.values)
            {
                if ([attributeValueModel isKindOfClass:[ESProductAttributeValueModel class]]
                    && attributeValueModel.valueStatus != ESCartLabelStatusEnableSelected)
                {
                    attributeValueModel.valueStatus = labelStatus;
                }
            }
        }
    }
}

+ (void)setSelectedAttributes:(NSArray <ESProductAttributeModel *> *)availAttributes
                  selectedIDs:(NSDictionary *)seledteIDs
              enableAllStatus:(BOOL)enableAllStatus
{
    if (!availAttributes
        || ![availAttributes isKindOfClass:[NSArray class]]
        || !seledteIDs
        || ![seledteIDs isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    
    for (ESProductAttributeModel *attributeModel in availAttributes)
    {
        if ([attributeModel isKindOfClass:[ESProductAttributeModel class]]
            && [attributeModel.values isKindOfClass:[NSArray class]]
            && [attributeModel.identifier isKindOfClass:[NSString class]])
        {
            BOOL selectedAttribute = [seledteIDs.allKeys containsObject:attributeModel.identifier];
            
            for (ESProductAttributeValueModel *attributeValueModel in attributeModel.values)
            {
                if ([attributeValueModel isKindOfClass:[ESProductAttributeValueModel class]]
                    && attributeValueModel.identifier
                    && [attributeValueModel.identifier isKindOfClass:[NSString class]])
                {
                    ESCartLabelStatus labelStatus = ESCartLabelStatusUnKnow;
                    if (selectedAttribute)
                    {
                        if ([seledteIDs.allValues containsObject:attributeValueModel.identifier])
                        {
                            labelStatus = ESCartLabelStatusEnableSelected;
                            attributeModel.selectedValue = attributeValueModel;
                        }
                        else
                        {
                            if (enableAllStatus)
                            {
                                labelStatus = ESCartLabelStatusEnableDisSelected;
                            }
                        }
                    }
                    else
                    {
                        if (enableAllStatus)
                        {
                            attributeValueModel.valueStatus = ESCartLabelStatusEnableDisSelected;
                        }
                    }
                    
                    if (labelStatus != ESCartLabelStatusUnKnow
                        && attributeValueModel.couldEdit)
                    {
                        attributeValueModel.valueStatus = labelStatus;
                    }
                }
            }
        }
    }
}

+ (void)resetCartWIthProduct:(ESProductModel *)product
              isCustomizable:(BOOL)isCustomizable
{
    if (!product
        || ![product isKindOfClass:[ESProductModel class]])
    {
        return;
    }
    
    product.itemQuantity = 1;
    
    if (isCustomizable)
    {
        [self resetAvailAttributes:product.customizableAvailAttributes];
    }
    else
    {
        [self resetAvailAttributes:product.availAttributes];
    }
}

+ (void)resetAvailAttributes:(NSArray <ESProductAttributeModel *> *)availAttributes
{
    if (!availAttributes
        || ![availAttributes isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    for (ESProductAttributeModel *attributeModel in availAttributes)
    {
        if ([attributeModel isKindOfClass:[ESProductAttributeModel class]])
        {
            attributeModel.selectedValue = nil;
            attributeModel.onSelected = NO;
            
            for (ESProductAttributeValueModel *attributeValueModel in attributeModel.values)
            {
                if ([attributeValueModel isKindOfClass:[ESProductAttributeValueModel class]])
                {
                    attributeValueModel.valueStatus = ESCartLabelStatusEnableDisSelected;
                    attributeValueModel.couldEdit = YES;
                }
            }
        }
    }
}

@end
