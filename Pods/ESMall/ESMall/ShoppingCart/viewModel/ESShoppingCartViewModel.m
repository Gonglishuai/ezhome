//
//  ESShoppingCartViewModel.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/30.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESShoppingCartViewModel.h"
#import "JRLocationServices.h"
#import "ESShoppingCartAPI.h"
#import <CoreLocation/CoreLocation.h>
#import "ESProductModel.h"

@implementation ESShoppingCartViewModel

#pragma mark - public
+ (void)retrieveCartInfoWithSuccess:(void(^)(NSArray *array, ESCartInfo *info))success andFailure:(void(^)(void))failure {
    
    [ESShoppingCartAPI getShoppingCartInfoWithSuccess:^(NSDictionary *dict) {
        
        SHLog(@"购物车列表:%@", dict);
        NSMutableArray *result = [NSMutableArray array];
        ESCartInfo *cartInfo = [ESCartInfo objFromDict:dict];
        ESShoppingCartViewModel *invalidData = nil;
        ESShoppingCartViewModel *unsupportData = nil;
        if (cartInfo.cartItems) {
            for (ESCartBrand *brand in cartInfo.cartItems) {
                if (brand.items) {
                    for (int i = 0; i < brand.items.count;) {
                        ESCartCommodity *commodity = [brand.items objectAtIndex:i];
                        switch (commodity.status) {
                            case ESCommodityStatusInvalid: {
                                if (invalidData == nil) {
                                    invalidData = [[ESShoppingCartViewModel alloc] init];
                                    invalidData.type = ESCommodityTypeInvalid;
                                    invalidData.data = [NSMutableArray array];
                                }
                                [invalidData.data addObject:commodity];
                                [brand.items removeObject:commodity];
                                break;
                            }
                            case ESCommodityStatusValid: {
                                NSString *cityCode = [JRLocationServices sharedInstance].locationCityInfo.cityCode;
                                if (![cityCode isEqualToString:commodity.regionId]) {
                                    if (unsupportData == nil) {
                                        unsupportData = [[ESShoppingCartViewModel alloc] init];
                                        unsupportData.type = ESCommodityTypeNonsupport;
                                        unsupportData.data = [NSMutableArray array];
                                    }
                                    [unsupportData.data addObject:commodity];
                                    [brand.items removeObject:commodity];
                                    break;
                                }
                                i++;
                                break;
                            }
                            default:
                                i++;
                                break;
                        }
                    }
                    
                    if (brand.items && brand.items.count > 0) {
                        
                        BOOL brandSeleted = YES;
                        for (ESCartCommodity *commodity in brand.items) {
                            if (commodity.chooseStatus == ESCommodityChooseStatusCancel) {
                                brandSeleted = NO;
                                break;
                            }
                        }
                        brand.selected = brandSeleted;
                        
                        [result addObject:brand];
                    }
                }
                
            }
        }
        
        //加入不支持商品
        if (unsupportData) {
            [result addObject:unsupportData];
        }
        
        //加入失效商品
        if (invalidData) {
            [result addObject:invalidData];
        }
        
        if (success) {
            success(result, cartInfo);
        }

    } andFailure:^(NSError *error) {
        
        if (failure) {
            failure();
        }
    }];
}

+ (void)requestForAttributesSpuId:(NSString *)spuId
                          success:(void(^)(ESProductModel *))success
                          failure:(void(^)(void))failure
{
    [ESShoppingCartAPI getSpuAttributesWithId:spuId success:^(NSDictionary *dict)
    {
        SHLog(@"获取spu属性: %@", dict);
        ESProductModel *model = [ESProductModel createModelWithDic:dict];
        if (success)
        {
            success(model);
        }
        
    } failure:^(NSError *error) {
        
        if (failure)
        {
            failure();
        }
    }];
}

