//
//  ESAccountTableCell.h
//  Homestyler
//
//  Created by shiyawei on 25/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,KeyBoardType) {
    KeyboardTypeDefault,
    KeyboardTypeNumber
};

@class ESAccountTableCell;
@protocol ESAccountTableCellDelegate <NSObject>
- (void)esAccountTableCell:(ESAccountTableCell *)cell textShouldChange:(BOOL)enable;
- (void)esAccountTableCell:(ESAccountTableCell *)cell textDidEndEditing:(NSString *)text;
@end

@interface ESAccountTableCell : UITableViewCell
@property (nonatomic,weak)    id<ESAccountTableCellDelegate>delegate;

///键盘
@property (nonatomic,assign)    KeyBoardType keyBoardType;
@end
