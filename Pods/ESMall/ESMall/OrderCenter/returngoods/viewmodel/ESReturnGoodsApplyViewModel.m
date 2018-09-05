//
//  ESReturnGoodsApplyViewModel.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/14.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESReturnGoodsApplyViewModel.h"
#import "ESOrderAPI.h"
#import "CoStringManager.h"
#import "MGJRouter.h"

@implementation ESReturnGoodsApplyViewModel

+ (void)retrieveRefundOrderInfoWithOrderId:(NSString *)orderId
                               withSuccess:(void(^)(ESReturnApplyOrderInfo *orderInfo))success
                                andFailure:(void(^)(void))failure {
    
    [ESOrderAPI getReturnGoodsApplyInfo:orderId withSuccess:^(NSDictionary *dict) {
        
        SHLog(@"申请退款:%@", dict);
        
        ESReturnApplyOrderInfo *orderInfo = [ESReturnApplyOrderInfo objFromDict:dict];
        if ([ESReturnGoodsApplyViewModel isInstalmentWithOrder:orderInfo]) {
            [ESReturnGoodsApplyViewModel selectAllItems:YES withOrder:orderInfo];
        }
        if (success) {
            success(orderInfo);
        }
    } andFailure:^(NSError *error) {
        if (failure) {
            failure();
        }
    }];
}

+ (void)createNewReturnGoods:(ESReturnApplyOrderInfo *)orderInfo
                 withSuccess:(void(^)(NSString *returnGoodsId))success
                  inProgress:(void(^)(void))progress
                  andFailure:(void(^)(NSString *, NSInteger))failure {
    @try {
        NSMutableArray *itemList = [NSMutableArray array];
        NSInteger allItemQuantity = 0;
        NSInteger allReturnedQuantity = 0;
        NSInteger giftCount = 0;
        ESReturnGoodsCommodity *giftCommodity = nil;
        for (ESReturnGoodsCommodity *commodity in orderInfo.itemList) {
            if (commodity.isSelected) {
                NSDictionary *item = @{@"orderItemId" : commodity.orderItemId,
                                       @"orderItemQuantity" : commodity.editReturnItemNum};
                [itemList addObject:item];
            }
            
            allItemQuantity += [commodity.itemQuantity integerValue];
            allReturnedQuantity += [commodity.returnedQuantity integerValue];
            if (commodity.returnGoodsStatus == ESReturnCommodityStatusGift)
            {
                giftCommodity = commodity;
                giftCount += [commodity.itemQuantity integerValue];
            }
        }
        
        if (giftCommodity
            && itemList.count == allItemQuantity - giftCount - allReturnedQuantity)
        {
            NSDictionary *item = @{@"orderItemId" : giftCommodity.orderItemId,
                                   @"orderItemQuantity" : giftCommodity.itemQuantity};
            [itemList addObject:item];
        }
        
        
        if (itemList.count <= 0) {
            if (failure) {
                failure(@"请选择要退货的商品!", -1);
                return;
            }
        }
        if (orderInfo.returnWay == ESReturnAmountTypeMoney
            && [orderInfo.returnMoney isEqualToString:@""])
        {
            if (failure) {
                failure(@"请输入退款金额!", -1);
                return;
            }
        }
        if ([orderInfo.returnGoodsReason isEqualToString:@""]) {
            if (failure) {
                failure(@"请填写退款原因!", 0);
                return;
            }
        }
        if ([CoStringManager stringContainsEmoji:orderInfo.returnGoodsReason]) {
            if (failure) {
                failure(@"退款原因含有特殊字符", 0);
                return;
            }
        }
        if ([orderInfo.name isEqualToString:@""]) {
            if (failure) {
                failure(@"请填写退款联系人!", 1);
                return;
            }
        }
        if ([CoStringManager stringContainsEmoji:orderInfo.name]) {
            if (failure) {
                failure(@"退款联系人含有特殊字符", 1);
                return;
            }
        }
        if ([orderInfo.mobile isEqualToString:@""]) {
            if (failure) {
                failure(@"请填写联系电话!", 2);
                return;
            }
        }
        
        NSInteger refundType = orderInfo.returnWay == ESReturnAmountTypeMoney?2:1;
        NSDictionary *info = @{@"returnGoodsReason" : orderInfo.returnGoodsReason,
                               @"remark"            : orderInfo.remark,
                               @"userName"          : orderInfo.name,
                               @"userMobile"        : orderInfo.mobile,
                               @"refundType"        : @(refundType),
                               @"refundAmount"      : orderInfo.returnMoney,
                               @"itemList"          : itemList};
        
        if (progress) {
            progress();
        }
        
        [ESOrderAPI createNewReturnGoodsWithInfo:info withSuccess:^(NSDictionary *dict){
            if (dict && [dict  objectForKey:@"data"]) {
                NSString *returnGoodsId = [dict objectForKey:@"data"];
                if (success) {
                    success(returnGoodsId);
                }
                return;
            }
            if (failure) {
                failure(@"网络异常, 请稍后重试!", -1);
            }
        } andFailure:^(NSError *error) {
            if (failure) {
                failure(@"网络异常, 请稍后重试!", -1);
            }
        }];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        if (failure) {
            failure(@"网络异常, 请稍后重试!", -1);
        }
    }
}

