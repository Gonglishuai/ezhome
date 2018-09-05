//
//  ESOrderProductCell.h
//  Consumer
//
//  Created by jiang on 2017/6/27.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESOrderProductCell : UITableViewCell
- (void)setProductInfo:(NSDictionary *)productInfo orderType:(NSString *)orderType isFromMakeSureController:(BOOL)isFromMakeSureController;
@end
