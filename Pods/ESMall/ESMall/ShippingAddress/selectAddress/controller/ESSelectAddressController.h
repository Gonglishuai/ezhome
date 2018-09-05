//
//  ESSelectAddressController.h
//  Consumer
//
//  Created by 焦旭 on 2017/6/27.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//
//  选择收货地址

#import "MPBaseViewController.h"

@class ESAddress;

@interface ESSelectAddressController : MPBaseViewController

/**
 *  选择地址 初始化
 *  @param addressId  地址ID
 *  @param address    选择地址后的回调block
 */
- (instancetype)initWithAddressID: (NSString *)addressId
              withSelectedAddress:(void(^)(ESAddress *selectedAddr))address;
@end
