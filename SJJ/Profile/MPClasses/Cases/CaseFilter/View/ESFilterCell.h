//
//  ESFilterCell.h
//  Consumer
//
//  Created by 焦旭 on 2017/11/6.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESFilterCellDelegate <NSObject>

/**
 获取筛选项的标题

 @param section 组索引
 @param index item索引
 @return 标题
 */
- (NSString *)getFilterItemText:(NSInteger)section andIndex:(NSInteger)index;

/**
 筛选项是否已选择

 @param section 组索引
 @param index item索引
 @return YES:已选择
 */
- (BOOL)filterItemIsSelected:(NSInteger)section andIndex:(NSInteger)index;

@end
@interface ESFilterCell : UICollectionViewCell

@property (nonatomic, weak) id<ESFilterCellDelegate> delegate;

- (void)updateCell:(NSInteger)section andIndex:(NSInteger)index;

@end
