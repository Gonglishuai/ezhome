//
//  MPCaseScreenTableViewCell.h
//  MarketPlace
//
//  Created by xuezy on 16/2/23.
//  Copyright © 2016年 xuezy. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol caseScreenTableViewCellDelegate <NSObject>

@required



- (void)cellWithSelectedIndex:(NSInteger)selectIndex andCellSection:(NSInteger)cellSection;
- (void)selectType:(NSString *)buttonTitle type:(NSString *)type;

@end

@interface MPCaseScreenTableViewCell : UITableViewCell
@property (weak, nonatomic)id<caseScreenTableViewCellDelegate>delegate;
@property (nonatomic, assign) NSInteger cellSection;
-(void) updateCellForIndex:(NSArray *) array withTitle:(NSString *)title andSelectIndes:(NSInteger)selectIndex;
@end