+ (void)requestForItemSelectedStatus:(BOOL)status
                         cartItemIds:(NSString *)cartItemIds
                             success:(void(^)(ESCartInfo *cartInfo))success
                             failure:(void(^)(NSString *errorMsg))failure
{
    if (status)
    {
        [self requestForSelectedItemWithCartItemIds:cartItemIds
                                            success:success
                                            failure:failure];
    }
    else
    {
        [self requestForCancelSelectedItemWithCartItemIds:cartItemIds
                                                  success:success
                                                  failure:failure];
    }
}

/// 选中item
+ (void)requestForSelectedItemWithCartItemIds:(NSString *)cartItemIds
                                      success:(void(^)(ESCartInfo *cartInfo))success
                                      failure:(void(^)(NSString *errorMsg))failure
{
    [ESShoppingCartAPI selectedItemWithCartItemIds:cartItemIds success:^(NSDictionary *dict)
    {
        SHLog(@"选中成功:%@", dict);
        ESCartInfo *cartInfo = [ESCartInfo objFromDict:dict];
        if (success)
        {
            success(cartInfo);
        }
         
    } failure:^(NSError *error) {
        NSString *errorMsg = [ESProductModel getErrorMessage:error];
        SHLog(@"选中失败:%@", errorMsg);
        if (failure)
        {
            failure(errorMsg);
        }
    }];
}

/// 取消选中item
+ (void)requestForCancelSelectedItemWithCartItemIds:(NSString *)cartItemIds
                                            success:(void(^)(ESCartInfo *cartInfo))success
                                            failure:(void(^)(NSString *errorMsg))failure
{
    [ESShoppingCartAPI unselectedItemWithCartItemIds:cartItemIds success:^(NSDictionary *dict)
     {
         SHLog(@"取消成功:%@", dict);
         ESCartInfo *cartInfo = [ESCartInfo objFromDict:dict];
         if (success)
         {
             success(cartInfo);
         }
         
     } failure:^(NSError *error) {
         
         NSString *errorMsg = [ESProductModel getErrorMessage:error];
         SHLog(@"选中失败:%@", errorMsg);
         if (failure)
         {
             failure(errorMsg);
         }
     }];
}

+ (NSDictionary *)getSkuAttributesFromArray:(NSArray *)array
                                withSection:(NSInteger)section
                                   andIndex:(NSInteger)index
{
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            ESCartBrand *brand = (ESCartBrand *)object;
            ESCartCommodity *commodity = [brand.items objectAtIndex:index];
            NSMutableDictionary *skuValues = [NSMutableDictionary dictionary];
            for (ESStockKeepingUnit *sku in commodity.skuList) {
                [skuValues setObject:sku.valueId forKey:sku.nameId];
            }
            return [skuValues copy];
        }else if ([object isKindOfClass:[ESShoppingCartViewModel class]]){
            ESShoppingCartViewModel *viewModel = (ESShoppingCartViewModel *)object;
            ESCartCommodity *commodity = [viewModel.data objectAtIndex:index];
            NSMutableDictionary *skuValues = [NSMutableDictionary dictionary];
            for (ESStockKeepingUnit *sku in commodity.skuList) {
                [skuValues setObject:sku.valueId forKey:sku.nameId];
            }
            return [skuValues copy];
        }
        
        return @{};
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @{};
    }
}

+ (NSInteger)getSectionNumsFromArray:(NSMutableArray *)array
                         withEditAll:(BOOL)editAll {
    @try {
        if (editAll) {
            NSInteger nums = 0;
            for (id object in array) {
                if ([object isKindOfClass:[ESCartBrand class]]) {
                    nums += 1;
                }
            }
            return nums;
        }
        return array.count;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return 0;
    }
}

+ (NSInteger)getItemNumsFromArray:(NSMutableArray <ESShoppingCartViewModel *> *)array
                      withSection:(NSInteger)section {
    @try {
        NSInteger itemNums = 0;
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            ESCartBrand *brand = (ESCartBrand *)object;
            itemNums = brand.items.count;
        }else if ([object isKindOfClass:[ESShoppingCartViewModel class]]) {
            ESShoppingCartViewModel *model = (ESShoppingCartViewModel *)object;
            itemNums = model.data.count;
        }
        return itemNums;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return 0;
    }
    
}

