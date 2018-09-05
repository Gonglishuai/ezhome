//
//  ESPayFinanceCollectionViewTableViewCell.h
//  ESMall
//
//  Created by jiang on 2017/12/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESPayBaseCell.h"

@protocol ESPayWayFinanceCellDelegate <ESPayBaseCellDelegate>

- (NSDictionary *)getFinanceData;

- (void)financeSelectedDidTapped:(NSIndexPath *)indexPath;

- (NSIndexPath *)getSelectIndexPath;
@end

@interface ESPayFinanceCollectionViewTableViewCell : ESPayBaseCell
@end
