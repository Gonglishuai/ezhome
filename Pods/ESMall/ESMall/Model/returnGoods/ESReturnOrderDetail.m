//
//  ESReturnOrderDetail.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESReturnOrderDetail.h"
#import "CoStringManager.h"

@implementation ESReturnOrderDetail

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.orderId             = [CoStringManager judgeNSString:dict forKey:@"orderId"];
        self.brandName           = [CoStringManager judgeNSString:dict forKey:@"brandName"];
        self.returnAmount        = [CoStringManager judgeNSString:dict forKey:@"returnAmount"];
        self.realityReturnAmount = [CoStringManager judgeNSString:dict forKey:@"realityReturnAmount"];
        self.returnReason        = [CoStringManager judgeNSString:dict forKey:@"returnReason"];
        self.deductioAmount      = [CoStringManager judgeNSString:dict forKey:@"deductioAmount"];
        self.storeName           = [CoStringManager judgeNSString:dict forKey:@"storeName"];
        
        ESReturnType returnType = ESReturnTypeGoodsUnknow;
        if (dict && [dict objectForKey:@"refundType"]) {
            NSString *status = [NSString stringWithFormat:@"%@", [dict objectForKey:@"refundType"]];
            if ([status isEqualToString:@"1"]) {
                returnType = ESReturnTypeGoodsAndMoney;
            } else if ([status isEqualToString:@"2"]) {
                returnType = ESReturnTypeMoney;
            }
        }
        self.returnType = returnType;
        
        ESReturnGoodsType type = ESReturnGoodsTypeNone;
        if (dict && [dict objectForKey:@"processStatus"]) {
            NSString *statusStr = [NSString stringWithFormat:@"%@", [dict objectForKey:@"processStatus"]?[dict objectForKey:@"processStatus"]:@"0"];
            NSInteger status = [statusStr integerValue];
            switch (status) {
                case 10:
                    type = ESReturnGoodsTypeInProgress;
                    break;
                case 20:
                    type = ESReturnGoodsTypeCanceled;
                    break;
                case 30:
                    type = ESReturnGoodsTypeFinished;
                    break;
                case 40:
                    type = ESReturnGoodsTypeConfirmed;
                    break;
                case 50:
                    type = ESReturnGoodsTypeRefuse;
                    break;
                default:
                    type = ESReturnGoodsTypeRefuse;
                    break;
            }
            
        }
        self.processStatus = type;
        
        self.remark         = [CoStringManager judgeNSString:dict forKey:@"remark"];
        self.createTime     = [CoStringManager judgeNSString:dict forKey:@"createTime"];
        self.contactMobile  = [CoStringManager judgeNSString:dict forKey:@"contactMobile"];
        self.refuseReason   = [CoStringManager judgeNSString:dict forKey:@"refuseReason"];
        
        self.consumerName     = [CoStringManager judgeNSString:dict forKey:@"consumerName"];
        self.consumerAvatar  = [CoStringManager judgeNSString:dict forKey:@"consumerAvatar"];
        self.consumerMobile   = [CoStringManager judgeNSString:dict forKey:@"consumerMobile"];
        
        self.detailList = [NSMutableArray array];
        NSArray *list = [dict objectForKey:@"detailList"];
        if (dict && [list isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in list) {
                [self.detailList addObject:[ESReturnGoodsCommodity objFromDict:dic]];
            }
        }
    }
    return self;
}

+ (instancetype)objFromDict:(NSDictionary *)dict {
    return [[ESReturnOrderDetail alloc] initWithDict:dict];
}
@end

