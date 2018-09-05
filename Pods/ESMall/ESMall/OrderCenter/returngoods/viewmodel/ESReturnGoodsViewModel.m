//
//  ESReturnGoodsViewModel.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESReturnGoodsViewModel.h"
#import "ESOrderAPI.h"
#import "ESReturnOrderDetail.h"

@implementation ESReturnGoodsViewModel

+ (void)retrieveReturnGoodsDetailWithId:(NSString *)returnGoodsId
                            withSuccess:(void(^)(ESReturnOrderDetail *order))success
                             andFailure:(void(^)(void))failure {
    [ESOrderAPI retrieveReturnGoodsDetailWithId:returnGoodsId withSuccess:^(NSDictionary *dict) {
        ESReturnOrderDetail *order = [ESReturnOrderDetail objFromDict:dict];
        if (success) {
            success(order);
        }
    } andFailure:^(NSError *error) {
        if (failure) {
            failure();
        }
    }];
}

+ (NSInteger)getCommodityNumsWithOrder:(ESReturnOrderDetail *)order {
    return order.detailList.count;
}

+ (ESReturnGoodsType)getOrderTypeWithOrder:(ESReturnOrderDetail *)order {
    return order.processStatus;
}

+ (NSString *)getContactNumberWithOrder:(ESReturnOrderDetail *)order {
    NSString *contact = @"暂无商家电话";
    if (order.contactMobile != nil && ![order.contactMobile isEqualToString:@""]) {
        contact = order.contactMobile;
    }
    return contact;
}

+ (NSString *)getBrandName:(ESReturnOrderDetail *)order {
    return order.brandName;
}

+ (NSString *)getOrderStatusBackImg:(ESReturnOrderDetail *)order {
    ESReturnGoodsType type = [ESReturnGoodsViewModel getOrderTypeWithOrder:order];
    NSString *image = @"";
    switch (type) {
        case ESReturnGoodsTypeInProgress:
            image = @"order_detail_drawbacking";
            break;
        case ESReturnGoodsTypeCanceled:
            image = @"order_detail_drawback_finish";
            break;
        case ESReturnGoodsTypeRefuse:
            image = @"order_detail_drawback_refuse";
            break;
        case ESReturnGoodsTypeFinished:
            image = @"order_detail_drawback_agree";
            break;
        case ESReturnGoodsTypeConfirmed:
            image = @"order_detail_drawback_finish";
            break;
        default:
            image = @"order_detail_drawback_finish";
            break;
    }
    return image;
}

+ (NSString *)getOrderStatusTitle:(ESReturnOrderDetail *)order {
    ESReturnGoodsType type = [ESReturnGoodsViewModel getOrderTypeWithOrder:order];
    NSString *title = @"";
    switch (type) {
        case ESReturnGoodsTypeInProgress:
            title = @"退款处理中";
            break;
        case ESReturnGoodsTypeRefuse:
            title = @"退款拒绝";
            break;
        case ESReturnGoodsTypeFinished:
            title = @"退款同意";
            break;
        case ESReturnGoodsTypeConfirmed:
            title = @"退款成功";
            break;
        case ESReturnGoodsTypeCanceled:
            title = @"退款关闭";
            break;
        default:
             title = @"退款拒绝";
            break;
    }
    return title;
}

+ (NSString *)getOrderRefuseReason:(ESReturnOrderDetail *)order {
    NSString *reason = [NSString stringWithFormat:@"退款拒绝原因：%@", order.refuseReason];
    return reason;
}

+ (NSString *)getReturnPriceTitle:(ESReturnOrderDetail *)order {
    ESReturnGoodsType type = [ESReturnGoodsViewModel getOrderTypeWithOrder:order];
    NSString *title = @"";
    switch (type) {
        case ESReturnGoodsTypeInProgress:
        case ESReturnGoodsTypeCanceled:
        case ESReturnGoodsTypeRefuse: {
            title = @"退款金额";
            break;
        
        }
        case ESReturnGoodsTypeFinished:
        case ESReturnGoodsTypeConfirmed: {
            title = @"实退金额:";
            break;
        }
        default:
            break;
    }
    return title;
}

