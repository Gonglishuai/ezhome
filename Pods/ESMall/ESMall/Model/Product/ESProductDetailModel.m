
#import "ESProductDetailModel.h"
#import "ESShoppingCartAPI.h"
#import <ESFoundation/UMengServices.h>
#import "ESMallAssets.h"

@implementation ESProductDetailModel

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
        if ([@"product" isEqualToString:key])
        {
            self.product = [models firstObject];
        }
        else
        {
            if (models)
            {
                [super setValue:models forKey:key];
            }
        }
    }
    else if ([@"discount" isEqualToString:key])
    {
        if (value
            && [value isKindOfClass:[NSArray class]])
        {
            self.discount = value;
        }
    }
    else if ([@"activityInfo" isEqualToString:key])
    {
        NSArray *activityInfos = value;
        if (activityInfos
            && [activityInfos isKindOfClass:[NSArray class]]
            && [[activityInfos firstObject] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *activityInfo = [activityInfos firstObject];
            NSString *skuId = activityInfo[@"sku"];
            NSArray *tagInfos = activityInfo[@"tagInfos"];
            if ([tagInfos isKindOfClass:[NSArray class]]
                && [skuId isKindOfClass:[NSString class]]
                && skuId.length > 0
                && tagInfos.count > 0
                && [[tagInfos firstObject] isKindOfClass:[NSString class]])
            {
                NSString *tagInfoStr = [tagInfos firstObject];
                NSDictionary *tagInfo = [NSJSONSerialization JSONObjectWithData:[tagInfoStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                if ([tagInfo isKindOfClass:[NSDictionary class]]
                    && tagInfo[@"activityType"])
                {
                    NSInteger activityInfoType = [tagInfo[@"activityType"] integerValue];
                    if (activityInfoType == ESProductDetailActivityInfoTypeEarnest)
                    {
                        self.earnestInfo = [ESProductDetailEarnestModel createModelWithDic:tagInfo];
                        self.earnestInfo.skuId = skuId;
                    }
                    else if (activityInfoType == ESProductDetailActivityInfoTypeFlashSale)
                    {
                        self.flashSaleInfo = [ESFlashSaleInfoModel createModelWithDic:tagInfo];
                        self.flashSaleInfo.sku = skuId;
                    }
                }
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
                           @"product"    : @"ESProductModel",
                           @"stores"     : @"ESProductStoreModel",
                           @"sampleroom" : @"ESProductDetailSampleroomModel",
                           @"coupons"    : @"ESProductDetailCouponsModel",
                           };
    return dict[key];
}

- (void)updateData
{
    // 门店地址信息
    [self updateStoresData];
    
    // 有试衣间
    [self updateSampleroom];
    
    // 是否抢购
    [self updateFlashSaleInfo];
    
    // 是否定金膨胀
    [self updateEarnestInfo];
    
    // 是够有折扣
    [self updateDiscount];
    
    // 是否有优惠券
    [self updateCoupons];
    
    // 获取展示优惠券的信息
    [self updateShowCoupons];
    
    // 手否有促销
    [self updatePromotion];
}

#pragma mark - Public Methods
+ (NSDictionary *)getJuranPromise
{
    NSString *plistPath = [[ESMallAssets hostBundle] pathForResource:@"JuranPromise"
                                                          ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    return dict;
}

+ (void)requestForProductDetailWithID:(NSString *)productId
                                 type:(NSString *)type
                      flashSaleItemId:(NSString *)flashSaleItemId
                           activityId:(NSString *)activityId
                              success:(void (^) (ESProductDetailModel *))success
                              failure:(void (^)(void))failure
{    
    [ESShoppingCartAPI requestForProductDetailWithID:productId
                                                type:type
                                     flashSaleItemId:flashSaleItemId
                                          activityId:activityId
                                             success:^(NSDictionary *dict)
    {
        SHLog(@"商品详情:%@", dict);
        ESProductDetailModel *model = [ESProductDetailModel createModelWithDic:dict];
        if (success)
        {
            success(model);
        }
        
    } failure:^(NSError *error) {
        
        SHLog(@"数据请求失败: %@", error.localizedDescription);
        if (failure)
        {
            failure(); 
        }
    }];
}

+ (void)requestForAddItemWithSkuId:(NSString *)skuId
                      itemQuantity:(NSInteger)itemQuantity
                        designerId:(NSString *)designerId
                           success:(void (^) (NSDictionary *))success
                           failure:(void (^) (NSDictionary *))failure
{
    [ESShoppingCartAPI addCartItemWithSkuId:skuId
                               itemQuantity:itemQuantity
                                 designerId:designerId
                                    success:success
                                    failure:^(NSError *error)
    {
        NSData *errorData = [error userInfo][AFNetworkingOperationFailingURLResponseDataErrorKey];
        
        NSDictionary *errDict = nil;
        if (errorData
            && [errorData isKindOfClass:[NSData class]])
        {
            errDict = [NSJSONSerialization JSONObjectWithData:errorData
                                                      options:NSJSONReadingMutableContainers
                                                        error:nil];
            if (![errDict isKindOfClass:[NSDictionary class]])
            {
                errDict = nil;
            }
        }
        
        SHLog(@"数据请求失败: %@", error.localizedDescription);
        if (failure)
        {
            failure(errDict);
        }
    }];
}

+ (void)requestForAddCustomItemWithSkuId:(NSString *)skuId
                            itemQuantity:(NSInteger)itemQuantity
                                 success:(void (^) (NSDictionary *))success
                                 failure:(void (^)(void))failure
{
    [ESShoppingCartAPI addCustomItemWithSkuId:skuId
                                 itemQuantity:itemQuantity
                                      success:success
                                      failure:^(NSError *error)
     {
         SHLog(@"数据请求失败: %@", error.localizedDescription);
         if (failure)
         {
             failure();
         }
     }];
}

+ (void)requestForBuyItemWithSkuId:(NSString *)skuId
                      itemQuantity:(NSInteger)itemQuantity
                           success:(void (^) (NSDictionary *))success
                           failure:(void (^) (NSString *errMeg))failure
{
    [ESShoppingCartAPI buyItemWithSkuId:skuId
                           itemQuantity:itemQuantity
                                success:success
                                failure:^(NSError *error)
     {
         SHLog(@"数据请求失败: %@", error.localizedDescription);
         if (failure)
         {
             failure([self getErrorMessage:error]);
         }
     }];
}

+ (void)requestForBuyWithActivityType:(NSString *)activityType
                           activityId:(NSString *)activityId
                                skuId:(NSString *)skuId
                         itemQuantity:(NSInteger)itemQuantity
                              success:(void (^) (NSDictionary *dict))success
                              failure:(void (^) (NSString *errorMessage,
                                                 NSInteger quantity))failure
{
    if (!skuId
        || ![skuId isKindOfClass:[NSString class]]
        || !activityId
        || ![activityId isKindOfClass:[NSString class]])
    {
        if (failure)
        {
            failure(@"请求参数有误", 0);
        }
        return;
    }
    
    NSDictionary *body = @{
                           @"sku"          : skuId,
                           @"activityType" : activityType,
                           @"activityId"   : activityId,
                           @"itemQuantity" : @(itemQuantity)
                           };
    
    if ([activityType integerValue] == ESProductDetailActivityInfoTypeFlashSale)
    {
        [UMengServices eventWithEventId:Event_to_promotion_purchase attributes:body];
    }
    
    [ESShoppingCartAPI activityBuyWithBody:body
                                   success:^(NSDictionary *dict)
     {
         
         if (success)
         {
             success(dict);
         }
         
     } failure:^(NSError *error) {
         
         NSData *errorData = [error userInfo][AFNetworkingOperationFailingURLResponseDataErrorKey];
         
         NSString *errorMessage = @"网络错误, 请稍后重试!";
         NSString *quantity = @"0";
         if (errorData
             && [errorData isKindOfClass:[NSData class]])
         {
             NSDictionary *dict = [NSJSONSerialization
                                   JSONObjectWithData:errorData
                                   options:NSJSONReadingMutableContainers
                                   error:nil];
             if ([dict isKindOfClass:[NSDictionary class]])
             {
                 if (dict[@"msg"]
                     && [dict[@"msg"] isKindOfClass:[NSString class]])
                 {
                     errorMessage = dict[@"msg"];
                 }
                 if (dict[@"quantity"]
                     && ![dict[@"quantity"] isKindOfClass:[NSNull class]])
                 {
                     quantity = [dict[@"quantity"] stringValue];
                 }
             }
         }
         
         SHLog(@"数据请求失败: %@, %@, %@", error.localizedDescription, errorMessage, quantity);
         if (failure)
         {
             failure(errorMessage, [quantity integerValue]);
         }
     }];
}

#pragma mark - Methods
- (void)updateStoresData
{
    self.hasStores = self.stores
    && [self.stores isKindOfClass:[NSArray class]]
    && self.stores.count > 0;
}

- (void)updateSampleroom
{
    self.hasModel = (self.sampleroom
                     && [self.sampleroom isKindOfClass:[NSArray class]]
                     && self.sampleroom.count > 0);
}

- (void)updateFlashSaleInfo
{
    if (self.flashSaleInfo
        && [self.flashSaleInfo isKindOfClass:[ESFlashSaleInfoModel class]])
    {
        self.flashSaleStartStatus = [self.flashSaleInfo.isStart boolValue];
        self.flashSaleStatus = YES;
        self.flashSaleInfo.productName = self.product.name;
        
        if ([self.flashSaleInfo.stockQuantity isKindOfClass:[NSString class]])
        {
            self.hasStockQuantity = [self.flashSaleInfo.stockQuantity integerValue] > 0;
            
            if ([self.flashSaleInfo.dexTime floatValue] <= 0)
            {
                self.flashSaleInfo.dexTime = @"0";
                self.hasStockQuantity = NO;
            }
        }
    }
}

- (void)updateEarnestInfo
{
    if (self.earnestInfo
        && [self.earnestInfo isKindOfClass:[ESProductDetailEarnestModel class]])
    {
        if (self.earnestInfo.isStart)
        {
            self.earnestStatus = YES;
            self.earnestStartStatus = self.earnestInfo.isEarnestStart;
            self.earnestInfo.productName = self.product.name;
            
            self.earnestInfo.earnestAmount = [self updatePrice:self.earnestInfo.earnestAmount];
            self.earnestInfo.discountAmount = [self updatePrice:self.earnestInfo.discountAmount];
            self.earnestInfo.finalPaymentAmount = [self updatePrice:self.earnestInfo.finalPaymentAmount];
            
            if (self.earnestInfo.earnestDexTime
                && [self.earnestInfo.earnestDexTime doubleValue] <= 0)
            {
                self.earnestInfo.earnestDexTime = @"0";
            }
            
            self.earnestInfo.activityPrice = @"0.00";
            if (self.earnestInfo.discountAmount
                && self.earnestInfo.finalPaymentAmount)
            {
                self.earnestInfo.activityPrice = [self updatePrice:[@([self.earnestInfo.discountAmount doubleValue] + [self.earnestInfo.finalPaymentAmount doubleValue]) stringValue]];
            }
        }
        else
        {
            self.earnestInfo = nil;
        }
    }
}

- (void)updateDiscount
{
    if (self.discount
        && [self.discount isKindOfClass:[NSArray class]]
        && self.discount.count > 0)
    {
        self.hasDiscount = YES;
    }
    
    // 隐藏折扣
    self.hasDiscount = NO;
}

- (void)updateCoupons
{
    if (self.coupons
        && [self.coupons isKindOfClass:[NSArray class]]
        && self.coupons.count > 0
        && [self.coupons firstObject]
        && [[self.coupons firstObject] isKindOfClass:[ESProductDetailCouponsModel class]]
        && !self.flashSaleStatus)
    {
        ESProductDetailCouponsModel *couponModel = [self.coupons firstObject];
        if (couponModel.list
            && [couponModel.list isKindOfClass:[NSArray class]]
            && couponModel.list.count > 0)
        {
            self.hasCoupons = YES;
        }
    }
}

- (void)updateShowCoupons
{
    NSMutableArray *couponDS = [NSMutableArray array];
    for (ESProductDetailCouponsModel *model in self.coupons)
    {
        if ([model isKindOfClass:[ESProductDetailCouponsModel class]]
            && model.list
            && [model.list isKindOfClass:[NSArray class]])
        {
            for (NSString *str in model.list)
            {
                if ([str isKindOfClass:[NSString class]]
                    && couponDS.count < 3)
                {
                    [couponDS addObject:str];
                }
                else
                {
                    break;
                }
            }
        }
    }
    self.couponDS = [couponDS copy];
}

- (void)updatePromotion
{
    if (self.product
        && [self.product isKindOfClass:[ESProductModel class]]
        && self.product.productTagResponseBeans
        && [self.product.productTagResponseBeans isKindOfClass:[NSArray class]]
        && self.product.productTagResponseBeans.count > 0
        && [[self.product.productTagResponseBeans firstObject] isKindOfClass:[ESCartCommodityPromotion class]])
    {
        self.promotiomStatus = YES;
    }
}

- (NSString *)updatePrice:(NSString *)oldPrice
{
    if (!oldPrice
        || ![oldPrice isKindOfClass:[NSString class]])
    {
        return oldPrice;
    }
    
    NSString *strPrice = nil;
    CGFloat priceNum = [oldPrice doubleValue];
    if (priceNum <= 0)
    {
        strPrice = @"";
    }
    
    if (priceNum > 10000000.0)
    {
        strPrice = [NSString stringWithFormat:@"%.2f万", priceNum/10000.0];
    }
    else
    {
        strPrice = [NSString stringWithFormat:@"%.2f", priceNum];
    }
    return strPrice;
}

@end
