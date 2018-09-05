//
//  ESReturnGoodsType.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#ifndef ESReturnGoodsType_h
#define ESReturnGoodsType_h


#endif /* ESReturnGoodsType_h */

typedef NS_ENUM(NSUInteger, ESReturnGoodsType) {
    ESReturnGoodsTypeNone,
    ESReturnGoodsTypeInProgress,    //订单进行中
    ESReturnGoodsTypeCanceled,      //订单取消
    ESReturnGoodsTypeFinished,      //订单完成
    ESReturnGoodsTypeConfirmed,     //用户确认收款
    ESReturnGoodsTypeRefuse,        //商家拒绝
};

typedef NS_ENUM(NSUInteger, ESReturnCommodityStatus) {
    ESReturnCommodityStatusNone,
    ESReturnCommodityStatusUnApplied, //未申请过退货
    ESReturnCommodityStatusApplied,   //申请过退货
    ESReturnCommodityStatusGift,   //赠品
};
