//
//  ESLiWuLoopCell.h
//  Mall
//
//  Created by 焦旭 on 2017/9/10.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESLiWuLoopCellDelegate <NSObject>

/**
 获取所有的轮播图信息

 @return 图片数组
 */
- (NSArray <NSString *>*)getLoopImgUrls;

/**
 点击了某一张轮播图

 @param index 索引
 */
- (void)selectLoopCellAtIndex:(NSInteger)index;
@end

@interface ESLiWuLoopCell : UICollectionViewCell

@property (nonatomic, weak) id<ESLiWuLoopCellDelegate> delegate;

- (void)updateCell;
@end
