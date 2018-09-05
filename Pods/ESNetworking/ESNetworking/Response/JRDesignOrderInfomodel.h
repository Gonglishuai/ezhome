//
//  JRDesignOrderInfomodel.h
//  Consumer
//
//  Created by jiang on 2017/5/5.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESBaseModel.h"
/*
 {
 "designerId": 20742276,
 "orderLineNo": 9,
 "orderNo": 9,
 "orderStatus": "10",
 "orderType": "2",
 "amount": "200",
 "remark": "定金200元",
 "pay_type" = "<null>";
 "originateTime": "2017-05-05 11:17:30",
 "paymentTime": null
 }
 */
@interface JRDesignOrderInfomodel : ESBaseModel

@property (nonatomic, copy) NSString *designerId;
@property (nonatomic, copy) NSString *orderLineNo;
@property (nonatomic, copy) NSString *orderNo;
@property (nonatomic, copy) NSString *orderStatus;
@property (nonatomic, copy) NSString *orderType;
@property (nonatomic, copy) NSString *amount;
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *originateTime;
@property (nonatomic, copy) NSString *paymentTime;
@property (nonatomic, copy) NSString *payType;
@property (nonatomic, copy) NSString *tradeNo;
@property (nonatomic, copy) NSString *payName;
@end
