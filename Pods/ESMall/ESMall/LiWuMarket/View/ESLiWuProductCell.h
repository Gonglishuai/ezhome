//
//  ESLiWuProductCell.h
//  Mall
//
//  Created by 焦旭 on 2017/9/9.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESCMSModel.h"

@protocol ESLiWuProductCellDelegate <NSObject>

- (ESCMSModel *)getProduct:(NSInteger)index;

@end

@interface ESLiWuProductCell : UICollectionViewCell

@property (nonatomic, weak) id<ESLiWuProductCellDelegate> delegate;

- (void)updateCell:(NSInteger)index;

@end
