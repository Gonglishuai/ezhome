//
//  ESPersonalActiveCell.h
//  Mall
//
//  Created by jiang on 2017/9/6.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESPersonalActiveCellDelegate <NSObject>

- (NSString *)getCouponNumber;

- (NSString *)getGoldNumber;

- (void)isSelectCoupon:(BOOL)isSelectCoupon;

@end

@interface ESPersonalActiveCell : UITableViewCell

@property (nonatomic, weak) id<ESPersonalActiveCellDelegate> delegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;
@end