+ (NSInteger)getItemsNumsWithSection:(NSInteger)section
                           withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    if (section == 0) {//商品
        return orderInfo.itemList.count;
    }else if (section == 1) {//输入项
        if (orderInfo.returnWay == ESReturnAmountTypeMoney)
        {
            return 5;
        }
        else if (orderInfo.returnWay == ESReturnAmountTypeGoodsAndMoney)
        {
            return 4;
        }
        return 3;
    }else {//联系商家
        return 1;
    }
}

+ (NSString *)getContactNumberWithOrder:(ESReturnApplyOrderInfo *)orderInfo {
    NSString *contact = nil;
    if (orderInfo.merchantMobile != nil && ![orderInfo.merchantMobile isEqualToString:@""]) {
        contact = orderInfo.merchantMobile;
    }
    return contact;
}

+ (BOOL)itemsIsSelectedAllWithOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        BOOL isSelectAll = YES;
        NSInteger flag = 0;
        for (ESReturnGoodsCommodity *commodity in orderInfo.itemList) {
            if (commodity.returnGoodsStatus == ESReturnCommodityStatusApplied
                || commodity.returnGoodsStatus == ESReturnCommodityStatusGift)
            {
                flag += 1;
            }

            if (commodity.isSelected == NO && commodity.returnGoodsStatus == ESReturnCommodityStatusUnApplied && isSelectAll == YES) {
                isSelectAll = NO;
            }
        }
        
        if (flag == orderInfo.itemList.count) {
            return NO;
        }else {
            return isSelectAll;
        }
    } @catch (NSException *exception) {
        SHLog(@"%@",exception.reason);
        return NO;
    }
}

+ (NSString *)getTotoalPriceWithOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        double total = 0.00;
        for (ESReturnGoodsCommodity *commodity in orderInfo.itemList) {
            if (commodity.isSelected == YES) {
                double amount = [commodity.payAmount doubleValue];
                NSInteger num = [commodity.editReturnItemNum integerValue];
                NSInteger totalNum = [commodity.itemQuantity integerValue];
                double returnAmount = amount * num / totalNum;
                total += round(returnAmount * 100) / 100;
            }
        }
        
        return [NSString stringWithFormat:@"¥ %.2f", total];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"¥ 0.00";
    }
}

+ (void)selectAllItems:(BOOL)selectAll withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        for (ESReturnGoodsCommodity *commodity in orderInfo.itemList) {
            if (commodity.returnGoodsStatus == ESReturnCommodityStatusUnApplied) {
                commodity.isSelected = selectAll;
            }
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
    }
}

+ (BOOL)itemIsSelectedWithIndex:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        ESReturnGoodsCommodity *commodity = [orderInfo.itemList objectAtIndex:index];
        return commodity.isSelected;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return NO;
    }
}

