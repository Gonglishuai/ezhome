//
//  ESCouponListViewController.h
//  Mall
//
//  Created by jiang on 2017/9/7.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "MPBaseViewController.h"
#import "ESCouponCell.h"

@interface ESCouponListViewController : MPBaseViewController
- (void)setStatus:(CouponStatus)status isCanSelect:(BOOL)isCanSelect subOrderId:(NSString *)subOrderId orderId:(NSString *)orderId;
- (void)setBlock:(void(^)(NSMutableDictionary *couponDic))block;
@end
