//
//  ESInvoiceDropListView.h
//  Consumer
//
//  Created by jiang on 2017/7/14.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESInvoiceDropListView : UIView
+ (instancetype)creatWithFrame:(CGRect)frame datasSource:(NSArray *)datasSource Block:(void(^)(NSIndexPath *))block;
- (void)setWithFrame:(CGRect)frame datasSource:(NSArray *)datasSource Block:(void(^)(NSIndexPath *))block;
- (void)initTable;
@end
