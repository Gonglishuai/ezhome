//
//  ESModifyPasswordTableCell.h
//  Homestyler
//
//  Created by shiyawei on 28/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ESModifyPasswordTableCell;

@protocol ESModifyPasswordTableCellDelegate <NSObject>
@optional
- (void)esModifyPasswordTableCell:(ESModifyPasswordTableCell *)cell textDidEndEditing:(NSString *)text;
@end

@interface ESModifyPasswordTableCell : UITableViewCell

@property (nonatomic,weak)    id<ESModifyPasswordTableCellDelegate>delegate;

@property (nonatomic,copy)    NSString *placehorder;
@property (nonatomic,strong)    UIView *lineView;
@end
