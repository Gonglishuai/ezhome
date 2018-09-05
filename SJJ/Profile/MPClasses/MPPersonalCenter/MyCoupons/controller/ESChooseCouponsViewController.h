//
//  ESChooseCouponsViewController.h
//  Mall
//
//  Created by jiang on 2017/9/8.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "MPBaseViewController.h"

@interface ESChooseCouponsViewController : MPBaseViewController
- (void)setSubOrderId:(NSString *)subOrderId orderId:(NSString *)orderId CouponInfo:(NSMutableDictionary*)couponInfo block:(void(^)(NSMutableDictionary *couponDic))block;
@end