+ (ESCommodityType)getSectionTypeFromArray:(NSArray *)array
                               withSection:(NSInteger)section {
    ESCommodityType type = ESCommodityTypeNone;
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            type = ESCommodityTypeValid;
        }else if ([object isKindOfClass:[ESShoppingCartViewModel class]]) {
            ESShoppingCartViewModel *model = (ESShoppingCartViewModel *)object;
            type = model.type;
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
    } @finally {
        return type;
    }
}

+ (BOOL)isSelectedFromArray:(NSArray *)array
                withSection:(NSInteger)section
                   andIndex:(NSInteger)index {
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            ESCartBrand *brand = (ESCartBrand *)object;
            ESCartCommodity *commodity = [brand.items objectAtIndex:index];
            return commodity.originChooseStatus == ESCommodityChooseStatusSelected;
        }
        return NO;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return NO;
    }
}

+ (BOOL)isSelectBrandFromArray:(NSArray *)array
                   withSection:(NSInteger)section {
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            ESCartBrand *brand = (ESCartBrand *)object;
            return brand.selected;
        }
        return NO;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return NO;
    }
}

+ (BOOL)brandIsEditingFromArray:(NSArray *)array
                       editDict:(NSMutableDictionary *)dict
                    withSection:(NSInteger)section
{
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]])
        {
            ESCartBrand *brand = (ESCartBrand *)object;
            if ([brand.brandId isKindOfClass:[NSString class]])
            {
                return dict[brand.brandId] && [dict[brand.brandId] boolValue];
            }
        }
        return NO;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return NO;
    }
}

+ (NSString *)getBrandNameFromArray:(NSArray *)array
                        withSection:(NSInteger)section {
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            ESCartBrand *brand = (ESCartBrand *)object;
            return brand.brandName;
        }
        return @"";
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (void)effectiveSelectBrandFromArray:(NSArray *)array
                          withSection:(NSInteger)section
{
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            ESCartBrand *brand = (ESCartBrand *)object;
            for (ESCartCommodity *commodity in brand.items) {
                commodity.originChooseStatus = commodity.chooseStatus;
                brand.selected = commodity.chooseStatus == ESCommodityChooseStatusSelected;
            }
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
    }
}

+ (NSDictionary *)selectBrandFromArray:(NSArray *)array
                       withSection:(NSInteger)section {
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            NSString *itemIds = @"";
            ESCartBrand *brand = (ESCartBrand *)object;
            BOOL selectedStatus = !brand.selected;
            for (ESCartCommodity *commodity in brand.items) {
                itemIds = [NSString stringWithFormat:@"%@,%@", commodity.cartItemId, itemIds];
                commodity.chooseStatus = selectedStatus ? ESCommodityChooseStatusSelected : ESCommodityChooseStatusCancel;
            }
            return @{
                     @"ids" : itemIds,
                     @"status" : @(selectedStatus)
                     };
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @{
                 @"ids" : @"",
                 @"status" : @(NO)
                 };
    }
}

+ (void)updateBrandSelectedStatusFromArray:(NSArray *)array
                                  editDict:(NSMutableDictionary *)editStatusDict
                               withSection:(NSInteger)section
{
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            ESCartBrand *brand = (ESCartBrand *)object;
            if (brand.brandId
                && editStatusDict[brand.brandId]
                && [editStatusDict[brand.brandId] boolValue])
            {//需要更新商品信息
                [editStatusDict setObject:@(NO) forKey:brand.brandId];
            }else {
                [editStatusDict setObject:@(YES) forKey:brand.brandId];
            }
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
    }
}

