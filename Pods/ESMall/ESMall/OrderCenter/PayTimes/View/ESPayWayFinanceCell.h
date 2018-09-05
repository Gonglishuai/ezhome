//
//  ESPayWayFinanceCell.h
//  ESMall
//
//  Created by jiang on 2017/12/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESPayBaseCell.h"

@protocol ESPayWayCellDelegate <ESPayBaseCellDelegate>

- (NSDictionary *)getPayDataWithIndexPath:(NSIndexPath *)indexPath;

- (void)paySelectedDidTapped:(NSIndexPath *)indexPath
                       title:(NSString *)title;
- (NSString *)getFinanceStatusName;
@end

@interface ESPayWayFinanceCell : ESPayBaseCell

@end
