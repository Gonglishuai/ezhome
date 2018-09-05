//
//  ESReturnGoodsDetailController.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/11.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//
//  退款详情

#import "MPBaseViewController.h"

@interface ESReturnGoodsDetailController : MPBaseViewController

- (instancetype)initWithOrderId:(NSString *)orderId Block:(void(^)(BOOL))block;
- (void)setIsFromRecommendCon:(BOOL)isFromRecommend;//是否来自我的推荐订单
@end