+ (NSString *)getItemImageFromArray:(NSArray *)array
                        withSection:(NSInteger)section
                           andIndex:(NSInteger)index {
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            ESCartBrand *brand = (ESCartBrand *)object;
            ESCartCommodity *commodity = [brand.items objectAtIndex:index];
            return commodity.itemImg;
        }else if ([object isKindOfClass:[ESShoppingCartViewModel class]]){
            ESShoppingCartViewModel *viewModel = (ESShoppingCartViewModel *)object;
            ESCartCommodity *commodity = [viewModel.data objectAtIndex:index];
            return commodity.itemImg;
        }
        return @"";
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (NSString *)getItemNameFromArray:(NSArray *)array
                       withSection:(NSInteger)section
                          andIndex:(NSInteger)index {
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            ESCartBrand *brand = (ESCartBrand *)object;
            ESCartCommodity *commodity = [brand.items objectAtIndex:index];
            return commodity.itemName;
        }else if ([object isKindOfClass:[ESShoppingCartViewModel class]]){
            ESShoppingCartViewModel *viewModel = (ESShoppingCartViewModel *)object;
            ESCartCommodity *commodity = [viewModel.data objectAtIndex:index];
            return commodity.itemName;
        }
        return @"";
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (NSString *)getItemSKUFromArray:(NSArray *)array
                      withSection:(NSInteger)section
                         andIndex:(NSInteger)index {
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            ESCartBrand *brand = (ESCartBrand *)object;
            ESCartCommodity *commodity = [brand.items objectAtIndex:index];
            NSMutableArray *skuValues = [NSMutableArray array];
            for (ESStockKeepingUnit *sku in commodity.skuList) {
                [skuValues addObject:sku.value];
            }
            NSString *skuStr = [skuValues componentsJoinedByString:@"; "];
            return skuStr;
        }else if ([object isKindOfClass:[ESShoppingCartViewModel class]]){
            ESShoppingCartViewModel *viewModel = (ESShoppingCartViewModel *)object;
            ESCartCommodity *commodity = [viewModel.data objectAtIndex:index];
            NSMutableArray *skuValues = [NSMutableArray array];
            for (ESStockKeepingUnit *sku in commodity.skuList) {
                [skuValues addObject:sku.value];
            }
            NSString *skuStr = [skuValues componentsJoinedByString:@"; "];
            return skuStr;
        }
        return @"";
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (double)getItemPriceFromArray:(NSArray *)array
                    withSection:(NSInteger)section
                       andIndex:(NSInteger)index {
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            ESCartBrand *brand = (ESCartBrand *)object;
            ESCartCommodity *commodity = [brand.items objectAtIndex:index];
            return [commodity.itemPrice doubleValue];
        }else if ([object isKindOfClass:[ESShoppingCartViewModel class]]){
            ESShoppingCartViewModel *viewModel = (ESShoppingCartViewModel *)object;
            ESCartCommodity *commodity = [viewModel.data objectAtIndex:index];
            return [commodity.itemPrice doubleValue];
        }
        return 0.00;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return 0.00;
    }
}

+ (NSInteger)getItemAmountFromArray:(NSArray *)array
                        withSection:(NSInteger)section
                           andIndex:(NSInteger)index {
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            ESCartBrand *brand = (ESCartBrand *)object;
            ESCartCommodity *commodity = [brand.items objectAtIndex:index];
            return [commodity.itemQuantity integerValue];
        }else if ([object isKindOfClass:[ESShoppingCartViewModel class]]){
            ESShoppingCartViewModel *viewModel = (ESShoppingCartViewModel *)object;
            ESCartCommodity *commodity = [viewModel.data objectAtIndex:index];
            return [commodity.itemQuantity integerValue];
        }
        return 0;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return 0;
    }
}

+ (ESCartCommodityPromotion *)getItemPromotionFromArray:(NSArray *)array
                                            withSection:(NSInteger)section
                                               andIndex:(NSInteger)index
{
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]])
        {
            ESCartBrand *brand = (ESCartBrand *)object;
            ESCartCommodity *commodity = [brand.items objectAtIndex:index];
            return commodity.promotion;
        }
        else if ([object isKindOfClass:[ESShoppingCartViewModel class]])
        {
            ESShoppingCartViewModel *viewModel = (ESShoppingCartViewModel *)object;
            ESCartCommodity *commodity = [viewModel.data objectAtIndex:index];
            return commodity.promotion;
        }
        return nil;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return nil;
    }
}

