//
//  ESPersonalCenterCell.h
//  Consumer
//
//  Created by 焦旭 on 2017/6/26.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESPersonalCenterCellDelegate <NSObject>

- (NSString *)getItemIconWithIndexPath:(NSIndexPath *)indexPath;

- (NSString *)getItemTitleWithIndexPath:(NSIndexPath *)indexPath;

- (NSString *)getMoneyNumber;
- (NSString *)getFinanceNumber;
- (NSString *)getFinanceStatus;
@end

@interface ESPersonalCenterCell : UITableViewCell

@property (nonatomic, weak) id<ESPersonalCenterCellDelegate> delegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

- (void)setBottomLine:(BOOL)visible;
@end
