//
//  LoopCollectionViewCell.h
//  Consumer
//
//  Created by jiang on 2017/5/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDCycleScrollView.h"
typedef void (^LoopClickBlock)(NSInteger);

@interface LoopCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic)SDCycleScrollView *apView;
- (void)setDatasImgArray:(NSMutableArray *)imgArray loopBlock:(LoopClickBlock)loopBlock;
@end