+ (void)effectiveSelectItemFromArray:(NSArray *)array
                         withSection:(NSInteger)section
                            andIndex:(NSInteger)index
{
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            ESCartBrand *brand = (ESCartBrand *)object;
            ESCartCommodity *commodity = [brand.items objectAtIndex:index];
            commodity.originChooseStatus = commodity.chooseStatus;
            
            BOOL brandSeleted = YES;
            for (ESCartCommodity *commodity in brand.items) {
                if (commodity.originChooseStatus == ESCommodityChooseStatusCancel) {
                    brandSeleted = NO;
                    break;
                }
            }
            brand.selected = brandSeleted;
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
    }
}

+ (NSDictionary *)selectItemFromArray:(NSArray *)array
                          withSection:(NSInteger)section
                             andIndex:(NSInteger)index
{
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            ESCartBrand *brand = (ESCartBrand *)object;
            ESCartCommodity *commodity = [brand.items objectAtIndex:index];
            if (commodity.chooseStatus == ESCommodityChooseStatusSelected) {
                commodity.chooseStatus = ESCommodityChooseStatusCancel;
            }else {
                commodity.chooseStatus = ESCommodityChooseStatusSelected;
            }
            
            BOOL brandSeleted = YES;
            for (ESCartCommodity *commodity in brand.items) {
                if (commodity.chooseStatus == ESCommodityChooseStatusCancel) {
                    brandSeleted = NO;
                    break;
                }
            }
            brand.selected = brandSeleted;
            
            return @{
                     @"ids" : commodity.cartItemId?commodity.cartItemId:@"",
                     @"status" : @(commodity.chooseStatus == ESCommodityChooseStatusSelected)
                     };
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @{
                 @"ids" : @"",
                 @"status" : @(NO)
                 };
    }
}

+ (void)deleteItemFromArray:(NSMutableArray *)array
                   editDict:(NSMutableDictionary *)editStatusDict
                withSection:(NSInteger)section
                  withIndex:(NSInteger)index
                withSuccess:(void(^)(BOOL, BOOL))success
                 andFailure:(void(^)(void))failure {
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            ESCartBrand *brand = (ESCartBrand *)object;
            ESCartCommodity *commodity = [brand.items objectAtIndex:index];
            [ESShoppingCartViewModel delteCommodities:@[commodity.cartItemId] withSuccess:^{
                if (brand.items.count == 1)
                {
                    [editStatusDict removeObjectForKey:brand.brandId];
                }
                if (success) {
                    success(YES, NO);
                }
            } andFailure:failure];
        }else if ([object isKindOfClass:[ESShoppingCartViewModel class]]){
            ESShoppingCartViewModel *viewModel = (ESShoppingCartViewModel *)object;
            ESCartCommodity *commodity = [viewModel.data objectAtIndex:index];
            [ESShoppingCartViewModel delteCommodities:@[commodity.cartItemId] withSuccess:^{
                BOOL delSection = NO;
                [viewModel.data removeObject:commodity];
                if (viewModel.data.count == 0) {
                    [array removeObject:object];
                    delSection = YES;
                }
                if (success) {
                    success(NO, delSection);
                }
            } andFailure:failure];
        }

    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
    }
}

+ (void)clearInvalidItemsFromArray:(NSMutableArray *)array
                       withSection:(NSInteger)section
                       withSuccess:(void(^)(void))success
                        andFailure:(void(^)(void))failure {
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESShoppingCartViewModel class]]){
            ESShoppingCartViewModel *viewModel = (ESShoppingCartViewModel *)object;
            NSMutableArray *cartItemsIds = [NSMutableArray array];
            for (ESCartCommodity *commodity in viewModel.data) {
                [cartItemsIds addObject:commodity.cartItemId];
            }
            if (cartItemsIds.count > 0) {
                [ESShoppingCartViewModel delteCommodities:cartItemsIds withSuccess:^{
                    [array removeObject:object];
                    if (success) {
                        success();
                    }
                } andFailure:failure];
                return;
            }
            if (failure) {
                failure();
            }
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        if (failure) {
            failure();
        }
    }
}

