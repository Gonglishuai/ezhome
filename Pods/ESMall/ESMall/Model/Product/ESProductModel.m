
#import "ESProductModel.h"

@implementation ESProductModel

#pragma mark - Super Methods

- (id)createModelWithDic:(NSDictionary *)dic
{
    [super createModelWithDic:dic];
    
    [self updateModel];
    
    return self;
}

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

#pragma mark - Methods
- (NSString *)getModelNameWithKey:(NSString *)key
{
    if (!key
        || ![key isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    NSDictionary *dict = @{
                           @"availAttributes"       : @"ESProductAttributeModel",
                           @"descriptionAttributes" : @"ESProductAttributeSelectedValueModel",
                           @"prices"                : @"ESProductPriceModel",
                           @"childSKUs"             : @"ESProductSKUModel",
                           @"model"                 : @"ESProductModelModel",
                           @"images"                : @"ESProductImagesModel",
                           @"brandResponseBean"     : @"ESProductBrandModel",
                           @"priceOriginal"         : @"ESProductPriceModel",
                           @"productTagResponseBeans" : @"ESCartCommodityPromotion",
                           };
    return dict[key];
}

- (void)updateModel
{
    // 刷新价格
    [self updatePrice];
    self.itemQuantity = 1;
    self.cartMaxNum = MAX_CART_NUMBER;
    
    [self updateOriginPrice];
    
    // 更新定制的自定义字段
    [self updateSkuCustomizableInformation];
    
    // 更新sku的图片
    [self updateSkuImage];
}

- (void)updateOriginPrice
{
    self.originalPrice = @"";
    if (self.priceOriginal
        && [self.priceOriginal isKindOfClass:[NSArray class]]
        && self.priceOriginal.count > 0)
    {
        ESProductPriceModel *model = [self.priceOriginal firstObject];
        self.originalPrice = model.showValue;
    }
}

// 定制相关
- (void)updateSkuCustomizableInformation
{
    // 筛选出定制的标签
    NSMutableArray *customizableAvailAttributes = [NSMutableArray array];
    for (ESProductAttributeModel *model in self.availAttributes)
    {
        NSMutableArray *valuesArrM = [NSMutableArray array];
        for (ESProductAttributeValueModel *valueModel in model.values)
        {
            if (valueModel.customizable)
            {
                ESProductAttributeValueModel *newValueModel = [ESProductAttributeValueModel copyValueModel:valueModel];
                if (newValueModel)
                {
                    [valuesArrM addObject:newValueModel];
                }
            }
        }
        
        if (valuesArrM.count > 0)
        {
            ESProductAttributeModel *customizableAttributeModel = [ESProductAttributeModel copyAttributeModel:model];
            if (customizableAttributeModel)
            {
                customizableAttributeModel.values = [valuesArrM copy];
                [customizableAvailAttributes addObject:customizableAttributeModel];
            }
        }
    }
    self.customizableAvailAttributes = [customizableAvailAttributes copy];
    
    
    // 筛选出定制的SKU
    NSMutableArray *customizableSkus = [NSMutableArray array];
    for (ESProductSKUModel *skumModel in self.childSKUs)
    {
        if (skumModel.isCustomizable)
        {
            [customizableSkus addObject:skumModel];
        }
    }
    self.customizableChildSKUs = [customizableSkus copy];
}

- (void)updateSkuImage
{
    if (!self.fullImage
        || ![self.fullImage isKindOfClass:[NSString class]]
        || self.fullImage.length <= 0)
    {
        return;
    }
    
    for (ESProductSKUModel *skuModel in self.childSKUs)
    {
        if (!skuModel.fullImage
            || ![skuModel.fullImage isKindOfClass:[NSString class]]
            || skuModel.fullImage.length <= 0)
        {
            skuModel.fullImage = self.fullImage;
        }
    }
}

// 刷新价格
- (void)updatePrice
{
    CGFloat minPrice = MAXFLOAT;
    CGFloat maxPrice = 0.0f;
    for (ESProductSKUModel *skuModel in self.childSKUs)
    {
        if ([skuModel isKindOfClass:[ESProductSKUModel class]])
        {
            for (ESProductPriceModel *priceModel in skuModel.prices)
            {
                if ([priceModel isKindOfClass:[ESProductPriceModel class]])
                {
                    CGFloat price = [priceModel.value doubleValue];
                    if (minPrice > price)
                    {
                        minPrice = price;
                    }
                    if (maxPrice < price)
                    {
                        maxPrice = price;
                    }
                }
            }
        }
    }
    
    minPrice = minPrice==MAXFLOAT?0:minPrice;
    
    NSString *strPrice = nil;
    if (minPrice > 10000000.0)
    {
        strPrice = [NSString stringWithFormat:@"%.2f万", minPrice/10000.0];
    }
    else
    {
        strPrice = [NSString stringWithFormat:@"%.2f", minPrice];
    }
    
    self.minPrice = strPrice;
    
    if (minPrice < maxPrice)
    {
        self.showMinPriceStatus = YES;
    }
}

@end
