//
//  ESOrderListButtonCell.h
//  Consumer
//
//  Created by jiang on 2017/7/4.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESOrderDetailTabbar.h"

@interface ESOrderListButtonCell : UITableViewCell
- (void)setInfo:(NSDictionary *)info block:(void(^)(ESOrderTabbarBtnType))block;
- (void)setReturnInfo:(NSDictionary *)info block:(void(^)(ESOrderTabbarBtnType))block;
@end
