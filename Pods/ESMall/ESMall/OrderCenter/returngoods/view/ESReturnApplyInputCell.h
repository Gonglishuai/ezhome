//
//  ESReturnApplyInputCell.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/14.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESReturnApplyInputCellDelegate <NSObject>

/**
 获取输入项标题

 @param index 索引
 @return 标题
 */
- (NSString *)getInputTitle:(NSInteger)index;

/**
 获取输入项内容

 @param index 索引
 @return 内容
 */
- (NSString *)getInputContent:(NSInteger)index;

/**
 获取输入项默认提示文字

 @param index 索引
 @return 提示文字
 */
- (NSString *)getInputPlaceHolder:(NSInteger)index;

/**
 完成了输入项

 @param content 内容
 @param index 索引
 */
- (void)setInputContent:(NSString *)content withIndex:(NSInteger)index;

@end

@interface ESReturnApplyInputCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, weak) id<ESReturnApplyInputCellDelegate> delegate;

- (void)updateApplyInputCell:(NSInteger)index;

- (void)focusTextField;
@end
