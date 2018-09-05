//
//  ESShoppingCartInvalidHeaderView.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/5.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESShoppingCartInvalidHeaderViewDelegate <NSObject>

/**
 点击清空

 @param section 组索引
 */
- (void)clearItemsWithSection:(NSInteger)section;

@end

@interface ESShoppingCartInvalidHeaderView : UITableViewHeaderFooterView
@property (nonatomic, weak) id<ESShoppingCartInvalidHeaderViewDelegate> delegate;

- (void)updateHeaderView:(NSInteger)section;

- (void)setInvalidTitle:(NSString *)title;
@end