+ (ESCartCommodity *)getCommodityFromArray:(NSArray *)array
                               withSection:(NSInteger)section
                                  andIndex:(NSInteger)index
{
    @try {
        id object = [array objectAtIndex:section];
        if ([object isKindOfClass:[ESCartBrand class]]) {
            ESCartBrand *brand = (ESCartBrand *)object;
            ESCartCommodity *commdity = [brand.items objectAtIndex:index];
            return commdity;
        }
        return nil;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return nil;
    }
}

+ (NSString *)getTotalPriceFromCartInfo:(NSArray *)array {
    @try {
        double price = 0.00f;
        for (id object in array) {
            if ([object isKindOfClass:[ESCartBrand class]]) {
                ESCartBrand *brand = (ESCartBrand *)object;
                for (ESCartCommodity *commodity in brand.items) {
                    if (commodity.chooseStatus == ESCommodityChooseStatusSelected) {
                        price += [commodity.itemPrice doubleValue] * [commodity.itemQuantity integerValue];
                    }
                }
            }
        }
        if (price > 10000000.0) {
            return [NSString stringWithFormat:@"¥ %.2f万", price/10000.0];
        }
        
        return [NSString stringWithFormat:@"¥ %.2f", price];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"¥ 0.00";
    }
}

+ (NSInteger)getSelectedTotoalNumsFromArray:(NSArray *)array
                                   withType:(ESCommodityType)type {
    @try {
        NSInteger nums = 0;
        for (id object in array) {
            if (type == ESCommodityTypeValid) {
                if ([object isKindOfClass:[ESCartBrand class]] ) {
                    ESCartBrand *brand = (ESCartBrand *)object;
                    for (ESCartCommodity *commodity in brand.items) {
                        if (commodity.originChooseStatus == ESCommodityChooseStatusSelected) {
                            nums += 1;
                        }
                    }
                }
            }else if (type == ESCommodityTypeNonsupport) {
                if ([object isKindOfClass:[ESCartBrand class]] ) {
                    ESShoppingCartViewModel *model = (ESShoppingCartViewModel *)object;
                    nums = model.data.count;
                }
            }else if (type == ESCommodityTypeInvalid) {
                if ([object isKindOfClass:[ESCartBrand class]] ) {
                    ESShoppingCartViewModel *model = (ESShoppingCartViewModel *)object;
                    nums = model.data.count;
                }
            }
        }
        return nums;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return 0;
    }
}

