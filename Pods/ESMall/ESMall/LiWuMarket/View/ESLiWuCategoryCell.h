//
//  ESLiWuCategoryCell.h
//  Mall
//
//  Created by 焦旭 on 2017/9/9.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESLiWuCategoryModel.h"

@protocol ESLiWuCategoryCellDelegate <NSObject>

- (ESLiWuCategoryModel *)getCategory:(NSInteger)index;

@end

@interface ESLiWuCategoryCell : UICollectionViewCell

@property (nonatomic, weak) id<ESLiWuCategoryCellDelegate> delegate;

- (void)updateCell:(NSInteger)index;
@end
