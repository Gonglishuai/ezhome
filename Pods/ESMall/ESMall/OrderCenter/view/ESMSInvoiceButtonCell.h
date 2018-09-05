//
//  ESMSInvoiceButtonCell.h
//  Consumer
//
//  Created by jiang on 2017/7/13.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ESMSInvoiceBtnType)//订单详情底部按钮type
{
    ESMSInvoiceBtnTypeDefault = 0,//无意义
    ESMSInvoiceBtnTypeNone,//不开具发票
    ESMSInvoiceBtnTypePaper,//纸质发票
    ESMSInvoiceBtnTypePersonal,//个人
    ESMSInvoiceBtnTypeCompany//单位
    
};

@interface ESMSInvoiceButtonCell : UITableViewCell
- (void)setLeftTitle:(NSString *)leftTitle leftType:(ESMSInvoiceBtnType)leftType rightTitle:(NSString *)rightTitle rightType:(ESMSInvoiceBtnType)rightType isSelectRight:(BOOL)isSelectRight block:(void(^)(ESMSInvoiceBtnType))block;
@end
