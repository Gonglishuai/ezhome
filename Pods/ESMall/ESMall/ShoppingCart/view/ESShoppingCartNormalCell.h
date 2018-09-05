//
//  ESShoppingCartNormalCell.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/3.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESShoppingCartViewModel.h"
#import "ESShoppingCartCellProtocol.h"

@interface ESShoppingCartNormalCell : UITableViewCell
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) id<ESShoppingCartCellDelegate> delegate;

- (void)updateNormalCellWithSection:(NSInteger)section
                           andIndex:(NSInteger)index;

- (void)deleteCellWithSection:(NSInteger)section
                     andIndex:(NSInteger)index;
@end
