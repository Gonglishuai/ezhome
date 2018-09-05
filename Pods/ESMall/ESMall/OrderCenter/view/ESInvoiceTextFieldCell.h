//
//  ESInvoiceTextFieldCell.h
//  Consumer
//
//  Created by jiang on 2017/7/13.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESInvoiceTextFieldCell : UITableViewCell
- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle placeholder:(NSString *)placeholder userEnabled:(BOOL)userEnabled block:(void(^)(NSString*))block dropListblock:(void(^)(void))dropListblock;
- (void)setFirstResponder;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@end
