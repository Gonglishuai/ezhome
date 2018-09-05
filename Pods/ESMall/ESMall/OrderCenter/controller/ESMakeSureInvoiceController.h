//
//  ESMakeSureInvoiceController.h
//  Consumer
//
//  Created by jiang on 2017/7/13.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "MPBaseViewController.h"

@interface ESMakeSureInvoiceController : MPBaseViewController
- (void)setInvoiceBlock:(void(^)(NSMutableDictionary*))block;
- (void)setInvoiceDic:(NSMutableDictionary *)invoiceDic;
@end