+ (NSString *)getItemImage:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        ESReturnGoodsCommodity *commodity = [orderInfo.itemList objectAtIndex:index];
        return commodity.itemImg;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (NSString *)getItemName:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        ESReturnGoodsCommodity *commodity = [orderInfo.itemList objectAtIndex:index];
        return commodity.itemName;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (NSString *)getItemSKUs:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        ESReturnGoodsCommodity *commodity = [orderInfo.itemList objectAtIndex:index];
        NSMutableArray *skuArr = [NSMutableArray array];
        for (ESStockKeepingUnit *sku in commodity.skuList) {
            NSString *skuStr = [NSString stringWithFormat:@"%@: %@", sku.name, sku.value];
            [skuArr addObject:skuStr];
        }
        
        if (skuArr.count > 0) {
            return [skuArr componentsJoinedByString:@"\n"];
        }
        return @"";
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (NSString *)getItemPrice:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        ESReturnGoodsCommodity *commodity = [orderInfo.itemList objectAtIndex:index];
        double price = [commodity.itemPrice doubleValue];
        return [NSString stringWithFormat:@"¥ %.2f", price];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (NSString *)getItemQuantity:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        if ([orderInfo.orderType isEqualToString:@"0"]) {
            return @"可定制";
        } else {
            ESReturnGoodsCommodity *commodity = [orderInfo.itemList objectAtIndex:index];
            NSInteger count = [commodity.itemQuantity integerValue];
            return [NSString stringWithFormat:@"x %ld", (long)count];
        }
        
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (void)selectItem:(BOOL)select withIndex:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        ESReturnGoodsCommodity *commodity = [orderInfo.itemList objectAtIndex:index];
        commodity.isSelected = select;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
    }
}

+ (BOOL)itemIsValidWithIndex:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        ESReturnGoodsCommodity *commodity = [orderInfo.itemList objectAtIndex:index];
        if (commodity.returnGoodsStatus == ESReturnCommodityStatusUnApplied) {
            return YES;
        }
        return NO;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return NO;
    }
}

+ (NSString *)getInputTitle:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo{
    NSString *title = @"";
    BOOL isReturnMoney = orderInfo.returnWay == ESReturnAmountTypeMoney;
    switch (index) {
        case 1:
            title = isReturnMoney?@"":@"退款原因";
            break;
        case 2:
            title = isReturnMoney?@"退款原因":@"退款联系人";
            break;
        case 3:
            title = isReturnMoney?@"退款联系人":@"联系电话";
            break;
        case 4:
            title = @"联系电话";
            break;
        default:
            break;
    }
    return title;
}

+ (NSString *)getInputContent:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    BOOL isReturnMoney = orderInfo.returnWay == ESReturnAmountTypeMoney;
    NSString *content = @"";
    switch (index) {
        case 1:
            content = isReturnMoney?@"":orderInfo.returnGoodsReason;
            break;
        case 2:
            content = isReturnMoney?orderInfo.returnGoodsReason:orderInfo.name;
            break;
        case 3:
            content = isReturnMoney?orderInfo.name:orderInfo.mobile;
            break;
        case 4:
            content = orderInfo.mobile;
            break;
        default:
            break;
    }
    return content;
}

+ (NSString *)getInputPlaceHolder:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo{
    NSString *placeHolder = @"";
    BOOL isReturnMoney = orderInfo.returnWay == ESReturnAmountTypeMoney;
    switch (index) {
        case 1:
            placeHolder = isReturnMoney?@"":@"请输入退款原因";
            break;
        case 2:
            placeHolder = isReturnMoney?@"请输入退款原因":@"请输入退款联系人";
            break;
        case 3:
            placeHolder = isReturnMoney?@"请输入退款联系人":@"请输入联系电话";
            break;
        case 4:
            placeHolder = @"请输入联系电话";
            break;
        default:
            break;
    }
    return placeHolder;
}

+ (void)setInputContent:(NSString *)content
              withIndex:(NSInteger)index
              withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    BOOL isReturnMoney = orderInfo.returnWay == ESReturnAmountTypeMoney;
    switch (index) {
        case 1:
            if (!isReturnMoney)
            {
                orderInfo.returnGoodsReason = content;
            }
            break;
        case 2:
            if (isReturnMoney)
            {
                orderInfo.returnGoodsReason = content;
            }
            else
            {
                orderInfo.name = content;
            }
            break;
        case 3:
            if (isReturnMoney)
            {
                orderInfo.name = content;
            }
            else
            {
                orderInfo.mobile = content;
            }
            break;
        case 4:
            orderInfo.mobile = content;
            break;
        default:
            break;
    }
}

