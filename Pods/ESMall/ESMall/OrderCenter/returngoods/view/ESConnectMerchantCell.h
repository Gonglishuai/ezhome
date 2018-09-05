//
//  ESConnectMerchantCell.h
//  Mall
//
//  Created by 焦旭 on 2017/9/15.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESConnectMerchantCellDelegate <NSObject>

- (NSString *)getMerchantNumberWithSection:(NSInteger)section andIndex:(NSInteger)index;

- (void)clickMerchantNumberWithSection:(NSInteger)section andIndex:(NSInteger)index;

@end

@interface ESConnectMerchantCell : UITableViewCell

@property (nonatomic, weak) id<ESConnectMerchantCellDelegate> delegate;

- (void)updateCellWithSection:(NSInteger)section andIndex:(NSInteger)index;
@end