+ (NSString *)getReturnPrice:(ESReturnOrderDetail *)order {
    ESReturnGoodsType type = [ESReturnGoodsViewModel getOrderTypeWithOrder:order];
    NSString *amount = @"";
    switch (type) {
        case ESReturnGoodsTypeInProgress:
        case ESReturnGoodsTypeCanceled:
        case ESReturnGoodsTypeRefuse: {
            double price = [order.returnAmount doubleValue];
            amount = [NSString stringWithFormat:@"¥ %.2f", price];
            break;
            
        }
        case ESReturnGoodsTypeFinished:
        case ESReturnGoodsTypeConfirmed: {
            double price = [order.realityReturnAmount doubleValue];
            amount = [NSString stringWithFormat:@"¥ %.2f", price];
            break;
        }
        default:
            break;
    }
    return amount;
}

+ (NSString *)getItemImage:(NSInteger)index
                 withOrder:(ESReturnOrderDetail *)order {
    @try {
        ESReturnGoodsCommodity *commodity = [order.detailList objectAtIndex:index - 1];
        return commodity.itemImg;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (NSString *)getItemName:(NSInteger)index
                withOrder:(ESReturnOrderDetail *)order {
    @try {
        ESReturnGoodsCommodity *commodity = [order.detailList objectAtIndex:index - 1];
        return commodity.itemName;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (NSString *)getItemPrice:(NSInteger)index
                 withOrder:(ESReturnOrderDetail *)order {
    @try {
        ESReturnGoodsCommodity *commodity = [order.detailList objectAtIndex:index - 1];
        double price = [commodity.itemPrice doubleValue];
        return [NSString stringWithFormat:@"¥ %.2f", price];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"¥ 0.00";
    }
}

+ (NSString *)getItemQuantity:(NSInteger)index
                    withOrder:(ESReturnOrderDetail *)order {
    @try {
        ESReturnGoodsCommodity *commodity = [order.detailList objectAtIndex:index - 1];
        return [NSString stringWithFormat:@"x %@", commodity.itemQuantity];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (NSString *)getItemSKU:(NSInteger)index
               withOrder:(ESReturnOrderDetail *)order {
    @try {
        ESReturnGoodsCommodity *commodity = [order.detailList objectAtIndex:index - 1];
        NSMutableArray *skus = [NSMutableArray array];
        for (ESStockKeepingUnit *sku in commodity.skuList) {
            [skus addObject:[NSString stringWithFormat:@"%@: %@", sku.name, sku.value]];
        }
        NSString *skusStr = [skus componentsJoinedByString:@"\n"];
        return skusStr;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"";
    }
}

+ (NSString *)getReturnAmount:(NSInteger)index
                    withOrder:(ESReturnOrderDetail *)order {
    @try {
        ESReturnGoodsCommodity *commodity = [order.detailList objectAtIndex:index - 1];
        double amount = [commodity.returnAmount doubleValue];
        return [NSString stringWithFormat:@"¥ %.2f", amount];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"¥ 0.00";
    }
}

+ (NSString *)getOrderNoWithOrder:(ESReturnOrderDetail *)order {
    return order.orderId;
}

+ (NSString *)getOrderCreateTimeWithOrder:(ESReturnOrderDetail *)order {
    return order.createTime;
}

+ (NSString *)getOrderReturnAmountWithOrder:(ESReturnOrderDetail *)order {
    @try {
        double amount = [order.returnAmount doubleValue];
        return [NSString stringWithFormat:@"¥ %.2f", amount];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"¥ 0.00";
    }
}

+ (NSString *)getOrderReturnReasonWithOrder:(ESReturnOrderDetail *)order {
    return order.returnReason;
}

+ (void)confirmReturnGoodsWithOrderId:(NSString *)orderId
                          withSuccess:(void(^)(void))success
                           andFailure:(void(^)(void))failure {
    [ESOrderAPI confirmReturnGoodsWithId:orderId withSuccess:success andFailure:^(NSError *error) {
        if (failure) {
            failure();
        }
    }];
}

+ (NSString *)getOrderServiceStoreWithOrder:(ESReturnOrderDetail *)order {
    @try {
        return order.storeName;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        return @"暂无服务门店";
    }
}
@end