+ (void)deleteSelectedItemsFromArray:(NSMutableArray *)array
                            editDict:(NSMutableDictionary *)editDictM
                         withSuccess:(void(^)(void))success
                          andFailure:(void(^)(void))failure {
    @try {
        NSMutableArray *cartItems = [NSMutableArray array];
        NSMutableArray *clearAllBrandIds = [NSMutableArray array];
        for (id object in array) {
            if ([object isKindOfClass:[ESCartBrand class]]) {
                ESCartBrand *brand = (ESCartBrand *)object;
                NSInteger brandSelectedCount = 0;
                for (ESCartCommodity *commodity in brand.items) {
                    if (commodity.chooseStatus == ESCommodityChooseStatusSelected) {
                        [cartItems addObject:commodity.cartItemId];
                        brandSelectedCount++;
                    }
                }
                if (brandSelectedCount == brand.items.count
                    && [brand.brandId isKindOfClass:[NSString class]])
                {
                    [clearAllBrandIds addObject:brand.brandId];
                }
            }
        }
        
        if (cartItems.count > 0) {
            [ESShoppingCartViewModel delteCommodities:cartItems withSuccess:^{
                
                for (NSString *brandId in clearAllBrandIds)
                {
                    [editDictM removeObjectForKey:brandId];
                }
                
                if (success) {
                    success();
                }
            } andFailure:failure];
        }else {
            if (failure) {
                failure();
            }
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        if (failure) {
            failure();
        }
    }
}

+ (BOOL)isSelectedAllItemsFromArray:(NSArray *)array {
    @try {
        BOOL selectedAll = YES;
        NSInteger flag = 0;
        for (id object in array) {
            if ([object isKindOfClass:[ESCartBrand class]]) {
                flag += 1;
                ESCartBrand *brand = (ESCartBrand *)object;
                if (brand.selected == NO) {
                    selectedAll = NO;
                    break;
                }
            }
        }
        return flag > 0 && selectedAll;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return NO;
    }
}

+ (void)effectiveMarkAllItemsSelected:(BOOL)select
                            withArray:(NSArray *)array
{
    @try {
        for (id object in array) {
            if ([object isKindOfClass:[ESCartBrand class]]) {
                ESCartBrand *brand = (ESCartBrand *)object;
                brand.selected = select;
                for (ESCartCommodity *commodity in brand.items) {
                    commodity.originChooseStatus = commodity.chooseStatus;
                }
            }
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
    }
}

+ (NSDictionary *)markAllItemsSelected:(BOOL)select
                             withArray:(NSArray *)array {
    @try {
        NSString *itemIds = @"";
        for (id object in array) {
            if ([object isKindOfClass:[ESCartBrand class]]) {
                ESCartBrand *brand = (ESCartBrand *)object;
                brand.selected = select;
                for (ESCartCommodity *commodity in brand.items) {
                    commodity.chooseStatus = select ? ESCommodityChooseStatusSelected : ESCommodityChooseStatusCancel;
                    itemIds = [NSString stringWithFormat:@"%@,%@",commodity.cartItemId, itemIds];
                }
            }
        }
        return @{
                 @"ids" : itemIds,
                 @"status" : @(select)
                 };
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @{
                 @"ids" : @"",
                 @"status" : @(NO)
                 };
    }
}

+ (void)markAllItemsEditingStatus:(BOOL)editing
                         withDict:(NSMutableDictionary *)dict
{
    if ([dict isKindOfClass:[NSMutableDictionary class]])
    {
        [dict removeAllObjects];
    }
}

+ (BOOL)hasEditingBrandFromDict:(NSMutableDictionary *)dict
{
    @try {
        for (id object in [dict allValues])
        {
            if ([object boolValue]) {
                return YES;
            }
        }
        return NO;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return NO;
    }
}

+ (void)createPendingOrderSuccess:(void(^)(NSDictionary *dict))success
                         andFailure:(void(^)(NSString *errMsg))failure
{
    [ESShoppingCartAPI createPendingOrderSuccess:success
                                      andFailure:^(NSError *error)
    {
        if (failure)
        {
            failure([ESProductModel getErrorMessage:error]);
        }
    }];
}

+ (void)updateSkuAttributesFromArray:(NSArray *)array
                         withSection:(NSInteger)section
                            andIndex:(NSInteger)index
                            newSkuId:(NSString *)skuId
                        itemQuantity:(NSInteger)itemQuantity
                         withSuccess:(void(^)(void))success
                          andFailure:(void(^)(NSString *errorMsg))failure
{
    @try {
        id object = [array objectAtIndex:section];
        ESCartBrand *brand = (ESCartBrand *)object;
        ESCartCommodity *commodity = brand.items[index];
        [ESShoppingCartAPI updateCartItemWithId:commodity.cartItemId
                                       newSkuId:skuId
                                   itemQuantity:itemQuantity
                                    withSuccess:^(NSDictionary *dict)
         {
             SHLog(@"修改购物车商品属性response: %@", dict);
             
             if (success)
             {
                 success();
             }
         } andFailure:^(NSError *error) {
             
             if (failure)
             {
                 failure([ESProductModel getErrorMessage:error]);
             }
         }];
    
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        if (failure)
        {
            failure(nil);
        }
    }
}

+ (void)checkLocalRegionInfoWithSuccess:(void(^)(void))success
                       withNoPermission:(void(^)(void))noPermission
                            withFailure:(void(^)(void))failure {
    NSString *cityCode = [JRLocationServices sharedInstance].locationCityInfo.cityCode;
    if (cityCode != nil && ![cityCode isEqualToString:@""]) {//有定位信息
        if (success) {
            success();
            return;
        }
    }else {//没有定位信息
        CLAuthorizationStatus type = [CLLocationManager authorizationStatus];
        if (![CLLocationManager locationServicesEnabled] || type == kCLAuthorizationStatusDenied) {//没有权限
            if (noPermission) {
                noPermission();
                return;
            }
        }else {//定位失败
            if (failure) {
                failure();
                return;
            }
        }
        
    }
}

+ (void)getLocalInfoWithSuccess:(void(^)(BOOL success))success {
    JRLocationServices *severces = [JRLocationServices sharedInstance];
    [severces requestLocation:^(JRCityInfo *info) {
        BOOL successful = info.cityCode != nil && ![info.cityCode isEqualToString:@""];
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(successful);
            });
        }
    }];
}

