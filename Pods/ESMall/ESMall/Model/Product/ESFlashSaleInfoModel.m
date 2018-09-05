
#import "ESFlashSaleInfoModel.h"

@implementation ESFlashSaleInfoModel

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

- (id)createModelWithDic:(NSDictionary *)dic
{
    [super createModelWithDic:dic];
    
    [self updateData];
    
    return self;
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
                           @"skuValues" : @"ESFlashSaleValueModel",
                           };
    return dict[key];
}

- (void)updateData
{    
    [self updatePrice];
    
    [self updateSkuMessage];
    
    [self updateLimitQuantity];
}

- (void)updatePrice
{
    CGFloat itemPrice = [self.itemPrice doubleValue];
    NSString *strItemPrice = nil;
    if (itemPrice > 10000000.0)
    {
        strItemPrice = [NSString stringWithFormat:@"%.2f万", itemPrice/10000.0];
    }
    else
    {
        strItemPrice = [NSString stringWithFormat:@"%.2f", itemPrice];
    }
    self.itemPrice = strItemPrice;
    
    CGFloat salePrice = [self.salePrice doubleValue];
    NSString *strSalePrice = nil;
    if (salePrice > 10000000.0)
    {
        strSalePrice = [NSString stringWithFormat:@"%.2f万", salePrice/10000.0];
    }
    else
    {
        strSalePrice = [NSString stringWithFormat:@"%.2f", salePrice];
    }
    self.salePrice = strSalePrice;
}

- (void)updateSkuMessage
{
    NSString *message = @"";
    if (self.skuValues
        && [self.skuValues isKindOfClass:[NSArray class]])
    {
        NSString *str = @"已选：";
        for (ESFlashSaleValueModel *model in self.skuValues)
        {
            if ([model isKindOfClass:[ESFlashSaleValueModel class]]
                && model.value)
            {
                str = [str stringByAppendingString:[NSString stringWithFormat:@"“%@”", model.value]];
            }
        }
        
        if (str.length > 3)
        {
            message = str;
        }
    }
    
    self.skuValueMessage = message;
}

- (void)updateLimitQuantity
{
    NSInteger limitQuantity = [self.limitQuantity integerValue];
    NSInteger buyQuantity = [self.buyQuantity integerValue];
    if (limitQuantity - buyQuantity >= 0)
    {
        self.limitQuantity = [NSString stringWithFormat:@"%ld", limitQuantity - buyQuantity];
    }
}

#pragma mark - Public Method
- (void)updateLimitQuantityWithCount:(NSInteger)count
{
    NSInteger limitQuantity = [self.limitQuantity integerValue];
    NSInteger newLimitQuantity = limitQuantity - count >= 0 ? limitQuantity - count : 0;
    self.limitQuantity = [NSString stringWithFormat:@"%ld", newLimitQuantity];
}

@end
