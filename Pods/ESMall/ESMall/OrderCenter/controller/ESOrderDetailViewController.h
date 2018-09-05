//
//  ESOrderDetailViewController.h
//  Consumer
//
//  Created by jiang on 2017/6/27.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "MPBaseViewController.h"

@interface ESOrderDetailViewController : MPBaseViewController
- (void)setOrderId:(NSString *)orderId Block:(void(^)(BOOL))block;
- (void)setIsFromRecommendCon:(BOOL)isFromRecommend;//是否来自我的推荐订单
@end
