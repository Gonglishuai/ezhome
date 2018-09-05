//
//  ESInvoiceTypeHeaderFooterView.h
//  Consumer
//
//  Created by jiang on 2017/7/13.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESInvoiceTypeHeaderFooterView : UITableViewHeaderFooterView
- (void)setTitle:(NSString *)title selected:(BOOL)selected isHistory:(BOOL)isHistory block:(void(^)(NSString *))block;
@end