+ (NSInteger)getMinAmountFromArray:(NSMutableArray *)array
                       withSection:(NSInteger)section
                          andIndex:(NSInteger)index {
    return 1;
//    @try {
//        id object = [array objectAtIndex:section];
//        if ([object isKindOfClass:[ESCartBrand class]]) {
//            ESCartBrand *brand = (ESCartBrand *)object;
//            ESCartCommodity *commodity = [brand.items objectAtIndex:index];
//            NSInteger amount = [commodity.itemQuantity integerValue];
//            return amount > 1;
//        }
//        return NO;
//    } @catch (NSException *exception) {
//        SHLog(@"%@", exception.reason);
//        return NO;
//    }
}

+ (NSInteger)getMaxAmountFromArray:(NSMutableArray *)array
                       withSection:(NSInteger)section
                          andIndex:(NSInteger)index {
    return 999;
//    @try {
//        id object = [array objectAtIndex:section];
//        if ([object isKindOfClass:[ESCartBrand class]]) {
//            ESCartBrand *brand = (ESCartBrand *)object;
//            ESCartCommodity *commodity = [brand.items objectAtIndex:index];
//            NSInteger amount = [commodity.itemQuantity integerValue];
//            return amount < 999;
//        }
//        return NO;
//    } @catch (NSException *exception) {
//        SHLog(@"%@", exception.reason);
//        return NO;
//    }
}

#pragma mark - private
//删除购物车商品
+ (void)delteCommodities:(NSArray <NSString *>*)cartItemIds
             withSuccess:(void(^)(void))success
              andFailure:(void(^)(void))failure {
    
    NSString *cartItems = [cartItemIds componentsJoinedByString:@","];
    [ESShoppingCartAPI deleteCartItems:cartItems withSuccess:success andFailure:^(NSError *error) {
        if (failure) {
            failure();
        }
    }];
}

+ (NSString *)getGiftIdFromArray:(NSArray *)array
                     withSection:(NSInteger)section
                        andIndex:(NSInteger)index
{
    ESCartCommodityPromotion *promotionModel = [self getItemPromotionFromArray:array withSection:section andIndex:index];
    if (promotionModel
        && [promotionModel isKindOfClass:[ESCartCommodityPromotion class]]
        && promotionModel.giftsCount > 0)
    {
        ESCartCommodityPromotionGift *gift = [promotionModel.rewardInfos firstObject];
        if (gift
            && gift.productStatus
            && gift.catentryId
            && [gift.catentryId isKindOfClass:[NSString class]])
        {
            return gift.catentryId;
        }
    }
    
    return @"";
}

@end