+ (BOOL)hasSelectedItemWithOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        BOOL has = NO;
        for (ESReturnGoodsCommodity *commodity in orderInfo.itemList) {
            if (commodity.returnGoodsStatus == ESReturnCommodityStatusUnApplied) {
                has = YES;
            }
        }
        return has;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return NO;
    }
}

+ (NSString *)getReturnGoodsDescription {
    __block NSString *desc = @"实际退款金额以商家可退款金额为准，退款金额为用户实际支付金额；装修基金支付，未过期部分将返还至您的账户中。";
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [MGJRouter openURL:@"/App/GetAppConfig" completion:^(id result) {
        NSDictionary *dict = (NSDictionary *)[result copy];
        if (dict && [dict objectForKey:@"return_goods_description"]) {
            desc = [dict objectForKey:@"return_goods_description"];
        }
        dispatch_semaphore_signal(sem);
    }];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0f * NSEC_PER_SEC));
    dispatch_semaphore_wait(sem, popTime);

    return desc;
}

+ (NSString *)getItemOriginalPrice:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        ESReturnGoodsCommodity *commodity = [orderInfo.itemList objectAtIndex:index];
        double amount = [commodity.payAmount doubleValue];
        
        return [NSString stringWithFormat:@"¥ %.2f", amount];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"¥ 0.00";
    }
}

+ (BOOL)isInstalmentWithOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        return [orderInfo.orderStatus isEqualToString:@"15"];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return NO;
    }
}

+ (BOOL)itemCouldMinus:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        if ([self isInstalmentWithOrder:orderInfo]) {//是否为部分支付
            return NO;
        }else {
            ESReturnGoodsCommodity *commodity = [orderInfo.itemList objectAtIndex:index];
            NSInteger num = [commodity.editReturnItemNum integerValue];
            return num > 1;
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return NO;
    }
}

+ (BOOL)itemCouldPlus:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        @try {
            if ([self isInstalmentWithOrder:orderInfo]) {//是否为部分支付
                return NO;
            }else {
                ESReturnGoodsCommodity *commodity = [orderInfo.itemList objectAtIndex:index];
                NSInteger num = [commodity.editReturnItemNum integerValue];
                NSInteger couldReturn = [commodity.itemQuantity integerValue] - [commodity.returnedQuantity integerValue];
                if (couldReturn > 0 && num < couldReturn) {
                    return YES;
                }
                return NO;
            }
        } @catch (NSException *exception) {
            SHLog(@"%@", exception.description);
            return NO;
        }
    } @catch (NSException *exception) {
        
    }
}

+ (void)itemMinus:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        if ([self isInstalmentWithOrder:orderInfo]) {//是否为部分支付
            return;
        }else {
            ESReturnGoodsCommodity *commodity = [orderInfo.itemList objectAtIndex:index];
            NSInteger num = [commodity.editReturnItemNum integerValue];
            if (num <= 1) {
                return;
            }else {
                num -= 1;
                commodity.editReturnItemNum = [NSString stringWithFormat:@"%ld", (long)num];
            }
        }

    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
    }
}

+ (void)itemPlus:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        if ([self isInstalmentWithOrder:orderInfo]) {//是否为部分支付
            return;
        }else {
            ESReturnGoodsCommodity *commodity = [orderInfo.itemList objectAtIndex:index];
            NSInteger num = [commodity.editReturnItemNum integerValue];
            NSInteger couldReturn = [commodity.itemQuantity integerValue] - [commodity.returnedQuantity integerValue];
            if (num >= couldReturn) {
                return;
            }else {
                num += 1;
                commodity.editReturnItemNum = [NSString stringWithFormat:@"%ld", (long)num];
            }
        }
        
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
    }
}

+ (NSString *)getReturnApplyItemNum:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {

        ESReturnGoodsCommodity *commodity = [orderInfo.itemList objectAtIndex:index];
        NSInteger num = [commodity.editReturnItemNum integerValue];
        if (num <= 0) {
            return @"0";
        }else {
            return commodity.editReturnItemNum;
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
    }
}

+ (BOOL)getReturnApplyItemGiftStatusNum:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo {
    @try {
        ESReturnGoodsCommodity *commodity = [orderInfo.itemList objectAtIndex:index];
        return commodity.returnGoodsStatus == ESReturnCommodityStatusGift;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return NO;
    }
}

@end
