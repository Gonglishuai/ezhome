//
//  ESCouponCell.h
//  Mall
//
//  Created by jiang on 2017/9/7.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CouponStatus) {
    CouponStatusNone = 0,        //未知
    CouponStatusUnUse = 1,     //未使用
    CouponStatusUsed = 2,        //已使用
    CouponStatusOverdue  = 3,    //已过期
    CouponStatusAbleUse = 4,   //可用
    CouponStatusUnableUse = 5,   //不可用
    CouponStatusSelect = 6,      //选中
};

@interface ESCouponCell : UITableViewCell
- (void)setStatus:(CouponStatus)status info:(NSDictionary *)info block:(void(^)(void))block;
@end
